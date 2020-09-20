---
title: Linux 定时任务一定要用绝对路径
date: '2019-05-27'
author: DG
slug: Linux定时任务一定要用绝对路径
tags: 
  - 日常
categories: 
  - Linux
---

### 重要的事情说三遍

Linux 用 `crontab` 定时任务一定要用绝对路径。

Linux 用 `crontab` 定时任务一定要用绝对路径。

Linux 用 `crontab` 定时任务一定要用绝对路径。

> 　`crontab` 执行命令时，默认用户是 `root`，默认文件夹是 `/root`。脚本一定要用绝对路径，默认`~` 路径是 `/root`。这个问题坑了我一个礼拜。

---------------

<small><font color="red">2019-8-10 更新</font></small>

> `crontab -u user` 如果不指定 `user` , 则默认为当前用户。上文中我使用了 `sudo` 启动才会出现默认用户是 `root` 的情况。