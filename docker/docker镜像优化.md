[toc]

# 一、使用更小的基础镜像

## 1. 用Alpine作为基础镜像

```bash
#alpine安装包程序用apk
```

[Alpine](https://yeasy.gitbooks.io/docker_practice/content/cases/os/alpine.html)



## 2. 使用distroless

“Distroless”镜像只包含应用程序及其运行时依赖。不包含包管理器、Shell以及其他标准Linux发行版中能找到的其他程序。

https://github.com/GoogleContainerTools/distroless

```dockerfile
FROM  golang:1.14 as build-env
ENV GOPROXY=https://goproxy.cn,direct
WORKDIR /home/docker
COPY . .
RUN make

FROM gcr.io/distroless/base
LABEL MAINTAINER="kcoewoys"
EXPOSE 8888
COPY --from=build-env /home/docker/dogo /home/docker/dogo
CMD ["/home/docker/dogo"]
```



**里面的镜像需要翻墙，所以仅参考**



## 3. 用scratch作为基础镜像

1. 交叉编译，只放二进制文件

2. 放基础工具来重新构建镜像

   https://www.cnblogs.com/sap-jerry/p/10029824.html

这两种使用太麻烦，可以使用多重构建的方式，并把scratch作为最终的基础镜像；

```dockerfile
FROM  golang:latest as build-env
ENV GOPROXY=https://goproxy.cn,direct CGO_ENABLED=0
WORKDIR /home/docker
COPY . .
RUN make

FROM scratch
LABEL MAINTAINER="kcoewoys"
EXPOSE 8888
COPY --from=build-env /home/docker/dogo /
CMD ["/dogo"]
```



使用alpine和scratch的时候，可能会遇到go的动态链接的在微型镜像上不支持的问题：

1. 默认go使用静态链接，在docker的golang环境中默认是使用动态编译。
2. 如果想使用docker编译+alpine部署，可以通过禁用cgo`CGO_ENABLED=0`来解决。
3. 如果要使用cgo可以通过`go build --ldflags "-extldflags -static"` 来让gcc使用静态编译。



# 二、清除缓存依赖包

## 清除非必要的包

```bash
RUN apk add --no-cache <package>
--no-cache #表示不再本地存储安装包

RUN apk add --no-cache --virtual .build git
RuN apk del .build
--virtual #表示先安装在一个虚拟包，方便删除
```



## 多阶段构建

Multi-stage build 即在一个 Dockerfile 中使用多个 FROM 指令，每个 FROM 指令可以使用不同的基础镜像，并且每一个都开启新的构建阶段，最终只留下需要的东西。

[distroless](#2. 使用distroless)也是这样做的

```dockerfile
FROM  golang:latest
ENV GOPROXY=https://goproxy.cn,direct CGO_ENABLED=0
WORKDIR /home/docker
COPY . .
RUN make

FROM alpine:latest
LABEL MAINTAINER="kcoewoys"
EXPOSE 8888
COPY --from=0 /home/docker/dogo /home/docker/
CMD ["/home/docker/dogo"]
```



## 使用docker-slim工具

[docker-slim](https://github.com/docker-slim/docker-slim)通过静态分析跟动态分析来实现镜像的缩小，在没有修改镜像内容前提下，可以缩小30倍。

**静态分析**
通过docker镜像自带镜像历史信息,获取生成镜像的dockerfile文件及相关的配置信息。

**动态分析**
通过内核工具ptrace(跟踪系统调用)、pevent(跟踪文件或目录的变化)、fanotify(跟踪进程)解析出镜像中必要的文件和文件依赖，将对应文件组织成新镜像。



例如：

```bash
docker-slim build --http-probe image:tag
```



# 三、减少镜像的层数

使用链式代码“&&”把多行指令结合成一行，但是构建过程会比多个RUN时更慢。



压缩命令压缩镜像



# 四、总结

* 开发 Dockerfile 时分别 RUN 每条命令，目的是分层减少重新 build 的时间，开发好了合并 RUN 为一条，减少分层。
* 使用多层构建的方式，最终用`scratch`或者`alpine`作为基础镜像；