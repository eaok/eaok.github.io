[toc]



# rpc概述

rpc(Remote Procedure Call Protocol)，通过网络从远程计算机程序上请求服务，隐藏了底层网络技术，是一个技术思想



rpc调用过程

![](https://cdn.jsdelivr.net/gh/eaok/img/micro/rpc.png)

客户端（Client）：服务的调用方
服务端（Server）：真正的服务提供者
客户端存根：存放服务端的地址消息，再将客户端的请求参数打包成网络消息，然后通过网络远程发送给服务方
服务端存根：接收客户端发送过来的消息，将消息解包，并调用本地的方法



rpc的实现

go原生rpc
grpc：Google开源的rpc实现
thrift：Facebook开源的跨语言的服务开发框架
dubbo：阿里开源的rpc框架



# go内置的rpc

Go标准包中已经提供了了对RPC的支持，而且支持三个级别的RPC：TCP、HTTP、JSONRPC。但Go的RPC它只支持Go开发的服务器与客户端之间的交互，因为在内部它们采用了了Gob编码。



Go RPC的函数格式

```go
// T、T1和T2类型必须能被`encoding/gob`包编解码。
func (t *T) MethodName(argType T1, replyType *T2) error 
```



## http demo

server

```go
type Args struct {
	A, B int
}

type Arith int

func (t *Arith) Multiply(args Args, reply *int) error {
	*reply = args.A * args.B
	return nil
}

func main() {
	arith := new(Arith)
	rpc.Register(arith)
	rpc.HandleHTTP()

	err := http.ListenAndServe(":1234", nil)
	if err != nil {
		fmt.Println(err.Error())
	}
}
```

client

```go
type Args struct {
	A, B int
}

func main() {
	if len(os.Args) != 2 {
		fmt.Println("Usage: ", os.Args[0], "server:port")
		os.Exit(1)
	}
	serverAddress := os.Args[1]

	client, err := rpc.DialHTTP("tcp", serverAddress)
	if err != nil {
		log.Fatal("dialing:", err)
	}

	// Synchronous call
	args := Args{17, 8}
	var reply int
	err = client.Call("Arith.Multiply", args, &reply)
	if err != nil {
		log.Fatal("arith error:", err)
	}
	fmt.Printf("Arith: %d*%d=%d\n", args.A, args.B, reply)
}
```

```
.\client.exe 127.0.0.1:1234
```



## tcp demo

server

```go
type Args struct {
	A, B int
}

type Arith int

func (t *Arith) Multiply(args Args, reply *int) error {
	fmt.Printf("Multiply: %v\n", time.Now())
	// time.Sleep(10 * time.Second)
	*reply = args.A * args.B
	return nil
}

func main() {
	arith := new(Arith)
	rpc.Register(arith)

	tcpAddr, err := net.ResolveTCPAddr("tcp", ":1234")
	checkError(err)

	listener, err := net.ListenTCP("tcp", tcpAddr)
	checkError(err)

	for {
		fmt.Printf("accept at %v\n", time.Now())
		conn, err := listener.Accept()
		if err != nil {
			continue
		}
		fmt.Printf("get at %v\n", time.Now())
		rpc.ServeConn(conn)
	}
}

func checkError(err error) {
	if err != nil {
		fmt.Println("Fatal error ", err.Error())
		os.Exit(1)
	}
}
```

client

```go
type Args struct {
	A, B int
}

func main() {
	if len(os.Args) != 2 {
		fmt.Println("Usage: ", os.Args[0], "server:port")
		os.Exit(1)
	}
	serverAddress := os.Args[1]

	client, err := rpc.Dial("tcp", serverAddress)
	if err != nil {
		log.Fatal("dialing:", err)
	}
    
	// Synchronous call
	args := Args{17, 8}
	var reply int
	err = client.Call("Arith.Multiply", args, &reply)
	if err != nil {
		log.Fatal("arith error:", err)
	}
	fmt.Printf("Arith: %d*%d=%d\n", args.A, args.B, reply)
}
```

```
.\client.exe 127.0.0.1:1234
```







# grpc

gRPC网址：https://www.grpc.io/

gRPC文档中文版：http://doc.oschina.net/grpc

安装gRPC package

```bash
go get -u google.golang.org/grpc
```



grpc是Google开源的rpc实现，与许多RPC系统类似，gRPC里客户端应用可以像调用本地对象一样直接调用另一台机器上服务端应用的方法，使得开发者能够更容易地创建分布式应用和服务。

gRPC默认使用protoBuf，这是 Google 开源的一套成熟的结构数据序列化机制(当然也可以使用其他数据格式如 JSON )。



生成go代码

```bash
protoc --go_out=plugins=grpc:. *.proto
```



基本demo	见`rpc/grpc/base`

双向数据流demo	见`rpc/grpc/gidstream`





gRPC主要有4种请求／响应模式，分别是：
1. 简单模式（Simple RPC）
客户端发起一次请求，服务端响应一个数据，即标准RPC通信。
2. 服务端数据流模式（Server-side streaming RPC）
这种模式是客户端发起一次请求，服务端返回一段连续的数据流。典型的例子是客户端向服务端发送一个股票代码，服务端就把该股票的实时数据源源不断的返回给客户端。
3. 客户端数据流模式（Client-side streaming RPC）
与服务端数据流模式相反，这次是客户端源源不断的向服务端发送数据流，而在发送结束后，由服务端返回一个响应。典型的例子是物联网终端向服务器报送数据。
4. 双向数据流模式（Bidirectional streaming RPC）
这是客户端和服务端都可以向对方发送数据流，这个时候双方的数据可以同时互相发送，也就是可以实现实时交互。比如聊天应用。