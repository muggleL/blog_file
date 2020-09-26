---
title: 🍓树莓派 mongodb-for-docker 配置
date: '2019-09-07'
author: DG
slug: mongodb-docker-for-respi
tags: 
  - 日常
  - 折腾
categories: 
  - Docker
---
## 数据库基础配置
### 启动
```bash
docker run -d --name rmongo --restart unless-stopped -v /data/db:/data/db -v /data/configdb:/data/congifdb -v /mnt/samba/mongoBank:/bank -p 27017:27017 -p 28017:28017 mongo mongod --auth
```
### 创建数据库管理员
```bash
docker exec -it rmongo mongo admin
db.createUser({user: "admin", pwd: "password", roles: [{role: "userAdminAnyDatabase", db: "admin"}]})
```
### 创建数据库与数据库用户
```bash
use images
db.createUser({ user: "image", pwd: "yourpassword", roles: [{ role: "dbOwner", db: "images" }] })
```
### 重启容器 验证用户
- 验证 admin
```bash
db.auth("admin", "password")
```
- 验证 image
```bash
use images
db.auth("image", "password")
```
## 数据库备份与恢复
- 备份
```bash
docker exec rmongo mongodump --username image --password 12134 --authenticationDatabase images -d images -h localhost -o /bank
```
- 恢复
```bash
docker exec rmongo mongorestore --username image --password 12134 --authenticationDatabase images /bank 
```
