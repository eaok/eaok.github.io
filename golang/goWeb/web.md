[TOC]

## 一、现代Web服务

### 1. Web⼯作⽅式

**普通的上网过程：**

> 浏览器本身是⼀个客户端，当你输⼊URL的时候，⾸先浏览器会去请求DNS服务器，通过DNS获取相应的域名对应的IP，然后通过IP地址找到IP对应的服务器后，要求建⽴TCP连接，等浏览器发送完HTTP Request（请求）包后，服务器接收到请求包之后才开始处理请求包，服务器调⽤⾃身服务，返回HTTP Response（响应）包；客户端收到来⾃服务器的响应后开始渲染这个Response包⾥的主体（body），当解析到HTML DOM⾥ ⾯的图⽚连接，css脚本和js脚本的连接，浏览器会⾃动发起⼀个请求静态资源的HTTP请求，获取 相应静态资源，然后浏览器会渲染出来，最终将所有资源整合、渲染、完整展现在屏幕上。(⽹⻚ 优化有⼀向措施是减少HTTP请求次数，把尽量多的css和js资源合并在⼀起)。等收到全部的内容随后断开与该服务器之间的TCP连接。

![](https://cdn.jsdelivr.net/gh/eaok/img/web/goweb/webProcess.png)

### 2. url

 URL (Uni form Resource Locator)是“统⼀资源定位符” 的英⽂缩写，基本格式如下

```go
[scheme:][//[userinfo@]host][/]path[?query][#fragment]
例如：
    https://ls:password@www.lianshiclass.com/posts?page=1&count=10#fmt
```

* `scheme` ：协议名，常⻅的有 http/https/ftp ； 
* `userInfo` ：若有，则表示⽤户信息，如⽤户名和密码可写作 ls:password ； 
* `host `：表示主机域名或地址，和⼀个可选的端⼝信息。若端⼝未指定，则默认为 80。例如 www.example.com ， www.example.com:8080 ， 127.0.0.1:8080 ； 
* `path` ：资源在主机上的路径，以 / 分隔，如 /posts ； 
* `query `：可选的查询字符串，客户端传输过来的键值对参数，键值直接⽤ = ，多个键值对之间 ⽤ & 连接，如 page=1&count=10 ； 
* `fragment`：⽚段，⼜叫锚点。表示⼀个⻚⾯中的位置信息。由浏览器发起的请求 URL 中，通常 没有这部分信息。但是可以通过 ajax 等代码的⽅式发送这个数据；



**uri url urn**

> URI：uniform resource identifier， 统⼀资源标识符，⽤来唯⼀的标识⼀个资源。 
>
> URL：uniform resource locator， 统⼀资源定位器，它是⼀种具体的URI，即URL可以⽤来标识 ⼀个资源，⽽且还指明了如何locate这个资源。
>
> URN：uniform resource name， 统⼀资源命名，是通过名字来标识资源，⽐如mailto:lianshi@l ianshiclass.com。 也就是说，URI是以⼀种抽象的，⾼层次概念定义统⼀资源标识，⽽URL和URN则是具体的资源标 识的⽅式。URL和URN都是⼀种URI。



### 3. dns

**DNS解析过程**

![](https://cdn.jsdelivr.net/gh/eaok/img/web/goweb/DNSparse .png)

1. 检查浏览器缓存中是否缓存过该域名对应的IP地址
2. 如果在浏览器缓存中没有找到IP，那么将继续查找本机系统是否缓存过IP
3. 向本地域名解析服务系统发起域名解析的请求，此解析具有权威性。 
4. 向根域名解析服务器发起域名解析请求。 
5. 根域名服务器返回gTLD域名解析服务器地址。 
6. 向gTLD服务器发起解析请求
7. gTLD服务器接收请求并返回Name Server服务器
8. Name Server服务器返回IP地址给本地服务器
9. 本地域名服务器缓存解析结果
10. 返回解析结果给用户



### 4. http协议

#### 什么是HTTP协议

> HTTP协议是Hyper Text Transfer Protocol（超⽂本传输协议）的缩写，是⼀个基于TCP/IP通信协议来传
> 递数据，服务器传输超⽂本到本地浏览器的传送协议，是⼀个⽆状态的请求/响应协议，同⼀个客户端的每个请求之间没有关联，对HTTP服务器来说，它并不知道这两个请求是否来⾃同⼀个客户端。为了解决这个问题引⼊了cookie机制来维护链接的可持续状态。

#### HTTP请求包

HTTP请求包的结构：

![](https://cdn.jsdelivr.net/gh/eaok/img/web/goweb/httpRequest.png)

请求包例子：

```go
GET http://edu.kongyixueyuan.com/ HTTP/1.1 //请求⾏: 请求⽅法请求URI HTTP协议/ 协议版本
Accept: application/x-ms-application, image/jpeg, application/xaml+xml,
image/gif, image/pjpeg, application/x-ms-xbap, //客户端能接收的数据格式
Accept-Language: zh-CN
User-Agent: Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Win64; x64;
Trident/4.0; .NET CLR 2.0.50727; SLCC2; .NET CLR 3.5.30729; .NET CLR 3.0.30729;
Media Center PC 6.0; .NET4.0C; .NET4.0E)
UA-CPU: AMD64
Accept-Encoding: gzip, deflate 	//是否⽀持流压缩
Host: edu.kongyixueyuan.com 	//服务端的主机名
Connection: Keep-Alive
//空⾏，⽤于分割请求头和消息体
//消息体,请求资源参数,例如POST传递的参数
```



#### HTTP响应包

![](https://cdn.jsdelivr.net/gh/eaok/img/web/goweb/httpResponse.png)

响应包的例⼦：

```go
HTTP/1.1 200 OK 						//状态⾏
Server: nginx 							//服务器使⽤的WEB软件名及版本
Content-Type: text/html; charset=UTF-8  //服务器发送信息的类型
Connection: keep-alive 					//保持连接状态
Set-Cookie: PHPSESSID=mjup58ggbefu7ni9jea7908kub; path=/; HttpOnly
Cache-Control: no-cache
Date: Wed, 14 Nov 2018 08:27:32 GMT 	//发送时间
Content-Length: 99324 					//主体内容⻓度
 										//空⾏⽤来分割消息头和主体
<!DOCTYPE html>... 						//消息体
```

HTTP/1. 1协议中定义了5类状态码，状态码由三位数字组成，第⼀个数字定义了响应的类别。

* 1XX 提示信息⼀表示请求已被成功接收，继续处理 

* 2XX 成功⼀表示请求已被成功接收，理解，接受 

* 3XX 重定向-要完成请求必须进⾏更进⼀步的处理 

* 4XX 客户端错误-请求有语法错误或请求⽆法实现 

* 5XX 服务器端错误-服务器未能实现合法的请求

常⻅状态码：

```go
200 OK //客户端请求成功
400 Bad Request //客户端请求有语法错误，不能被服务器所理解
401 Unauthorized //请求未经授权，这个状态代码必须和WWWAuthenticate报头域⼀起使⽤
403 Forbidden //服务器收到请求，但是拒绝提供服务
404 Not Found //请求资源不存在，eg：输⼊了错误的URL
500 Internal Server Error //服务器发⽣不可预期的错误
503 Server Unavailable //服务器当前不能处理客户端的请求，⼀段时间后可能恢复正常
```

HTTP协议是⽆状态的和Connection: keep alive的区别

> **⽆状态**是指协议对于事务处理没有记忆能⼒，服务器不知道客户端是什么状态。从另⼀⽅⾯讲，打开⼀个服务器上的⽹⻚和你之前打开这个服务器上的⽹⻚之间没有任何联系。 HTTP是⼀个⽆状态的⾯向连接的协议，⽆状态不代表HTTP不能保持TCP连接，更不能代表HTTP使⽤的是UDP协议(⾯对⽆连接)。
>
> 从HTTP/1.1起，默认都开启了Keep-Alive保持连接特性，简单地说，当⼀个⽹⻚打开完成后，客户端和服务器之间⽤于传输HTTP数据的TCP连接不会关闭，如果客户端再次访问这个服务器上的⽹⻚，会继续使⽤这⼀条已经建⽴的TCP连接。 Keep-Alive不会永久保持连接，它有⼀个保持时间，可以在不同服务器软件(如Apache) 中设置这个时间。

#### 请求⽅法

HTTP1.0定义了三种请求⽅法： GET, POST 和HEAD⽅法。 

HTTP1.1新增了五种请求⽅法：OPTIONS, PUT, DELETE, TRACE 和 CONNECT ⽅法。

```go
GET 		请求指定的⻚⾯信息，并返回实体主体。
HEAD 		⽤于获取报头，可以检查链接的可访问性及资源是否修改。
POST 		向指定资源提交数据进⾏处理请求（例如提交表单或者上传⽂件）。数据被包含在请求体中。POST请求可能会导致新的资源的建⽴和/或已有资源的修改。
PUT 		从客户端向服务器传送的数据取代指定的⽂档的内容。
DELETE 		请求服务器删除指定的⻚⾯。
CONNECT 	HTTP/1.1协议中预留给能够将连接改为管道⽅式的代理服务器。
OPTIONS 	允许客户端查看服务器的性能。
TRACE 		回显服务器收到的请求，主要⽤于测试或诊断。
```

GET和POST的区别：

> * GET在浏览器回退时是⽆害的，⽽POST会再次提交请求。 
> * GET产⽣的URL地址可以被Bookmark，⽽POST不可以。 
> * GET请求会被浏览器主动cache，⽽POST不会，除⾮⼿动设置。 
> * GET请求只能进⾏url编码，⽽POST⽀持多种编码⽅式。 
> * GET请求参数会被完整保留在浏览器历史记录⾥，⽽POST中的参数不会被保留。 
> * GET请求在URL中传送的参数是有⻓度限制的，⽽POST没有。 
> * 对参数的数据类型，GET只接受ASCII字符，⽽POST没有限制。 
> * GET⽐POST更不安全，因为参数直接暴露在URL上，所以不能⽤来传递敏感信息。 
> * GET参数通过URL传递，POST放在Request body中。
> * GET 产⽣⼀个TCP数据包；POST产⽣两个TCP数据包。对于GET⽅式的请求，浏览器会把http header和data ⼀并发送出去，服务器响应200（返回数据）；⽽对于POST，浏览器先发送header，服务器响应100 continue，浏览器再发送data，服务器响应200 ok（返回数据））

#### HTTPS通信原理

HTTPS（Secure Hypertext Transfer Protocol）安全超⽂本传输协议；HTTP是应⽤层协议，TCP是传输层协议，在应⽤层和传输层之间，增加了⼀个安全套接层SSL

![](https://cdn.jsdelivr.net/gh/eaok/img/web/goweb/https.png)

服务器 ⽤RSA⽣成公钥和私钥，把公钥放在证书⾥发送给客户端，私钥⾃⼰保存；客户端⾸先向⼀个权威的
服务器检查证书的合法性，如果证书合法，客户端产⽣⼀段随机数，这个随机数就作为通信的密钥，我们称之为对称密钥，⽤公钥加密这段随机数，然后发送到服务器服务器⽤密钥解密获取对称密钥，然后双⽅就以对称密钥进⾏加密解密通信了。

Https的作⽤

* 内容加密 建⽴⼀个信息安全通道，来保证数据传输的安全； 
* 身份认证 确认⽹站的真实性 数据完整性 
* 防⽌内容被第三⽅冒充或者篡改

Https和Http的区别

* https协议需要到CA申请证书。 
* http是超⽂本传输协议，信息是明⽂传输；https 则是具有安全性的ssl加密传输协议。 
* http和https使⽤的是完全不同的连接⽅式，⽤的端⼝也不⼀样，前者是80，后者是443。 
* http的连接很简单，是⽆状态的；HTTPS协议是由SSL+HTTP协议构建的可进⾏加密传输、身份认证的⽹络协议，⽐http协议安全。

### 5. tcp/udp

ip tcp/udp http三者的区别

> IP协议对应⽹络层，TCP协议对应于传输层，⽽http协议对应于应⽤层，从本质上来说，三者是不同层⾯的东⻄，如果打个⽐⽅的话，IP就像⾼速公路，TCP就如同卡 ⻋，http就如同货物，货物要装载在卡⻋并通过⾼速公路才能从⼀个地点送到另⼀个地点。

TCP与UDP的区别

> TCP 传输控制协议，是⼀种⾯向连接的、可靠的、基于字节流的传输层通信协议。（类似于打电话）TCP⾸部开销20字节，TCP只能是点 到点的连接，
>
> UDP ⽤户数据报协议是⼀种⽆连接的传输层协议，提供⾯向事务的简单不可靠信息传送服务。（类似于发短信）UDP⾸部开销8字节，UDP⽀持⼀对⼀，⼀对多，多对⼀，多对多的交互通信
>
> TCP适合传输数据，UDP适合流媒体

TCP连接断开过程

> ![](https://cdn.jsdelivr.net/gh/eaok/img/web/goweb/tcp.png)

### 6. Socket

我们利⽤ip地址＋协议＋端⼝号唯⼀标示⽹络中的⼀个进程，让后就可以利⽤socket进⾏通信了；socket是⼀种"打开—读/写—关闭"模式的实现，服务器和客户端各⾃维护⼀个"⽂件"，在建⽴连接打开后，可以向⾃⼰⽂件写⼊内容供对⽅读取或者读取对⽅内容，通讯结束时关闭⽂件。

![](https://cdn.jsdelivr.net/gh/eaok/img/web/goweb/socket.png)

Socket通信流程⼤概是下图这样的：

![](https://cdn.jsdelivr.net/gh/eaok/img/web/goweb/socketFlow.png)

Go代码示例

> 服务端：
>
> ```go
> // 处理函数
> func process(conn net.Conn) {
> 	defer conn.Close() // 关闭连接
> 	for {
> 		reader := bufio.NewReader(conn)
> 		var buf [128]byte
> 		n, err := reader.Read(buf[:]) // 读取数据
> 		if err != nil {
> 			fmt.Println("read from client failed, err:", err)
> 			break
> 		}
> 		recvStr := string(buf[:n])
> 		fmt.Println("收到client端发来的数据：", recvStr)
> 		conn.Write([]byte(recvStr)) // 发送数据
> 	}
> }
> 
> func main() {
> 	listen, err := net.Listen("tcp", "127.0.0.1:20000")
> 	if err != nil {
> 		fmt.Println("listen failed, err:", err)
> 		return
> 	}
> 	for {
> 		conn, err := listen.Accept() // 建⽴连接
> 		if err != nil {
> 			fmt.Println("accept failed, err:", err)
> 			continue
> 		}
> 		go process(conn) // 启动⼀个goroutine处理连接
> 	}
> }
> ```
>
> 客户端：
>
> ```go
> func main() {
> 	conn, err := net.Dial("tcp", "127.0.0.1:20000")
> 	if err != nil {
> 		fmt.Println("err :", err)
> 		return
> 	}
> 	defer conn.Close() // 关闭连接
> 	inputReader := bufio.NewReader(os.Stdin)
> 	for {
> 		input, _ := inputReader.ReadString('\n') // 读取⽤户输⼊
> 		inputInfo := strings.Trim(input, "\r\n")
> 		if strings.ToUpper(inputInfo) == "Q" { // 如果输⼊q就退出
> 			return
> 		}
> 		_, err = conn.Write([]byte(inputInfo)) // 发送数据
> 		if err != nil {
> 			return
> 		}
> 		buf := [512]byte{}
> 		n, err := conn.Read(buf[:])
> 		if err != nil {
> 			fmt.Println("recv failed, err:", err)
> 			return
> 		}
> 		fmt.Println(string(buf[:n]))
> 	}
> }
> ```



### 7. WebSocket

WebSocket protocol 是HTML5⼀种新的协议。它实现了浏览器与服务器全双⼯通信，能更好的节省服
务器资源和带宽并达到实时通讯它建⽴在TCP之上，同 HTTP⼀样通过TCP来传输数据。WebSocket同
HTTP⼀样也是应⽤层的协议，并且⼀开始的握⼿也需要借助HTTP请求完成。

![](https://cdn.jsdelivr.net/gh/eaok/img/web/goweb/httpVsWebsocket.png)

WebSocket和HTTP最大的不同点

> WebSocket 是⼀种双向通信协议，在建⽴连接后，WebSocket 服务器和 Browser/Client Agent 都 能主动的向对方发送或接收数据，就像 Socket ⼀样； 
>
> WebSocket 需要类似 TCP 的客户端和服务器端通过握手连接，连接成功后才能相互通信。

### 8. RPC

Remote Procedure Call 远程过程调⽤ 它是⼀种通过⽹络从远程计算机程序上请求服务，⽽不需要了解底层⽹络技术的协议。RPC协议假定某些传输协议的存在，如TCP或UDP，为通信程序之间携带信息数据。在OSI⽹络通信模型中，RPC跨越了传输层和应⽤层。RPC使得开发包括⽹络分布式多程序在内的应⽤程序更加容易。

⼀个完整的RPC架构⾥⾯包含了四个核⼼的组件，分别是Client,Server,Client Stub以及Server Stub，这个Stub⼤家可以理解为存根。

> ![](https://cdn.jsdelivr.net/gh/eaok/img/web/goweb/rpc.png)

RPC vs HTTP

> * 论复杂度，RPC框架肯定是⾼于简单的HTTP接⼝的。但毋庸置疑，HTTP接⼝由于受限于HTTP协 议，需要带HTTP请求头，还有三次握⼿，导致传输起来效率或者说安全性不如RPC。 
> * HTTP是⼀种协议,RPC可以通过HTTP来实现,也可以通过Socket⾃⼰实现⼀套协议来实现. 
> * RPC更是⼀个软件结构概念，是构建分布式应⽤的理论基础。就好⽐为啥你家可以⽤到发电⼚发出 来的电？是因为电是可以传输的。⾄于⽤铜线还是⽤铁丝还是其他 种类的导线，也就是⽤http还 是⽤其他协议的问题了。

### 9. Rest & Restful

Rest全称是Representational State Transfer，中⽂意思是表述性状态转移。Rest指的是⼀组架构约束条件和原则。如果⼀个架构符合Rest的约束条件和原则，我们就称它为Restful架构。

Rest架构的主要原则

> * 在Rest中的⼀切都被认为是⼀种资源。 
> * 每个资源由URI标识。 使⽤统⼀的接⼝。
> * 处理资源使⽤POST，GET，PUT，DELETE操作类似创建，读取，更新和删除 （CRUD）操作。 
> * ⽆状态：每个请求是⼀个ᇿ⽴的请求。从客户端到服务器的每个请求都必须包含所有必要的信 息，以便于理解。 
> * 同⼀个资源具有多种表现形式，例如XML，JSON

Restful API 简单例⼦

```go
[POST] http://localhost/users 		// 新增
[GET] http://localhost/users/1 		// 查询
[PATCH] http://localhost/users/1 	// 更新
[PUT] http://localhost/users/1 		// 覆盖，全部更新
[DELETE] http://localhost/users/1 	// 删除
```



## 二、net/http包

### 1. 多路复⽤器

⼀个典型的 Go Web 程序结构如下：

> ![](https://cdn.jsdelivr.net/gh/eaok/img/web/goweb/goWeb.png)

net/http 包内置了⼀个默认的多路复⽤器 DefaultServeMux 。定义如下：

> ```go
> // DefaultServeMux is the default ServeMux used by Serve.
> var DefaultServeMux = &defaultServeMux
> 
> var defaultServeMux ServeMux
> ```
>
> net/http 包中很多⽅法都在内部调⽤ DefaultServeMux 的对应⽅法，如 HandleFunc 。
>
> ```go
> // HandleFunc registers the handler function for the given pattern
> // in the DefaultServeMux.
> // The documentation for ServeMux explains how patterns are matched.
> func HandleFunc(pattern string, handler func(ResponseWriter, *Request)) {
> 	DefaultServeMux.HandleFunc(pattern, handler)
> }
> //实际上， http.HandleFunc ⽅法是将处理器函数注册到 DefaultServeMux 中的。
> ```
>
> 
>
> 当http.ListenAndServe的参数handler为nil 时，会创建⼀个默认的多路复用器：
>
> ```go
> // serverHandler delegates to either the server's Handler or
> // DefaultServeMux and also handles "OPTIONS *" requests.
> type serverHandler struct {
> 	srv *Server
> }
> 
> func (sh serverHandler) ServeHTTP(rw ResponseWriter, req *Request) {
> 	handler := sh.srv.Handler
> 	if handler == nil {
> 		handler = DefaultServeMux
> 	}
> 	if req.RequestURI == "*" && req.Method == "OPTIONS" {
> 		handler = globalOptionsHandler{}
> 	}
> 	handler.ServeHTTP(rw, req)
> }
> ```
>
> 
>
> 虽然默认的多路复⽤器使⽤起来很⽅便，但是在⽣产环境中不建议使⽤。由于 DefaultServeMux 是⼀
> 个全局变量，所有代码，包括第三⽅代码都可以修改它。 有些第三⽅代码会在 DefaultServeMux 注册
> ⼀些处理器，这可能与我们注册的处理器冲突。



服务器收到的每个请求会调⽤对应多路复⽤器（即 ServeMux ）的 ServeHTTP ⽅法。在 ServeMux 的
ServeHTTP ⽅法中，根据 URL 查找我们注册的处理器，然后将请求交由它处理。

```go
type Handler interface {
	ServeHTTP(ResponseWriter, *Request)
}

// The HandlerFunc type is an adapter to allow the use of
// ordinary functions as HTTP handlers. If f is a function
// with the appropriate signature, HandlerFunc(f) is a
// Handler that calls f.
type HandlerFunc func(ResponseWriter, *Request)

// ServeHTTP calls f(w, r).
func (f HandlerFunc) ServeHTTP(w ResponseWriter, r *Request) {
	f(w, r)
}
```



创建多路复⽤器直接调⽤ http.NewServeMux ⽅法即可。然后，在新创建的多路复⽤器上注册处理器：

```go
func main() {
    //创建Mux
    mux := http.NewServeMux()
    mux.HandleFunc("/", hello)
    server := &http.Server{
        Addr: ":8080",
 		Handler: mux,
        //创建了⼀个读超时和写超时均为 1s 的服务器。
 		ReadTimeout: 1 * time.Second,
 		WriteTimeout: 1 * time.Second,
	}
    if err := server.ListenAndServe(); err != nil {
 		log.Fatal(err)
 	}
}
```



### 2. 处理器和处理器函数

Handler 接⼝定义

```go
type Handler interface {
    func ServeHTTP(w Response.Writer, r *Request)
}
```

可以定义⼀个实现该接⼝的结构，注册这个结构类型的对象到多路复⽤器中：

```go
package main

import (
	"fmt"
	"log"
	"net/http"
)

type GreetingHandler struct {
	Language string
}

func (h GreetingHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "%s", h.Language)
}

func main() {
	mux := http.NewServeMux()
	mux.Handle("/chinese", GreetingHandler{Language: "你好"})
	mux.Handle("/english", GreetingHandler{Language: "Hello"})

	server := &http.Server {
		Addr:   ":8080",
		Handler: mux,
	}

	if err := server.ListenAndServe(); err != nil {
		log.Fatal(err)
	}
}
```



⾃定义处理器这种⽅式⽐较灵活，强⼤，但是需要定义⼀个新的结构，实现 ServeHTTP ⽅法，还是⽐较繁琐的。为了⽅便使⽤，net/http 包提供了以函数的⽅式注册处理器，即使⽤ HandleFunc 注册。函数必须满⾜签名： func (w http.ResponseWriter, r *http.Request) 。 这个函数称为处理器函数。 

HandleFunc ⽅法内部，会将传⼊的处理器函数转换为 HandlerFunc 类型。

```go
func (mux *ServeMux) HandleFunc(pattern string, handler func(ResponseWriter, *Request)) {
    if handler == nil {
        panic("http: nil handler")
    }
    mux.Handle(pattern, HandlerFunc(handler))
}
```

HandlerFunc 是底层类型为 func (w ResponseWriter, r *Request) 的新类型，它可以⾃定义其⽅法。由于 HandlerFunc 类型实现了 Handler 接⼝，所以它也是⼀个处理器类型，最终使⽤ Handle 注册。

```go
type HandlerFunc func(w *ResponseWriter, r *Request)

func (f HandlerFunc) ServeHTTP(w ResponseWriter, r *Request) {
    f(w, r)
}
```



注意，这⼏个接⼝和⽅法名很容易混淆：

* `Handler `：处理器接⼝，定义在 net/http 包中。实现该接⼝的类型，其对象可以注册到多路复⽤ 器中； 
* `Handle `：注册处理器的⽅法； 
* `HandleFunc` ：注册处理器函数的⽅法； 
* `HandlerFunc `：底层类型为 func (w ResponseWriter, r *Request) 的新类型，实现了 Handler 接⼝。它连接了处理器函数与处理器。

绑定处理器函数过程：

![](https://cdn.jsdelivr.net/gh/eaok/img/web/goweb/HandleFunc.png)



### 3. URL 匹配

如果注册的 URL 不是以 / 结尾的，那么它只能精确匹配请求的 URL。反之，url会逐步去掉末尾部分和注册的url相匹配；







### 4. http请求

#### http.Request

http.Request结构体的定义：

```go
type Request struct {
 	Method string
 	URL *url.URL
 	Proto string
 	ProtoMajor int
 	ProtoMinor int
 	Header Header
 	Body io.ReadCloser
 	ContentLength int
 	// 省略⼀些字段...
}
```



url.URL结构体的定义：

> ```go
> type URL struct {
>  	Scheme string
>  	Opaque string
>  	User *Userinfo
>  	Host string
>  	Path string
>  	RawPath string
>  	RawQuery string
>  	Fragment string
> }
> ```
>
> 可以通过 URL 结构得到⼀个 URL 字符串：
>
> ```go
> URL := &net.URL {
>  	Scheme: "http",
>  	Host: "example.com",
>  	Path: "/posts",
>  	RawQuery: "page=1&count=10",
>  	Fragment: "main",
> }
> fmt.Println(URL.String())
> 
> //http://example.com/posts?page=1&count=10#main
> ```



Proto 表示 HTTP 协议版本，如 HTTP/1.1 ， ProtoMajor 表示⼤版本， ProtoMinor 表示⼩版本。

> ```go
> func protoFunc(w http.ResponseWriter, r *http.Request) {
>  	fmt.Fprintf(w, "Proto: %s\n", r.Proto)
>  	fmt.Fprintf(w, "ProtoMajor: %d\n", r.ProtoMajor)
>  	fmt.Fprintf(w, "ProtoMinor: %d\n", r.ProtoMinor)
> }
> 
> mux.HandleFunc("/proto", protoFunc)
> 
> //Proto: HTTP/1.1
> //ProtoMajor: 1
> //ProtoMinor: 1
> ```



#### Header

> Header 中存放的客户端发送过来的⾸部信息，键-值对的形式。
>
> ```go
> type Header map[string][]string
> ```
>
> 浏览器发起 HTTP 请求的时候，会⾃动添加⼀些⾸部。
>
> ```go
> func headerHandler(w http.ResponseWriter, r *http.Request) {
>  	for key, value := range r.Header {
>  		fmt.Fprintf(w, "%s: %v\n", key, value)
>  	}
> }
> mux.HandleFunc("/header", headerHandler)
> 
> //Accept-Enreading: [gzip, deflate, br]
> //Sec-Fetch-Site: [none]
> //Sec-Fetch-Mode: [navigate]
> //Connection: [keep-alive]
> //Upgrade-Insecure-Requests: [1]
> //User-Agent: [Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.1904.108 Safari/537.36]
> //Sec-Fetch-User: [?1]
> //Accept:[text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3]
> //Accept-Language: [zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7]
> ```
>
> 常⻅的⾸部有：
>
> * Accept ：客户端想要服务器发送的内容类型；
> * Accept-Charset ：表示客户端能接受的字符编码；
> * Content-Length ：请求主体的字节⻓度，⼀般在 POST/PUT 请求中较多；
> * Content-Type ：当包含请求主体的时候，这个⾸部⽤于记录主体内容的类型。在发送 POST 或
>   PUT 请求时，内容的类型默认为 x-www-form-urlecoded 。但是在上传⽂件时，应该设置类型
>   为 multipart/form-data 。
> * User-Agent ：⽤于描述发起请求的客户端信息，如什么浏览器。

Content-Length/Body

Content-Length 表示请求体的字节⻓度，请求体的内容可以从 Body 字段中读取。

Body 字段是⼀个 `io.ReadCloser` 接⼝。在读取之后要关闭它，否则会有资源泄露。可以使⽤ `defer` 简化代码编写。

```go
func bodyHandler(w http.ResponseWriter, r *http.Request) {
 	data := make([]byte, r.ContentLength)
 	r.Body.Read(data) // 忽略错误处理
 	defer r.Body.Close()

 	fmt.Fprintln(w, string(data))
}
mux.HandleFunc("/body", bodyHandler)

//可以使⽤ io/ioutil 包简化读取操作：
data, _ := ioutil.ReadAll(r.Body)
```



#### 发起带请求体的请求

> 1 使用表单
>
> 通过 HTML 的表单我们可以向服务器发送 POST 请求，将表单中的内容作为请求体发送：
>
> ```go
> func indexHandler(w http.ResponseWriter, r *http.Request) {
>  	fmt.Fprint(w, `
> <html>
>  	<head>
>  		<title>Go Web</title>
>  	</head>
>  	<body>
>  		<form method="post" action="/body">
>  			<label for="username">⽤户名：</label>
>  			<input type="text" id="username" name="username">
>  			<label for="email">邮箱：</label>
>  			<input type="text" id="email" name="email">
>  			<button type="submit">提交</button>
>  		</form>
>  	</body>
> </html>
> `)
> }
> mux.HandleFunc("/", indexHandler)
> ```
>
> 点击提交按钮后，浏览器会发送⼀个 POST 请求到路径 /body上，将⽤户名和邮箱作为请求包体。上⾯的数据使⽤了 x-www-form-urlencoded 编码，这是表单的默认编码。
>
> 
>
> 2 使用调试工具Postman/Postwoman/Paw



#### 获取请求参数

> 1 URL 键值对
>
> ```go
> func queryHandler(w http.ResponseWriter, r *http.Request) {
> 	fmt.Fprintln(w, r.URL.RawQuery)
> }
> 
> mux.HandleFunc("/query", queryHandler)
> ```
>
> 
>
> 2 表单
>
> `action` 表示提交表单时请求的 URL；
>
> `method` 表示请求的⽅法。如果使⽤ GET 请求，由于 GET ⽅法没有请求体，参数将会拼接到 URL 尾部；
>
> `enctype` 指定请求体的编码⽅式，默认为 `application/x-www-form-urlencoded` 。如果需要发送⽂件，必须指定为 `multipart/form-data`；
>
> urlencoded 编码：RFC 3986 中定义了 URL 中的保留字以及⾮保留字，所有保留字符都需要进⾏ URL编码。URL 编码会把字符转换成它在 ASCII 编码中对应的字节值，接着把这个字节值表示为⼀个两位⻓的⼗六进制数字，最后在这个数字前⾯加上⼀个百分号（%）。例如空格的 ASCII 编码为 32，⼗六进制为 20，故 URL 编码为 %20 。
>
> * Form 字段
>
>   使⽤ x-www-form-urlencoded 编码的请求体，在处理时⾸先调⽤请求的 ParseForm ⽅法解析，然后
>   从 Form 字段中取数据：
>
>   ```go
>   func formHandler(w http.ResponseWriter, r *http.Request) {
>    	r.ParseForm()
>    	fmt.Fprintln(w, r.Form)
>   }
>   mux.HandleFunc("/form", formHandler)
>   ```
>
>   表单如下时：
>
>   ```html
>   <html>
>       <head>
>           <title>Go Web</title>
>       </head>
>       
>       <body>
>           <form action="/form2?lang=cpp&name=ls" method="post" enctype="application/x-www-form-urlencoded">
>               <label>Form:</label>
>               <input type="text" name="lang" />
>               <input type="text" name="age" />
>               <button type="submit">提交</button>
>           </form>
>       </body>
>   </html>
>   ```
>
>   字符串中的键值对和表单中解析处理的会合并到⼀起。同⼀个键下，表单值总是排在前⾯，如[lang cpp]
>
> * PostForm 字段
>
>   如果⼀个请求，同时有 URL 键值对和表单数据，⽽⽤户只想获取表单数据，可以使⽤ PostForm 字段。使⽤ PostForm 只会返回表单数据，不包括 URL 键值。
>
>   PostForm字段只支持application/x-www-form-urlencoded
>
> * MultipartForm 字段
>
>   如果要处理上传的⽂件，那么就必须使⽤ multipart/form-data 编码。与之前的 Form/PostForm 类
>   似，处理 multipart/form-data 编码的请求时，也需要先解析后使⽤。只不过使⽤的⽅法不同，解析
>   使⽤ ParseMultipartForm ，之后从 MultipartForm 字段取值。
>
>   ```html
>   <form action="/multipartform?lang=cpp&name=dj" method="post" enctype="multipart/form-data">
>    	<label>MultipartForm:</label>
>    	<input type="text" name="lang" />
>    	<input type="text" name="age" />
>    	<input type="file" name="uploaded" />
>    	<button type="submit">提交</button>
>   </form>
>   ```
>
>   ```go
>   func multipartFormHandler(w http.ResponseWriter, r *http.Request) {
>    	r.ParseMultipartForm(1024)
>    	fmt.Fprintln(w, r.MultipartForm)
>   
>    	fileHeader := r.MultipartForm.File["uploaded"][0]
>    	file, err := fileHeader.Open()
>    	if err != nil {
>    		fmt.Println("Open failed: ", err)
>    		return
>    	}
>    	data, err := ioutil.ReadAll(file)
>    	if err == nil {
>    		fmt.Fprintln(w, string(data))
>    	}
>   }
>   mux.HandleFunc("/multipartform", multipartFormHandler)
>   ```
>
>   MultipartForm 包含两个 map 类型的字段，⼀个表示表单键值对，另⼀个为上传的⽂件信息。使⽤表单中⽂件控件名获取 MultipartForm.File 得到通过该控件上传的⽂件，可以是多个。得到的是 multipart.FileHeader 类型，通过该类型可以获取⽂件的各个属性。需要注意的是，这种⽅式⽤来处理⽂件。为了安全， ParseMultipartForm ⽅法需要传⼀个参数，表示最⼤使⽤内存，避免上传的⽂件占⽤空间过⼤。
>   
>   
>   
> * FormValue/PostFormValue
>
>   为了⽅便地获取值， net/http 包提供了 FormValue/PostFormValue ⽅法。它们在需要时会⾃动调
>   ⽤ ParseForm/ParseMultipartForm ⽅法。
>   FormValue ⽅法返回请求的 Form 字段中指定键的值。如果同⼀个键对应多个值，那么返回第⼀个。如
>   果需要获取全部值，直接使⽤ Form 字段。下⾯代码将返回 hello 对应的第⼀个值：
>
>   ```go
>   fmt.Fprintln(w, r.FormValue("hello"))
>   ```
>
>   PostFormValue ⽅法返回请求的 PostForm 字段中指定键的值。如果同⼀个键对应多个值，那么返回
>   第⼀个。如果需要获取全部值，直接使⽤ PostForm 字段
>   
>   注意： 当编码被指定为 multipart/form-data 时， FormValue/PostFormValue 将不会返回任何值，
>   它们读取的是 Form/PostForm 字段，⽽ ParseMultipartForm 将数据写⼊ MultipartForm 字段。

### 5. http 响应

#### 1.http.ResponseWriter

ReponseWriter接口定义：

```go
type ReponseWriter interface {
 	Header() Header
 	Write([]byte) (int, error)
 	WriteHeader(statusCode int)
}
```

那为什么请求对象使⽤的是结构指针*http.Request ，⽽响应要使⽤接⼝呢？

> 请求对象使⽤指针是为了能在处理逻辑中⽅便地获取请求信息。⽽响应使⽤接⼝来操作，底层 也是对象指针，可以保存修改。



Write ⽅法

> 由于接⼝ ResponseWriter 拥有⽅法 Write([]byte) (int, error) ，所以实现了 ResponseWriter 接⼝的结构也实现了 io.Writer 接⼝：
>
> ```go
> type Writer interface {
>  	Write(p []byte) (n int, err error)
> }
> ```
>
> 所以 http.ResponseWriter 类型的变量 w 能在下⾯代码中使⽤（ fmt.Fprintln 的第⼀个参数接收⼀个 io.Writer 接⼝）：
>
> ```go
> fmt.Fprintln(w, "Hello World")
> ```
>
> 
>
> 我们也可以直接调⽤ Write ⽅法来向响应中写⼊数据：
>
> ```go
> func writeHandler(w http.ResponseWriter, r *http.Request) {
>  	str := `
> <html>
> 	<head><title>Go Web</title></head>
> 	<body><h1>直接使⽤ Write ⽅法<h1></body>
> </html>`
>  	w.Write([]byte(str))
> }
> mux.HandleFunc("/write", writeHandler)
> ```



WriteHeader ⽅法

> `WriteHeader` 接收⼀个整数，并将这个整数作为 HTTP 响应的状态码返回；
>
> 调⽤这个返回之后，可以继续对 ResponseWriter 进⾏写⼊，但是不能对响应的⾸部进⾏任何修改操作。
>
> 如果⽤户在调⽤ Write ⽅法之前没有执⾏过WriteHeader ⽅法，那么程序默认会使⽤ 200 作为响应的状态码。
>
> 例如：定义了⼀个 API，还未定义其实现。那么请求这个 API 时，可以返回⼀个 501 NotImplemented 作为状态码。
>
> ```go
> func writeHeaderHandler(w http.ResponseWriter, r *http.Request) {
> 	w.WriteHeader(501)
> 	fmt.Fprintln(w, "This API not implemented!!!")
> }
> ```
>
> `curl -i localhost:8080/writeheader`返回：
>
> ```go
> HTTP/1.1 501 Not Implemented
> Date: Wed, 1 Jan 2020 14:15:16 GMT
> Content-Length: 28
> Content-Type: text/plain; charset=utf-8
> This API not implemented!!!
> ```



Header ⽅法

> `Header` ⽅法其实返回的是⼀个 `http.Heade`r 类型，该类型的底层类型为 `map[string][]string` ：
>
> ```go
> type Header map[string][]string
> ```
>
> 
>
> 设置重定向的网址：
>
> ```go
> func headerHandler(w http.ResponseWriter, r *http.Request) {
>  	w.Header().Set("Location", "http://baidu.com")
>  	w.WriteHeader(302) //调用后就不能对响应的⾸部进⾏修改了，所以一般放后面
> }
> ```
>
> 浏览器收到该状态码时会再发起⼀个请求到⾸部中Location 指向的地址。
>
> `curl -i localhost:8080/header`返回：
>
> ```go
> HTTP/1.1 302 Found
> Location: http://baidu.com
> Date: Wed, 1 Jan 2020 14:17:49 GMT
> Content-Length: 0
> ```
>
> 
>
> 通过 Header.Set ⽅法设置响应的⾸部
>
> ```go
> func jsonHandler(w http.ResponseWriter, r *http.Request) {
> 	w.Header().Set("Content-Type", "application/json")
> 	u := &User{
> 		FirstName: "ls",
> 		LastName:  "ls",
> 		Age:       18,
> 		Hobbies:   []string{"reading", "learning"},
> 	}
> 	data, _ := json.Marshal(u)
> 	w.Write(data)
> }
> ```
>
> `curl -i localhost:8080/json`返回：
>
> ```go
> HTTP/1.1 200 OK
> Content-Type: application/json
> Date: Wed, 1 Jan 2020 14:31:03 GMT
> Content-Length: 78
> 
> {"first_name":"ls","last_name":"ds","age":18,"hobbies":["reading","learning"]}
> ```
>
> 响应⾸部中类型 Content-Type 除了 application/json 还有
>
> * xml（ application/xml ）
>
> * pdf（ application/pdf ）
>
> * png（ image/png ）等等



#### 2.cookie

⽤ http.Cookie 结构体定义：

```go
type Cookie struct {
 	Name string
 	Value string
 	Path string
 	Domain string
 	Expires time.Time		//决定cookie在什么时间点过期
 	RawExpires string		
 	MaxAge int				//决定cookie可以存活多久
 	Secure bool
 	HttpOnly bool			//为true时，该cookie只能通过HTTP访问
 	SameSite SameSite
 	Raw string
 	Unparsed []string
}
```

cookie 需要通过响应的⾸部发送给客户端。浏览器收到 Set-Cookie ⾸部时，会将其中的值解析成cookie 格式保存在浏览器中。

设置cookie有两种方式：

```go
//使用ResponseWriter.Header().Set/Add设置cookie
func setCookie(w http.ResponseWriter, r *http.Request) {
	c1 := &http.Cookie{
		Name:     "name",
		Value:    "lianshi",
		HttpOnly: true,
	}
	c2 := &http.Cookie{
		Name:     "age",
		Value:    "18",
		HttpOnly: true,
	}
	w.Header().Set("Set-Cookie", c1.String())
	w.Header().Add("Set-Cookie", c2.String())
}

//使用http.SetCookie⽅法设置cookie
func setCookie2(w http.ResponseWriter, r *http.Request) {
	c1 := &http.Cookie{
		Name:     "name",
		Value:    "lianshi",
		HttpOnly: true,
	}
	c2 := &http.Cookie{
		Name:     "age",
		Value:    "18",
		HttpOnly: true,
	}
	http.SetCookie(w, c1)
	http.SetCookie(w, c2)
}
```

读取 Cookie：

```go
//从Header字段读取Cookie切片
func getCookie(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "Host:", r.Host)
	fmt.Fprintln(w, "Cookies:", r.Header["Cookie"])
}

//使用http.Request提供了⼀些⽅法可以更容易地获取cookie的键值对格式：
func getCookie2(w http.ResponseWriter, r *http.Request) {
	name, err := r.Cookie("name")
	if err != nil {
		fmt.Fprintln(w, "cannot get cookie of name")
	}

	cookies := r.Cookies()
	fmt.Fprintln(w, name)
	fmt.Fprintln(w, cookies)
}
```





### 6. curl ⼯具

安装方式：

* 在官网下载安装 https://curl.haxx.se/download.html

* 使用包管理工具scoop

  ```bash
  scoop install curl
  ```

例子：

```bash
curl -i localhost:8080/write
#-i 显示响应头部
#没有设置内容类型时，返回的⾸部中也有 Content-Type: text/html; charset=utf8 ，说明 net/http 会⾃动推断。 net/http 包是通过读取响应体中前⾯的若⼲个字节来推断的，并不是百分百准确的。
```



## 三、模板引擎

模板引擎按照功能可以划分为两种类型：

* **⽆逻辑模板引擎**：此类模板引擎只进行字符串的替换，无其它逻辑；
* **嵌⼊逻辑模板引擎**：此类模板引擎可以在模板中嵌⼊逻辑，实现流程控制/循环等。

在 Go 标准库中， text/template 和 html/template 两个库实现模板功能。模板内容可以是 UTF-8 编码的任何内容，其中⽤ {{ 和 }} 包围的部分称为动作。

![](https://cdn.jsdelivr.net/gh/eaok/img/web/goweb/templateAction.png)

### 1. 使用模板

使⽤模板引擎⼀般有 3 个步骤：

* 定义模板（直接使⽤字符串字⾯量或⽂件）；
* 解析模板（使⽤ text/template 或 html/template 中的⽅法解析）；
* 传⼊数据⽣成输出。



解析模板：

```go
t, _ := template.ParseFiles("t1.html", "t2.html", "t3.html")
//同下面两行，相当于新建一个模板，然后调用它的ParseFiles方法
t := template.New("t1.html")
t, _ := t.ParseFiles("t1.html", "t2.html", "t3.html")

//ParseFiles函数/方法都可以接收一个或多个文件名作为参数
//传入多个文件时，返回的是一个模板集合

t, _ := template.ParseGlob("*.html")	//对匹配所有模板文件进行解析
```



专用于处理分析模板时出现的错误：

```go
t := template.Must(template.ParseFiles("tmpl.html"))
```



`Execute`只会执行第一个模板，其它模板可用`ExecuteTemplate`

```go
t, _ := template.ParseFiles("t1.html", "t2.html")

t.Execute(w, "Hello World!") //默认只执行第一个模板
t.ExecuteTemplate(w, "t2.html", "Hello world!") //执行第二个模板
```



注意，如果多个不同路径下的⽂件名相同，那么后解析的会覆盖之前的。



### 2. 模板动作

#### 点动作

模板中的 {{ . }} 会被替换为传⼊的数据；



模板⽂件 `hello.html` ：

```html
<!DOCTYPE html>
<html lang="en">
<head>
 <meta charset="UTF-8">
 <meta name="viewport" content="width=device-width, initial-scale=1.0">
 <meta http-equiv="X-UA-Compatible" content="ie=edge">
 <title>Go Web</title>
</head>
<body>
 {{ . }}
</body>
</html>
```

处理器函数：

```go
func indexHandler(w http.ResponseWriter, r *http.Request) {
	t := template.Must(template.ParseFiles("hello.html"))
	t.Execute(w, "Hello World")
}
```



程序也可以对字符串形式的模板进行分析，对模板分析，底层都是调用的`Parse`方法：

```go
tmpl := `
<!DOCTYPE html>
<html lang="en">
<head>
 <meta charset="UTF-8">
 <meta name="viewport" content="width=device-width, initial-scale=1.0">
 <meta http-equiv="X-UA-Compatible" content="ie=edge">
 <title>Go Web</title>
</head>
<body>
 {{ . }}
</body>
</html>`

t := template.New("tmpl.html")
t = template.Must(t.Parse(tmpl))
t.Execute(w, "Hello world!")
```



#### 条件动作

条件动作的语法与编程语⾔中的 if 语句语法类似，有⼏种形式：

```go
//形式一
{{ if arg }}
	content
{{ end }}

//形式二
{{ if arg }}
	content
{{ else }}
	content
{{ end }}

//形式三
{{ if arg }}
	content
{{ else if arg }}
	content
{{ else }}
	content
{{ end }}

//其中arg为假的情况有
//false 、0、空指针或接⼝、⻓度为 0 的数组、切⽚、map或字符串
```



模板⽂件 `condition.html`

```html
<p>Your age is: {{ . }}</p>
{{ if gt . 60 }}
<p>Old People!</p>
{{ else if gt . 40 }}
<p>Middle Aged!</p>
{{ else }}
<p>Young!</p>
{{ end }}
```

处理器函数：

```go
func conditionHandler(w http.ResponseWriter, r *http.Request) {
	age, err := strconv.ParseInt(r.URL.Query().Get("age"), 10, 64)
	if err != nil {
		fmt.Fprint(w, err)
		return
	}
	t := template.Must(template.ParseFiles("condition.html"))
	t.Execute(w, age)
}
```



#### 迭代动作

迭代动作⼀般⽤于⽣成⼀个列表，与编程语⾔中的循环遍历类似。有两种形式：

```go
//形式一
{{ range array }}
	content
{{ end }}

//形式二
{{ range array }}
	content
{{ else }}
	content	//如果array的长度为0，就执行这里
{{ end }}

//array可以是数组、切⽚、map、channel。
```



模板⽂件 `iterate.html` ：

```html
<h1>Apple Products</h1>
<ul>
{{ range . }}
	<li>{{ .Name }}: ￥{{ .Price }}</li>
{{ else }}
    <li>Nothing to show</li>
{{ end }}
</ul>
```

处理器函数：

```go
type Item struct {
	Name string
	Price int
}

func iterateHandler(w http.ResponseWriter, r *http.Request) {
	t := template.Must(template.ParseFiles("iterate.html"))
	items := []Item {
		{ "iPhone", 5499 },
		{ "iPad", 6331 },
		{ "iWatch", 1499 },
		{ "MacBook", 8250 },
	}
	t.Execute(w, items)
}
```



#### 设置动作

设置动作使⽤ with 关键字重定义 . 。在 with 语句内， . 会被定义为指定的值。

```go
//形式一
{{ with arg }}
	content
{{ end }}

//形式二
{{ with arg }}
	content
{{ else }}
	Fallback if arg is empty
{{ end }}
```



⽤在结构嵌套很深时，能起到简化代码的作⽤：

```html
<h1>Pet Info</h1>
<p>Name: {{ .Name }}</p>
<p>Age: {{ .Age }}</p>
<p>Owner:</p>
{{ with .Owner }}
<p>Name: {{ .Name }}</p>
<p>Age: {{ .Age }}</p>
{{ end }}

<!--
在 {{ with .Owner }} 和 {{ end }} 之间，可以直接通过 {{ .Name }} 和 {{ .Age }} 访问宠物主⼈的信息
-->
```



模板⽂件 set.html ：

```html
<div>The dot is {{ . }}</div>
<div>
    {{ with "world"}}
    	Now the dot is set to {{ . }}
    {{ else }}
    	The dot still {{ . }}
    {{ end }}
</div>
<div>The dot is {{ . }} again</div>
```

处理器函数：

```go
func setHandler(w http.ResponseWriter, r *http.Request) {
	t := template.Must(template.ParseFiles("set.html"))
	err := t.Execute(w, "hello")
	if err != nil {
		log.Fatal("Execute error:", err)
	}
}
```



#### 包含动作

包含动作允许⽤户在⼀个模板⾥⾯包含另⼀个模板，从⽽构造出嵌套的模板。

```go
//形式一
{{ template "name" }}	//将使⽤ nil 作为传⼊内嵌模板的参数

//形式二
{{ template "name" arg }}	//arg将会作为参数传给内嵌的模板
```



模板文件`include1.html`：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>包含动作</title>
</head>
<body>
    <div> This is include1.html before</div>
    <div>This is the value of the dot in t1.html - [{{ . }}]</div>
    <hr/>
    {{ template "include2.html" }}
    <hr/>
    {{ template "include2.html" . }}
    <hr/>
    <div> This is include1.html after</div>
</body>
</html>
```

模板文件`include2.html`：

```html
<div style="background-color: yellow;">
    This is include2.html<br/>
    This is the value of the dot in include2.html - [{{ . }}]
</div>
```

处理器函数：

```go
func includeHandler(w http.ResponseWriter, r *http.Request) {
	t := template.Must(template.ParseFiles("include1.html", "include2.html"))
	err := t.Execute(w, "hello")
	if err != nil {
		log.Fatal("Execute error:", err)
	}
}
```



#### 定义动作

在⼀个模板⽂件中还可以通过 {{ define }} 动作定义其它的模板，这些模板就是嵌套模板，嵌套模板⼀般⽤于布局（layout）。模板定义必须在模板内容的最顶层，像 Go 程序中的全局变量⼀样。



显式地定义一个模板：

```html
{{ define "layout" }}
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>嵌套模板</title>
</head>
<body>
    {{ . }}
</body>
</html>
{{ end }}
```



也可以在同一个文件中显式地定义多个模板：

```html
{{ define "layout" }}
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>嵌套模板</title>
</head>
<body>
    {{ template "content" }}
    {{ template "content" . }}
</body>
</html>
{{ end }}

{{ define "content" }}
    <h1 style="color: blue">Hello {{ . }}!</h1>
{{ end }}
```



#### 块动作

块动作就是定义⼀个模板，并且立即使用，语法如下：

```go
{{ block "name" arg }}
	content
{{ end }}
```

就等价于：

```go
{{ define "name" }}
	content
{{ end }}

{{ template "name" arg }}
```



模板文件block.html：

```html
<!DOCTYPE html>
{{ define "layout" }}
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>块动作</title>
</head>
<body>
    This is body.
    {{ block "content" . }}
        <h1 style="color: blue">Hello {{ . }}!</h1>
    {{ end }}
</body>
</html>
{{ end }}
```

模板文件content.html：

```html
{{ define "content" }}
    <h1 style="color: red">Hello {{ . }}!</h1>
{{ end }}

```

处理器函数：

```go
func blockHandler(w http.ResponseWriter, r *http.Request) {
	//t := template.Must(template.ParseFiles("block.html"))
	t := template.Must(template.ParseFiles("block.html", "content.html"))
	err := t.ExecuteTemplate(w, "layout", "world")
	if err != nil {
		log.Fatal("Execute error:", err)
	}
}
```

如果模板引擎没有找到content模板，它就会使用块动作中定义的content模板；



### 3. 其他元素

#### 注释

```html
{{ /* 注释 */ }}
```



#### 参数

⼀个参数就是模板中的⼀个值。它的取值有多种：

* 布尔值、字符串、字符、整数、浮点数、虚数和复数等字⾯量； 
* 结构中的⼀个字段或 map 中的⼀个键。结构的字段名必须是导出的，即⼤写字⺟开头，map 的键 名则不必； 
* ⼀个函数或⽅法。必须只返回⼀个值，或者只返回⼀个值和⼀个错误。如果返回了⾮空的错误， 则 Execute ⽅法执⾏终⽌，返回该错误给调⽤者；



关于参数的⼏个要点：

* 参数可以是任何类型；

* 如果参数为指针，实现会根据需要取其基础类型； 
* 如果参数计算得到⼀个函数类型，它不会⾃动调⽤。例如 {{ .Method1 }} ，如果 Method1 ⽅法 返回⼀个函数，那么返回值函数不会调⽤。如果要调⽤它，使⽤内置的 call 函数。



#### 管道

管道的语法与 Linux 中的管道类似，即命令的链式序列：

```bash
{{ p1 | p2 | p3 }}
```

每个单独的命令（即 p1/p2/p3... ）可以是下⾯三种类型：

* 参数；
* 可能带有参数的⽅法调⽤；
* 可能带有参数的函数调⽤。

管道必须只返回⼀个值，或者只返回⼀个值和⼀个错误。如果返回了⾮空的错误，那么 Execute ⽅法执
⾏终⽌，并将该错误返回给调⽤者。

例如：

```html
￥{{ .Total | printf "%.2f" }}
```



#### 变量

在动作中，可以⽤管道的值定义⼀个变量

```html
$variable := pipeline
```

也可以重新赋值：

```html
$variable = pipeline
```

用变量实现迭代动作：

```html
{{ range $key, $value := . }}
	The key is {{ key }} and the value is {{ $value }}
{{ end }}
```



变量的作⽤域持续到定义它的控制结构的 {{ end }} 动作。如果没有这样的控制结构，则持续到模板结
束。



#### 函数

##### 预定义函数

Go 模板提供了⼤量的预定义函数，如果有特殊需求也可以实现⾃定义函数。模板执⾏时，遇到函数调
⽤，先从模板⾃定义函数表中查找，⽽后查找全局函数表。预定义函数分为以下⼏类：

* 逻辑运算  `and/or/not` ；
* 调⽤操作 `call` ；
* 格式化操作 `print/printf/println` ，与⽤参数直接调⽤ `fmt.Sprint/Sprintf/Sprintln` 得到的内容相同；
* ⽐较运算 `eq/ne/lt/le/gt/ge` 。



注意点：

* 由于是函数调⽤，所有的参数都会被求值，没有短路求值； {{if p1 or p2}}
* 比较运算只作⽤于基本类型，且没有 Go 语法那么严格，例如可以⽐较有符号和⽆符号整数。



##### 自定义函数

实现⼀个格式化⽇期的⾃定义函数：

```go
func formatDate(t time.Time) string {
	return t.Format("2006-01-02")
}

func funcHandler(w http.ResponseWriter, r *http.Request) {
	funcMap := template.FuncMap{
		"fdate": formatDate,
	}
	t := template.New("func.html").Funcs(funcMap)

	t, err := t.ParseFiles("func.html")
	if err != nil {
		log.Fatal("Parse error:", err)
	}
	err = t.Execute(w, time.Now())
	if err != nil {
		log.Fatal("Exeute error:", err)
	}
}
```

在模板文件中调用：

```go
//通过管道使用自定义函数
{{ . | fdate }
 
//通过传递参数的方式使用自定义函数
{{ fdate . }}
```

这⾥不能使⽤ template.ParseFiles ，因为在解析模板⽂件的时候 fdate 未定义会导致解析失败。必须先创建模板，调⽤ Funcs 设置⾃定义函数，然后再解析模板。



### 4. 上下文感知

上下⽂感知的⼀个常⻅⽤途就是对内容进⾏转义。如果需要显示的是 HTML 的内容，那么进⾏ HTML 转义。如果显示的是 JavaScript 内容，那么进⾏JavaScript 转义。 Go 模板引擎还能识别出内容中的 URL 或 CSS，可以对它们实施正确的转义。

```go
func contextAwareHandler(w http.ResponseWriter, r *http.Request) {
	t := template.Must(template.ParseFiles("context-aware.html"))
	t.Execute(w, `He saied: <i>"She's alone?"</i>`)
}
```

模板⽂件 `context.html` ：

```html
<div>{{ . }}</div>
<div><a href="/{{ . }}">Path</a></div>
<div><a href="/?q={{ . }}">Query</a></div>
<div><a onclick="f('{{ . }}')">JavaScript</a></div>
```

得到下⾯的内容：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>上下文感知</title>
</head>
    <body>
        <div>He saied: &lt;i&gt;&#34;She&#39;s alone?&#34;&lt;/i&gt;</div>
        <div><a href="/He%20saied:%20%3ci%3e%22She%27s%20alone?%22%3c/i%3e">Path</a></div>
        <div><a href="/?q=He%20saied%3a%20%3ci%3e%22She%27s%20alone%3f%22%3c%2fi%3e">Query</a></div>
        <div><a onclick="f('He saied: \x3ci\x3e\x22She\x27s alone?\x22\x3c\/i\x3e')">JavaScript</a></div>
    </body>
</html>
```

转义分析：

* 第⼀个 div 中，直接在⻚⾯中显示，其中 HTML 标签``和单、双引号都被转义了；
* 第⼆个 div 中，数据出现在 URL 的路径中，所有⾮法的路径字符都被转义了，包括空格、尖括
  号、单双引号；
* 第三个 div 中，数据出现在查询字符串中，除了 URL 路径中⾮法的字符，还有冒号（ : ）、问号（ ? ）和斜杠也被转义了；
* 第四个 div 中，数据出现在 OnClick 代码中，单双引号和斜杠都被转义了。

这四种转义⽅式⼜有所不同，第⼀种转义为 HTML 字符实体，第⼆、三种转义为 URL 转义字符（ % 后
跟字符编码的⼗六进制表示） ，第四种转义为 Go 中的⼗六进制字符表示。



### 6. 防御XSS攻击

XSS 是⼀种常⻅的攻击形式。在论坛之类的可以接受⽤户输⼊的⽹站，攻击者可以内容中添加 <script> 标签。如果⽹站未对输⼊的内容进⾏处理， 其他⽤户浏览该⻚⾯时， <script> 标签中的内容就会被执⾏，泄露⽤户的私密信息或利⽤⽤户的权限做破坏。

```go
func xssHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == "POST" {
		t := template.Must(template.ParseFiles("xss_display.html"))
		t.Execute(w, r.FormValue("comment"))                //会对内容进行转义
		t.Execute(w, template.HTML(r.FormValue("comment"))) //不对内容进行转义
	} else {
		t := template.Must(template.ParseFiles("xss_form.html"))
		t.Execute(w, nil)
	}
}
```

模板文件`xss_form.html`：

```html
<form action="/xss" method="post">
    Comment: <input name="comment" type="text">
    <hr/>
    <button id="submit">Submit</button>
</form>
```

模板文件`xss_display.html`：

```html
{{ . }}
```

如果不想被转义，可以把内容传给template.HTML函数：

```go
t.Execute(w, template.HTML(r.FormValue("comment")))
```

