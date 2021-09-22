# HTTP协议

HTTP协议，即超文本传输协议(Hypertext transfer protocol)。是一种详细规定了浏览器和万维网(WWW = World Wide Web)服务器之间互相通信的规则，通过因特网传送万维网文档的数据传送协议。HTTP是一个无状态的协议。

HTTP协议通常承载于TCP协议之上，有时也承载于TLS或SSL协议层之上，这个时候，就成了我们常说的HTTPS；HTTP默认的端口号为80，HTTPS的端口号为443。



## 请求信息

请求信息格式如下：

```
请求行（request-line）；例如GET /images/logo.gif HTTP/1.1
零个或多个首部（header）；例如Accept-Language: en
一个空行；
一个可选的报文主体（body）；

在HTTP/1.1协议中，所有的请求头，除post外，都是可选的。
```

### 请求方法

```
OPTIONS - 返回服务器针对特定资源所支持的HTTP请求方法。也可以利用向Web服务器发送'*'的请求来测试服务器的功能性。
HEAD- 向服务器索要与GET请求相一致的响应，只不过响应体将不会被返回。这一方法可以在不必传输整个响应内容的情况下，就可以获取包含在响应消息头中的元信息。该方法常用于测试超链接的有效性，是否可以访问，以及最近是否更新。
GET - 向特定的资源发出请求。注意：GET方法不应当被用于产生“副作用”的操作中，例如在web app.中。
POST - 向指定资源提交数据进行处理请求（例如提交表单或者上传文件）。数据被包含在请求体中。
PUT - 向指定资源位置上传其最新内容。
DELETE - 请求服务器删除Request-URI所标识的资源。
TRACE- 回显服务器收到的请求，主要用于测试或诊断。
CONNECT - HTTP/1.1协议中预留给能够将连接改为管道方式的代理服务器。

PATCH - 用来将局部修改应用于某一资源，添加于规范RFC5789。
```

当某个请求所针对的资源不支持对应的请求方法的时候，服务器应当返回状态码405（Method Not Allowed）；当服务器不认识或者不支持对应的请求方法的时候，应当返回状态码501（Not Implemented）。
HTTP服务器至少应该实现GET和HEAD方法，其他方法都是可选的。



### ***HTTP常见的请求头***

在HTTP/1.1 协议中，所有的请求头，除Host外，都是可选的

```
If-Modified-Since: 缓存的最后修改时间发送到服务器去，一致就返回304，否则返回200和新的资源
If-None-Match: 和ETag一起工作，如果服务器验证资源的ETag没有改变返回304，否则返回200和新的资源和ETag
Pragma: 例如：Pragma: no-cache，表示服务器必须返回一个刷新后的文档
Cache-Control: 指定请求和响应遵循的缓存机制
	Cache-Control:Public 可以被任何缓存所缓存
	Cache-Control:Private 内容只缓存到私有缓存中
	Cache-Control:no-cache 所有内容都不会被缓存
	Cache-Control:no-store 用于防止重要的信息被无意的发布。在请求消息中发送将使得请求和响应消息都不使		用缓存。
	Cache-Control:max-age 指示客户机可以接收生存期不大于指定时间（以秒为单位）的响应。
	Cache-Control:min-fresh 指示客户机可以接收响应时间小于当前时间加上指定时间的响应。
	Cache-Control:max-stale 指示客户机可以接收超出超时期间的响应消息。如果指定max-stale消息的值，那		么客户机可以接收超出超时期指定值之内的响应消息。
Accept: 浏览器端可以接受的MIME类型。例如：Accept: text/html    Accept: */*
Accept-Encoding: 浏览器申明自己可接收的编码方法
Accept-Language: 浏览器申明自己接收的语言
Accept-Charset: 浏览器可接受的字符集
User-Agent: 客户端使用的操作系统和浏览器的名称和版本。
Content-Type: 例如：Content-Type: application/x-www-form-urlencoded
Referer: 告诉服务器我是从哪个链接过来的
Connection: 例如：keep-alive/close，HTTP1.1默认为前者
Host: 被请求资源的Internet主机和端口号（发送请求时，该头域是必需的，否则返回400）
Cookie: 保存的cookie信息
Content-Length: 请求消息正文的长度
Authorization: 授权信息，如果响应代码为401（未授权），则可以带此报头域请求进行验证
UA-Pixels，UA-Color，UA-OS，UA-CPU: 表示屏幕大小、颜色深度、操作系统和CPU类型
From: 发送者的email地址
Range: 可以请求实体的一个或者多个子范围，如果无条件GET包含Range请求头，响应状态码为206而不是200
```





**GET和POST的区别**：

