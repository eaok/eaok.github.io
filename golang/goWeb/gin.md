[TOC]



## 一、Gin

**Gin文档**：https://gin-gonic.com/zh-cn/docs/



**安装Gin**: 

```bash
go get -u github.com/gin-gonic/gin
```

或者使用go module，go会自动下载依赖，下载的依赖信息都会保存在 $GOPATH/pkg/mod/ ；



**简单示例**：

> `main.go`
>
> ```go
> package main
> 
> import (
> 	initRouter "gin_hello/initRouter"
> )
> 
> func main() {
> 	router := initRouter.SetupRouter()
> 
> 	err := router.Run()
> 	if err != nil {
> 		panic(err)
> 	}
> }
> ```
>
> `initRouter.go`
>
> ```go
> package initRouter
> 
> import (
> 	"github.com/gin-gonic/gin"
> 	"net/http"
> )
> 
> func SetupRouter() *gin.Engine {
> 	router := gin.Default()
> 
> 	// 添加 Get 请求路由
> 	router.GET("/", func(context *gin.Context) {
> 		context.String(http.StatusOK, "hello gin")
> 	})
> 
> 	return router
> }
> ```
>
> 单元测试`index_test.go`
>
> ```go
> package test
> 
> import (
> 	"gin_hello/initRouter"
> 	"github.com/stretchr/testify/assert"
> 	"net/http"
> 	"net/http/httptest"
> 	"testing"
> )
> 
> func TestIndexGetRouter(t *testing.T) {
> 	router := initRouter.SetupRouter()
> 	w := httptest.NewRecorder()
> 	req, _ := http.NewRequest(http.MethodGet, "/", nil)
> 	router.ServeHTTP(w, req)
> 
> 	assert.Equal(t, http.StatusOK, w.Code)
> 	assert.Equal(t, "hello gin", w.Body.String())
> }
> ```
>
> 此项目的目录结构：
>
> ```bash
> gin_hello
> ├── go.mod
> ├── go.sum
> ├── initRouter
> │   └── initRouter.go
> ├── main.go
> └── test
>     └── index_test.go
> ```
>
> 
>
> 运行项目：
>
> ```bash
> go run main.go
> ```
>
> 单元测试：
>
> ```bash
> go test ./test
> ```



## 二、Gin Router

### 服务器

#### 默认服务器

```go
func main() {
	router := gin.Default()
	router.Run()
}
```

#### http服务器

```go
func main() {
	router := gin.Default()
	http.ListenAndServe(":8080", router)
}
```

自定义配置的HTTP服务器：

```go
func main() {
	router := gin.Default()
	s := &http.Server{
		Addr: ":8080",
		Handler: router,
		ReadTimeout: 10 * time.Second,
		WriteTimeout: 10 * time.Second,
		MaxHeaderBytes: 1 << 20,
	}
	s.ListenAndServe()
}
```



### 路由

#### 基本路由

基本路由 Gin 框架中采⽤的路由库是 httprouter。

```go
// 创建带有默认中间件(⽇志与恢复中间件)的路由:
router := gin.Default()

//创建不带中间件的路由：
//router := gin.New()

router.GET("/someGet", getting)
router.POST("/somePost", posting)
router.PUT("/somePut", putting)
router.DELETE("/someDelete", deleting)
router.PATCH("/somePatch", patching)
router.HEAD("/someHead", head)
router.OPTIONS("/someOptions", options)
```

Gin 的路由⽀持 GET , POST , PUT , DELETE , PATCH , HEAD , OPTIONS 请求；

Any方法，可以同时⽀持以上的所有请求：

```go
router.Any("/some", someHandler)
```



NoRoute方法可以处理没有匹配到路由的请求

```go
router.NoRoute(func(c *gin.Context) {
	c.HTML(http.StatusNotFound, "views/404.html", nil)
})
```



#### 参数路由

不⽀持路由正则表达式。

##### API参数

api 参数通过Context的Param⽅法来获取：

