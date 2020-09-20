---
title: VMware 虚拟机克隆
date: '2020-08-03'
slug: clone-VM
author: DG
tags: 
  - 编程
  - 代码
categories: 
  - VMware
---

具体步骤为

- 复制虚拟机

- 设置静态 IP

- Windows Terminal 设置

  ## 复制虚拟机

![批注 2020-08-03 194629.png](https://i.loli.net/2020/08/03/AnZhlWq9Ir8LYSo.png)


![批注 2020-08-03 194932.png](https://i.loli.net/2020/08/03/Q9qJWCI2ap3BLKP.png)

> 一定要选择创建完整克隆

## 修改虚拟机名称以及设置静态 IP

直接克隆虚拟机有可能会出现多个虚拟机同一个 IP 的情况，可以通过配置静态 IP 来解决这个问题。

通过 `ip a` 命令（Linux）查看复制之前虚拟机 IP。

```bash
ss@manager131:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0c:29:7a:6e:d2 brd ff:ff:ff:ff:ff:ff
    inet 192.168.174.131/24 brd 192.168.174.255 scope global ens33
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fe7a:6ed2/64 scope link
       valid_lft forever preferred_lft forever
```

如上可以看出 虚拟机的 IP 为 `192.168.174.131`，则克隆后的虚拟机的 IP 应该设置为与这个 IP 同一网段下。

在新的 Ubuntu 中 设置静态 IP 是配置 `netplan`。修改 `/etc/netplan/00-installer-config.yaml` 。写入如下内容：

```bash
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

> 注意文件内容一定要遵循 [Yaml 的格式](http://www.ruanyifeng.com/blog/2016/07/yaml.html)

> 注意当虚拟机网络设置为 net 时，网关为 `192.168.174.2` 并不是 `192.168.174.1`。网络状态为桥接时，通常为路由器 IP，配置错了可能上不了网。

然后执行 `netplan apply` 提交更改。

为了让每台虚拟机更具有辨识度，简易修改 VMware 中虚拟机的名称以及虚拟机的 `hostname`，虚拟机名称可以直接重命名。

修改 `hostname` 方法为:

```bash
sudo hostnamectl set-hostname worker133
```

> 名称最好要有意义，比如 `worker133` 意为该虚拟机是`docker swarm` 中的从节点（node），IP 尾号为 133

## Windows Terminal 设置

在 VMware 的某次更新中，VMware 虚拟机可以在后台运行。

![批注 2020-08-03 201146.png](https://i.loli.net/2020/08/03/V4gzWCj87wQAd6r.png)

微软的 Windows Terminal 是一个牛逼的终段模拟器

用 Windows Terminal 连接的虚拟机的配置如下：

```json
            {
                "guid": "{50347a88-d4d6-403a-ad5f-fc0776b9f38b}",
                "hidden": false,
                "name": "worker133",
                "commandline" :"ssh ss@192.168.174.133",
            },
```

其中 `guid` 可以通过[Create GUIDs online](https://www.guidgen.com/)在线生成。

### 使用公钥登录服务器

1. windows 生成公钥

   打开 `powershell` 执行 `ssh-keygen` 然后按照提示输入（或者一路回车），公钥就会生成在当前用户的 .ssh 文件夹下，名称为 `id_rsa.pub`	

2. 发送公钥到服务器

   切换到公钥所在目录

   powershell 执行:

   ```bash
   scp id_rsa.pub ss@192.168.174.133:~
   ```

   然后登录服务器执行：

   ```bash
   mkdir .ssh
   cat ./id_rsa.pub >> .ssh/authorized_keys
   ```

   