1、GET提交的数据会放在URL之后，以?分割URL和传输数据，参数之间以&相连，如EditPosts.aspx?name=test1&id=123456. POST方法是把提交的数据放在HTTP包的Body中。
2、GET提交的数据大小有限制，最多只能有1024字节（因为浏览器对URL的长度有限制），而POST方法提交的数据没有限制。
3、GET方式需要使用Request.QueryString来取得变量的值，而POST方式通过Request.Form来获取变量的值。
4、GET方式提交数据，会带来安全问题，比如一个登录页面，通过GET方式提交数据时，用户名和密码将出现在URL上，如果页面可以被缓存或者其他人可以访问这台机器，就可以从历史记录获得该用户的账号和密码。



## 响应消息

格式如下

```
响应行（response line）；例如HTTP/1.1 200 OK
零个或多个首部（header）；
一个空⾏；
一个可选的报文主体（body）；
```

### ***HTTP常见的响应头***

```
Allow：服务器支持哪些请求方法（如GET、POST等）
Date：表示消息发送的时间，可以用setDateHeader来设置这个头以避免转换时间格式的麻烦
Expires：指明文档过期时间
P3P：用于跨域设置Cookie, 这样可以解决iframe跨域访问cookie的问题
Set-Cookie：用于把cookie发送到客户端浏览器，每一个写入cookie都会生成一个Set-Cookie。
ETag：和If-None-Match 配合使用。
Last-Modified：用于指示资源的最后修改日期和时间。Last-Modified也可用setDateHeader方法来设置。
Content-Type：WEB服务器告诉浏览器自己响应的对象的类型和字符集。
    IANA(The Internet Assigned Numbers Authority，互联网数字分配机构)定义了8个大类的媒体类型:
    application— (比如: application/vnd.ms-excel.)
    audio (比如: audio/mpeg.)
    image (比如: image/png.)
    message (比如,:message/http.)
    model(比如:model/vrml.)
    multipart (比如:multipart/form-data.)
    text(比如:text/html.)
    video(比如:video/quicktime.)
Content-Range: 
Content-Length：指明实体正文的长度
Content-Encoding：WEB服务器表明自己使用了什么压缩方法（gzip，deflate）压缩响应中的对象。
Content-Language：WEB服务器告诉浏览器自己响应的对象所用的自然语言。
Server：指明HTTP服务器用来处理请求的软件信息。例如：Server：Apache-Coyote/1.1
X-AspNet-Version：如果网站是用ASP.NET开发的，这个header用来表示ASP.NET的版本。
X-Powered-By：表示网站是用什么技术开发的。
Connection：例如：Connection: keep-alive    Connection: close
Location：用于重定向一个新的位置，包含新的URL地址。
Refresh：表示浏览器应该在多少时间之后刷新文档，以秒计。
WWW-Authenticate：该响应报头域必须被包含在401（未授权的）响应消息中，客户端收到401响应消息时候，并发送Authorization报头域请求服务器对其进行验证时，服务端响应报头就包含该报头域。
```

## http的状态响应码

**1\**(信息类)**：表示接收到请求并且继续处理

```
100——客户必须继续发出请求
101——客户要求服务器根据请求转换HTTP协议版本
```

**2\**(响应成功)**：表示动作被成功接收、理解和接受

```
200——表明该请求被成功地完成，所请求的资源发送回客户端
201——提示知道新文件的URL
202——接受和处理、但处理未完成
203——返回信息不确定或不完整
204——请求收到，但返回信息为空
205——服务器完成了请求，用户代理必须复位当前已经浏览过的文件
206——服务器已经完成了部分用户的GET请求
```

**3\**(重定向类)**：为了完成指定的动作，必须接受进一步处理

```
300——请求的资源可在多处得到
301——本网页被永久性转移到另一个URL
302——请求的网页被转移到一个新的地址，但客户访问仍继续通过原始URL地址，重定向，新的URL会在response中的Location中返回，浏览器将会使用新的URL发出新的Request。
303——建议客户访问其他URL或访问方式
304——自从上次请求后，请求的网页未修改过，服务器返回此响应时，不会返回网页内容，代表上次的文档已经被缓存了，还可以继续使用
305——请求的资源必须从服务器指定的地址得到
306——前一版本HTTP中使用的代码，现行版本中不再使用
307——申明请求的资源临时性删除
```

**4\**(客户端错误类)**：请求包含错误语法或不能正确执行