```go
// 此 handler 将匹配 /user/john 但不会匹配 /user/ 或者 /user
router.GET("/user/:name", func(c *gin.Context) {
    name := c.Param("name")
    c.String(http.StatusOK, "Hello %s", name)
})

// 此 handler 将匹配 /user/john/ 和 /user/john/send
router.GET("/user/:name/*action", func(c *gin.Context) {
    name := c.Param("name")
    action := c.Param("action")
    message := name + " is " + action
    c.String(http.StatusOK, message)
})
```



##### URL参数

URL中的`query string`可以通过DefaultQuery 或 Query ⽅法获取：

```go
//当参数不存在的时候，提供⼀个默认值
c.DefaultQuery("key", "default value")

//当参数不存在的时候，返回空字串
c.Query("key")	//相当于 c.Request.URL.Query().Get("key")
```

```go
router.GET("/url", func(c *gin.Context) {
    defaultName := c.DefaultQuery("name", "Guest") //可设置默认值
    queryName := c.Query("name")
    str := fmt.Sprintf("defaultName=%s queryName=%s ", defaultName, queryName)
	c.String(http.StatusOK, str)
})
```



##### 表单参数

http的报⽂体传输数据常⻅的格式：

* multipart/form-data

* ##### application/x-www-form-urlencoded

* application/json

* application/xml

表单参数通过 PostForm 方法获取，解析的时前两种格式的参数：

```go
router.POST("/form", func(c *gin.Context) {
    type1 := c.DefaultPostForm("type", "alert")
    username := c.PostForm("username")
    password := c.PostForm("password")
    //hobbys := c.PostFormMap("hobby")
    //hobbys := c.QueryArray("hobby")
    hobbys := c.PostFormArray("hobby")

    str := fmt.Sprintf("type1=%s, username=%s, password=%s, hobbys= %v",
                       type1, username, password, hobbys)
    c.String(http.StatusOK, str)
})
```

用于POST请求的页面：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>登录</title>
</head>
<body>
    <form action="http://127.0.0.1:8080/form" method="post" enctype="application/x-www-form-urlencoded">
        ⽤户名：<input type="text" name="username">
        <br>
        密&nbsp&nbsp&nbsp码：<input type="password" name="password">
        <br>
        兴&nbsp&nbsp&nbsp趣：
        <input type="checkbox" value="girl" name="hobby">⼥⼈
        <input type="checkbox" value="game" name="hobby">游戏
        <input type="checkbox" value="money" name="hobby">⾦钱
        <br>
        <input type="submit" value="登录">
    </form>
</body>
</html>
```



使⽤PostForm形式，注意必须要设置Post的type，同时此⽅法中忽略URL中带的参数,所有的参数需要从Body中获得



##### 文件上传

###### 单个文件

路由函数：

```go
router.POST("/upload", func(c *gin.Context) {
    // 单文件
    file, err := c.FormFile("file")
    if err != nil {
        panic(err)
    }
    log.Println(file.Filename)

    // 上传文件至指定目录
    c.SaveUploadedFile(file, file.Filename)
    c.String(http.StatusOK, fmt.Sprintf("'%s' uploaded!", file.Filename))
})
```

文件上传页面file.html：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>上传单个文件</title>
</head>
<body>
    <form action="http://127.0.0.1:8080/upload" method="post"
          enctype="multipart/form-data">
        头像：
        <input type="file" name="file">
        <br>
        <input type="submit" value="提交">
    </form>
</body>
</html>
```

也可以使用curl测试：

```bash
curl -X POST localhost:8080/upload \
-F "file=@/home/beaver/node-v10.16.0-linux-x64.tar.xz" \
-H "Content-Type: multipart/form-data"
```



###### 多个文件

上传多个文件，就是多⼀次遍历文件，然后⼀次copy数据存储即可：

