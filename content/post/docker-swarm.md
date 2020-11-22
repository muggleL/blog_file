---
title: ⚓️🐛Docker Swarm
date: '2020-08-02'
tags: docker-swarm
categories: 
- docker
slug: docker-swarm
---

# 0x00

## 修改主机名称

```bash
sudo hostnamectl set-hostname manager131
```

## ubuntu 静态 IP

1. 编辑  `/etc/netplan/` 下的 `yaml` 文件

```c
   # vim /etc/netplan/00-installer-config.yaml
   
   # This is the network config written by 'subiquity'
   network:
     ethernets:
       ens33:
         dhcp4: false
         addresses:
                 - 192.168.174.131/24
         gateway4: 192.168.174.2
         nameservers:
                 addresses:
                         - 8.8.8.8
     version: 2          
```

> 注意网关地址不要填错了，否则可能上不了网

2. 提交更改

```bash
   sudo netplan apply
```

## 启动 docker swarm

```bash
docker swarm init --advertise-addr 192.168.174.131
```

记录输出的 token信息

```bash
docker node ls  # 查看所有的节点
```

## 添加节点

登录 work 服务器

```bash
docker swarm join \
   --token SWMTKN-1-3ww97u875p605ce3hqbecf51lgelh8x4ju0k8lmpehlxpn22b5-33bp9x5d92onlh7gio3h4m2pd 192.168.174.131:2377
```

此时在 `manage` 服务器中运行 `docker service ls` 可以看见 `worker` 节点了

# 0x01

## 运行一个服务

在 `manager` 中运行：

```bash
docker service create --replicas 1 --name helloworld alpine ping baidu.com
```

执行 `docker service ls`

```bash
ss@manager131:~$ docker service ls
ID                  NAME                MODE                REPLICAS            IMAGE               PORTS
v3wcxtzv8ybo        helloworld          replicated          1/1                 alpine:latest
```

查看详情

```bash
ss@manager131:~$ docker service inspect --pretty helloworld

ID:             v3wcxtzv8ybo9gr4b6cxn76u6
Name:           helloworld
Service Mode:   Replicated
 Replicas:      1
Placement:
UpdateConfig:
 Parallelism:   1
 On failure:    pause
 Monitoring Period: 5s
 Max failure ratio: 0
 Update order:      stop-first
RollbackConfig:
 Parallelism:   1
 On failure:    pause
 Monitoring Period: 5s
 Max failure ratio: 0
 Rollback order:    stop-first
ContainerSpec:
 Image:         alpine:latest@sha256:185518070891758909c9f839cf4ca393ee977ac378609f700f60a771a2dfe321
 Args:          ping baidu.com
 Init:          false
Resources:
Endpoint Mode:  vip

```

查看那个节点在运行服务

```bash
ss@manager131:~$ docker service ps helloworld
ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE           ERROR               PORTS
pb49uksjxqd8        helloworld.1        alpine:latest       node134             Running             Running 3 minutes ago
```

可以看到该服务在 `node134` 节点运行

在 `node134` 服务器中运行 `docker ps` 也可以看到该服务

```bash
ss@node134:~$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
7060cc23a6e1        alpine:latest       "ping baidu.com"    6 minutes ago       Up 6 minutes                            helloworld.1.pb49uksjxqd8jm8pdz9dwwqhz
```

## Change Scale

修改任务（task）个数

```bash
docker service scale helloworld=5
```

结果:

```bash
ss@manager131:~$ docker service scale helloworld=5
helloworld scaled to 5
overall progress: 2 out of 5 tasks
1/5: running   [==================================================>]
2/5: preparing [=================================>                 ]
3/5: preparing [=================================>                 ]
4/5: preparing [=================================>                 ]
5/5: running   [==================================================>]
```

查看服务运行情况

```bash
ss@manager131:~$ docker service ps helloworld
ID               NAME       IMAGE          NODE     DESIRED STATE      CURRENT STATE           
pb49uksjxqd8  helloworld.1  alpine:latest   node134    Running     Running 11 minutes ago
kpmzb7vrz177  helloworld.2  alpine:latest   node133    Running     Running about a minute ago
20rber0uda8s  helloworld.3  alpine:latest   node133    Running     Running about a minute ago
ldbicyl1m258  helloworld.4  alpine:latest   manager131 Running     Running about a minute ago
cq9go8er8w45  helloworld.5  alpine:latest   node132    Running     Running about a minute ago
```

服务被分到各个节点运行

## Delete Service

```bash
docker service rm helloworld
```

## 运行一个滚动更新的服务

- 创建一个 `redis` 服务

```bash
docker service create --replicas 3 --name redis --update-delay 10s redis:3.0.6
```

- `docker service inspect --pretty redis`

