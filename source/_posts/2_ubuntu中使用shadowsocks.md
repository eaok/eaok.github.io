---
title: ubuntu中使用shadowsocks
date: 2016-10-09 15:55:30
tags: [shadowsocks,proxychains]
categories: [linux,online]

---

### 安装shadowsock
shadowsock主页 https://github.com/shadowsocks/shadowsocks
`sudo apt-get update`
`sudo apt-get install python-gevent python-pip`
`sudo pip install shadowsocks`
<!-- more -->
### 编辑配置文件
`sudo vi etc/shadow.config`
```
{
	"server":"47.90.65.76",
	"server_port":41754,
	"local_port":1080,
	"password":"euwatP",
	"timeout":600,
	"method":"chacha20"
}
```

### 启动
`sudo sslocal -c /etc/shadow.conf -d start`
`sudo sslocal -c /etc/shadow.conf -d stop`
后台长期启动shadowsockts
`nohup sslocal -c etc/shadow.config &

* 设置开机自动启动
`sudo vim /etc/rc.local`
在*exit 0*前加上一行：
`/usr/local/bin/sslocal -c /etc/shadow.conf`

### 安装一些加密方式所依赖的库
python-m2crypto
`apt-get install python-m2crypto`
libsodium    //chacha20加密方式需要用到
```
wget https://download.libsodium.org/libsodium/releases/LATEST.tar.gz
tar zxf LATEST.tar.gz
cd libsodium*
./configure
make && make install

echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf    # 修复关联
ldconfig
```

### 终端中使用shadowsocks
可以使用的有 **Privoxy Polipo proxychains**，前两者貌似不支持ssh,所以就选择了**proxychains**

* 安装proxychains
```
git clone https://github.com/rofl0r/proxychains-ng
cd proxychains-ng/
./configure --prefix=/usr --sysconfdir=/etc
make && sudo make install
sudo make install-config
```
`sudo vi /etc/proxychains.conf`
```
strict_chain
proxy_dns
remote_dns_subnet 224
tcp_read_time_out 15000
tcp_connect_time_out 8000j
localnet 127.0.0.0/255.0.0.0
quiet_mode

[ProxyList]
socks5  127.0.0.1 1080
```
* 使用例子
`proxychains curl www.google.com`
```
proxychains bash
curl ip.gs
curl www.google.com
wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.8.1.tar.xz
git clone git@github.com:baidu/Paddle.git
```

### 在windows的cmd中使用系统代理
`set http_proxy=http://127.0.0.1:1080`