```go
router.POST("/uploads", func(c *gin.Context) {
    form, err := c.MultipartForm()
    if err != nil {
        c.String(http.StatusBadRequest, fmt.Sprintf("get form err: %s", err.Error()))
        return
    }
    files := form.File["files"]

    for _, file := range files {
        log.Println(file.Filename)

        if err := c.SaveUploadedFile(file, file.Filename); err != nil {
            c.String(http.StatusBadRequest, fmt.Sprintf("upload file err:%s", err.Error()))
            return
        }
    }
    c.String(http.StatusOK, fmt.Sprintf("Uploaded successfully %d files ", len(files)))
})
```

使用curl测试：

```bash
curl -X POST http://localhost:8080/uploads \
-F "files=@/home/beaver/node-v10.16.0-linux-x64.tar.xz" \
-F "files=@/home/beaver/linux-5.5.6.tar.xz" \
-H "Content-Type: multipart/form-data"
```



#### 路由组

路由分组是为了⽅便⼀部分相同的URL的管理，通常用在划分业务逻辑或划分API版本；

```go
v1 := router.Group("/v1")
{
    v1.GET("/login", anyHandler)
    v1.GET("/submit", anyHandler)
}
```

路由组也是⽀持嵌套的，例如：

```go
shopGroup := router.Group("/v1")
{
    shopGroup.GET("/login", anyHandler)
    shopGroup.GET("/submit", anyHandler)

    xx := shopGroup.Group("xx")
    {
        xx.GET("/oo", anyHandler)
        xx.GET("/gg", anyHandler)
    }
}
```



### 路由原理

Gin框架中的路由使⽤的是httprouter这个库，其基本原理就是构造⼀个路由地址的前缀树。



## 三、Gin Model

### 数据解析绑定

模型绑定可以将请求体绑定给⼀个类型，就是根据Body数据类型，将数据赋值到指定的结构体变量中 (类似于序列化和反序列化)。⽬前Gin⽀持JSON、XML、YAML和标准表单值的绑定。使用时，需要在要绑定的所有字段上，设置相应的tag，如果一个字段的 tag 加上了 binding:"required"，但绑定时是空值, Gin 会报错。

**Gin提供了两套绑定⽅法**：

1. **Must bind**

   ⽅法：Bind , BindJSON , BindXML , BindQuery , BindYAML 

   ⾏为：这些⽅法使⽤`MustBindWith`。如果存在绑定错误，则⽤c终⽌请求，使 ⽤ `c.AbortWithError (400) .SetType (ErrorTypeBind)` 即可。将响应状态代码设置为 400，`Content-Type header`设置为 `text/plain;charset = utf - 8` 。请注意，如果在此 之后设置响应代码，将会受到警告： `[GIN-debug][WARNING] Headers were already written. Wanted to override status code 400 with 422` 如果想更好地控制⾏为，可以考虑使⽤ShouldBind等效⽅ 法。

2. **Should bind**

   ⽅ 法： ShouldBind , ShouldBindJSON , ShouldBindXML , ShouldBindQuery , ShouldBindYAML

   ⾏为：这些⽅法使⽤`ShouldBindWith`。如果存在绑定错误，则返回错误，开发⼈员有责任适当地处理请求和错误。



使用 Bind 方法时，Gin 会尝试根据 Content-Type 推断如何绑定。 如果你明确知道要绑定什么，可以使用 `MustBindWith` 或 `ShouldBindWith`。



### JSON/XML绑定

将request中的Body中的数据按照JSON格式进⾏解析，解析后存储到结构体对象中。

```go
type Login struct {
	User     string `form:"username" json:"user" xml:"user"  binding:"required"`
	Password string `form:"password" json:"password" xml:"password" binding:"required"`
}

func bindJSON(c *gin.Context) {
	var json Login
    //var xml Login
    //if err := c.ShouldBindXML(&xml); err != nil {
	if err := c.ShouldBindJSON(&json); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if json.User != "pan" || json.Password != "123" {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "unauthorized"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "you are logged in"})
}
```

调用c.JSON则返回json数据，其中gin.H封装了⽣成json的⽅式，对于嵌套json的实现，嵌套gin.H即可。

