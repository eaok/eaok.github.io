[toc]

# 概述

http协议连接是无状态的，所以服务器并不知道上一次浏览器做了什么样的操作，这样严重阻碍了交互式Web 应用程序的实现，出现吧下面四种技术来解决无状态的问题：

* 隐藏表单域

  <input type="hidden"/>，在隐藏的表单中存储用户信息

* URL重写

  .../?jsessionid=xxx

* Cookie


![](https://cdn.jsdelivr.net/gh/eaok/img/web/cookieAndSession/seesionAndCookie.png)

* Session

![](https://cdn.jsdelivr.net/gh/eaok/img/web/cookieAndSession/sessionFlow.png)



# 一、cookie

## cookie机制

如果不在浏览器中设置过期时间，cookie被保存在内存中，生命周期随浏览器的关闭而结束，这种cookie简称会话cookie。如果在浏览器中设置了cookie的过期时间，cookie被保存在硬盘中，关闭浏览器后，cookie数据仍然存在，直到过期时间结束才消失； Cookie是服务器发给客户端的特殊信息，cookie是以文本的方式保存在客户端，每次请求时都带上它。

cookie只能保存字符串类型，以文本的方式；单个cookie保存的数据不能超过4kb；针对cookie所存在的攻击：Cookie欺骗，Cookie截获；

## cookie应用场景：

1. 判断用户是否登陆过网站，以便下次登录时能够实现自动登录（或者记住密码）。如果我们删除cookie，则每次登录必须从新填写登录的相关信息。

2. 保存上次登录的时间等信息。

3. 保存上次查看的页面

4. 浏览计数

## cookie缺点：

1. 大小受限
2. 用户可以操作（禁用）cookie，使功能受限
3. 安全性较低
4. 有些状态不可能保存在客户端
5. 每次访问都要传送cookie给服务器，浪费带宽
6. cookie数据有路径（path）的概念，可以限制cookie只属于某个路径下

## 浏览器中cookie的字段

```js
//Name		Cookie唯一的名称，同名会出现覆盖。
//Value
//Domain	设置该值来确保对其子域是否有效，默认在当前域下有效。
//Path		指定Cookie在哪些路径下有效，默认是当前路径下。
//Expires/Max-Age
//Size
//HTTP
//Secure	指定之后只允许Cookie发送给https协议。
//SameSite
Set-Cookie: value[; expires=date][; domain=domain][; path=path][; secure]
```

## 在go中操作cookie

### Cookie结构体

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

### 将cookie发送到浏览器

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

### 从浏览器中获取cookie

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



# 二、session

Session用于保存每个用户的专用信息，变量的值保存在服务器端，通过SessionID来区分不同的客户。

## seesion机制

当服务器收到请求需要创建session对象时，首先会检查客户端请求中是否包含sessionid。如果有sessionid，服务器将根据该id返回对应session对象。如果客户端请求中没有sessionid，服务器会创建新的session对象，并把sessionid在本次响应中返回给客户端。通常使用cookie方式存储sessionid到客户端，在交互中浏览器按照规则将sessionid发送给服务器。如果用户禁用cookie，则要使用URL重写，可以通过response.encodeURL(url) 进行实现；API对encodeURL的结束为，当浏览器支持Cookie时，url不做任何处理；当浏览器不支持Cookie的时候，将会重写URL将SessionID拼接到访问地址后。

session通过类似与Hashtable的数据结构来保存，能支持任何类型的对象(session中可含有多个对象)；session大小没有限制；

## seesion应用场景：

1. 网上商城中的购物车
2. 保存用户登录信息
3. 将某些数据放入session中，供同一用户的不同页面使用
4. 防止用户非法登录

## seesion缺点：

1. Session保存的东西越多，就越占用服务器内存，对于用户在线人数较多的网站，服务器的内存压力会比较大
2. 依赖于cookie（sessionID保存在cookie），如果禁用cookie，则要使用URL重写，不安全
3. 创建Session变量有很大的随意性，可随时调用，不需要开发者做精确地处理，所以，过度使用session变量将会导致代码不可读而且不好维护。

## seesion流程

![](https://cdn.jsdelivr.net/gh/eaok/img/web/cookieAndSession/session.png)

##  单独使用beego的seesion模块

```go
import (
    "github.com/astaxie/beego/session"
)

var globalSessions *session.Manager

func init() {
    sessionConfig := &session.ManagerConfig{
        CookieName:"gosessionid", 		//客户端存储 cookie 的名字
        EnableSetCookie: true, 
        Gclifetime:3600,				//触发 GC 的时间
        Maxlifetime: 3600, 				//服务器端存储的数据的过期时间
        Secure: false,					//是否开启 HTTPS
        CookieLifeTime: 3600,			//客户端存储的 cookie 的时间
        ProviderConfig: "./tmp",
    }
    globalSessions, _ = session.NewManager("memory",sessionConfig)
    go globalSessions.GC()
}

//处理函数中可以这样调用：
func login(w http.ResponseWriter, r *http.Request) {
    sess, _ := globalSessions.SessionStart(w, r)
    defer sess.SessionRelease(w)
    username := sess.Get("username")
    if r.Method == "GET" {
        t, _ := template.ParseFiles("login.gtpl")
        t.Execute(w, nil)
    } else {
        sess.Set("username", r.Form["username"])
    }
}
```

globalSessions有下面的函数

```go
SessionStart 根据当前请求返回 session 对象
SessionDestroy 销毁当前 session 对象
SessionRegenerateId 重新生成 sessionID
GetActiveSession 获取当前活跃的 session 用户
SetHashFunc 设置 sessionID 生成的函数
SetSecure 设置是否开启 cookie 的 Secure 设置
```

返回的 session 对象是一个 Interface，包含下面的方法

```go
Set(key, value interface{}) error
Get(key interface{}) interface{}
Delete(key interface{}) error
SessionID() string
SessionRelease()
Flush() error
```



## 如果是在beego中，可以这样使用

```go
func (this *MainController) Get() {
    v := this.GetSession("asta")
    if v == nil {
        this.SetSession("asta", int(1))
        this.Data["num"] = 0
    } else {
        this.SetSession("asta", v.(int)+1)
        this.Data["num"] = v.(int)
    }
    this.TplName = "index.tpl"
}

//seesion有下面几个方法
SetSession(name string, value interface{})
GetSession(name string) interface{}
DelSession(name string)
SessionRegenerateID()
DestroySession()
```



# 三、WebStorage

WebStorage的目的是克服由cookie所带来的一些限制，当数据需要被严格控制在客户端时，不需要持续的将数据发回服务器；WebStorage两个主要目标：

（1）提供一种在cookie之外存储会话数据的路径。

（2）提供一种存储大量可以跨会话存在的数据的机制。HTML5的WebStorage提供了两种API：localStorage（本地存储）和sessionStorage（会话存储）。

## localStorage和sessionStorage

* 生命周期：

  localStorage的生命周期是永久的，关闭页面或浏览器之后localStorage中的数据也不会消失。localStorage除非主动删除数据，否则数据永远不会消失。

  sessionStorage的生命周期是在仅在当前会话下有效。sessionStorage引入了一个“浏览器窗口”的概念，sessionStorage是在同源的窗口中始终存在的数据。只要这个浏览器窗口没有关闭，即使刷新页面或者进入同源另一个页面，数据依然存在。但是sessionStorage在关闭了浏览器窗口后就会被销毁。同时独立的打开同一个窗口同一个页面，sessionStorage也是不一样的。

* 存储大小：localStorage和sessionStorage的存储数据大小一般都是：5MB

* 存储位置：localStorage和sessionStorage都保存在客户端，不与服务器进行交互通信。

* 存储内容类型：localStorage和sessionStorage只能存储字符串类型，对于复杂的对象可以使用ECMAScript提供的JSON对象的stringify和parse来处理

* 获取方式：localStorage：window.localStorage;；sessionStorage：window.sessionStorage;。

* 应用场景：localStoragese：常用于长期登录（+判断用户是否已登录），适合长期保存在本地的数据。sessionStorage：敏感账号一次性登录；

## WebStorage的优点：

* 存储空间更大：cookie为4KB，而WebStorage是5MB；

* 节省网络流量：WebStorage不会传送到服务器，存储在本地的数据可以直接获取，也不会像cookie一样美词请求都会传送到服务器，所以减少了客户端和服务器端的交互，节省了网络流量；

* 对于那种只需要在用户浏览一组页面期间保存而关闭浏览器后就可以丢弃的数据，sessionStorage会非常方便；

* 快速显示：有的数据存储在WebStorage上，再加上浏览器本身的缓存。获取数据时可以从本地获取会比从服务器端获取快得多，所以速度更快；

* 安全性：WebStorage不会随着HTTP header发送到服务器端，所以安全性相对于cookie来说比较高一些，不会担心截获，但是仍然存在伪造问题；

* WebStorage提供了一些方法，数据操作比cookie方便；

  setItem (key, value) ——  保存数据，以键值对的方式储存信息

  getItem (key) ——  获取数据，将键值传入，即可获取到对应的value值

  removeItem (key) ——  删除单个数据，根据键值移除对应的信息

  clear () ——  删除所有的数据

  key (index) —— 获取某个索引的key