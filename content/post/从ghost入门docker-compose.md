---
title: 从 Ghost 入门 docker-compose
date: '2020-8-1'
tags: docker-compose
categories: docker
slug: the-docker-compose-beginner
---

如果按照平常的方法通过 docker 启动 ghost，需要运行如下一串超长的命令：

```bash
docker run -d --name myghost -p 80:2368 -v /var/ghost/blog:/var/lib/ghost/content ghost
```

这种方法比较复杂，可配置空间小。

> ### 关于 docker-compose
>
> docker-compose 是 docker 官方的开源项目，使用 python 编写，实现上调用了 Docker 服务的 API 进行容器管理。其官方定义为为 「定义和运行多个 Docker 容器的应用（Defining and running multi-container Docker applications）。
>

# 安装Docker-compose

```bash
pip3 install -i https://pypi.douban.com/simple docker-compose
```

# 使用

1. 创建一个项目文件夹

```bash
mkdir ghost-docker
```


2. 创建 docker-compose.yml

```bash
cd ghost-docker && touch docker-compose.yml
```
   写入以下内容

```yaml
version: '3'

services:
   ghost:
      image: ghost:latest
      ports:
        - 9030:2368
      volumes:
        - ./data:/var/lib/ghost/content
      enviroment:
        - url=http://o0o0o0.de
      restart: always
```

文件中使用了本目录下的 data 文件夹，所以需要生成该文件夹

```bash
mkdir data
```

3. 容器管理

   启动容器

```bash
   docker-compose up -d # -d 参数忽略输出
```

   停止容器

```bash
   docker-compose stop
```

   删除容器

```bash
   docker-compose rm
```

> 这些命令必须要在 docker-compose.yml 同一目录下执行  

# 从 build 开始构建 docker 容器

## 例1 构建简单 go 应用

`ghost` 的例子中，`docker-compose.yml` 指定了 `image` 镜像，也可以从一个 `Dockfile` 开始构建一个容器。本例子使用 [Manjaro Docker 用法]([https://blog.degen.run/note/2019/08/23/manjaro-docker/#dockerfile-%E5%A4%9A%E6%AE%B5%E6%9E%84%E5%BB%BA](https://blog.degen.run/note/2019/08/23/manjaro-docker/#dockerfile-多段构建)) 中使用的 `Dockerfile`。

先看以下 `Dockerfile` 内容

```dockerfile
    # 分段 1
    FROM golang:1.12-alpine as builder
    # 配置国内源 以及安装 git
    RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
        && apk --no-cache add git
    # 工作目录
    WORKDIR /go/src/github.com/go/helloworld/
    
    COPY app.go .
    # 依赖和编译
    RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .
    
    # 分段 2
    FROM alpine:latest as prod
    # 源和基本环境
    RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
        && apk --no-cache add ca-certificates
    # 工作目录
    WORKDIR /root
    # 从上一层拷贝文件
    COPY --from=0 /go/src/github.com/go/helloworld/app .
    # 执行
    CMD ["./app"]
```

app.go 文件内容

```go
package main

import "fmt"

func main() {
    fmt.Println("THE APP IS RUNNING")
}
```

docker-compose

```yaml
# 这个项目没有什么端口之类的依赖关系，所以及其简单
version: '3'

services:
        myapp:
                build: .
```

## 例2：使用 Docker-compose 构建一个 php 应用

myphp.dockerfile 内容

```dockerfile
FROM php:7.1.22-fpm

# 安装依赖
run apt-get update \
	&& apt-get install -qq git curl libmcrypt-dev libjpeg-dev libfreetype6-dev libbz2-dev \
	&& apt-get clean

# 安装 php 扩展
RUN docker-php-ext-install pdo pdo_mysql mcrypt zip gd
```

nginx.dockerfile

```dock
FROM nginx:1.10
ADD vhost.conf /etc/nginx/conf.d/default.conf
```

niginx 配置文件 vhost.conf

```c
server {
    listen 80;
    server_name www.o0o0o0.de;
    index index.php index.html;
    root /var/www/public;

    error_log /var/log/nginx/error.log notice;
    access_log /var/log/nginx/access.log main;

    location / {
        try_files $uri /index.php?$args;
    }
    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass myphp:9000; // 动态请求转发给 myphp 容器的 9000 端口 docker-compose 同一项目下的容器默认在同一网络中，无需映射可以直接访问
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}
```

docker-compose.yml

```yaml
version: '3'

services:
        myphp:
                build:
                        context: ./
                        dockerfile: myphp.dockerfile
                volumes:
                        - ./:/var/www
                working_dir: /var/www
                environment:
                        - DBHOST=database
                        - REDIS_HOST=redis

        composer: # 这是一个 php 依赖管理容器
                 image: prooph/composer:7.1
                 volumes:
                         - ./:/var/www
                 working_dir: /var/www
                 command: install

        nginx:
                build:
                        context: ./
                        dockerfile: nginx.dockerfile
                volumes:
                        - ./public:/var/www/public
                ports:
                        - 80:80

        database:
                image: mysql:5.7
                environment:
                        - "MYSQL_ROOT_PASSWORD=root"
                        - "MYSQL_DATABASE=test"
                        - "MYSQL_USER=ss"
                        - "MYSQL_PASSWORD=123456789"
        redis:
                image: redis:5
```



# Docker-compose 其它功能

- 