使用curl测试：

```bash
curl -v -X POST localhost:8080/loginJSON \
  -H 'contenttype:application/json' \
  -d '{"user":"pan","password":"123"}'
```



### Form表单

将request中的Body中的数据解析到form中

```go
func bindForm(c *gin.Context) {
	var form Login

	// 根据 Content-Type Header 推断使用哪个绑定器
	//if err := c.Bind(&form); err != nil {
	//if err := c.BindWith(&form, binding.Form); err != nil {
	//if err := c.ShouldBindWith(&form, binding.Form); err != nil {
	if err := c.ShouldBind(&form); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if form.User != "pan" || form.Password != "123" {
		c.JSON(http.StatusUnauthorized, gin.H{"status": "unauthorized"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "you are logged in"})
}
```

测试：

```bash
curl -X POST localhost:8080/loginForm \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'username=pan&password=123'
```



### URI绑定

```go
type Person struct {
	ID string `uri:"id" binding:"required,uuid"`
	Name string `uri:"name" binding:"required"`
}

func bindUri(c *gin.Context) {
	var person Person
	if err := c.ShouldBindUri(&person); err != nil {
		c.JSON(400, gin.H{"msg": err})
		return
	}
	c.JSON(200, gin.H{"name": person.Name, "uuid": person.ID})
}
```

测试：

```bash
curl -v -X POST localhost:8080/login/pan/987fbc97-4bed-5078-9f07-9141ba07c9f3
```



### 绑定表单数据至嵌套结构体

```go
type StructA struct {
	FieldA string `form:"field_a"`
}

type StructB struct {
	NestedStruct StructA
	FieldB string `form:"field_b"`
}

type StructC struct {
	NestedStructPointer *StructA
	FieldC string `form:"field_b"`
}

type StructD struct {
	NestedAnonyStruct struct {
		FieldX string `form:"field_a"`
	}
	FieldD string `form:"field_b"`
}

func GetData(c *gin.Context) {
	var b StructB
	var cc StructC
	var d StructD

	if err := c.Bind(&b); err != nil {
		c.JSON(400, gin.H{"msg": err})
		return
	}
	if err := c.Bind(&cc); err != nil {
		c.JSON(400, gin.H{"msg": err})
		return
	}
	if err := c.Bind(&d); err != nil {
		c.JSON(400, gin.H{"msg": err})
		return
	}

	c.JSON(200, gin.H{"a": b.NestedStruct, "b": b.FieldB})
	c.JSON(200, gin.H{"a": cc.NestedStructPointer, "c": cc.FieldC})
	c.JSON(200, gin.H{"x": d.NestedAnonyStruct, "d": d.FieldD})
}
```

测试：

```bash
curl localhost:8080/get_data?field_a=hello&field_b=world
```



## 四、Gin 响应

请求可以使⽤不同的 content-type ，响应也如此，响应会有html，text，plain，json和xml 等。

### JSON/XML/YAML渲染

gin.H 是 map[string]interface{} 的一种快捷方式

```go
func main() {
	r := gin.Default()

	r.GET("/someJSON", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"message": "hey", "status": http.StatusOK})
	})

	r.GET("/moreJSON", func(c *gin.Context) {
		// 你也可以使用一个结构体
		var msg struct {
			Name    string `json:"user"`
			Message string
			Number  int
		}
		msg.Name = "Lena"
		msg.Message = "hey"
		msg.Number = 123
		// 注意 msg.Name 在 JSON 中变成了 "user"
		// 将输出：{"user": "Lena", "Message": "hey", "Number": 123}
		c.JSON(http.StatusOK, msg)
	})

	r.GET("/someXML", func(c *gin.Context) {
		c.XML(http.StatusOK, gin.H{"message": "hey", "status": http.StatusOK})
	})

	r.GET("/someYAML", func(c *gin.Context) {
		c.YAML(http.StatusOK, gin.H{"message": "hey", "status": http.StatusOK})
	})

	r.GET("/someProtoBuf", func(c *gin.Context) {
		reps := []int64{int64(1), int64(2)}
		label := "test"
		// protobuf 的具体定义写在 testdata/protoexample 文件中。
		data := &protoexample.Test{
			Label: &label,
			Reps:  reps,
		}
		// 请注意，数据在响应中变为二进制数据
		// 将输出被 protoexample.Test protobuf 序列化了的数据
		c.ProtoBuf(http.StatusOK, data)
	})

	r.Run(":8080")
}
```



