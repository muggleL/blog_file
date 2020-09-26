---
title: 🐜Wsl2 Ubuntu20.04 配置 docker
tags: 
categories:
  -  wsl
date: '2020-06-13'
slug: wsl2-ubuntu20.04-install-docker
---

# 1. win10 2004 开启 wsl2
- ### 开启虚拟化平台组件

```bash
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
```

- ### 开启 Linux 子系统组件

```bash
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
```

- ### 下载 wsl2 独立内核并安装

```bash
https://docs.microsoft.com/zh-cn/windows/wsl/wsl2-kernel
```

- ### 设置 wsl2 为默认 wsl

```bash
wsl --set-default-version 2
```

- ### [从 Microsoft Store 下载 Linux 系统](https://www.microsoft.com/zh-cn/p/ubuntu-2004-lts/9n6svws3rx71?activetab=pivot:overviewtab)



# 2. 配置docker 源
```bash
sudo apt update
```
```bash
sudo apt install apt-transport-https ca-certificates curl software-properties-common
```
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```
```bash
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
```
# 3. 安装
```bash
sudo apt update
sudo apt install docker-ce
```
# 4. 配置
- ### 启动
```bash
sudo service docker start
```
- ### 用户配置
```bash
sudo usermod -aG docker ${USER}
```


> 更多 Docker 的使用方法可参考往期文章：[Manjaro Docker 用法](http://blog.mygoooosh.com/note/2019/08/23/tutorial-of-manjaro-docker/#%E8%AE%BE%E7%BD%AE%E9%95%9C%E5%83%8F%E4%BB%93%E5%BA%93)