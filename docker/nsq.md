[toc]

# nsq介绍和应用场景

## nsq介绍

nsq是Go语言编写的一个开源的实时分布式内存消息队列，其性能十分优异。 NSQ的优势有以下优势：

1. NSQ提倡分布式和分散的拓扑，没有单点故障，支持容错和高可用性，并提供可靠的消息交付保证
2. NSQ支持横向扩展，没有任何集中式代理。
3. NSQ易于配置和部署，并且内置了管理界面。



## nsq应用场景

一般消息队列都适用以下场景：

1. **应用解耦**

   将一个流程加入一层数据接口拆分成两个部分，上游专注通知，下游专注处理，将不同的业务逻辑解耦，降低系统间的耦合，提高系统的健壮性。

   ![](http://blog.maser.top/micro/application_decoupling.png)

   

2. **异步处理**

   上游发送消息以后可以马上返回，处理工作交给下游进行，把业务流程中的非关键流程异步化，可以显著降低业务请求的响应时间。

   ![](http://blog.maser.top/micro/asynchronous_processing.png)

3. 流量削峰

   消息队列有很好的缓冲削峰作用，保证后端服务的稳定性。

   ![](http://blog.maser.top/micro/traffic_buffer.png)



4. 广播，让一个消息被多个下游进行处理

5. 冗余，保存处理的消息，防止消息处理失败导致的数据丢失



## nsq特性

官方给出的文档给出了很多特性的说明，针对于一个MQ来说，下面几个特性有必要知道：

- 默认一开始消息不是持久化的
  nsq采用的方式时内存+硬盘的模式，当内存到达一定程度时就会将数据持久化到硬盘
  1、如果将 --mem-queue-size 设置为 0，所有的消息将会存储到磁盘。
  2、服务器重启也会将当时在内存中的消息持久化
- 消息是没有顺序的
  这一点很关键，由于nsq使用内存+磁盘的模式，而且还有requeue的操作，所以发送消息的顺序和接收的顺序可能不一样
- 官方不推荐使用客户端发消息
  官方提供相应的客户端发送消息，但是HTTP可能更方便一些
- 没有复制
  nsq节点相对独立，节点与节点之间没有复制或者集群的关系。
- 没有鉴权相关模块
  当前release版本的nsq没有鉴权模块，只有版本v0.2.29+高于这个的才有
- 几个小点
  topic名称有长度限制，命名建议用下划线连接；
  消息体大小有限制；



## nsq优缺点

优点：
1、部署极其方便，没有任何环境依赖，直接启动就行
2、轻量没有过多的配置参数，只需要简单的配置就可以直接使用
3、性能高
4、消息不存在丢失的情况

缺点：
1、消息不保证有序
2、节点之间没有消息复制
3、没有鉴权



# 安装和部署

源码地址：https://github.com/nsqio/nsq

部署参考文档：https://nsq.io/deployment/installing.html



## 源码部署

```bash
nohup ./nsqlookupd > /dev/null 2>&1 &
nohup ./nsqd --lookupd-tcp-address=127.0.0.1:4160 > /dev/null 2>&1 &
nohup ./nsqadmin --lookupd-http-address=127.0.0.1:4171 > /dev/null 2>&1 &
```

将test中的消息输出到服务器/tmp目录中

```bash
nsq_to_file --topic=test --output-dir=/tmp --lookupd-http-address=127.0.0.1:4161
```



## docker部署

```bash
#获取镜像
docker pull nsqio/nsq

#运行lookupd
docker run -d --name lookupd -p 4160:4160 -p 4161:4161 nsqio/nsq /nsqlookupd

#获取docker host的IP地址
docker inspect -f '{{ .NetworkSettings.IPAddress }}' lookupd

#运行nsqd
# --broadcast-address=广播到虚拟机地址
docker run -d --name nsqd -p 4150:4150 -p 4151:4151 \
	nsqio/nsq /nsqd \
	--broadcast-address=172.17.0.1 \
	--lookupd-tcp-address=172.17.0.2:4160

#运行nsqadmin
docker run -d --name nsqadmin -p 4171:4171 nsqio/nsq /nsqadmin  --lookupd-http-address=172.17.0.2:4161
```



## docker-compose部署

创建docker-compose.yml

```yaml
version: '2'
services:

  nsqlookupd:
    image: nsqio/nsq
    command: /nsqlookupd
    networks:
      - nsq-network
    hostname: nsqlookupd
    ports:
      - "4161:4161"
      - "4160:4160"
      
  nsqd:
    image: nsqio/nsq
    # -broadcast-address=宿主机地址 
    command: /nsqd --lookupd-tcp-address=nsqlookupd:4160 -broadcast-address=172.17.0.1
    depends_on:
      - nsqlookupd
    hostname: nsqd
    networks:
      - nsq-network
    ports:
      - "4151:4151"
      - "4150:4150"
      
  nsqadmin:
    image: nsqio/nsq
    command: /nsqadmin --lookupd-http-address=nsqlookupd:4161
    depends_on:
      - nsqlookupd
    hostname: nsqadmin
    ports:
      - "4171:4171"
    networks:
      - nsq-network
 
networks:
  nsq-network:
    driver: bridge
```

配置检查

```bash
docker-compose config
```

启动 docker-compose

```bash
docker-compose up -d
```



# nsq架构

## nsq组件

NSQ主要包含3个组件：

- nsqd：在服务端运行的守护进程，负责接收，排队，投递消息给客户端；
- nsqlookupd：负责管理拓扑信息并提供发现服务；
- nsqadmin：一套WEB UI，用来汇集集群的实时统计，并执行不同的管理任务；



### nsqd

启动nsqd

```bash
$ nsqd

#在搭配nsqlookupd使用的模式下需要还指定nsqlookupd地址
$ nsqd --lookupd-tcp-address=127.0.0.1:4160

#指定广播地址，默认为hostname,同一台机器开启多个需要设置成不同ip
$ nsqd --lookupd-tcp-address=127.0.0.1:4160 --broadcast-address=127.0.0.1

#指定消息存储的路径，同一台机器开启多个需要设置成不同路径
$ nsqd -data-path="/temp/nsq"

#设置单条消息的最大字节数，如果消息超过这个字节数将被丢弃。
$ nsqd -max-msg-size=50000000
```

nsqd监听了两个端口

**4151** HTTP Producer使用**HTTP协议**的curl等工具生产数据；Consumer使用**HTTP协议**的curl等工具消费数据；
**4150** TCP Producer使用**TCP协议**的nsq-j等工具生产数据；Consumer使用**TCP协议**的nsq-j等工具消费数据；

```bash
$ curl -d 'hello world' 'http://127.0.0.1:4151/pub?topic=test'
```



### nsqlookupd

启动nsqlookupd

```bash
$ nsqlookupd
```



nsqlookupd会监听两个端口： 

**4160** TCP 用于接收nsqd的广播，记录nsqd的地址以及监听TCP/HTTP端口等。
**4161** HTTP 用于接收客户端发送的管理和发现操作请求(增删话题,节点等管理查看性操作等)。当Consumer进行连接时，返回对应存在Topic的nsqd列表。



### nsqadmin

启动nsqadmin

```bash
$ nsqadmin --lookupd-http-address=127.0.0.1:4161
```



nsqadmin监听一个端口：

**4171** HTTP 用于管理页面



## nsq工作模式

![](http://blog.maser.top/micro/nsq_work_flow.png)



## Topic和Channel

每个nsqd实例旨在一次处理多个数据流。这些数据流称为`Topics`，一个`Topic`具有1个或多个`“channels”`。每个`channel`都会收到`topic`所有消息的副本，下游的服务就是通过对应的`channel`来消费`Topic`消息。

`topic`和`channel`不是预先配置的。`topic`在首次使用时创建，方法是将其发布到指定`topic`，或者订阅指定`topic`上的`channel`。`channel`是通过订阅指定的`channel`在第一次使用时创建的。

`topic`和`channel`都相互独立地缓冲数据，防止缓慢的消费者导致其他`chennel`的积压（同样适用于`topic`级别）。

`channel`可以并且通常会连接多个客户端。假设所有连接的客户端都处于准备接收消息的状态，则每条消息将被传递到随机客户端。例如：

![](http://blog.maser.top/micro/nsqd_channels.gif)



**注意**：

Consumer与Topic没有直接联系，而是通过具体的Channel接受数据。如果Consumer退出，Channel不会自动删除。 如果不再需要，需要通过http端口删除Channel，否则很可能会导致磁盘空间不足。





# nsq客户端

官方提供了很多语言接入的客户端 https://nsq.io/clients/client_libraries.html


针对消息生产者的客户端，官方推荐直接使用post请求发送消息，如：向test主题发送hello world这个消息

```bash
curl -d 'hello world' 'http://127.0.0.1:4151/pub?topic=test'
```



## 使用`go-nsq`客户端

producer

```go
package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"

	nsq "github.com/nsqio/go-nsq"
)

var producer *nsq.Producer

// 初始化生产者
func initProducer(str string) (err error) {
	config := nsq.NewConfig()
	producer, err = nsq.NewProducer(str, config)
	if err != nil {
		fmt.Printf("create producer failed, err:%v\n", err)
		return err
	}
	return nil
}

func main() {
	nsqAddress := "127.0.0.1:4150"
	err := initProducer(nsqAddress)
	if err != nil {
		fmt.Printf("init producer failed, err:%v\n", err)
		return
	}

	reader := bufio.NewReader(os.Stdin) // 从标准输入读取

	fmt.Println("Please input:")
	for {
		data, err := reader.ReadString('\n')
		if err != nil {
			fmt.Printf("read string from stdin failed, err:%v\n", err)
			continue
		}
		data = strings.TrimSpace(data)
		if strings.ToUpper(data) == "Q" { // 输入Q退出
			break
		}

		// 向 'topic_demo' publish 数据
		err = producer.Publish("topic_demo", []byte(data))
		if err != nil {
			fmt.Printf("publish msg to nsq failed, err:%v\n", err)
			continue
		}
	}
}
```



consumer

```go
package main

import (
	"fmt"
	"os"
	"os/signal"
	"syscall"
	"time"

	nsq "github.com/nsqio/go-nsq"
)

// MyHandler 是一个消费者类型
type MyHandler struct {
	Title string
}

// HandleMessage 是需要实现的处理消息的方法
func (m *MyHandler) HandleMessage(msg *nsq.Message) (err error) {
	fmt.Printf("%s recv from %v, msg:%v\n", m.Title, msg.NSQDAddress, string(msg.Body))
	return
}

// 初始化消费者
func initConsumer(topic string, channel string, address string) (err error) {
	config := nsq.NewConfig()
	config.LookupdPollInterval = 15 * time.Second
	c, err := nsq.NewConsumer(topic, channel, config)
	if err != nil {
		fmt.Printf("create consumer failed, err:%v\n", err)
		return
	}
	consumer := &MyHandler{
		Title: "gggggg",
	}
	c.AddHandler(consumer)

	// if err := c.ConnectToNSQD(address); err != nil { // 直接连NSQD
	if err := c.ConnectToNSQLookupd(address); err != nil { // 通过lookupd查询
		return err
	}
	return nil
}

func main() {
	err := initConsumer("topic_demo", "first", "127.0.0.1:4161")
	if err != nil {
		fmt.Printf("init consumer failed, err:%v\n", err)
		return
	}
	c := make(chan os.Signal)        // 定义一个信号的通道
	signal.Notify(c, syscall.SIGINT) // 转发键盘中断信号到c
	<-c                              // 阻塞
}
```



参考

https://www.cnblogs.com/linkstar/p/10341685.html

https://www.cnblogs.com/zhaohaiyu/p/11826080.html