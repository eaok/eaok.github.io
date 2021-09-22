[toc]



**micro相关网站**

* Micro development framework：https://github.com/micro/go-micro
* Learn Micro by example：https://github.com/micro/examples
* Micro is a microservices runtime：https://github.com/micro/micro
* Micro 中文示例：https://github.com/micro-in-cn/tutorials
* 网站主页：https://micro.mu/



# 0x00 micro安装

安装帮助文档：https://micro.mu/docs/installation.html

## **安装micro框架的依赖**

```bash
# 下载安装protoc
# https://github.com/protocolbuffers/protobuf/releases
wget ....zip
sudo unzip protoc-3.10.0-rc-1-linux-x86_64.zip -d /usr/local/

# 安装protoc-gen-go
go get -u github.com/golang/protobuf/protoc-gen-go

# 安装protoc-gen-micro
go get -u github.com/micro/protoc-gen-micro/v2
```

**代码中使用go-micro框架**

```go
import "github.com/micro/go-micro/v2"
```



## **安装micro工具集**

```bash
go get github.com/micro/micro/v2


# 或者使用源码安装
# Mac OS or Linux
curl -fsSL https://micro.mu/install.sh | /bin/bash

# Windows
powershell -Command "iwr -useb https://micro.mu/install.ps1 | iex"
```



## protoc命令

一般的命令形式：

```bash
$ protoc --proto_path=. --go_out=. --micro_out=. ./proto/user/*.proto
```

* **--proto_path**

  指定编译源码（包括直接编译的和被导入的 proto 文件）的搜索路径，proto 文件中使用 import 关键字导入的路径一定是要基于 --proto_path 参数所指定的路径的。该参数如果不指定，默认为 pwd，也可以指定多个路径。

* **--go_out**

  用来指定 protoc-gen-go 插件的工作方式 和 go 代码目录架构的生成位置

* **--micro_out**

  指定 protoc-gen-micro 生成代码的路径



批量执行脚本格式：

```bash
$ for x in **/*.proto; do protoc --go_out=plugins=grpc,paths=source_relative:. $x; done
```



# 0x01 go-micro框架

go-micro 的作用是简化微服务开发、构建分布式系统。而有些工作是在每个分布式系统中都需要的，所以 go-micro 把这些常见任务统一抽象成接口。这使得开发者不必理会底层实现细节， 降低了学习和开发成本， 快速搭建灵活、健壮的系统。

