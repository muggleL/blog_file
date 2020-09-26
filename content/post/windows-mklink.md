---
title: 🖥️windows 创建软/硬链接
date: '2019-05-27'
author: DG
slug: windows-mklink
tags: 
  - 折腾
categories: 
  - Windows
---

　　Linux 可以通过 `ln` 来创建硬链接和软链接，Windows 也可以右键创建快捷方式。但是 Windows 的 `shortcut` 只能通过鼠标点击访问，和软/硬链接差别还是挺大的。在这我记录一下 Windows 创建软/硬链接的方式。

## fsutil 硬链接

![批注 2019-05-27 194506.png](https://i.loli.net/2019/05/27/5cebcde3d985f29272.png)



这个只适用于 `NTFS` 文件系统

```powershell
fsutil hardlink create NewFileName ExistingFileName
```




## MKLINK

![批注 2019-05-27 191018.png](https://i.loli.net/2019/05/27/5cebcd0467e6222620.png)

**这是 cmd 自带命令， 一定要切换到 cmd 下**

### 为目录创建软链接

```powershell
MKLINK /D NewFolder ExistingFolder
```

### 文件硬链接

```powershell
MKLINK /H NewFile ExistingFile
```

> 硬链接只针对文件，不针对文件夹