```
400——客户端请求有语法错误，不能被服务器所理解
401——请求未经授权，这个状态代码必须和WWW-Authenticate报头域一起使用
HTTP 401.1 - 未授权：登录失败
　　HTTP 401.2 - 未授权：服务器配置问题导致登录失败
　　HTTP 401.3 - ACL 禁止访问资源
　　HTTP 401.4 - 未授权：授权被筛选器拒绝
HTTP 401.5 - 未授权：ISAPI 或 CGI 授权失败
402——保留有效ChargeTo头响应
403——禁止访问，服务器收到请求，但是拒绝提供服务
HTTP 403.1 禁止访问：禁止可执行访问
　　HTTP 403.2 - 禁止访问：禁止读访问
　　HTTP 403.3 - 禁止访问：禁止写访问
　　HTTP 403.4 - 禁止访问：要求 SSL
　　HTTP 403.5 - 禁止访问：要求 SSL 128
　　HTTP 403.6 - 禁止访问：IP 地址被拒绝
　　HTTP 403.7 - 禁止访问：要求客户证书
　　HTTP 403.8 - 禁止访问：禁止站点访问
　　HTTP 403.9 - 禁止访问：连接的用户过多
　　HTTP 403.10 - 禁止访问：配置无效
　　HTTP 403.11 - 禁止访问：密码更改
　　HTTP 403.12 - 禁止访问：映射器拒绝访问
　　HTTP 403.13 - 禁止访问：客户证书已被吊销
　　HTTP 403.15 - 禁止访问：客户访问许可过多
　　HTTP 403.16 - 禁止访问：客户证书不可信或者无效
HTTP 403.17 - 禁止访问：客户证书已经到期或者尚未生效
404——一个404错误表明可连接服务器，但服务器无法取得所请求的网页，请求资源不存在。eg：输入了错误的URL
405——用户在Request-Line字段定义的方法不允许
406——根据用户发送的Accept拖，请求资源不可访问
407——类似401，用户必须首先在代理服务器上得到授权
408——客户端没有在用户指定的饿时间内完成请求
409——对当前资源状态，请求不能完成
410——服务器上不再有此资源且无进一步的参考地址
411——服务器拒绝用户定义的Content-Length属性请求
412——一个或多个请求头字段在当前请求中错误
413——请求的资源大于服务器允许的大小
414——请求的资源URL长于服务器允许的长度
415——请求资源不支持请求项目格式
416——请求中包含Range请求头字段，在当前请求资源范围内没有range指示值，请求也不包含If-Range请求头字段
417——服务器不满足请求Expect头字段指定的期望值，如果是代理服务器，可能是下一级服务器不能满足请求长
```

**5\**(服务端错误类)**：服务器不能正确执行一个正确的请求

```
HTTP 500 - 服务器遇到错误，无法完成请求
　　HTTP 500.100 - 内部服务器错误 - ASP 错误
　　HTTP 500-11 服务器关闭
　　HTTP 500-12 应用程序重新启动
　　HTTP 500-13 - 服务器太忙
　　HTTP 500-14 - 应用程序无效
　　HTTP 500-15 - 不允许请求 global.asa
　　Error 501 - 未实现
HTTP 502 - 网关错误
HTTP 503：由于超载或停机维护，服务器目前无法使用，一段时间后可能恢复正常
```

## HTTP认证方式

HTTP请求报头： Authorization
HTTP响应报头： WWW-Authenticate

HTTP认证是基于质询/回应(challenge/response)的认证模式。

## 解决HTTP无状态的问题

Web服务器不保存发送请求的Web浏览器进程的任何信息，比如客户获得一张网页之后关闭浏览器，然后再一次启动浏览器，再登陆该网站，但是服务器并不知道客户关闭了一次浏览器；因此HTTP协议属于无状态协议。

1. cookie
2. session
3. 隐藏式表单
4. url重写

## http测试

### 使用telnet

例如

```
telnet www.baidu.com 80
Ctrl + ]
Enter
GET /index.html HTTP/1.1
Enter

GET /index.html HTTP/1.1
connection: close
Host: www.baidu.com
Enter
```

使用curl



## URL详解

URL(Uniform Resource Locator) 地址用于描述一个网络上的资源， 基本**格式**如下

```
schema://host[:port#]/path/.../[;url-params][?query-string][#anchor]
　　scheme 指定低层使用的协议(例如：http, https, ftp)
　　host HTTP服务器的IP地址或者域名
　　port# HTTP服务器的默认端口是80，这种情况下端口号可以省略。如果使用了别的端口，必须指明，例如 http://www.cnblogs.com:8080/
　　path 访问资源的路径
　　url-params
　　query-string 发送给http服务器的数据
　　anchor- 锚
```

URL 的一个例子：

```
http://www.mywebsite.com/sj/test;id=8079?name=sviergn&x=true#stuff
Schema: http
host: www.mywebsite.com
path: /sj/test
URL params: id=8079
Query String: name=sviergn&x=true
Anchor: stuff
```

