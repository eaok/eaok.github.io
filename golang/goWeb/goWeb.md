# go web笔记

## 一、发送请求

### Client结构体

```go
type Client struct {
        Transport RoundTripper
        CheckRedirect func(req *Request, via []*Request) error
        Jar CookieJar
        Timeout time.Duration
}
```

### Transport结构体

```go
type Transport struct {
	idleMu     sync.Mutex
	wantIdle   bool           // user has requested to close all idle conns
	idleConn   map[connectMethodKey][]*persistConn // most recently used at end
	idleConnCh map[connectMethodKey]chan *persistConn
	idleLRU    connLRU
	reqMu      sync.Mutex
	reqCanceler map[*Request]func(error)
	altMu    sync.Mutex   // guards changing altProto only
	altProto atomic.Value // of nil or map[string]RoundTripper, key is URI scheme
	connCountMu          sync.Mutex
	connPerHostCount     map[connectMethodKey]int
	connPerHostAvailable map[connectMethodKey]chan struct{}

	Proxy func(*Request) (*url.URL, error)
	DialContext func(ctx context.Context, network, addr string) (net.Conn, error)
	Dial func(network, addr string) (net.Conn, error)
	DialTLS func(network, addr string) (net.Conn, error)

	TLSClientConfig *tls.Config
	TLSHandshakeTimeout time.Duration
	DisableKeepAlives bool
	DisableCompression bool
	MaxIdleConns int
	MaxIdleConnsPerHost int
	MaxConnsPerHost int
	IdleConnTimeout time.Duration
	ResponseHeaderTimeout time.Duration
	ExpectContinueTimeout time.Duration

	TLSNextProto map[string]func(authority string, c *tls.Conn) RoundTripper

	ProxyConnectHeader Header
	MaxResponseHeaderBytes int64
	nextProtoOnce sync.Once
	h2transport   h2Transport // non-nil if http2 wired up
}
```



### 生成requests

```go
resp, err := http.Get("http://example.com/")
if err != nil {
	// handle error
}
defer resp.Body.Close()
body, err := ioutil.ReadAll(resp.Body)

resp, err := http.Post("http://example.com/upload", "image/jpeg", &buf)
resp, err := http.PostForm("http://example.com/form", url.Values{
    "key": {"Value"}, 
    "id": {"123"}
})
```

### 带配置的请求

```go
tr := &http.Transport{
	MaxIdleConns:       10,
	IdleConnTimeout:    30 * time.Second,
	DisableCompression: true,
}
client := &http.Client{Transport: tr}
resp, err := client.Get("https://example.com")
if err != nil {
    log.Fatal(err)
}
defer resp.Body.Close()

body, err := ioutil.ReadAll(resp.Body)
if err != nil {
    log.Fatal(err)
}
fmt.Println(string(body))
```

### GET请求

```go
resp, err := http.Get("http://abced.com/" + "/user/false/lsj")
if err != nil {
    t.Log("query cluster failed", err.Error())
    t.FailNow()
}
defer resp.Body.Close()

var serviceResp ServiceResp
respByte, _ := ioutil.ReadAll(resp.Body)
```

设置header的GET请求

```go
req, _ := http.NewRequest("GET", "http://abced.com/" + "/user/false/lsj", nil)
// 比如说设置个token
req.Header.Set("token", "d8cdcf8427e")
// 再设置个json
req.Header.Set("Content-Type","application/json")

resp, err := (&http.Client{}).Do(req)
//resp, err := http.Get(serviceUrl + "/topic/query/false/lsj")
if err != nil {
    t.Log("query topic failed", err.Error())
    t.FailNow()
}
defer resp.Body.Close()

var serviceResp ServiceResp
respByte, _ := ioutil.ReadAll(resp.Body)
```

通过client设置参数

```go
tr := &http.Transport{
    MaxIdleConns:       10,
    IdleConnTimeout:    30 * time.Second,
    DisableCompression: true,
}
client := &http.Client{Transport: tr}
resp, err := client.Get("https://example.com")
if err != nil {
    log.Fatal(err)
}
defer resp.Body.Close()

body, err := ioutil.ReadAll(resp.Body)
if err != nil {
    log.Fatal(err)
}
```

