---
title: Raspberrypi系统安装
date: 2016-11-01 09:42:07
tags: [raspberrypi]
categories: [linux,raspberrypi]

---

### 安装系统
系统下载地址 https://www.raspberrypi.org/downloads/
解压提取出.img文件，再用[Win32DiskImager](https://sourceforge.net/projects/win32diskimager/)工具写到存储卡上。
在cmd中运行 `arp/a` 查看树莓派的ip 或者用工具`ipscan22`扫描ip地址，得到ip地址后，用putty链接 户名和密码分别为 `pi， raspberry`
<!-- more -->
### 修改源为阿里云的
`deb http://mirrors.aliyun.com/raspbian/raspbian/ jessie main contrib non-free rpi`
`sudo apt-get update`

### 修改为静态ip
`sudo vi /etc/dhcpcd.conf` 在末尾添加
```
interface eth0
static ip_address=192.168.1.2
static routers=192.168.1.1
static domain_name_servers=202.96.154.8 223.5.5.5
```
`sudo reboot` 修改后重启

### 桌面连接
#### 用远程桌面连接
`sudo apt-get install xrdp` 安装xrdp
windows端运行`mstsc`，或者在listary中搜索`rdp`打开远程连接程序；用Linux 系统连接需要安装rdesktop: `sudo apt-get install rdesktop`
系统需要在系统属性\远程设置\远程 中设置相应的选项
#### 用vnc链接
`sudo apt-get install tightvncserver` 在树莓派上安装Tight VNC 包
`vncpasswd`
windows端下载 [VNC Viewer](https://www.realvnc.com/download/vnc/),连接rasberrypi
`raspi-config` 里面有配置开启VNC的选项
