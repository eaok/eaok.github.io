[toc]

# 0x00 docker

## 1. docker简介

docker是一个基于go语言的开源的应用容器引擎，可以让开发者打包他们的应用以及依赖包到一个轻量级、可移植的容器中，然后发布到任何流行的 Linux 机器上，也可以实现虚拟化。容器是完全使用沙箱机制，相互之间不会有任何接口,更重要的是容器性能开销极低。

容器技术的实现: 得益于以下三点技术

- Namespace命名空间 : 作用是隔离
- Control Groups控制组：作用是限制计算机资源的使用
- Union File System 联合文件系统：作用是实现不同目录挂载到同一目录



## 2. docker架构

docker 采用典型的 C/S 架构，你安装 docker 软件。默认会在本机启动一个守护进程 docker daemon ， 同时提供一个命令行客户端 docker cli . 你可以使用命令行操作包括：镜像、容器等各种资源。

![](https://cdn.jsdelivr.net/gh/eaok/img/docker/dockerFramework.jpg)



docker cli 的命令主要围绕这四个命令展开：

- docker image // 操作镜像
- docker container // 操作容器
- docker network // 操作网络
- docker volume // 操作数据卷



仓库注册中心（Registry）分私有和公有两种形式，公有的有

| 源                                                 | 镜像                                                         |
| -------------------------------------------------- | ------------------------------------------------------------ |
| Docker Hub(http://docker.io)                       | http://f1361db2.m.daocloud.io<br>https://dd31kyx9.mirror.aliyuncs.com |
| Google container registry(http://gcr.io)           |                                                              |
| k8s.gcr.io(等同于 http://gcr.io/google-containers) | googlecontainersmirror                                       |
| Red Hat运营的镜像库(http://quay.io)                | http://quay-mirror.qiniu.com                                 |



## 3. 安装docker

**ubuntu**

`$ sudo apt-get update` 
`$ sudo apt-get install docker-ce docker-ce-cli containerd.io`

安装文档地址：https://docs.docker.com/install/linux/docker-ce/ubuntu/

**mac**

`$ brew cask install docker`

**mac/windows**

下载安装包安装：https://www.docker.com/products/docker-desktop

win10：https://www.cnblogs.com/360linux/p/13662355.html



## 4. docker测试例子

* 测试运行hello-world
`$ docker run hello-world`

* 测试构建镜像
```bash
git clone https://github.com/docker/doodle.git
cd doodle\cheers2019
docker build -t kcoewoys/cheers2019:1.0 .
docker run -it --rm kcoewoys/cheers2019:1.0
docker login
docker push kcoewoys/cheers2019:1.0
```

* 更换镜像仓库为阿里云
```bash
docker build -t registry.cn-shenzhen.aliyuncs.com/kcoewoys/cheers2019:1.0 .
docker login --username=kcoewoys@qq.com registry.cn-shenzhen.aliyuncs.com
docker push registry.cn-shenzhen.aliyuncs.com/kcoewoys/cheers2019:1.0
```



## 5. docker配置

* 配置容器Hub服务为阿里     
`$ docker login --username=kcoewoys@qq.com registry.cn-hangzhou.aliyuncs.com`

* 修改daemon配置文件/etc/docker/daemon.json来使用加速器
```
{
      "registry-mirrors": ["https://dd31kyx9.mirror.aliyuncs.com"]
}
```



# 0x03 镜像相关命令

```bash
$ docker search image_name        #搜索镜像
$ docker pull image_name          #下载镜像
$ docker images                   #列出镜像
$ docker rmi image_name           #删除指定镜像
$ docker inspect image_name       #查看镜像的详细信息
$ docker history image_name       #显示一个镜像的历史
```



# 0x04 容器相关命令

```bash
#启动容器
docker run [options] xxx            #新建并运行容器
-d:让容器在后台运行
-P:指定端口映射,主机端口:容器端口
-t:在新容器内指定一个伪终端或终端。
-i:允许你对容器内的标准输入 (STDIN) 进行交互。
-v:指定映射的目录
$ docker run -dp 90:80 nginx       #访问localhost:90
$ docker run image_name echo "hello word"
$ docker run -it image_name /bin/bash
$ docker run image_name apt-get install -y app_name


#查看容器
docker ps                   #列出容器
docker ps -a                #列出所有容器
docker ps -l                #查看正在运行的容器


#对容器的操作
docker create [options] IMAGE
  -a, --attach               # attach stdout/err
  -i, --interactive          # attach stdin (interactive)
  -t, --tty                  # pseudo-tty
      --name NAME            # name your image
  -p, --publish 5000:5000    # port map
      --expose 5432          # expose a port to linked containers
  -P, --publish-all          # publish all ports
      --link container:alias # linking
  -v, --volume `pwd`:/app    # mount (absolute paths needed)
  -e, --env NAME=hello       # env vars
$ docker create --name app_redis_1 --expose 6379 redis:3.0.2

#进入到运行的容器里面
docker exec [options] CONTAINER COMMAND
  -d, --detach        # run in background
  -i, --interactive   # stdin
  -t, --tty           # interactive
$ docker exec app_web_1 tail logs/development.log
$ docker exec -it app_web_1 rails c
$ docker exec -it xxx /bin/bash    #进入容器


docker start [options] CONTAINER    #启动已停止的容器
  -a, --attach        # attach stdout/err
  -i, --interactive   # attach stdin
$ docker stop [options] CONTAINER   #停止容器
$ docker kill Name/ID               #强制停止
$ docker restart Name/ID            # 重启一个正在运行的容器

docker rm Name/ID               #删除容器
docker logs -f Name/ID          #跟踪容器日志
docker top Name/ID        #查看容器内部运行的进程
$docker diff Name/ID        #列出容器里面被改变的文件或者目录
$docker attach ID        # 附加到一个运行的容器上面

docker container ls
docker container kill Name/ID   #杀掉进程
docker container logs Name/ID   #查看容器的日志
```

复制文件

```bash
#从主机复制文件到容器内
docker cp /root/home/test.go ubuntu:/usr/local

#从容器复制文件到主机
docker cp ubuntu:/usr/local/test.go /root/home
```

# 0x05 创建镜像

## 1. 从已经创建的容器中更新镜像

```bash
#保存和加载镜像
$docker save image_name -o file_path    # 保存镜像到一个tar包
$docker save imageId > xx.tar.gz
$docker load -i file_path               # 加载一个tar包格式的镜像
$docker load < xx.tar.gz

$docker push new_image_name             # 发布docker镜像
$docker tag dperson/samba:latest samba:me    #从已有的镜像上增加

$docker commit CONTAINER_ID new_image_name:tag        # 保存对容器的修改
```



## 2. 使用 Dockerfile 指令创建新的镜像

[Dockerfile文档](https://docs.docker.com/engine/reference/builder/)

Dockerfile由一行行命令语句组成，并且支持用“#”开头作为注释，一般的，Dockerfile分为四部分：

* 基础镜像信息
* 维护者信息
* 镜像操作指令
* 容器启动时执行的指令



### Dockerfile指令

```dockerfile
FROM			#基础镜像
MAINTAINET		#指定维护者信息
ENV				#指定环境变量
USER			#指定运行容器时的用户名或 UID
WORKDIR			#后续的 RUN 、 CMD 、 ENTRYPOINT 指令配置工作目录
RUN				#运行命令

ADD				#复制文件，会自动解压
COPY			#复制文件
EXPOSE			#开放端口

VOLUME			#指定本地主机或其他容器挂载的挂载点

CMD				#指定启动容器时默认的执行命令
ENTRYPOINT		#指定启动容器时的执行命令

ONBUILD			#配置当所创建的镜像作为其它新创建镜像的基础镜像时，所执行的操作指令
```



**CMD和ENTRYPOINT**

```dockerfile
#CMD有三种用法：
CMD ["executable","param1","param2"] (exec form, this is the preferred form)
CMD ["param1","param2"] (as default parameters to ENTRYPOINT)
CMD command param1 param2 (shell form)

#ENTRYPOINT有两种用法
ENTRYPOINT ["executable", "param1", "param2"] (exec form, preferred)
ENTRYPOINT command param1 param2 (shell form)

#例dockerfile为下时：
--------------------------
FROM centos
 
CMD ["p in cmd"]
ENTRYPOINT ["echo"]
--------------------------
docker run mydk				#p in cmd
docker run mydk p in run	#p in run
```



### 用Dockerfile创建容器例子

```bash
docker build [options] . -t "app/container_name:tag"    # name
docker build . -t my:1.0 -f Dockerfile    #构建容器
```

`Dockerfile`文件：

```dockerfile
FROM alpine
MAINTAINER David Personette <dperson@gmail.com>

# Install samba
RUN apk --no-cache --no-progress upgrade

COPY samba.sh /usr/bin/

EXPOSE 137/udp 138/udp 139 445

HEALTHCHECK --interval=60s --timeout=15s \
            CMD smbclient -L '\\localhost' -U '%' -m SMB3

VOLUME ["/etc", "/var/cache/samba", "/var/lib/samba", "/var/log/samba",\
            "/run/samba"]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/samba.sh"]
```

构建容器：

```bash
docker build [options] . -t "app/container_name:tag"    # name
docker build . -t my:1.0 -f Dockerfile    				#构建容器
```



# 0x06 其它

## docker的垃圾清理

```bash
#清理容器
$ docker rm `docker ps -aq`
> docker rm $(docker ps -aq)    #windows端用powershell
#清理未使用的镜像
$ docker images -q|xargs docker rmi
> docker rmi $(docker images -q)
#深度清理image
$ docker images|sed '1d'|awk '{print $1":"$2}'|xargs docker rmi

docker image prune	#删除临时镜像
#-f 强制删除；
#-a 删除所有没有用到的镜像
```

## docker镜像过滤查询

```bash
docker images -f "dangling=true"	#找出tag为<none>的
docker images -f "dangling=true" -q	#找出tag为<none>的, 只返回image id

#根据repository名称和tag模糊过滤，我验证时，如果repository有/或小数点符号，通过*是无法匹配的
docker images --filter=reference='busy*:*libc'

#使用before或since根据时间查找，实际上以repository的名字作为时间分隔，
docker images -f "before=image1"
docker images -f "since=image3"

#此外还有label, label=<key> or label=<key>=<value>
docker images --filter "label=com.example.version"
```

## docker格式化输出

--format和go模板搭配可以格式化输出，支持的列名如下：

```bash
--format="TEMPLATE"
Pretty-print containers using a Go template.
Valid placeholders:
.ID - Container ID
.Image - Image ID
.Command - Quoted command
.CreatedAt - Time when the container was created.
.RunningFor - Elapsed time since the container was started.
.Ports - Exposed ports.
.Status - Container status.
.Size - Container disk size.
.Names - Container names.
.Labels - All labels assigned to the container.
.Label - Value of a specific label for this container. For example {{.Label "com.docker.swarm.cpu"}}
.Mounts - Names of the volumes mounted in this container.
```

例如：

```bash
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
```



## 应用记录

```bash
mysql:
docker pull mysql
docker run --name mysql -e MYSQL_ROOT_PASSWORD=root -dp 3306:3306 --restart=always mysql
docker exec -it mysql /bin/bash mysql -uroot -proot 

#解决windows上的连接错误
alter user 'root'@'%' identified with mysql_native_password BY 'root'; 
alter user 'root'@'localhost' identified with mysql_native_password BY 'root';
#修改mysql8的认证方式
mysql --help | grep "Default options" -A 1 
vi /etc/mysql/my.cnf
default-authentication-plugin=mysql_native_password

redis:
docker run --name redis -dp 6379:6379 --restart=always redis
https://hub.docker.com/_/redis

mongo:
docker run --name mongo -dp 27017:27017 --restart=always mongo

portainer:
docker run -dp 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer

music:
docker run --name music --restart always -dp 8890:8080 nondanee/unblockneteasemusic

postgres:
docker run --name postgres -e POSTGRES_PASSWORD=root -dp 5432:5432 postgres
https://hub.docker.com/_/postgres
```

---

docker相关网址：

* [Docker Hub](https://hub.docker.com/ )
* [docker 文档](https://docs.docker.com/ )
* [阿里Hub服务](https://cr.console.aliyun.com )
* [daocloud](https://www.daocloud.io/ )

