---
title: Rust Trait
date: '2020-09-13'
author: DG
slug: rust-trait
tags: 
  - 编程
  - 代码
categories: 
  - Rust

---

trait是对类型的行为约束，主要有如下4种用法：
- 接口抽象。
- 泛型约束。
- 抽象类型。
- 标签 trait。

## 接口抽象
Rust 的接口有如下特点：
- 可以自定义方法，支持默认实现。
- 接口之间可继承不可实现（不可以用一个接口实现另一个接口）。
- 同一个接口可以被多个类型实现，但不能被一个类型多次实现。
- impl 关键字为类型实现接口的方法。
- trait 关键字定义接口。

实例1: 为自定义类型实现加法接口
```rust
use std::ops::Add;

#[derive(Debug)]
struct Point {
    x: i32,
    y: i32,
}

impl Add for Point {
    type Output = Point;
    fn add(self, other: Point) -> Self {
        Point {
            x: self.x + other.x,
            y: self.y + other.y,
        }
    }
}

pub fn test() {
    let point = Point{x: 1, y: 3};
    let other = Point{x: 3, y: 2};
    let result = point + other;
    println!("{:?}.", result);
}
```
> Output 指定返回值类型
> 函数种 返回值可以写成 Self、Point 或 Self::Point

### trait 接口继承
子 trait 可以继承父 trait 中定义或者实现的方法。
以下是一个分页为例的 trait 继承实例：
```rust
trait Page {
    fn set_page(&self, p: i32) {
        println!("Page Defualt: {}.", p);
    }
}

trait Perpage {
    fn set_prepage(&self, num: i32) {
        println!("Per Page Defualt: {}", num);
    }
}

struct MyPaginate{
    page: i32,
}
impl Page for MyPaginate {}
impl Perpage for MyPaginate{}

trait Paginate: Page + Perpage {
    fn set_skip_page(&self, num: i32) {
        println!("Skip Page: {:?}.", num);
    }
}

impl <T: Page + Perpage> Paginate for T {} // 为所有实现了 Page 、 Perpage 的类型实现 Paginate



pub fn test() {
    let my_paginate = MyPaginate{page: 1};
    my_paginate.set_page(1);
    my_paginate.set_prepage(100);
    my_paginate.set_skip_page(12);
}
```

> 为什么不可以直接只实现 Paginate ？？如果真的是继承的话，Paginate里面应该包含了 Page 和 Prepage 的行为。如果像上个例子中的代码，Paginate 直接是一个独立的 trait 不继承 Page 与 Prepage 代码功能也不会有任何变化。可能作者使用的这个例子有问题，这个例子对理解Rust 继承毫无帮助。

## 泛型约束
有一些泛型函数在需要有一定的约束才能运行或者是有意义，比如一个泛型的求和函数，如果传入两个数字，则可以计算加法。如果传入两个字符串，也是可以勉强理解成将两个字符串拼接。但是如果传入两个布尔类型，则就毫无意义了。因此可以使用 trait 对泛型适用的类型进行约束。
求和泛型约束实例如下：
```rust

use std::ops::Add;

fn sum<T: Add<T, Output=T>>(a: T, b: T) -> T { // 只有实现了 add 加号两边类型返回值类型一致的类型适用
    a + b
}

pub fn test() {
    let result = sum(1, 100);
    //let r2 = sum("aa", "bb"); // &str 没有实现加法 所以报错
    let r3 = sum(1.0, 2.0);
    println!("result1: {}, r2: {{}}, r3: {}.", result, /*r2, */ r3);
}
```

## 抽象类型
### TraitObject
TraitObject 是将具有相同行为的具体类型的集合抽象成一个不可实例化的类型，等价于面对对象语言中的抽象类型（Abstract Object）。
trait 对象实例：
```rust
#[derive(Debug)]
struct Foo;

trait Bar {
    fn baz(&self);
}
impl Bar for Foo {
    fn baz(&self) {
        println!("{:?}.", self);
    }
}

fn static_dispatch<T>(t: &T) where T: Bar { // 这里是 trait 泛型限定
    t.baz();
}

fn dynamic_dispatch(t: &dyn Bar) { // Bar 被当成了一个类型。
    t.baz();
}

pub fn test() {
    let foo = Foo;
    static_dispatch(&foo);
    dynamic_dispatch(&foo);
    
}
```

### Impl Trait

实例：
```rust
use std::fmt::Debug;

pub trait Fly {
    fn fly(&self) -> bool;
}

#[derive(Debug)]
struct Duck;

#[derive(Debug)]
struct Pig;

impl Fly for Duck {
    fn fly(&self) -> bool {
        true
    }
}

impl Fly for Pig {
    fn fly(&self) -> bool {
        false
    }
}

fn fly_static(s: impl Fly + Debug) -> bool { // impl 作为参数类型
    s.fly()
}

fn can_fly(s: impl Fly + Debug) -> impl Fly { // impl trait 作为返回值类型
    if s.fly() {
        println!("{:?} can fly.", s);
    } else {
        println!("{:?} can't fly.", s);
    }
    s
}

pub fn test() {
    let pig = Pig;
    let duck = Duck;

    println!("{}.", fly_static(pig));
    println!("{}.", fly_static(Duck));

    let pig = Pig;
    let duck = duck;
    let _ = can_fly(pig);
    let _ = can_fly(duck);
}
```

> 未完待续...