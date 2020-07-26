---
title: Wsl2 Ubuntu20.04 配置 docker
tags: 
categories:
  -  wsl
date: '2020-06-13'
slug: wsl2-ubuntu20.04-install-docker
---

# 1. 配置docker 源
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
# 2. 安装
```bash
sudo apt update
sudo apt install docker-ce
```
# 3. 配置
- 启动
```bash
sudo service docker start
```
- 用户配置
```bash
sudo usermod -aG docker ${USER}
```
