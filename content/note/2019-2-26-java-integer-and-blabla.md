---
title: 由反射引起的 Java 常量名与变量名的思考
date: '2019-02-26'
author: DG
slug: java-reflect
tags: 
  - 编程
  - 代码
categories: 
  - Java

---

## 0x00

<p style="text-indent:2em">前几天，一个同学问我关于反射的问题。我对 Java 反射了解并不多，照着他给的例子做实验的时候发现了一个让我摸不着头脑的问题。代码如下：</p>

```java
public class demo {
    public static void change(Integer a, Integer b) throws NoSuchFieldException, IllegalAccessException {
        Field field = Integer.class.getDeclaredField("value");
        field.setAccessible(true);
        field.set(b, 10);
        field.set(a, 1);
    }

    public static void main(String[] args) throws NoSuchFieldException, IllegalAccessException {
        Integer a = 10, b = 1;
        change(a, b);
        System.out.println("a = " + a + " b = " + b);
    }
}
```

<p style="text-indent:2em">这本来就是很平常的改变两个变量的值，但是结果如下</p>

![](http://ww1.sinaimg.cn/large/0067x4Magy1g0k6wshlxbj30gb02p3yj.jpg)

<p style="text-indent:2em">WTF?? b 是 10 没错 a 怎么变成 10 了。</p>

## 0x01

<p style="text-indent:2em">经过一番搜索，原来是 Java 在的 Integer 类型在 -127-128 之间会生产缓存（ python 也有类似特性）。也就是说，<font color=chocolate>假如已经创建了一个值在 -127-128之间的 Integer 变量。虚拟机会在缓存区生成该变量的缓存。当下一次使用到该变量时，并不会重新分配存储空间，而是直接从缓存中提取已有的地址。当然，用 new 强制分配存储空间除外。</font></p>

请看：

```java
public class demo {
    private static void change(Integer a , Integer b) throws NoSuchFieldException, IllegalAccessException {
        Field field = Integer.class.getDeclaredField("value");
        field.setAccessible(true);
        field.set(b, 10);
        System.out.println("修改后 b 的 identityHashCode 为");
        System.out.println(System.identityHashCode(b));
        System.out.println("b 的值为: " + b);
        System.out.println("常量 1 的 identityHashCode 为");
        System.out.println(System.identityHashCode(1));
        field.set(a, 1);
    }

    public static void main(String[] args) throws NoSuchFieldException, IllegalAccessException {
        Integer a = 10, b = 1;
        System.out.println("刚开始 b 的 identityHashCode 为");
        System.out.println(System.identityHashCode(b));
        System.out.println("b 的值为：" + b);
        change(a, b);
        System.out.println("a = " + a + " b = " + b);
    }
}

```

结果：

![](http://ww1.sinaimg.cn/large/0067x4Magy1g0k7lbymw6j30ip09ymxv.jpg)

<p style="text-indent:2em">`b` 被修改为 `10` 之后，常量 `1` 仍然指向这块内存！所以会出现上述结果显而易见了：</p>

<p style="text-indent:2em"><font color=chocolate>在 b 被修改之后 Java 虚拟机任然固执地把 1 指向的储存里面的内容复制给了变量 a， 却不管 实际上 这个 1 是表里不一 的 1，是一个披着 1 的皮的 10。</font></p>

## 0x02

<p style="text-indent:2em">我们再扩展一下， 假如拿这个‘假的’ 1 去做运算 `1 + 1` 结果会是 `11` 还是 `2`呢？我想，结果是显然的，Java 设计者肯定不可能容忍 `1 + 1 = 11` 这么可怕的结果存在：</p>

```java
public class demo3 {
    public static void change(Integer a, Integer b) throws NoSuchFieldException, IllegalAccessException {
        Field field = Integer.class.getDeclaredField("value");
        field.setAccessible(true);
        field.set(b, 10);
        field.set(a, 1);
        System.out.println("1 + 1 = " + (1 + 1));
    }

    public static void main(String[] args) throws NoSuchFieldException, IllegalAccessException {
        Integer a = 10, b = 1;
        change(a, b);
        System.out.println("a = " + a + " b = " + b);
    }
}

```

![](http://ww1.sinaimg.cn/large/0067x4Magy1g0k82d8y6pj30ff02z0sr.jpg)

## 0x03

<p style="text-indent:2em">由此可见， 在运算中使用 Java 常量时，是之间取其字面意思，并不会去存储中取值，或者对二者进行比对（想想也确实没有必要，而且还浪费时间）。但在遇到反射这种比较底层的操作时， Integer 并没有特殊待遇。而是像处理其它对象一样找到地址，复制到内容新的地址。至于与 Integer 缓存机制的冲突，不知道是设计者的疏忽，还是设计者在为 Integer 缓存的存在刷存在感（瞧， 我还有这么厉害的东西，没想到吧 (: )。</p>



----------------------------

2019年2月26日晚