![](https://cdn.jsdelivr.net/gh/eaok/img/micro/micro_overview.png)

框架为每个组件强定义了接口

![](https://cdn.jsdelivr.net/gh/eaok/img/micro/micro_interface.png)



## 服务发现Registry

这是每个分布式系统首先要解决的问题。go-micro 将此类任务抽象到一个接口中 `github.com/micro/go-micro/registry/Registry` ：

```go
// The registry provides an interface for service discovery
// and an abstraction over varying implementations
// {consul, etcd, zookeeper, ...}
type Registry interface {
   Init(...Option) error
   Options() Options
   Register(*Service, ...RegisterOption) error
   Deregister(*Service) error
   GetService(string) ([]*Service, error)
   ListServices() ([]*Service, error)
   Watch(...WatchOption) (Watcher, error)
   String() string
}
```

在 go-plugins 中已经提供了**很多插件**实现。既有对 etcd / consul / zookeeper 等主流产品的支持，也有基于内存的轻量级实现。默认实现基于组播 DNS(mdns)， 无需任何配置；



## 异步消息broker

异步消息是降低耦合、提高系统鲁棒性的关键技术。与之对应的 go-micro 接口为：`github.com/micro/go-micro/broker/Broker`

```go
// Broker is an interface used for asynchronous messaging.
type Broker interface {
   Init(...Option) error
   Options() Options
   Address() string
   Connect() error
   Disconnect() error
   Publish(topic string, m *Message, opts ...PublishOption) error
   Subscribe(topic string, h Handler, opts ...SubscribeOption) (Subscriber, error)
   String() string
}
```

go-plugins 中已有的 **broker 插件**包括 RabbitMQ, Kafka,NSQ 等，默认实现基于 http，也是无需配置；



## 编解码codec

编解码定义了微服务之间通讯的消息传输格式，对应的接口是：`github.com/micro/go-micro/codec/Codec`

```go
// Codec encodes/decodes various types of messages used within go-micro.
// ReadHeader and ReadBody are called in pairs to read requests/responses
// from the connection. Close is called when finished with the
// connection. ReadBody may be called with a nil argument to force the
// body to be read and discarded.
type Codec interface {
   Reader
   Writer
   Close() error
   String() string
}
```

已有的实现包括 json / bson / msgpack 等等。



## 还有其它方面的接口

- **Server**， 定义微服务的服务器
- **Transport**， 定义传输协议
- **Selector**，定义服务选择逻辑， 可以灵活地实现各种负载均衡策略
- **Wrapper**，定义包装服务器和客户端请求的中间件



# 0x02 micro运行时工具集

![](https://cdn.jsdelivr.net/gh/eaok/img/micro/micro_tools.png)



## micro api

**micro api 特点：**

1. Go-Micro风格服务的网关，负责代理外部请求

2. 不提供统一的接入层，针对不同的微服务类型，提供不同的网关接入{ **HTTP、RPC、API、Event** }

3. 默认基于服务命名空间自动路由，支持 { **Namespace、Host、GRPC** }

服务网关：

<img src="https://cdn.jsdelivr.net/gh/eaok/img/micro/micro_api.png" style="zoom:67%;" />



**api handler类别**

| **类型**        | **说明**                                                     |
| --------------- | ------------------------------------------------------------ |
| rpc             | 通过RPC向go-micro应用转送请求，**只支持**Get/Post。GET转发RawQuery，POST转发Body |
| api             | 与rpc差不多，但是会把完整的http头封装向下传送，**不限制**请求方法 |
| http/proxy，web | 以反向代理的方式使用API，相当于把普通的web应用部署在API之后，让外界像调api接口一样调用web服务，web**显式**支持websocket |
| event           | 代理event事件服务类型的请求                                  |
| meta            | 默认值，元数据，通过在代码中的Endpoint配置选择使用上述中的某一个处理器，默认RPC |



namespace路由规则：

设定micro api的命名空间为：go.micro.api

| **http路径**         | **后台服务**             | **接口方法** |
| -------------------- | ------------------------ | ------------ |
| /learning/hi         | go.micro.api.learning    | Learning.Hi  |
| /learning/greeter/hi | go.micro.api.learning    | Greeter.Hi   |
| /v2/learning/hi      | go.micro.api.v2.learning | Learning.Hi  |



## micro cli

micro cli 基于命令行，与Go-Micro服务交互。

```bash
$ micro cli
$ micro> list services
$ micro> exit 
```

![](https://cdn.jsdelivr.net/gh/eaok/img//micro/micro_cli.png)

主要功能：

1. 服务列表 (micro list services)

2. 服务信息与状态 (micro health/get service xxx)

3. 上下线服务(micro register/deregister)

4. 调用服务



## micro web

Go-Micro服务的管理控制台，Go-Micro风格的Web服务反向代理

启动指令

```bash
micro web
```

<img src="https://cdn.jsdelivr.net/gh/eaok/img/micro/micro_web.png" style="zoom:80%;" />

## micro proxy

功能：提供访问Go-Micro服务代理

它与Micro API不一样的地方在于，API将Go-Micro服务暴露为Http接口，而Proxy的职责则是为不同网络之间Go-Micro服务提供入口互相访问的入口。所以Proxy是可以选择代理的协议的（mucp，grpc，http）

<img src="https://cdn.jsdelivr.net/gh/eaok/img/micro/micro_proxy.png" style="zoom:70%;" />



# 0x03 micro example



```bash
micro new hello --namespace=com.foo
```

- **micro new** 代表调用 micro 工具的 new 命令，创建一个 gRPC 服务
- **hello** 为服务名称
- **--namespace=com.foo** 指定了此服务的名称空间



编译运行

```bash
cd hello
make build
./hello-service
```



生成的项目结构如下：

```bash
.
├── main.go
├── generate.go					#实现与 go generate 命令的集成
├── plugin.go					#建议在这里管理所需 plugin 的导入
├── proto/hello
│   └── hello.proto				#gRPC服务定义文件
│   └── hello.pb.go				#由protoc生成gRPC相关代码
│   └── hello.pb.micro.go		#由protoc-gen-micro生成的
├── handler
│   └── hello.go				#实现 gRPC 业务逻辑的地方
├── subscriber
│   └── hello.go				#实现异步消息接收并处理的地方
├── Dockerfile
├── go.mod
├── go.sum
├── Makefile
└── README.md
```

