---
title: windows 终端的傻逼逻辑
date: '2019-05-22'
author: DG
slug: shabi-win10
tags: 
  - 日常
categories: 
  - Windows
---

　　windows 的终端程序有一个逻辑我始终搞不懂。那就是假如你不小心用鼠标点到了他的界面，在终端运行中的程序就会停下来。而你必须点一下键盘它才会继续。。。

[![test.gif](https://i.loli.net/2019/05/22/5ce51dce85bd310778.gif)](https://i.loli.net/2019/05/22/5ce51dce85bd310778.gif)

　　我觉得大部分人 点击界面并不是想要暂停。也许是误操作，更多的情况应该是和我一样只是为了认真读一读输出的调试信息。读完之后，整个程序就暂停了。好多次我以为是程序bug。我觉得 Linux 下的大部分终端才是正常的逻辑，点击并不会触发什么行为； 选中之后暂停滚动，但是程序还在向下执行；ctrl + s 之后，程序暂停。不知道微软新的 [windows termainl](https://devblogs.microsoft.com/commandline/introducing-windows-terminal/) 怎么样， 否则我就真的滚回 [Manjaro](<https://manjaro.org/>) 去了。