---
title: JavaScript 对象
date: '2019-03-24'
author: DG
slug: js-object
tags: 
  - 编程
  - 代码
categories: 
  - JavaScript
---
本文记录了 JavaScript 面对对象的一些基础方法，如对象的属性，对象的遍历，对象的复制与合并等。
## 多词属性

  可以用多字词语来作为属性名

```javascript
let person = {
name: 'John',
age: 20,
'likes birds': true //必须加引号
};
```

多词属性不适用于点操作，但可以用方括号

```javascript
person.likes birds; //错误
person['likes birds']; //true

let key = 'likes birds';
person[key] //true
```


## delete 删除属性

delete + 属性 可以删除属性

```javascript
delete person.age //age 被删除
delete person['like birds'] //删除多词属性
```

## 计算属性

在方括号中的属性

```javascript
let fruit = prompt("whitch fruit to buy?");

let bag = {
  [fruit]: 5,
};
//假如输入 apple
bag.apple //值为 5
```

它的本质其实是：

```javascript
let fruit = prompt("whitch fruit to buy?");
let bag = {};

bag[fruit] = 5;
```

方括号里面可以写一些复杂的表达式

```javascript
let fruit = "apple";

let bag = {
  [fruit + "Computer"]: 5,
};

bag.appleComputer //5
```

## 属性值简写

当属性名与变量名一致时，属性名可以简写。

```javascript
function makeUser(name, age) {
  name,  //与 name: name 相同
  age    // 与 age: age  相同
}
```

也可以混用

```javascript
function make30YearsOldUser(name) {
  name,
  age: 30
}
```

## `for...in` 遍历对象

```javascript
let user = {
  name: "zhangsan",
  age: 23,
  isAdmin: false
};

for (let key in user) {
  console.log(key); // name, age, isAdmin
  console.log(user[key]); //zhangsan, 23, false
}
```

**对象里面的 <font color="chocolate">整数属性</font><sup>1</sup> 会按照整数顺序排列，其他属性按照创建顺序排列.**

```javascript
let code = {
  "49": "Germany",
  "41": "Switzerland",
  "44": "Great Britain"
};
```

>1. **整数属性**是指一个字符串，里面包含一个纯整数。如 `"43"` `'51'` 是整数属性，`"+32"` `"1.3"` 就不是整数属性。所以有时我们不需要自动排序时，只要把整数属性转换成非整数属性就行。

## 常量对象

在对象面前加 `const` 使该变量只能指向当前对象。

## Object.assign 对象复制与合并

```javascript
Object.assign(dest[, src1, src2, src3...])
```
- 参数 `dest` 和 `src1, src2, src3.....` 是对象。
- 这个方法把 `src1, src2, src3.....` 的属性复制到 `dest`, 然后再返回 `dest`。
- 如果复制过程中碰到了相同的属性，后面的会覆盖前面的属性。

因此，可以很方便地用它来复制和合并对象。
```javascript
let user = {
  name: "zhangsan",
  age 23
};

let clone = Object.assign({}, user);
```
> <font color='red'>注</font>: assign 只能进行浅层拷贝。如果属性里面包含一个对象，所有的拷贝结果将会共享该对象。也就是说只要一旦某个拷贝结果（或原值）修改了该对象的，所有的拷贝结果都会受到影响。目前，为了解决这种方法，用的比较多的是 JS 实现库 [lodash](https://lodash.com/) 的 [_.cloneDeep(obj)](https://lodash.com/docs#cloneDeep) 方法。

-------------------
> 参考:
> 1. [Objects](http://javascript.info/object)
> 2. [对象](http://zh.javascript.info/object)