### 模板

#### HTML模板渲染

先要使用 LoadHTMLGlob() 或者 LoadHTMLFiles() ⽅法来加载模板⽂件:

```go
router.LoadHTMLGlob("templates/*.html")
//router.LoadHTMLFiles("templates/template1.html", "templates/template2.html")
router.GET("/index", func(c *gin.Context) {
    c.HTML(http.StatusOK, "index.html", gin.H{
        "title": "Main website",
    })
})
```

使用不同目录下的模板

```go
router.LoadHTMLGlob("templates/**/*")
router.GET("/posts/index", func(c *gin.Context) {
    c.HTML(http.StatusOK, "posts/index.html", gin.H{
        "title": "Posts",
    })
})
router.GET("/users/index", func(c *gin.Context) {
    c.HTML(http.StatusOK, "users/index.html", gin.H{
        "title": "Users",
    })
})
```

使用html/template渲染模板：

```go
router.GET("/index", func(c *gin.Context) {
    html := template.Must(template.ParseFiles("templates/posts/index.html"))
    router.SetHTMLTemplate(html)
    c.HTML(http.StatusOK, "posts/index.html", gin.H{
        "title": "Posts",
    })
})
```



#### 自定义模板函数

定义并映射模板函数：

```go
router.SetFuncMap(template.FuncMap{
    "unsafe": func(str string) template.HTML {
        return template.HTML(str)
    },
})
```

调用模板：

```go
router.GET("/unsafe", func(c *gin.Context) {
    //根据完整文件名渲染模板，并传递参数
    c.HTML(http.StatusOK, "unsafe.html", gin.H{
        "content": "<a href='https://www.lianshiclass.com'>lianshi</a>",
    })
})
```

模板文件`safe.html`

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>unsafe</title>
</head>
<body>

{{ .content }}
<br>
{{ .content | unsafe }}

</body>
</html>
```



#### 使用模板继承

Gin框架默认都是使⽤单模板，如果需要使⽤ block template 功能，可以通过`"github.com/gincontrib/multitemplate" `库实现。

假设我们项⽬⽬录下的templates⽂件夹下有以下模板⽂件，其中 home.html 和 index.html 继承了 base.html ：

```bash
templates/
├── includes
│   ├── home.html
│   └── index.html
└── layouts
    └── base.html
