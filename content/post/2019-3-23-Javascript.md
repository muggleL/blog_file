---
title: JavaScript 基础
date: '2019-03-23'
slug: js-foundation
author: DG
tags: 
  - 编程
  - 代码
categories: 
  - JavaScript
---
JavaScript 是一门坑比较多的语言。这里记录了一些基本数据类型里面不容易注意到的点，比如：字符串的表示方式、基本数据类型的比较等等。
<!--more-->

## JavaScript 编程风格

![code-style@2x.png](https://i.loli.net/2019/03/23/5c959a00eb972.png)

## JavaScript 基本数据类型

JavaScript 有六种数据类型 分别是 number, string,  boolean, null, undefined

### 字符串的表示方式

1. 单引号：
```javascript
let a = 'this is a string';
```

2. 双引号
```javascript
let b = "this is a string";
```

3. 反引号
```javascript
let c = `this num is ${1 + 2}`; //this num is 3
```

用反引号表示字符串时，允许通过 ${...} 嵌入表达式，表达式的结果将成为字符串的一部份。

### 数据的一般比较 （==, >, <, !=, >=, <=）

数据进行双等号比较时，遵循以下三种规则

1. 当两边数据类型相等时， 按照通用规则进行比较

2. 当两边数据类型不等且不涉及 `null` 与 `undefined` 时，**先转换成 `Number` 类型，再进行比较。** 

```javascript
'0' == 0; //true
'a' == 0; //false
true == 1; //true
false == 0; //true
```

```javascript
let a = 0;
Boolean(a); //false

let b = '0';
Boolean(b); //true

a == b; //true
```

3. 当涉及到 `null` 和 `undefined` 时:

- 进行`==`比较时，不会发生类型转换，默认两者相等。

```javascript
null == undefined; //true
```

- 当进行 `>`, `<`, `>=`, `<=`, `!=` 比较时，**`null` 会被转换成 `0`, `undefined` 会被转换成 `NaN`**

```javascript
null > 0 //false
null >= 0  //true
null == 0 //false
```

```javascript
undefined > 0; //false
undefined < 0; //false
undefined == 0; //false
```

**JavaScript 中 `===`不会进行任何字符转换，因此这是推荐的使用方式**

### `+` 的用法

JavaScript 中 `+` 号可以用来将数据类型转换成整型

```javascript
+'02' //2
+'20f' //NaN
+'2'/0 //Infinity
```

### alert， confirm， prompt

- `alert` 弹出对话框
- `confirm` 弹出选择框（true or false）
- `prompt` 弹出输入框


## JavaScript 函数

### 函数声明

```javascript
function sum(a, b) {
  return a + b;
  }
```

### 函数表达式
```javascript
let sum = function (a, b) {
  return a + b;
}
```

函数表达式的函数也可以有名字， 不过该名称只在函数内可见

```javascript
let fact = function fact_iter(n) {
  if(n==0){
    return 1;
  } else {
    return n* fact_iter(n-1);
  }
};
```

### 箭头函数

```javascript
let sum = (a, b) => a + b;
let sum = (a, b) => {
  return a + b;
};
let sumOf1And2 = () => 1 + 2;
let abs = a => (a > 0)? a: -a;
```

**函数声明式函数在初始化时创建，函数表达式和箭头函数在脚本执行到该行时创建。所以函数声明式函数可以先调用，在写函数体**

```javascript
sum(1, 3); //这么写没问题
sum(a, b) {
  return a + b;
}
```

```javascript
sum(1, 3); //这里会出错 sum is not defined
let sum = function (a, b) {
  return a + b;
}
```

-------------------
> 参考:
> 1. [The Modern Javascript Tutorial](http://javascript.info/)
> 2. [现代 Javascript 教程](http://zh.javascript.info/)