### POST请求

```go
// 在别处定义
info := model.User{
    Desc:        "test UserInfo",
    UserId:      "lsj",
    TopicName:   "test",
    ClusterName: "test",
    Type:        1,
}

byte, _ := json.Marshal(info)
resp, err := http.Post("http://abced.com/" + "/user/save", "application/json", strings.NewReader(string(byte)))
if err != nil {
    t.Log("query info failed", err.Error())
    t.FailNow()
}
defer resp.Body.Close()

var serviceResp ServiceResp
respByte, _ := ioutil.ReadAll(resp.Body)
```

设置header 的POST请求

```go
// 在别处定义
info := model.User{
    Desc:        "test UserInfo",
    UserId:      "lsj",
    TopicName:   "test",
    ClusterName: "test",
    Type:        1,
}
byte, _ := json.Marshal(info)

req, _ := http.NewRequest("POST", "http://abced.com/" + "/user/false/lsj", strings.NewReader(string(byte)))
req.Header.Set("token", "00998ecf8427e")
resp, err := (&http.Client{}).Do(req)
if err != nil {
    t.Log("save topic failed", err.Error())
    t.FailNow()
}
defer resp.Body.Close()

var serviceResp ServiceResp
respByte, _ := ioutil.ReadAll(resp.Body)
```

## 二、接收请求

### 1.带附加配置的web服务器

```go
package main

import (
	"net/http"
)

func main() {
	server := http.Server{
		Addr:	"127.0.0.1:8080",
		Handler:	nil,
	}

	server.ListenAndServe()
    //server.ListenAndServe("cert.pem", "key.pem") //通过https提供服务
}
```

Server结构体

```go
type Server struct {
	Addr    string  // TCP address to listen on, ":http" if empty
	Handler Handler // handler to invoke, http.DefaultServeMux if nil

	TLSConfig *tls.Config

	ReadTimeout time.Duration
	ReadHeaderTimeout time.Duration
	WriteTimeout time.Duration
	IdleTimeout time.Duration

	MaxHeaderBytes int
	TLSNextProto map[string]func(*Server, *tls.Conn, Handler)
	ConnState func(net.Conn, ConnState)
	ErrorLog *log.Logger

	disableKeepAlives int32     // accessed atomically.
	inShutdown        int32     // accessed atomically (non-zero means we're in Shutdown)
	nextProtoOnce     sync.Once // guards setupHTTP2_* init
	nextProtoErr      error     // result of http2.ConfigureServer if used

	mu         sync.Mutex
	listeners  map[*net.Listener]struct{}
	activeConn map[*conn]struct{}
	doneChan   chan struct{}
	onShutdown []func()
}
```



### 2.处理器和处理器函数

#### 处理器：
就是拥有ServeHTTP方法的接口；

```go
package main

import (
	"fmt"
	"net/http"
)

type HelloHandler struct {}

func (h *HelloHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "hello!")
}

type WorldHandler struct {}

func (h *WorldHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "world!")
}

func main() {
	server := http.Server{
		Addr:	"127.0.0.1:8080",
	}
	hello := HelloHandler{}
	world := WorldHandler{}
	http.Handle("/hello", &hello)
	http.Handle("/world", &world)

	server.ListenAndServe()
}
```



#### 处理器函数：

与处理器拥有相同行为的函数；

```go
package main

import (
	"fmt"
	"net/http"
)

func hello(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "hello!")
}

func world(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "world!")
}

func main() {
	server := http.Server{
		Addr:	"127.0.0.1:8080",
	}
	http.HandleFunc("/hello", hello)
	http.HandleFunc("/world", world)

	server.ListenAndServe()
}
```

#### 串联处理器：

```go
package main

import (
	"fmt"
	"net/http"
)

type HelloHandler struct {}

func (h HelloHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "hello!")
}

func log(h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Printf("Handler called -%T log\n", h)
		h.ServeHTTP(w, r)
	})
}

func protect(h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Printf("Handler called -%T protect\n", h)
		h.ServeHTTP(w, r)
	})
}

func main() {
	server := http.Server{
		Addr:	"127.0.0.1:8080",
	}
	hello := HelloHandler{}
	http.Handle("/hello", protect(log(hello)))

	server.ListenAndServe()
}
```