```

定义⼀个 loadTemplates 函数如下：

```go
func loadTemplates(templatesDir string) multitemplate.Renderer {
	r := multitemplate.NewRenderer()
	layouts, err := filepath.Glob(templatesDir + "/layouts/*.html")
	if err != nil {
		panic(err.Error())
	}
	includes, err := filepath.Glob(templatesDir + "/includes/*.html")
	if err != nil {
		panic(err.Error())
	}
	// 为layouts/和includes/目录生成 templates map
	for _, include := range includes {
		layoutCopy := make([]string, len(layouts))
		copy(layoutCopy, layouts)
		files := append(layoutCopy, include)
		r.AddFromFiles(filepath.Base(include), files...)
	}
	return r
}
```

调用模板：

```go
router.HTMLRender = loadTemplates("./templates")
router.GET("/base/index", func(c *gin.Context) {
    c.HTML(http.StatusOK, "index.html", gin.H{
        "content": "/base/index",
    })
})
router.GET("/base/home", func(c *gin.Context) {
    c.HTML(http.StatusOK, "home.html", gin.H{
        "content": "/base/home",
    })
})
```



### 文件响应

可以向客户端展示本地的⼀些⽂件信息

```go
func main() {
	router := gin.Default()

	//把images映射到static文件系统
	router.Static("static", "images")
	tmpl := `<img src="static/strawberry.jpg" alt="" width="400">`
	t := template.New("tmpl.html")
	router.SetHTMLTemplate(template.Must(t.Parse(tmpl)))
	router.GET("/index", func(c *gin.Context) {
		c.HTML(http.StatusOK, "tmpl.html", nil)
	})

	//显示指定⽂件夹下的所有⽂件
	router.StaticFS("/dir", http.Dir("."))
	router.StaticFS("/home", http.Dir("/home/beaver"))

	//显示指定⽂件
	router.StaticFile("/file", "./images/strawberry.jpg")

	router.Run(":8080")
}
```



### 重定向

```go
func main() {
	r := gin.Default()

	//http重定向
	r.GET("/redirect", func(c *gin.Context) {
		c.Redirect(http.StatusFound, "http://www.baidu.com/")
	})

	//路由重定向
	r.GET("/test", func(c *gin.Context) {
		c.Request.URL.Path = "/test2"
		r.HandleContext(c)
	})
	r.GET("/test2", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"hello": "world"})
	})

	r.Run(":8080")
}
```



### 同步异步

goroutine 机制可以⽅便地实现异步处理。当在中间件或处理程序中启动新的Goroutines时，应该使⽤只读的副本。

```go
func main() {
	r := gin.Default()

	//1. 异步
	r.GET("/async", func(c *gin.Context) {
		// goroutine 中只能使⽤只读的上下⽂ c.Copy()
		cCp := c.Copy()
		go func() {
			time.Sleep(5 * time.Second)
			// 注意使⽤只读上下⽂
			log.Println("Done! in path " + cCp.Request.URL.Path)
		}()
	})

	//2. 同步
	r.GET("/sync", func(c *gin.Context) {
		time.Sleep(5 * time.Second)
		// 注意可以使⽤原始上下⽂
		log.Println("Done! in path " + c.Request.URL.Path)
	})

	r.Run(":8080")
}
```



## 五、Gin Middleware

### 中间件middleware

Go的net/http设计的⼀⼤特点就是特别容易构建中间件。gin也提供了类似的中间件。需要注意的是中间件只对注册过的路由函数起作⽤。对于分组路由，嵌套使⽤中间件，可以限定中间件的作⽤范围。中间件分为全局中间件，单个路由中间件和群组中间件。
Context 是 Gin 的核心, 它的构造如下:

```go
type Context struct {
	writermem responseWriter
	Request   *http.Request
	Writer    ResponseWriter

	Params   Params
	handlers HandlersChain
	index    int8
	fullPath string

	engine *Engine
	Keys map[string]interface{}
	Errors errorMsgs
	Accepted []string
	queryCache url.Values
	formCache url.Values
}
```

其中 handlers 我们通过源码可以知道就是 `[]HandlerFunc`：

```go
type HandlerFunc func(*Context)
```

所以中间件和我们普通的 HandlerFunc 没有任何区别。



### 添加中间件

默认的全局中间件：

```go
// 新建一个没有任何默认中间件的路由
r := gin.New()

// 全局中间件
// Logger 中间件将日志写入 gin.DefaultWriter，即使你将 GIN_MODE 设置为 release。
r.Use(gin.Logger())

