[toc]

# Docker Compose

## docker-compose介绍与安装

Docker Compose：https://github.com/docker/compose

Docker Compose 是 docker 提供的一个命令行工具，用来定义和运行由多个容器组成的应用。使用 compose，我们可以通过 YAML 文件声明式的定义应用程序的各个服务，并由单个命令完成应用的创建和启动。



安装

```bash
sudo apt-get install python-pip
pip install docker-compose
```

看安装的版本

```bash
docker-compose version
```



## docker-compose命令

### docker-compose up

```bash
docker-compose up [options] [--scale SERVICE=NUM...] [SERVICE...]
选项包括：
-d 在后台运行服务容器
-no-color 不是有颜色来区分不同的服务的控制输出
-no-deps 不启动服务所链接的容器
--force-recreate 强制重新创建容器，不能与-no-recreate同时使用
–no-recreate 如果容器已经存在，则不重新创建，不能与–force-recreate同时使用
–no-build 不自动构建缺失的服务镜像
–build 在启动容器前构建服务镜像
–abort-on-container-exit 停止所有容器，如果任何一个容器被停止，不能与-d同时使用
-t, –timeout TIMEOUT 停止容器时候的超时（默认为10秒）
–remove-orphans 删除服务中没有在compose文件中定义的容器
```

### docker-compose down

```bash
docker-compose down [options]
停止和删除容器、网络、卷、镜像。
选项包括：
–rmi type，删除镜像，类型必须是：all，删除compose文件中定义的所有镜像；local，删除镜像名为空的镜像
-v, –volumes，删除已经在compose文件中定义的和匿名的附在容器上的数据卷
–remove-orphans，删除服务中没有在compose中定义的容器
docker-compose down
停用移除所有容器以及网络相关
```

### docker-compose bulid

```bash
docker-compose build [options] [--build-arg key=val...] [SERVICE...]
构建（重新构建）项目中的服务容器。
选项包括：
–compress 通过gzip压缩构建上下环境
–force-rm 删除构建过程中的临时容器
–no-cache 构建镜像过程中不使用缓存
–pull 始终尝试通过拉取操作来获取更新版本的镜像
-m, –memory MEM为构建的容器设置内存大小
–build-arg key=val为服务设置build-time变量
服务容器一旦构建后，将会带上一个标记名。可以随时在项目目录下运行docker-compose build来重新构建服务
```



其它常用命令

```bash
docker-compose -h
docker-compose ps		#列出项目中所有的容器
docker-compose stop
docker-compose start	#启动已经存在的服务容器
docker-compose rm		#删除所有（停止状态的）服务容器
docker-compose restart
docker-compose pull		#拉取服务依赖的镜像
docker-compose port		#显示某个容器端口所映射的公共端口
docker-compose kill		#通过发送SIGKILL信号来强制停止服务容器
```





## docker-compose模板文件

docker-compose标准模板文件应该包含version、services、volumes、networks 几部分，比如：

```yaml
version: '3'
services:
  redis:
    image: redis
    links:
      - web
    networks:
      - back-tier
 
networks:
  back-tier:
    driver: bridge
```

### version

Compose目前最高版本为3.7，参考文档：https://docs.docker.com/compose/compose-file/



### servicess

servicess里面指定了各种服务，每种服务下面有指定的配置；

```yaml
version: "3.7"
services:
  redis:
    image: redis:latest
    deploy:
      replicas: 1
    configs:
      - my_config
      - my_other_config
configs:
  my_config:
    file: ./my_config.txt
  my_other_config:
    external: true
```



### volumes

```yaml
version: "3.7"

services:
  db:
    image: postgres
    volumes:
      - data:/var/lib/postgresql/data

volumes:
  data:
    external: true
```



### networks

```yaml
version: "3.7"
services:
  web:
    networks:
      hostnet: {}

networks:
  hostnet:
    external: true
    name: host
```



## docker-compose模板文件示例

下面`docker-compose.yml`文件指定了3个web服务：

```yaml
version: '3'
services:
  web1:
    image: nginx
    ports:
      - "6061:80"
    container_name: "web1"
    networks:
      - dev
  web2:
    image: nginx
    ports:
      - "6062:80"
    container_name: "web2"
    networks:
      - dev
      - pro
  web3:
    image: nginx
    ports:
      - "6063:80"
    container_name: "web3"
    networks:
      - pro
 
networks:
  dev:
    driver: bridge
  pro:
    driver: bridge
```

启动应用

```
docker-compose up -d
```

通过浏览器访问web1，web2，web3

```go
http://127.0.0.1:6061
http://127.0.0.1:6062
http://127.0.0.1:6063
```





# Dockerfile

[Dockerfile文档](https://docs.docker.com/engine/reference/builder/)

Dockerfile由一行行命令语句组成，并且支持用“#”开头作为注释，一般的，Dockerfile分为四部分：

* 基础镜像信息

* 维护者信息

* 镜像操作指令

* 容器启动时执行的指令

  

参考

https://www.cnblogs.com/minseo/p/11548177.html

https://docs.docker.com/compose/compose-file/#network-configuration-reference





# 自定义网络



使用docker创建 macvlan 网络

```bash
#创建 macvlan 网络
docker network create -d macvlan  --subnet=172.16.0.0/19 --gateway=172.16.0.1 -o parent=eth0 gitlab-net

#查看
docker network ls

#创建容器指定网络
docker run --net=gitlab-net --ip=172.16.0.170  -dt --name test dogo:alpine

#删除全部未使用的网络
docker network prune
```

docker-compose中指定

```yaml
version: '3'
services:
   nginx:
      image: nginx:1.13.12
      container_name: nginx
      networks:
         extnetwork:
            ipv4_address: 172.19.0.2
 
networks:
   extnetwork:
      ipam:
         config:
         - subnet: 172.19.0.0/16
           gateway: 172.19.0.1
```



win10添加路由映射

```bash
#查看路由表
route print

#添加路由
route -p add 172.19.0.0/16 10.0.75.2

#重新ping容器地址
ping 172.17.0.2

#删除路由：
route delete 172.18.12.0

#最新版有bug，这种方法无效
#https://www.cnblogs.com/brock0624/p/9788710.html
```