#### 串联处理器函数：

```go
package main

import (
	"fmt"
	"net/http"
	"reflect"
	"runtime"
)

func hello(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "hello!")
}

func log(h http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		name := runtime.FuncForPC(reflect.ValueOf(h).Pointer()).Name()
		fmt.Println("Handler function called -" + name)
		h(w, r)
	}
}

func main() {
	server := http.Server{
		Addr:	"127.0.0.1:8080",
	}
	http.HandleFunc("/hello", log(hello))

	server.ListenAndServe()
}
```

## 三、处理请求

请求和响应的结构：

```
请求行或者响应行
零个或多个首部
空行
报文主体
```

Request结构体

```go
type Request struct {
    Method string
    URL *url.URL
    Proto      string // "HTTP/1.0"
    ProtoMajor int    // 1
    ProtoMinor int    // 0

    Header Header

    Body io.ReadCloser
    GetBody func() (io.ReadCloser, error)
    ContentLength int64

    TransferEncoding []string
    Close bool

    Host string
    Form url.Values
    PostForm url.Values
    MultipartForm *multipart.Form

    Trailer Header
    RemoteAddr string
    RequestURI string

    TLS *tls.ConnectionState
    Cancel <-chan struct{}

    Response *Response
}
```

Request结构体中的URL字段

```go
type URL struct {
	Scheme     string
	Opaque     string    // encoded opaque data
	User       *Userinfo // username and password information
	Host       string    // host or host:port
	Path       string    // path (relative paths may omit leading slash)
	RawPath    string    // encoded path hint (see EscapedPath method)
	ForceQuery bool      // append a query ('?') even if RawQuery is empty
	RawQuery   string    // encoded query values, without '?'
	Fragment   string    // fragment for references, without '#'
}
```

URL的一般格式：

```go
[scheme:][//[userinfo@]host][/]path[?query][#fragment]
scheme:opaque[?query][#fragment]
```

### 1.读取请求首部：

```go
h := r.Header
h := r.Header["Accept-Encoding"] //返回切片
h := r.Header.Get("Accept-Encoding") //返回字符串
```

### 2.读取请求主体中的数据：

```go
len := r.ContentLength		//获取主体数据的长度
body := make([]byte, len)
r.Body.Read(body)
fmt.Fprintln(w, string(body))
```

### 3.获取HTML表单：

enctype的属性有下面几种：

```
application/x-www-form-urlencoded	//传送简单文本数据时更好
multipart/form-data					//传送大量数据时更好
text/plain							//HTML5支持的
```

获取表单数据

```go
//application/x-www-form-urlencoded编码的表单数据
r.ParseForm()
fmt.Fprintln(w, r.Form)	//包含表单键值对和URL键值对
fmt.Fprintln(w, r.PostForm) //只包含表单键值对

//multipart/form-data编码的表单数据
r.ParseMultipartForm(1024)
rmt.Fprintln(w, r.MultipartForm) //包含两个映射，只含表单数据，第二个用于记录上传的文件

fmt.Fprintln(w, r.FormValue("hello")) //如果有多个，只取出第一个
fmt.Fprintln(w, r.PostFormValue("hello")) //只会返回表单键值对

```

### 4.接收上传的文件：

```go
//html中增加
enctype="multipart/form-data"
<input type="file" name="uploaded">

func process(w http.ResponseWriter, r *http.Request) {
    r.ParaseMultipartForm(1024)
    fileHeader := r.MultipartForm.File["uploaded"][0]
    file, err := fileHeader.Open()
    if err == nil {
        data, err := ioutil.ReadAll(file)
        if err == nil {
            fmt.Fprintln(w, string(data))
        }
    }
}

//使用FormFile 返回给定简直的第一个值
func process(w http.ResponseWriter, r *http.Request) {
    file, _, err := r.FormFile("uploaded")
    if err == nil {
        data, err := ioutil.ReadAll(file)
        if err == nil {
            fmt.Fprintln(w, string(data))
        }
    }
}
```

### 5.ResponseWriter

ResponseWriter接口

```go
type ResponseWriter interface {
        Header() Header
        Write([]byte) (int, error)
        WriteHeader(statusCode int)
}
```