// Recovery 中间件会 recover 任何 panic。如果有 panic 的话，会写入 500。
r.Use(gin.Recovery())
```

自定义的中间件函数：

```go
func MiddleWare() gin.HandlerFunc {
	return func(c *gin.Context) {
		t := time.Now()
		fmt.Println("before middleware...")
		//设置request变量到Context的Key中,通过Get等函数可以取得
		c.Set("request", "client_request")

		//发送request之前
		c.Next()
		//发送requst之后

		// 这个c.Write是ResponseWriter,我们可以获得状态等信息
		status := c.Writer.Status()
		fmt.Println("after middleware,", status)
		t2 := time.Since(t)
		fmt.Println("time:", t2)
	}
}
```

单个路由的中间件：

```go
r.GET("/before", MiddleWare(), func(c *gin.Context) {
    request := c.MustGet("request").(string)
    fmt.Println("request:", request)
    c.JSON(http.StatusOK, gin.H{
        "middle_request": request,
    })
})
```

为组路由添加中间件：

```go
//v1 := r.Group("/v1", MiddleWare())
v1 := r.Group("/v1")
v1.Use(MiddleWare())
{
    v1.GET("/middleware", func(c *gin.Context) {
        //获取gin上下文中的变量
        request := c.MustGet("request").(string)
        req, _ := c.Get("request")
        fmt.Println("request:", request, req)

        c.JSON(http.StatusOK, gin.H{
            "middle_request": request,
            "request":        req,
        })
    })
}
```

全局中间件：

```go
r.Use(MiddleWare())
r.GET("/router", func(c *gin.Context) {
    request := c.MustGet("request").(string)
    fmt.Println("request:", request)

    c.JSON(http.StatusOK, gin.H{
        "middle_request": request,
    })
})
```



### 中间件的几个方法

#### Next()方法

`c.Next()`的核心代码如下：

```go
func (c *Context) Next() {
	c.index++
	for c.index < int8(len(c.handlers)) {
		c.handlers[c.index](c)
		c.index++
	}
}
```

因为 handlers 是 slice ，所以后来者中间件会追加到尾部。这样就形成了形如 m1(m2(f())) 的调⽤链。正如上⾯数字① ② 标注的⼀样, 我们会依次执⾏如下的调用：

```bash
m1① -> m2① -> f -> m2② -> m1②
```

#### Abort()方法

停止嵌套的调用下一个处理函数，源码如下：

```go
func (c *Context) Abort() {
	c.index = abortIndex
}
```

#### Set()/Get()方法

往`gin.Context`上存值和取值；

```go
func (c *Context) Set(key string, value interface{}) {
	if c.Keys == nil {
		c.Keys = make(map[string]interface{})
	}
	c.Keys[key] = value
}

func (c *Context) Get(key string) (value interface{}, exists bool) {
	value, exists = c.Keys[key]
	return
}
```



### Gin自带的鉴权

中间件最⼤的作用，莫过于⽤于⼀些记录log，错误handler，还有就是对部分接⼝的鉴权。

先定义私有数据：

```go
var secrets = gin.H{
	"pan": gin.H{"email": "pan@gmail.com", "phone": "123456"},
}
```

然后使⽤ gin.BasicAuth 中间件，设置授权⽤户：

```go
authorized := r.Group("/admin", gin.BasicAuth(gin.Accounts{
    "pan":    "123456",
    "golang": "123",
}))
```

最后定义路由：

```go
authorized.GET("/secrets", func(c *gin.Context) {
    // 获取提交的用户名（AuthUserKey）
    user := c.MustGet(gin.AuthUserKey).(string)
    if secret, ok := secrets[user]; ok {
        c.JSON(http.StatusOK, gin.H{"user": user, "secret": secret})
    } else {
        c.JSON(http.StatusOK, gin.H{"user": user, "secret": "NO SECRET :("})
    }
})
```



### 通过中间件对HTTPS的支持

获取证书：

* 申请域名
* 给域名申请免费的证书
* 下载对应的pem和key文件

示例代码：

```go
package main

import (
    "github.com/gin-gonic/gin"
    "github.com/unrolled/secure"
)

func main() {
    router := gin.Default()
    router.Use(TlsHandler())

    router.RunTLS(":8080", "ssl.pem", "ssl.key")
}

func TlsHandler() gin.HandlerFunc {
    return func(c *gin.Context) {
        secureMiddleware := secure.New(secure.Options{
            SSLRedirect: true,
            SSLHost:     "localhost:8080",
        })
        err := secureMiddleware.Process(c.Writer, c.Request)
        if err != nil {
            return
        }

        c.Next()
    }
}
```