```bash
ss@manager131:~$ docker service inspect --pretty redis

ID:             xx6qkoxg0zwx33eiru0o0kfdf
Name:           redis
Service Mode:   Replicated
 Replicas:      3
Placement:
UpdateConfig:
 Parallelism:   1
 Delay:         10s
 On failure:    pause
 Monitoring Period: 5s
 Max failure ratio: 0
 Update order:      stop-first
RollbackConfig:
 Parallelism:   1
 On failure:    pause
 Monitoring Period: 5s
 Max failure ratio: 0
 Rollback order:    stop-first
ContainerSpec:
 Image:         redis:3.0.6@sha256:6a692a76c2081888b589e26e6ec835743119fe453d67ecf03df7de5b73d69842
 Init:          false
Resources:
Endpoint Mode:  vip
```

- 更新 `redis`

```bash
docker service update --image redis:3.0.7 redis
```

- `docker service ps redis` 查看更新状况

```bash
ss@manager131:~$ docker service ps redis
ID             NAME        IMAGE         NODE     DESIRED STATE   CURRENT STATE    
adcpxb6xwy5u  redis.1     redis:3.0.7    node132      Running     Running 4 minutes ago
ctnaww4tje61  \_ redis.1  redis:3.0.6    node132      Shutdown    Shutdown 5 minutes ago
870rxdpqu9ij  redis.2     redis:3.0.7    node134      Running     Running 3 minutes ago
pgopz7spccu1  \_ redis.2  redis:3.0.6    node134      Shutdown    Shutdown 4 minutes ago
jg6ducfn797w  redis.3     redis:3.0.7    manager131   Running     Running 5 minutes ago
wqq5t17sxh2z  \_ redis.3  redis:3.0.6    manager131   Shutdown    Shutdown 6 minutes ago
```

## 踢出一个节点（set a node to drain avaliability）

- 查看节点情况

```bash
ss@manager131:~$ docker node ls
ID                            HOSTNAME    STATUS  AVAILABILITY  MANAGER STATUS  ENGINE VERSION
jdp3wydf3nhtjdg6mmvvn7wec *   manager131    Ready    Active     Leader              19.03.12
o593zfiqb5ttf7jlvi5e5nwbl     node132       Ready    Active                         19.03.12
wv46ge1v0yzlpccyi723cl1h4     node133       Ready    Active                         19.03.12
i815q7inckde1z0t2cb1w64kv     node134       Ready    Active                         19.03.12
```

- 查看各节点任务情况

```bash
ss@manager131:~$ docker service ps redis
ID            NAME     IMAGE       NODE     DESIRED STATE    CURRENT STATE   
adcpxb6xwy5u  redis.1  redis:3.0.7  node132    Running        Running 36 minutes ago
870rxdpqu9ij  redis.2  redis:3.0.7  node134    Running        Running 35 minutes ago
jg6ducfn797w  redis.3  redis:3.0.7  manager131 Running        Running 37 minutes ago
uqz8ue3ngqvc  redis.4  redis:3.0.7  node133    Running        Running 2 minutes ago
xc1txlklr1jq  redis.5  redis:3.0.7  node133    Running        Running 2 minutes ago
```

- 踢出（drain）节点 `node113`

```bash
ss@manager131:~$ docker node update --availability drain node133
node133
```

- 此时节点状态

```bash
ss@manager131:~$ docker node ls
ID                            HOSTNAME    STATUS  AVAILABILITY  MANAGER STATUS  ENGINE VERSION
jdp3wydf3nhtjdg6mmvvn7wec *   manager131    Ready    Active     Leader              19.03.12
o593zfiqb5ttf7jlvi5e5nwbl     node132       Ready    Active                         19.03.12
wv46ge1v0yzlpccyi723cl1h4     node133       Ready    Drain                          19.03.12
i815q7inckde1z0t2cb1w64kv     node134       Ready    Active                         19.03.12
```

- 此时任务情况

```bash
 docker service ps redis
ID       NAME          IMAGE        NODE         DESIRED STATE    CURRENT STATE 
adcpxb6xwy5u     redis.1    redis:3.0.7   node132       Running      Running 42 minutes ago
870rxdpqu9ij     redis.2    redis:3.0.7   node134       Running      Running 40 minutes ago
jg6ducfn797w     redis.3    redis:3.0.7   manager131    Running      Running 43 minutes ago
fmxaulougxdn     redis.4    redis:3.0.7   manager131    Running      Running 25 seconds ago
uqz8ue3ngqvc     \_ redis.4 redis:3.0.7   node133       Shutdown     Shutdown 28 seconds ago
122cnudga3m4     redis.5    redis:3.0.7   node134       Running      Running 24 seconds ago
xc1txlklr1jq     \_ redis.5 redis:3.0.7   node133       Shutdown     Shutdown 28 seconds ago
```

可以看到 原本属于 node133 的任务被分配给了`manager131` 与 `node134`

- 重新启用节点

```bash
ss@manager131:~$ docker node update --availability active node133
node133
```

## routing mesh

开启一个新的nginx 服务器

```bash
docker service create --name my-web --publish published=8080,target=80 --replicas 2 nginx
```

也可以简写成

```bash
docker service create --name my-web -p 8080:80 --replicas 2 nginx
```

`swarm` 会将访问 `nginx` 的负载均衡到两个服务器上，但是四个服务器在同一个网络中，任意访问一个服务器的 `8080` 端口都能访问到 `nginx`

# 0x02

## docker swarm 与 docker compose 的结合

待续



