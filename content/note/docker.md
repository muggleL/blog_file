---
title: 📦⚓️Manjaro Docker 用法
date: '2019-08-23'
author: DG
tags:
  - 编程
  - 代码
categories: 
  - Docker
slug: tutorial-of-manjaro-docker
---

*<font style="color:red; font-size:13px">不同发行版的指令，文件位置略有不同，本文仅以 arch 及其衍生系统为准。</font>*

#### 目录

1. [安装](#安装)
2. [设置镜像仓库](#设置镜像仓库)
3. [设置代理](#设置代理)
4. [基础命令](#基础命令)
5. [Dockerfile](#dockerfile)
6. [Dockerfile 多段构建](#dockerfile-多段构建)
7. [容器的操作](#容器的操作)
8. [数据管理](#数据管理)
9. [网络](#网络)

## 安装

```bash
sudo pacman -Syy
sudo pacman -S docker
# 启动
sudo systemctl start docker
# 用户加入 docker 用户组（可以不用 sudo 启动docker)
sudo usermod -aG docker $USER
# 注销重新登录
```
## 设置镜像仓库

```bash
echo '{        
  "registry-mirrors": [
    "https://dockerhub.azk8s.cn", # 国内镜像仓库1
    "https://reg-mirror.qiniu.com" # 仓库2
  ]
}' | sudo tee -a /etc/docker/daemon.json > /dev/null
# 重启服务
sudo systemctl daemon-reload
sudo systemctl restart docker
```

> 通过 `docker info` 可以看到仓库设置情况。

## 设置代理

> 参考[官方文档]((https://docs.docker.com/config/daemon/systemd/) )

> 通过 [polipo](https://wiki.archlinux.org/index.php/Polipo) 将 `socks` 代理转换成 `http` 代理。

  - 创建 `systemd` 的插入式([drop-in](https://wiki.archlinux.org/index.php/systemd#Drop-in_files)) 目录
```bash
    sudo mkdir -p /etc/systemd/system/docker.service.d
```
  - 建立配置文件
```bash
    sudo vim /etc/systemd/system/docker.service.d/http-proxy.conf
```
```bash
    [Service]
    #NO_PROXY 为代理白名单
    Environment="HTTP_PROXY=http://localhost:8123/" "NO_PROXY=localhost,127.0.0.1,docker-registry.example.com,.corp"
```
  - 刷新
```bash
    sudo systemctl daemon-reload
```
  - 重启 `Docker`
```bash
    sudo systemctl restart docker
```

    > 通过 `docker info` 能看到代理信息。

## 基础命令

- ### 查看版本

```bash
  docker --version
  docker info
```

- ### Hello-world
  
```bash
  docker run hello-world
```

- ### List Image

```bash
  docker image ls
```

  > `docker image ls --help` 查看所有操作。

- ### List Container

```bash
  docker container ls       # 列出正在运行的容器
  docker container ls --all # 列出所有
  docker container ls --aq  # all in 
```

  > `docker container ls --help` 可以查看所有的操作。

- 启动容器
```bash
  docker run image:tag # 启动容器
  docker run -it image:tag # 进入交互式 tty 环境
  docker run --rm image:tag # 容器退出后自动删除
  docker run image:tag command # 容器启动后执行 command 命令
```
  >`docker run --help` 可以查看所有的操作。


## Dockerfile

### 1. FROM

```bash
FROM image
```

`FROM` 指定基础镜像，是 Dockerfile 的必备指令，并且必须是第一条指令。`FROM` 可以指定基础服务类镜像，如 [nginx](https://hub.docker.com/_/nginx/) 、[redis](https://hub.docker.com/_/redis/) 等，语言镜像 [python](https://hub.docker.com/_/python/) 、[golang](https://hub.docker.com/_/golang/) 等。也可以是操作系统类镜像，如 [ubuntu](https://hub.docker.com/_/ubuntu/) 、[alpine](https://hub.docker.com/_/alpine/) 等。

特别的，`Docker` 还存在着一个名为 `scratch` 的特殊镜像，表示空白的镜像。

### 2. RUN

RUN 指定执行的命令有 `shell 格式 ` 和 `exec 格式` 两种形式。

- shell 格式

```bash
  RUN python app.py
```

- exec 格式

```bash
  RUN ["python", "app.py"]
```

`Dockerfile` 中每一个指令都会建立一层，`RUN` 也不例外。因此最好在一个 `RUN` 中执行完所有的命令。为了保证镜像的简洁，切记要清除 `RUN` 执行过程中产生的不必要的中间文件和缓存文件。

### 3. COPY

与 `RUN` 一样 `COPY` 也有两种格式

- shell 格式

```bash
  COPY [--chown=<user>:<group>] <源路径>... <目标路径>
  # 支持通配符 参考 https://golang.org/pkg/path/filepath/#Match
  COPY hom* /app
  COPY hom?.txt /app
  # 用户权限
  COPY --chown=theuser:thegroup files* /app
```

- exec 格式

```bash
  COPY [--chown=<user>:<group>] ["<源路径1>",... "<目标路径>"]
```

`COPY` 会保留原文件，如果指定目录不存在，会自动创建该目录。`COPY` 也会保留源文件的各种元数据，比如读、写、执行、变更时间等。

### 4. ADD

`ADD` 的格式与性质基本与 `COPY` 一致，但在 其基础上增加了一些功能。

- 如果 `<源路径>` 可以是 `URL`，`ADD` 会自动下载到对应目录并给予 `600` 的权限。

- 如果 `<源路径>` 是一个 `tar` 压缩文件，格式为 `gzip` 、`bzip2` 以及 `xz` 的话，`ADD` 会自动解压这个文件到目标文件

第一条 `URL` 中更多的情况是压缩文件 并且我们所需要的权限往往不一定是 `600` ，所有这种情况还是用 `RUN` 比较实在，并不推荐用 `ADD`

> 当仅仅复制文件时，用 `COPY` 。
>
> 当复制一个压缩文件，并且要解压时用 `ADD` 。

### 5. CMD

`CMD` 命令与 `RUN` 相似

- shell 格式

```bash
  CMD <命令>
```

- exec 格式

```bash
  CMD ["可执行文件", "参数1", "参数2"...] # 只能用 " 不能用 '
```

- 参数列表格式

```bash
  # 指定 ENTRYPOINT 之后
  CMD ["参数1", "参数2", "参数3"...]
```

`CMD` 指定容器启动时所运行的程序与参数。

使用 `shell 格式` 时，容器实际上以 `sh -c` 的形式执行

```bash
CMD echo $HOME
# 实际执行时为
CMD ["sh", "-c", "echo $HOME"]
```

所以在 Dockerfile 中设置环境变量能够被 shell 解析并处理。

再者，由于所有的命令由 `sh` 执行 当主进程的 `sh` 退出后，命令自然结束运行。所以容器内部没有后台的概念。

> 运行时镜像后面的参数 会替换 `CMD` 的默认值，如上，当我执行 `docker run myimage sth` 时 `sth` 会替换 `echo $home`。
>
> `CMD` 指令只能出现一次，出现多次只有最后一个有效。

### 6. ENTRYPOINT

`ENTRYPOINT` 格式和 `RUN` 一样，但其目的和 `CMD` 一样。旨在指定容器启动时运行的程序与参数

当指定 `ENTRYPOINT` 时， `CMD` 就会被当成参数传递给 `ENTRYPOINT`

```bash
CMD ["-s"]
ENTRYPOINT ["curl", "ip.sb"]
# 当执行 docker run theimage 时 相当于执行 curl ip.sb -s
# 当执行 docker run theimage -i 时 CMD 被取代 相当于执行 curl ip.sb -i
```

还有一个场景能体现出 `ENTRYPOINT` 与 `CMD` 的不同作用。当某个程序要经过一些初始化之后才能运行时，可以写一个脚本 ，脚本中先进行初始化，然后再接收 `CMD` 为参数运行。脚本放入 `ENTRYPOINT`中执行。`redis` 官方镜像就是这么做的。

> `ENTRYPOINT` 指令只能出现一次，出现多次只有最后一个有效。

### 7. ENV

设置环境变量

- ```bash
  ENV <key> <value>
  ```

- ```bash
  ENV <key>=<value> <key2>=<value2>...
  ```

`ENV` 可以当做 `Dockerfile` 中的变量存在。只要修改少部分，就可以做到一个 `Dockerfiel` 维护多个镜像如果用。

### 8. ARG

```bash
ARG <参数名> [=<默认值>]
```

`ARG` 与 `ENV` 效果一样，但是 `ENV` 在容器运行时，还会存在这些变量，而 `ARG`仅仅是作为 `Dockerfile` 构建时的参数。

> 构建时参数默认值可以被 `--build-arg <参数名>=<值>` 覆盖。

### 9. VOLUME

定义自动挂载的[匿名卷](#数据管理)

格式

- ```bash
  VOLUME ["<路径1>", "<路径2>"...]
  ```

- ```bash
  VOLUME <路径>
  ```

> 运行时可以用 `docker run -d -v mydata:/data xxxx` 覆盖这个默认挂载。

### 10. EXPOSE

端口声明

```bash
EXPOSE <端口1> [<端口2>...]
```

这仅仅是一个声明，并不意味着定义了 `EXPOSE` 就一定会开启该端口。该声明的作用是方便使用者理解这个程序的守护端口。

> 当运行 `docker run -P sth` 时，会将 `EXPOSE` 声明的端口随机映射到宿主机上。

### 11. WORKDIR

指定工作目录

```bash
WORKDIR <工作目录路径> # 该容器各层的目录改为等前目录，如果目录不存在，会自动创建
```

`Dockerfile` 中每执行一条指令都会建立一层，而每层的当前目录都是固定的。假如 `Dockerfile` 中有两条 `RUN` ：

```bash
RUN cd /app
RUN echo "Hello" > world.txt
```
执行之后，`world.txt` 并不会出现在 `/app` 目录中。 只会在 `当前目录` 默认为 `/` 。

### 13. USER

指定当前用户，与 `WORKDIR` 类似，都会影响以后的层。

```bash
USER <用户名>[:<用户组>]
```

`USER` 并不会自动建立不存在的用户，切换之前应该建立好相应用户。

建议使用 [gosu](https://github.com/tianon/gosu) 来代替 `su` 和 `sudo` 以 `root` 身份来执行进程。

配置 `gosu` 示例：
```bash
# 建立 redis 用户，并使用 gosu 换另一个用户执行命令
RUN groupadd -r redis && useradd -r -g redis redis
# 下载 gosu
RUN wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.7/gosu-amd64" \
   && chmod +x /usr/local/bin/gosu \
    && gosu nobody true
# 设置 CMD，并以另外的用户执行
CMD [ "exec", "gosu", "redis", "redis-server" ]
```

### 14 .HEALTHCHECK

容器健康检查

```bash
HEALTHCHECK [选项] CMD <命令> #检查容器健康状况
HEALTHCHECK NONE # 屏蔽基础容器的健康检查指令
```

`HEALTHCHECK` 支持以下选项

- ```bash
  --interval=<间隔> #两次健康检查的间隔，默认 30 秒
  ```

- ```bash
  --timeout=<时长> # 默认检查有效的时长，超过这个时间，则检查失败。默认 30 秒
  ```

- ```bash
  --retries=<次数> # 当检查失败之后 才重新检查的次数 默认 3 次。当连续失败之后，结果标记为 unhealthy
  ```

> 通过 `docker container ls` 的 `STATUS` 栏能看到 健康状态标记。

### 15. ONBUILD

```bash
ONBUILD <其它指令>
```

只有当以当前镜像为基础镜像构建项目时，才会执行的指令。

### 16. 使用 Dockerfile 构建镜像

```bash
docker build -t imageName:tag .
```

> 切记不要忘记后面的点（dot）

## Dockerfile 多段构建

`Docker` 多段构建将编译、测试、打包等环境与运行环境分开。

步骤为将需要的文件在一个环境测试、编译、打包好之后，拷贝到运行环境。

- golang 的 hello-world 项目 多段构建示例

  - app.go

```go
    package main
    
    import "fmt"
    
    func main() {
        fmt.Println("hello world")
    }
```

  - Dockerfile

```bash
    # 分段 1
    FROM golang:1.12-alpine as builder
    # 配置国内源 以及安装 git
    RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
        && apk --no-cache add git
    # 工作目录
    WORKDIR /go/src/github.com/go/helloworld/
    
    COPY app.go .
    # 编译
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
> 1. 可以只构建某一段的镜像
>
>    ```bash
>    docker build --target builder -t name/imagename:tag .
>    ```
>
> 2. 构建时，也能从其他镜像复制文件
>
>    ```bash
>    COPY --from=nginx:latest /etc/nginx/nginx.conf /nginx.conf
>    ```
>
>    

## 容器的操作

### 1.启动、终止、重启与删除

```bash
docker container start    <容器名称或id>
docker container stop     <容器名称或id>
docker container restart  <容器名称或id>
docker container rm       <容器名称或id>
docker container prune    # 删除所有不在运行的容器
```

### 2. 以守护状态运行容器

```bash
docker run -d ... 
```

> 可以通过 `docker container logs` 查看后台程序输出的内容。

### 3. 进入容器

- `attach`

```bash
  docker attach <容器名称或id>
```

  > 如果在这里输入 `exit` 会导致容器停止。

- `exec`


```bash
  docker exec -it <容器名称或id> bash # 启动 bash --> 容器中有bash 才能启动成功。
```

    `-i` 使 `STDIN` 始终处于可交互状态。
    
    `-t` 虚拟tty
    
    `-it` 一起用就可以看到熟悉的 linux 终端环境。
    
    > 这里输入 `exit`不会导致容器停止，所以更推荐用 `exec`

  







### 4. 导入与导出

- 导出

  - export

```bash
    # 导出 id 为 7691a814370e 的容器快照，保存为 ubuntu.tar
    docker export -o ubuntu.tar 7691a814370e
    docker export 7691a814370e > ubuntu.tar 
```
  - save
```bash
    # 镜像保存为文件
    docker save -o ubuntu.tar test/ubunt:v1.0
```

- 导入

  - import

```bash
    # 导入名为 ubuntu.tar 的容器快照
  docker import ubuntu.tar test/ubuntu:v1.0
    cat ubuntu.tar | docker import - test/ubuntu:v1.0 
    # 从网络导入
    docker import http://example.com/exampleimage.tgz example/imagerepo
```


  - load

```bash
    # 导入 ubuntu.tar 为镜像
    docker load -i ubuntu.tar
    docker load < ubuntu.tar
```


  > `export` 、`import` 相当于虚拟机快照，只保存当前状态，不保存元数据。
  >
  > `save` 、`load` 相当于镜像的复制。

## 数据管理
### 数据卷

数据卷类似于 linux 里面的 `mount`。挂载点原有的文件将会被隐藏，只显示挂载的数据卷里面的文件。

- 数据卷可以在容器间共享和重用。
- 删除容器不会影响数据卷的存在。
- 更新数据卷不会影响镜像。
- 对数据卷修改会立马生效。

#### 数据卷创建、查看、删除

```bash
docker volume create my-vol
docker volume ls
docker volume rm     my-vol
docker volume prune  # 删除无主数据卷
```

#### 查看指定数据卷具体信息

```bash
docker volume inspect my-vol
```

#### 启动一个挂载数据卷的容器

```bash
docker run --name web \
	--mount source=my-vol,target=/webapp \
	# -v my-vol:/webapp  \   # 简写
	--rm -d -p  80:80 dockerdemo
# 此时目录 /webapp 相当于一块独立的硬盘，可以同时在其他容器中使用，也不会随着容器的生命周期结束而结束
```

#### 查看容器信息

```bash
docker inspect web # 在这能看到 web 挂载的数据卷的信息
```

### 挂载主机目录

#### 挂载目录

```bash
    docker run --name web \
	  --mount type=bind,source=/my/host/path,target=/webapp \
	  # -v /the/host/path:/webapp \
	  --rm -d -p  80:80 dockerdemo
```

  > 此时被挂载的目录可以被容器读写（以root身份）。

  挂载时，加 `readonly` 参数，指定为只读：

```bash
  docker run --name web \
  --mount type=bind,source=/my/host/path,target=/webapp,readonly \
  # -v /the/host/path:/webapp:ro\
  --rm -d -p  80:80 dockerdemo
```


#### 挂载文件

```bash
  docker run --name web \
	  --mount type=bind,source=$HOME/.bash_history,target=/root/.bash_history \
	  # -v $HOME/.bash_history:/root/.bash_history \
	  --rm -d -p  80:80 dockerdemo
```

## 网络

### 端口映射

- 随机映射

```bash
  docker run -P # 随机映射 49000~49900 之间的端口。
```

- 指定端口，所有地址

```bash
  docker run -p 8080:80
```

- 指定地址，指定端口

```bash
  docker run -p 127.0.0.1:8080:80
```

- 指定地址，随机端口

```bash
  docker run -p 127.0.0.1::80
```

- 查看端口配置

```bash
  docker port <容器名称> <容器内部端口>
```

> `-p` 标记支持多端口映射

### 容器互联

#### 1. 新建网络

```bash
docker network create -d bridge my-net # -d 指定网络类型
```

#### 2. 连接网络

- 创建第一个容器，并连接网络。

```bash
  docker run -it --rm --name net1 --network my-net busybox sh
```

- 创建第二个容器，连接同一网络。

```bash
  docker run -it --rm --name net2 --network my-net busybox sh
```

这时候 `net1` 和 `net2` 可以相互 ping 通。

> 2020.8.1 更新添加 docker 构建命令&&优化Dockerfile 例子