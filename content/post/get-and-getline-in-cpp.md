---
title: ✏️c++中的get与getline
author: DG
tags:
  - 代码
  - 编程
categories:
  - C++
slug: cpp-get-getline
date: '2018-01-30'
---

## c++ 中的cin

c++中的`cin`以空白符（空格 回车 制表）作为分隔符，以回车作为输入结束符。在平时使用中除了输入数字，否则很难避免输入的内容包含空格等特殊字符的情况。
```cpp
    char name1[20];
    char name2[20];
    cin>>name1>>name2;
    cout<<name1<<endl<<name2<<endl;
```

如果输入`barack obama`，再按回车。程序直接输出
```bash
    barack
    obama
```

在此次输入中，把`barack`赋值给了`name1`，把`obama`赋值给了`name2`；（此时最后输入的回车符任保存在缓存中）。

## cin.getline

好在c++给了一个解决这个问题的方法。在`cin`的成员函数中，有一个以回车为分隔符的函数`getline()`。

`getline()`因为是`cin`的成员函数。所以使用方法为`cin.getline()`。他有（一般）两个参数，第一个为接收这行字符串的数组的名称，第二个为读取的字符数。

`getline()`读取某行字符时，会接收最后的回车符，然后把回车符丢弃换成空字符串`'\0'`，所以如果`getline`的第二个参数为20，他最多能接收19个字符。
```cpp
    char name1[20];
    char name2[20];
    cin.getline(name1,20);
    cin.getline(name2,20);
```

## cin.get

与此同时，c++也给出了`get()`，与`getline()`不同的是，`get`不会接收最后的回车符（参数与`getline`一样）。

```cpp
    char name1[20];
    char name2[20];
    cin.get(name1,20);
    cin.get(name2,20);
    cout<<name1<<name2;
```

输入`barack obama`，回车。输出的将是：

```cpp
barack obama
```

因为第一个`get`函数完成后，`'\n'`被留在了缓存中，当执行第二个`get`时，程序从缓存中读到了一个`\n`，所以第二个`get`没有接收到任何参数就结束了。

为了解决这个问题，`get`还有一个不带参数的形式，这时只能接收一个字符，所以可以通过下面这种方式，把最后的回车用`get`丢弃。
```cpp
    char name1[20];
    char name2[20];
    cin.get(name1,20).get();
    cin.get(name2,20).get();
```
如果你想保存那个字符，你可以 `char a = cin.get();`。或者使用`get`的第三种形式`char a; cin.get(a);`。

在第一节中说到。`cin`以回车为输入结束，输入结束后，回车依然留在缓存中。如果你在`cin`后面紧接着来一个`cin.get(string&amp;,int)`，你的`get`可能接收不到任何参数。

所以像上面一样，在`cin`完之后，应该用一个不带参数的`get`把回车接收并丢弃掉。

```cpp
    char name1[20],name2[20],a[20];
    cin>>a;   //or (cin>>a).get();从而不要下面那句。
    cin.get() //or char ch; cin.get(ch);
```

上面之所以能够`cin.get(string&amp;,int).get()`或`(cin&gt;&gt;a).get()`，是因为`cin`在有参数的情况下，返回的是一个`cin`对象（`cin.get()`在没有参数的情况下，返回的是接收的字符）。

## get与getline

如此看来，貌似`getline`使用起来比`get`更加方便，那么`get`存在的意义是什么？

在`getline`中，当输入的字符超过限制时，`getline`会读取她所需要的字符，并阻断接下来的输入。

```cpp
    char name1[5];
    char name2[5];
    cin.getline(name1,5).getline(name2,5);
    cout<<"name1: "<<name<<"\tname2: "<<name2;
```

输入`obama\n`，输出的是：

```cpp
name1: obam
```

`get`不会阻断输入，他只会接收自己需要的字符，其余的将留在缓存中：

```cpp
    char name1[5];
    char name2[5];
    cin.get(name1,5).get(name2,5);
    cout<<"name1: "<<name1<<"\tname2: "<<name2;
```

输入`obama\n`,输出：

```cpp
    char1: obam     char2: a
```

所以当我们不知道该输入是因为`\n`而结束，还是因为字符超出而结束时，只要使用`get`，然后用一个`char ch;cin.get(ch)`或者`char ch = cin.get()`接收缓存中的第一个字符，如果是回车符，说明正常结束，如果是一个字符，说明输入超过字符限制。


## string与cin.get

因为引入string类型之前，`cin`就有了`get`与`getline`方法。所以`cin.get`与`cin.getline`并不能处理`string`类。

所以处理string类的`getline`方法为：`getline(cin,str)`,`cin`作为参数传入函数`string`为可扩展类型，所以不需要后面的边界参数，
```cpp
    string name;
    getline(cin,name);
```
**没有对应string的get方法**