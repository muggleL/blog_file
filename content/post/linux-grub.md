---
title: linux 开机出现grub rescue的恢复方法
author: DG
tags:
  - 折腾
  - 系统
categories:
  - Linux
date: '2017-10-19'
slug: linux-grub-rescue
---

昨天，微软推送了win10的秋季大更新，我也及时接收了。但在更新重启时，正常的grub引导界面进不去了。屏幕上只出现
```bash
grub rescue >
```
根据百度的方法


    grub rescue > ls
    grub rescue > (hd0),(hd0,gpt5),(hd0,gpt4),(hd0,gpt3),(hd0,gpt2),(hd0,gpt1),(hd1)(....)


我明明记得第一个硬盘只有四个分区（efi，windows保留分区，win10系统分区，manjaro系统分区），这会儿怎么出现五个，应该是微软搞的鬼。接下来弄清楚grub到底在那个分区。

执行

```
grub rescue > ls (hd0,gpt5)/boot/grub
grub rescue > .....
```

如果系统在gtp5的话，它会列出对应的文件，如果不在就会报错。一个一个试。

```
grub rescue > set root=(hd0,gpt5)
grub rescue > set prefix=(hd0,gpt5)/boot/grub
grub rescue > insmod normal
grub rescue > normal
```


这时候应该能启动到熟悉的grub引导界面，但此时并没有完全修复，应该启动linux

执行以下命令，重新生成grub就可以了。

```
sudo update-grub
sudo grub-install /dev/sda
sudo reboot
```


还有一种思路，启动不了不就是因为从磁盘的第四个分区变成了第五个吗，我把第四个分区删掉不就恢复了吗？
所以，可以进入pe，把没什么用的第四个分区删掉，再扩展到第三个分区，这时重启就恢复原样了。

> 参考：[grub rescue模式下修复](https://www.douban.com/note/66041888/)