---
title: 搭建亚马逊云aws免费服务器
date: 2016-10-18 12:19:57
tags: [aws,mosh]
categories: ubuntu
---

### 注册
亚马逊云计算中心的网址：https://aws.amazon.com/cn 注册成功之后，系统会从你的信用卡扣掉你1美元

### aws12个月免费包的重点
服务器的免费政策是720 * 1个Instance小时/月。instance记时是以1小时做单位的，如果你一个小时之内start/stop 5次服务器的话，你会被记5个小时。12月之内一定要终止你使用的aws服务，否则会被计费
<!-- more -->

### 开启aws云计算服务器
EC2云计算服务器服务中心页面:https://console.aws.amazon.com/ec2/

a，设置安全策略组时选择一个已经存在的安全策略组。实例建成功后再编辑安全策略组，因为我们后面要ssh连接这个服务器，所以选择的安全策略要打开ssh服务端口。以后根据自己服务器对外提供的功能，安全策略也要相应的更新，否则外部终端无法访问相应的端口。为了简便可以把入站和出站的所有端口打开；

b，在“ Select an existing key pair or create a new key pair ”页面选“Create a new key pair”创建ssh用的key文件，创建之后务必要“Download Key Pair”，下载生成的key；

c，注意：如果在“Instances”页面看到多于一个instance，你一定要stop甚至terminate多于一个的，不然你将面临计费风险；
![aws创建实例](http://ofat4idzj.bkt.clouddn.com/aws%E5%88%9B%E5%BB%BA%E5%AE%9E%E4%BE%8B.gif)

### 连接EC2云计算服务器
在 Host Name (主机名) 框中，输入 user_name@public_dns_name。
`ubuntu@ec2-35-160-120-14.us-west-2.compute.amazonaws.com`
在putty中，connection|ssh|auth 下面选择puttygen转换后的key
![用putty连接](http://ofat4idzj.bkt.clouddn.com/%E7%94%A8putty%E8%BF%9E%E6%8E%A5.gif)

### 使用ip和密码登陆Amazon EC2
```
sudo passwd root
sudo vi /etc/ssh/sshd_config
#编辑亚马逊云主机的ssh登录方式，找到 PasswordAuthentication no，把no改成yes
#要重新启动下ssh
sudo service sshd restart
su root
passwd ubuntu
```
![用ip和密码登录](http://ofat4idzj.bkt.clouddn.com/%E7%94%A8ip%E5%92%8C%E5%AF%86%E7%A0%81%E7%99%BB%E5%BD%95.gif)

### 解决键盘延迟
1、把实例建在延迟较小的区域，推荐一个网站专门看延迟：http://www.cloudping.info/
2、更改端口号
3、使用[mosh](https://mosh.org/)
```
sudo apt-get install mosh
#两端都要安装，详情见官网
#mosh USERNAME@IP
#mosh --ssh="ssh -p 22222" ubuntu@52.198.212.57
```
