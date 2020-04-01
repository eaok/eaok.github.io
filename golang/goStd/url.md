# url包

## 一、url包中的方法

URL对象

```go
//获取URL对象
func Parse(rawurl string) (*URL, error)
func ParseRequestURI(rawurl string) (*URL, error)

```

URL结构体

```go
type URL struct {
        Scheme     string
        Opaque     string    // encoded opaque data
        User       *Userinfo // username and password information
        Host       string    // host or host:port
        Path       string    // path (relative paths may omit leading slash)
        RawPath    string    // encoded path hint (see EscapedPath method); 
        ForceQuery bool      // append a query ('?') even if RawQuery is empty; 
        RawQuery   string    // encoded query values, without '?'
        Fragment   string    // fragment for references, without '#'
}
```

## 二、代码示例

```go
str := "https://root:123456@www.baidu.com:8080/login/xxx?&name=xiaoqing&age=24#fff"
u, err := url.Parse(str)
if err == nil {
    scheme := u.Scheme
    fmt.Println(scheme)     // "https"
    
    opaque := u.Opaque
    fmt.Println(opaque)     // ""
    
    user := u.User
    fmt.Println(user)       // "root:123456"
    
    host := u.Host
    fmt.Println(host)       // "www.baidu.com:8080"
    
    path := u.Path
    fmt.Println(path)       // "/login/xxx"
    
    rawPath := u.RawPath
    fmt.Println(rawPath)    // ""
    
    forceQuery := u.ForceQuery
    fmt.Println(forceQuery) // "false"
    
    rawQuery := u.RawQuery
    fmt.Println(rawQuery)   // "&name=xiaoqing&age=24"
    
    fragment := u.Fragment
    fmt.Println(fragment)   // "fff"
}
```



