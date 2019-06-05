# docker
docker相关网址：
* [Docker Hub]
* [docker 文档]
* [阿里Hub服务]
* [daocloud]

### 0x00 安装Docker
**ubuntu**

`$ sudo apt-get update`     
`$ sudo apt-get install docker-ce docker-ce-cli containerd.io`

安装文档地址：https://docs.docker.com/install/linux/docker-ce/ubuntu/

**mac**

`$ brew cask install docker`

**mac/windows**

下载安装包安装：https://hub.docker.com/?overlay=onboarding

### 0x01 docker测试
* 测试运行hello-world   
`$ docker run hello-world`

* 测试构建镜像
```
git clone https://github.com/docker/doodle.git
cd doodle\cheers2019
docker build -t kcoewoys/cheers2019:1.0 .
docker run -it --rm kcoewoys/cheers2019:1.0
docker login
docker push kcoewoys/cheers2019:1.0
```

* 更换镜像仓库为阿里云
```
docker build -t registry.cn-shenzhen.aliyuncs.com/kcoewoys/cheers2019:1.0 .
docker login --username=kcoewoys@qq.com registry.cn-shenzhen.aliyuncs.com
docker push registry.cn-shenzhen.aliyuncs.com/kcoewoys/cheers2019:1.0
```

### 0x02 docker配置
* 配置容器Hub服务为阿里     
`$ docker login --username=kcoewoys@qq.com registry.cn-hangzhou.aliyuncs.com`

* 修改daemon配置文件/etc/docker/daemon.json来使用加速器
```
{
      "registry-mirrors": ["https://dd31kyx9.mirror.aliyuncs.com"]
}
```

### 0x03 镜像相关命令
```
$ docker search image_name        #搜索镜像
$ docker pull image_name          #下载镜像
$ docker images                   #列出镜像
$ docker rmi image_name           #删除指定镜像
$ docker inspect image_name       #查看镜像的详细信息
$ docker history image_name       #显示一个镜像的历史
```

### 0x04 容器相关命令
```
#启动容器
docker run [options] xxx            #新建并运行容器
-d:让容器在后台运行
-P:指定端口映射
-t:在新容器内指定一个伪终端或终端。
-i:允许你对容器内的标准输入 (STDIN) 进行交互。
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


docker start [options] CONTAINER    #停止容器
  -a, --attach        # attach stdout/err
  -i, --interactive   # attach stdin
$ docker stop [options] CONTAINER   #启动已停止的容器
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

### 0x05 创建镜像
* 从已经创建的容器中更新镜像，并且提交这个镜像

```
#保存和加载镜像
$docker save image_name -o file_path    # 保存镜像到一个tar包
$docker load -i file_path               # 加载一个tar包格式的镜像
$docker push new_image_name             # 发布docker镜像
$docker tag dperson/samba:latest samba:me    #从已有的镜像上增加

$docker commit CONTAINER_ID new_image_name:tag        # 保存对容器的修改
```

* 使用 Dockerfile 指令来创建一个新的镜像

```
docker build [options] . -t "app/container_name:tag"    # name
docker build . -t my:1.0 -f Dockerfile    #构建容器
```

* Dockerfile例子

```
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

### 0x06 其它

* docker的垃圾清理
```
#清理容器
$ docker rm `docker ps -aq`
docker rm $(docker ps -aq)    #windows端用powershell
#清理未使用的镜像
$ docker images -q|xargs docker rmi
#深度清理image
$ docker images|sed '1d'|awk '{print $1":"$2}'|xargs docker rmi
```

---
[Docker Hub]: https://hub.docker.com/
[docker 文档]: https://docs.docker.com/
[阿里Hub服务]: https://cr.console.aliyun.com
[daocloud]: https://www.daocloud.io/