例子：

```go
func writeHeaderExample(w http.ResponseWriter, r *http.Request) {
    w.WriteHeader(501)
    fmt.Fprintln(w, "No such service, try next door")
}

func headerExample(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Location", "http://google.com")
    w.WriteHeader(302) //执行后就不能对首部写入了，所以要提前写
}

func writeExample(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    post := &Post{
        User:		"Sau Sheong",
        Threads:	[]string{"first", "second", "third"},
    }
    json, _ := json.Marshal(post)
    w.Write(json)
}
```

### 6.cookie

#### Cookie结构体

```go
type Cookie struct {
	Name  string
	Value string

	Path       string    // optional
	Domain     string    // optional
	Expires    time.Time // optional
	RawExpires string    // for reading cookies only

	// MaxAge=0 means no 'Max-Age' attribute specified.
	// MaxAge<0 means delete cookie now, equivalently 'Max-Age: 0'
	// MaxAge>0 means Max-Age attribute present and given in seconds
	MaxAge   int
	Secure   bool
	HttpOnly bool
	SameSite SameSite
	Raw      string
	Unparsed []string // Raw text of unparsed attribute-value pairs
}
```

#### 将cookie发送到浏览器

```go
//用w.Header().Set和w.Header().Add添加
func setCookie(w http.ResponseWriter, r *http.Rquest) {
    c1 := http.Cookie{
        Name:		"first_cookie",
        Value:		"Go Web Programming",
        HttpOnly:	true,
    }
    c2 := http.Cookie{
        Name:		"second_cookie",
        Value:		"Manning Publications Co",
        HttpOnly:	true,
    }
    w.Header().Set("Set-Cookie", c1.String())
    w.Header().Add("Set-Cookie", c2.String())
}

//用SetCookie添加
func setCookie(w http.ResponseWriter, r *http.Rquest) {
    c1 := http.Cookie{
        Name:		"first_cookie",
        Value:		"Go Web Programming",
        HttpOnly:	true,
    }
    c2 := http.Cookie{
        Name:		"second_cookie",
        Value:		"Manning Publications Co",
        HttpOnly:	true,
    }
    http.SetCookie(w, &c1)
    http.SetCookie(w, &c2)
}
```

#### 从浏览器中获取cookie

```go
//从请求首部获取cookie
getCookie(w http.ResponseWriter, r *http.Request) {
    h := r.Header["Cookie"]
    fmt.Fprintln(w, h)
}

//使用Cookie方法和Cookies方法
getCookie(w http.ResponseWriter, r *http.Request) {
    c1, err := r.Cookie("first_cookie")
    if err != nil {
        fmt.Fprintln(w, "Cannot get the first cookie")
    }
    cs := r.Cookies()
    fmt.Fprintln(w, c1)
    fmt.Fprintln(w, cs)
}
```

#### 使用cookie实现闪现消息

```go
package main

import (
	"encoding/base64"
	"fmt"
	"net/http"
	"time"
)

func setMessage(w http.ResponseWriter, r *http.Request) {
	msg := []byte("hello world!")
	c := http.Cookie{
		Name:	"flash",
		Value:	base64.URLEncoding.EncodeToString(msg),
	}
	http.SetCookie(w, &c)
}

func showMessage(w http.ResponseWriter, r *http.Request) {
	c, err := r.Cookie("flash")
	if err != nil {
		if err == http.ErrNoCookie {
			fmt.Fprintln(w, "No message found")
		}
	} else {
		rc := http.Cookie{
			Name:		"flash",
			MaxAge:		-1,
			Expires:	time.Unix(1, 0),
		}
		http.SetCookie(w, &rc)
		val, _ := base64.URLEncoding.DecodeString(c.Value)
		fmt.Fprintln(w, string(val))
	}
}

func main() {
	server := http.Server{
		Addr:	"localhost:8080",
	}
	http.HandleFunc("/set_message", setMessage)
	http.HandleFunc("/show_message", showMessage)
	server.ListenAndServe()
}
```

## 四、模板引擎

模板引擎大部分定义在text/template库当中，小部分与HTML相关的功能定义在了html/template库里，动作默认使用两组大括号包围；

