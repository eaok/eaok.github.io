[toc]



# 1 安装

## apt安装：

```shell
sudo apt-get install nginx
nginx -v

# 彻底卸载nginx
dpkg --get-selections|grep nginx # 罗列和nginx相关的包
sudo apt-get --purge autoremove nginx nginx-core

# 查看nginx正在运行的进程，如果有就kill掉
ps -ef |grep nginx
```

安装后主要文件的位置：

```
/usr/sbin/nginx：主程序
/etc/nginx：存放配置文件
/usr/share/nginx：存放静态文件
/var/log/nginx：存放日志
```



启动

```shell
sudo service nginx start
```



## 编译安装：

1 去官网找安装包的链接：https://nginx.org/en/download.html，然后再终端中用`wget`下载

2 安装依赖包：

```shell
sudo apt-get install gcc libpcre3 libpcre3-dev zlib1g zlib1g-dev openssl libssl-dev
```

3 编译安装

```shell
sudo tar -xvzf nginx-1.22.tar.gz -C /usr/local
cd /usr/local/nginx-1.22
sudo ./configure
sudo make
sudo make install
```

4 启动

```shell
cd /usr/local/nginx/sbin
sudo ./nginx
```



# 2 配置 https

## 配置本地https

查看是否带`http_ssl_module`模块，如果没有需要重新编译：

```shell
nginx -V
```



创建签名证书：

```shell
su
mkdir /etc/nginx/cert

#创建私匙
openssl genrsa -des3 -out server.key 2048
#创建签名请求证书
openssl req -new -key server.key -out server.csr
#备份私钥
cp server.key server.key.org
#去除私钥口令
openssl rsa -in server.key.org -out server.key
#创建签名证书
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

#用一行简化上面的操作
openssl req -x509 -nodes -days 36500 -newkey rsa:2048 -keyout ./server.key -out ./server.crt
#Common Name (e.g. server FQDN or YOUR name) []: 输入证书域名
```

修改配置文件`/etc/nginx/sites-availabl/default`

```shell
server {
    listen 443 ssl;

    server_name localhost;

    root /var/www/html;
    index index.html;

    ssl_certificate /etc/nginx/cert/server.crt;
    ssl_certificate_key /etc/nginx/cert/server.key;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers         HIGH:!aNULL:!MD5;
    #ssl_prefer_server_ciphers on;
    #ssl_session_cache shared: SSL: 10m;
    ssl_session_timeout 1m;

    #if ($server_port!~443) {
    #    rewrite ^(/.*)$ https://$host$1 permanent;
    #}

    location / {
        proxy_pass http://127.0.0.1:8080/;
        proxy_redirect off;
    }
}
```



通过HTTPS访问网站，第一次访问时会出现警告（因为我们的自签名证书不被浏览器信任），把证书通过浏览器导入到系统并设置为“受信任”，以后该电脑访问网站就可以安全地连接Web服务器了：



## 云服务器中配置https

免费证书申请：https://freessl.cn/ 阿里云

配置修改参考文档：http://nginx.org/en/docs/http/configuring_https_servers.html#single_http_https_server