### 在处理器函数中使用模板引擎

```go
func process(w http.ResponseWriter, r *http.Rquest) {
    t, _ := template.ParseFiles("tmpl.html")
    //t, _ := template.ParseGlob("*.html") //目录只有一个文件时和上面一句相同
    t.Execute(w, "Hello World!")
}

//和上面的相同
func process(w http.ResponseWriter, r *http.Rquest) {
    t := template.New("tmpl.html")
    t, _ := t.ParseFiles("tmpl.html")
    t.Execute(w, "Hello World!")
}

//对字符串形式的模板进行分析
func process(w http.ResponseWriter, r *http.Rquest) {
	tmpl := ``
	t := tmplate.New("tmpl.html")
	t, _ = t.Parse(tmpl)
	t.Execute(w, "Hello World!")
}
```

在向ParseFiles传入单个文件时，返回一个模板，传入多个文件时，返回一个模板的集合；

处理分析模板时出现的错误

```go
t := template.Must(template.ParseFiles("tmpl.html"))
```

执行模板

```go
t, _ := template.ParseFiles("t1.html", "t2.html")
t.Execute(w, "Hello World!") //只有t1模板会被执行
t.ExecuteTemplate(w, "t2.html", "Hello World!") //执行t2模板
```

### 模板中的动作

![](https://cdn.jsdelivr.net/gh/eaok/img/web/goweb/templateAction.png)

### 模板自定义函数

```go
func formatDate(t time.Time) string {	//2.实现函数
    layout := "2006-01-02"
    return t.Format(layout)
}

func process(w http.ResponseWriter, r *http.Request) {
    funcMap := template.FuncMap{"fdate":formatDate}	//1.创建映射
    t := template.New("tmpl.html").Funcs(funcMap)	//3.绑定
    t, _ = t.ParseFiles("tmpl.html")
    t.Execute(w, time.Now())
}

//在模板中使用函数
{{ . | fdate }}
{{ fdate . }}
```

### 上下文感知

go语言的模板引擎可以根据内容所处的上下文改变其显示的内容；

不对html转义：

```go
func process(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("X-XSS-Protection", "0") //让浏览器关闭内置的XSS防御功能
    t, _ := template.ParseFiles("tmple.html")
    t.Execute(w, template.HTML(r.FormValue("comment")))
}
```







## 二、代码示例

简单的请求获取页面

```go
func main() {
    res, err := http.Get("https://www.baidu.com/"); // 返回响应对象指针
    if err != nil {
        panic(err)
    }
    defer res.Body.Close()                          // 最后关闭 响应 资源
    
    str, err := httputil.DumpResponse(res, true)
    if err != nil {
        panic(err)
    }
    fmt.Printf("%s", str)
}
resp, err := http.Get("http://example.com/")        // GET 
resp, err := http.Post("http://example.com/")       // POST
resp, err := http.PostForm("http://example.com/", url.Values{"foo": "bar"}) // 提交表单
```

复杂请求，带响应头等信息

```go
func main() {
    // 返回请求对象指针
    request, err := http.NewRequest(http.MethodGet,"https://www.baidu.com/", nil)
    request.Header.Add("User-Agent","Mozilla/5.0 ...")      // 添加头信息
    res, err := http.DefaultClient.Do(request)              // 默认简易版客户端访问
    if err != nil {
        panic(err)
    }
    defer res.Body.Close()
    str, err := httputil.DumpResponse(res, true)
    if err != nil {
        panic(err)
    }
    fmt.Printf("%s", str)
}
```

自定义客户端访问，可查看重定向，cookie等信息

```go
func main() {
    request, err := http.NewRequest(http.MethodGet,"https://www.baidu.com/", nil);
    request.Header.Add("User-Agent","Mozilla/5.0...")
    client := http.Client{              // 自定义客户端
        CheckRedirect: func(req *http.Request, via []*http.Request) error {
            fmt.Println(req)
            return nil
        },
        // ...
    }
    res, err := client.Do(request)
    if err != nil {
        panic(err)
    }
    defer res.Body.Close()
    str, err := httputil.DumpResponse(res, true)
    if err != nil {
        panic(err)
    }
    fmt.Printf("%s", str)
}
```

