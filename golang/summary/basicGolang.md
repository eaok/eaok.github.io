[toc]



# 一、golang环境

## 1.1 环境安装

Go的官网地址：https://go.dev

Go的官网中国地区版：https://golang.google.cn

开源包的文档：https://pkg.go.dev/

### whindows中安装：

直接安装 go1.13.5.windows-amd64.msi

```
会自动添加下面的环境变量
GOPATH %USERPROFILE%\go
%GOPATH%\bin
GOROOT C:\Program Files\go
PATH %GOROOT%\bin


GOPROXY https://mirrors.aliyun.com/goproxy/
```

### linux中安装：

```bash
sudo tar xvzf go1.13.5.linux-amd64.tar.gz -C /usr/local/

#sudo vi ~/.bashrc
export GOROOT=/usr/local/go
export GOPATH=$HOME/golang
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
export GOPROXY=https://goproxy.cn,direct
```

### mac中安装

```bash
vi .bash_profile
export GOPATH=/Users/GoWork/Public:/Users/GoWork/Company
```

### 从源码安装

```bash
git clone git@github.com:golang/go.git
#先编译go1.4
git checkout go1.4.3
cd src && ./all.bash
cp -f go go1.4
export GOROOT_BOOTSTRAP=/source/go1.4

#编译高版本
git clean -xdf
git checkout go1.13.5
cd src && ./all.bash

# Golang Env
export PATH=$PATH:/source/go/bin
export GOPATH=/home/pi/golang
```

### Go 语言开发工具:

* 1 go tools

  * linux 中安装`go-vim`插件后执行`GoInstallBinaries`

  * 也可以使用`go get`安装

    ```shell
    go get github.com/golangci/golangci-lint/cmd/golangci-lint
    ```

    官网建议二进制安装

    ```shell
    curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin
    ```

  * clone到本地再安装

    ```shell
    git clone https://github.com/golang/tools.git $GOPATH/src/golang.org/x/tools
    go install golang.org/x/tools/cmd/guru@latest
    go install golang.org/x/tools/cmd/gorename@latest
    go install golang.org/x/tools/cmd/fiximports@latest
    go install golang.org/x/tools/gopls@latest
    go install golang.org/x/tools/cmd/godex@latest
    ```

    

* 2 goland

下载地址：https://www.jetbrains.com/go/

* 3 vscode

下载地址：https://code.visualstudio.com/

* 4 reflex

用于监控文件改动并执行命令：https://github.com/cespare/reflex

.bashrc中可添加`alias okgo="reflex -r '\.go$' go run "`



## 1.2 工作区

工作区是Go中的一个对应于特定工程的目录，其包括src，pkg，bin三个目录

+ src：用于以代码包的形式组织并保存Go源码文件。（比如：.go .c .h .s等）
+ pkg：用于存放经由go install命令构建安装后的代码包（包含Go库源码文件）的“.a”归档文件。
+ bin：与pkg目录类似，在通过go install命令完成安装后，保存由Go命令源码文件生成的可执行文件。

GOPATH包含多个路径时，go install命令需要设置GOBIN；



从go1.1以后，项目一般都用gomod的形式了；



## 1.3 常用go命令

* go help build	获取build命令的帮助文档

* go version         获取golang的版本信息

* go env               查看当前系统内go相关的环境变量信息

* go doc               获取帮助文档

  ```go
  go doc strconv		//获取某个包的介绍以及包下可用的公共方法
  go doc strconv.Itoa	//获取某个方法的文档
  
  //网页形式查看文档
  godoc			   浏览器中访问http://localhost:6060
  godoc -http=:6060  浏览器中访问http://localhost:6060
  ```

* go run  编译并运行

  ```bash
  go run [build flags] [-exec xprog] package [arguments...]
  
  例如：
  go run hello.go
  ```

* go build   编译

  ```
  go build [-o output] [-i] [build flags] [packages]
  ```
  
  | 参数      | 备注                                        |
  | -------- | ------------------------------------------- |
  | -o		 |指定编译后的名字|
  | -i		 |install 安装作为目标的依赖关系的包(用于增量编译提速)|
  | -v       | 编译时显示包名                              |
  | -p n     | 开启并发编译，默认情况下该值为 CPU 逻辑核数 |
  | -a       | 强制重新构建                                |
  | -n       | 打印编译时会用到的所有命令，但不真正执行    |
  | -x       | 打印编译时会用到的所有命令                  |
  
   * 交叉编译
  
     go语言向下支持C语言，可以在go语言中直接编写C语言代码，在编译时，环境必须支持C语言
  
     ```bash
     #Mac上编译Linux和Windows可执行二进制文件
     CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build main.go
     CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build main.go
     
     #Linux上编译Mac和Windows可执行二进制文件
     CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build main.go
     CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build main.go
     
     #Windows上编译Mac和Linux可执行二进制文件
     SET CGO_ENABLED=0 SET GOOS=darwin SET GOARCH=amd64 go build main.go
     SET CGO_ENABLED=0 SET GOOS=linux SET GOARCH=amd64 go build main.go
     
     #CGO_ENABLED 交叉编译不支持 CGO 所以要禁用它
     #GOOS 目标平台的操作系统（darwin、freebsd、linux、windows）
     #GOARCH 目标平台的体系架构（386、amd64、arm）
     ```
  
     
  
 * go get  获取代码、编译并安装

   ```
   go get [-d] [-f] [-t] [-u] [-v] [-fix] [-insecure] [build flags] [packages]
   ```

   | 参数      | 备注                                   |
   | --------- | -------------------------------------- |
   | -v        | 显示操作流程的日志及信息，方便检查错误 |
   | -u        | 下载丢失的包，但不会更新已经存在的包   |
   | -d        | 只下载，不安装                         |
   | -insecure | 允许使用不安全的 HTTP 方式进行下载操作 |

* go install	编译并安装

  ```
  go install [-i] [build flags] [packages]
  ```

* go vet   检测代码的常见错误

* go fmt   代码格式化

* go test  自动读取源码目录下面名为 *_test.go 的文件，并运行
  * 文件名必须是 _test.go 结尾的
  * 必须 import testing 这个包
  * 测试函数 TestXxx() 的参数是 testing.T ，我们可以使用该类型来记录错误或者是测试状态
  * 函数中通过调用 testing.T 的 Error, Errorf, FailNow, Fatal, FatalIf 方法，说明测试不通过，调用 Log 方法用来记录测试的信息。



# 二、golang基础知识

## 2.1 关键字和标志符

### golang中的25 个关键字：

```go
//8个引导程序整体结构的关键字
package    //定义包名
import     //导入包名
const      //常量声名
var        //变量声名
func       //函数定义
defer      //延迟执行
go         //迸发语法糖
return     //函数返回

//4个声明复合数据结构的关键字
struct        //定义结构类型
interface     //定义接口类型
map           //声明创建map类型
chan          //声明创建通道类型

//13个控制程序结构的关键字
if else                                        //if else语句
for range break continue                       //for循环使用
switch select type case default fallthrough    //switch和select语句使用
goto                                           //goto跳转语句
```

### 常见的关键字的用法

#### var

```go
/*指定变量类型，声明后若不赋值，使用默认值。*/
var a int
a = 4

/*根据值自行判定变量类型。*/
var a = 4

/*:=左侧的变量不应该声明过，只能用在函数中*/
a := 4

/*类型相同多个变量, 非全局变量*/
var a, b, c int
a, b, c = 1, 2, 3

/*不需要显示声明类型，自动推断，类型可以不一样*/
var a, b, c = 1, 2, 3

/*:=左侧的变量不应该是全被被声明过的，类型可以不一样*/
a, b, c := 1, 2, 3

/*这种因式分解关键字的写法一般用于声明全局变量*/
var (
    a int
    b string
    c, d = 4, "name"
)
```

#### const

常量中的数据类型只可以是布尔型、数字型（整数型、浮点型和复数）和字符串型。

```go
/*显式类型定义*/
const b string = "abc"

/*隐式类型定义*/
const b = "abc"

/*多个相同类型的声明*/
const c_name1, c_name2 = value1, value2

/*常量还可以用作枚举*/
const (
    Unknown = 0
    Female = 1
    Male = 2
)
```

#### iota

在每一个const关键字出现时，被重置为0，每出现一次iota，其所代表的数字会自动增加1。

```go
func main() {
    const (
            a = iota   //0
            b          //1
            c          //2
            d = "ha"   //独立值，iota += 1
            e          //"ha"   iota += 1
            f = 100    //iota +=1
            g          //100  iota +=1
            h = iota   //7,恢复计数
            i          //8
    )
    fmt.Println(a,b,c,d,e,f,g,h,i)
}
```

#### import

```go
import "fmt"	//只导入一个包

//导入多个时要用括号
import (
    "fmt"
    f "fmt"    //起一个别名导入
    . "fmt"    //使用时可以不再加前辍
    _ "fmt"    //只初始化
)
```



#### defer



#### panic/recover

go 里区分对待异常(panic)和错误(error)，绝大部分场景下我们使用的都是错误，只有少数场景下发生了严重错误我们想让整个进程都退出了才会使用异常。

例如配置文件读取失败这类错误：

```go
if err := readConfig("filepath"); err != nil {
    panic(err) // 读取失败直接执行defer语句，然后退出
}
```

`panic` 只会触发当前 Goroutine 的延迟函数调用：

```go
func panicOnlyCurrent() {
	defer println("in main")
	go func() {
		defer println("in goroutine")
		panic("panic test")
	}()

	time.Sleep(1 * time.Second)
}
```

panic也可以嵌套，比如：

```go
func panicNested() {
	defer fmt.Println("in main")
	defer func() {
		defer func() {
			panic("panic again and again")
		}()
		panic("panic again")
	}()

	panic("panic once")
}
```



panic 关键字在 Go 语言的源代码是由数据结构 runtime._panic 表示的：

```go
type _panic struct {
	argp      unsafe.Pointer		//指向 defer 调用时参数的指针
	arg       interface{}			//调用 panic 时传入的参数
	link      *_panic				//指向了更早调用的 runtime._panic 结构
	recovered bool					//表示当前 runtime._panic 是否被 recover 恢复
	aborted   bool					//表示当前的 panic 是否被强行终止

	pc        uintptr
	sp        unsafe.Pointer
	goexit    bool
}
```



go 还提供了一个 recover 函数用来从异常中恢复，比如使用 recover 可以把一个 panic 包装成为 error 再返回，而不是让进程退出：

```go
func Divide(a, b int) (res int, e error) {
    defer func() {
        if err := recover(); err != nil {
            e = fmt.Errorf("%v", err)
        }
    }()
    
    if b == 0 {
        panic("divide by zero")
    }
    res = a / b
    
    return
}
```



注意：

* panic会停止继续执行函数，然后执行defer语句，最后退出
* recover仅在defer中调用



**总结一下**：

- 对于一般不太严重的场景，返回错误值 error 类型 (业务绝大部分场景)
- 对于严重的错误需要整个进程退出的场景，使用 panic 来抛异常，及早发现错误
- 如果希望捕获 panic 异常，可以使用 recover 函数捕获，并且包装成一个错误返回
- web 框架等会帮你捕获 panic 异常，然后返回客户端一个 http 500 状态码错误



#### make/new

`make` 的作用是初始化内置的数据结构，比如切片、哈希表和 Channel；

```go
slice := make([]int, 0, 100)
hash := make(map[int]bool, 10)
ch := make(chan int, 5)
```

1. `slice` 是一个包含 `data`、`cap` 和 `len` 的私有结构体 [`internal/reflectlite.sliceHeader`](https://github.com/golang/go/blob/a5026af57c7934f0856cfd4b539a7859d85a0474/src/internal/reflectlite/value.go#L389-L393)；

2. `hash` 是一个指向 [`runtime.hmap`](https://github.com/golang/go/blob/36f30ba289e31df033d100b2adb4eaf557f05a34/src/runtime/map.go#L115-L129) 结构体的指针；

3. `ch` 是一个指向 [`runtime.hchan`](https://github.com/golang/go/blob/d1969015b4ac29be4f518b94817d3f525380639d/src/runtime/chan.go#L32-L51) 结构体的指针；

   

`new` 的作用是根据传入的类型在堆上分配一片内存空间，并返回指向这片内存空间的指针；

```go
i := new(int)

//等价于
var v int
i := &v
```



**总结**：

`make` 关键字的作用是创建切片、哈希表和 Channel 等内置的数据结构；

`new` 的作用是为类型申请一片内存空间，并返回指向这片内存的指针；





### go内置的标识符

20个内置数据类型标识符

```go
#数值类型15个
int int8 int16 int32 int64 
uint uint8 uint16 uint32 uint64 uintptr
float32 float64
complex64 complex128

#字符和字符串型3个
string rune byte

#接口型
error

#布尔型
bool
```

4个常量标识符

```go
true false    //表示bool类型的两常量值:真和假
iota          //用在连续的枚举类型声明中
nil           //指针或引用型的默认值
```

1个空白标识符

```go
_
```

15个内置函数

```go
make new len cap append copy delete panic recover close complex real imag print println
```



### Go语言命名规则

> * 小驼峰式命名法（lower camel case）：
>   第一个单词以小写字母开始，第二个单词的首字母大写，例如：myName、aDog
> * 大驼峰式命名法（upper camel case）：
>   每一个单字的首字母都采用大写字母，例如：FirstName、LastName





## 2.2 流程控制

### 1 if语句

```go
/*if 语句*/
if 布尔表达式 {
    
}

/*if...else 语句*/
if 布尔表达式 {
    
} else {
    
}

/* if else if语句*/
if 布尔表达式{
    
} else if 布尔表达式 {
    
} else if 布尔表达式 {
    
} else {
    
}
```

**注意点**：

* 不像 c 语言，if 条件只能是一个 bool 值或者返回 bool 值得表达式，而不能是 int；

* if 后边是可以先跟一个表达式，比如 `if v,ok := m[key]; ok {}`；

  

### 2 switch/case语句

#### 表达式switch语句

```go
//第一种格式：
switch var {
    case value1, value2:
        ...
    case value3:
        ...
    default:
        ...
}

//第二种格式:
switch {
    case condition:
        ...
    default:
        ...
}

// switch也支持初始化语句
switch x := 5; x {
	case value:
    	...
	default:
    	...
}
```



#### 类型switch语句

类型switch语句将对类型进行判定，而不是值。

```go
whatAmI := func(i interface{}) {
    switch i.(type) {
        case bool:
        fmt.Println("I'm a bool")
        case int:
        fmt.Println("I'm an int")
        default:
        fmt.Printf("Don't know type %T\n", i)
    }
}
whatAmI(true)
whatAmI(1)
```

类型 switch 语句的 switch 表达式还有一种变形写法，如下：

```go
whatAmI := func(i interface{}) {
    switch t := i.(type) {
        case bool:
        fmt.Println("I'm a bool")
        case int:
        fmt.Println("I'm an int")
        default:
        fmt.Printf("Don't know type %T\n", t)
    }
}
```



#### fallthrough

switch的case语句默认不会执行下一个case，除非显示使用 fallthrough 语句指定，但是fallthrough不会再匹配后续条件表达式；

```go
func main() {
	switch x := 5; x {
	case 5:
		fmt.Println("aa")
		fallthrough
	case 6:
		fmt.Println("bb")	// 6不满足，但是也会执行里面的语句
		fallthrough
	default:
		fmt.Println("cc")
	}
}
```



**注意点**：

* fallthrough不会再匹配后续条件表达式；
* fallthrough不能放在switch最后一个分支后面；
* fallthrough不允许出现在类型 switch 语句中；



### 3 select/case语句

```go
select {
    case communication clause  :
       statement(s);      
    case communication clause  :
       statement(s); 

    //不存在可以收发channel时，就执行default语句；
    default :
       statement(s);
}
```

如果有多个case都可以运行，Select会随机公平地选出一个执行；Go不会重新对channel或值进行求值。

- 每个 case 都必须是一个通信

- 所有 channel 表达式都会被求值

- 所有被发送的表达式都会被求值

- 如果任意某个通信可以进行，它就执行，其他被忽略。

- 如果有多个 case 都可以运行，Select 会随机公平地选出一个执行。其他不会执行。

  否则：

  1. 如果有 default 子句，则执行该语句。
  2. 如果没有 default 子句，select 将阻塞，直到某个通信可以运行；Go 不会重新对 channel 或值进行求值。



select 在 Go 语言的源代码中不存在对应的结构体，但是 select 控制结构中的 case 却使用 runtime.scase 结构体来表示：

```go
type scase struct {
	c           *hchan				//存储 case 中使用的 Channel
	elem        unsafe.Pointer		//接收或者发送数据的变量地址
	kind        uint16				//表示 runtime.scase 的种类
	pc          uintptr
	releasetime int64
}

//runtime.scase 的种类，总共包含以下四种：
const (
	caseNil = iota
	caseRecv
	caseSend
	caseDefault
)
```

**case读取数据时，可以读取的情况**：

* 当前 Channel 的 `sendq` 上有等待的 Goroutine；
* 当前 Channel 的缓冲区不为空；
* 当前 Channel 已经被关闭，当没有数据时就会读取零值；

**case发送数据时，可以发送的情况**：

* 当前 Channel 的 `recvq` 上有等待的 Goroutine；
* 当前 Channel 的缓冲区存在空闲位置，就会将待发送的数据存入缓冲区，否则阻塞等待；



**例子**：

select语句实现超时处理：

```go
go runc() {
    for {
        select {
        case num := <-ch:
            fmt.Println("num=", num)
        case <-time.After(3 * time.Second):
            fmt.Println("超时")
            quit <- true
        }
    }
}()

<- quit
fmt.Println("程序结束")
```



### 4 for循环

经典循环：

```go
/*for循环 和C语言的for一样*/
for init; condition; post {
}

/*for循环 和C语言的while一样*/
for condition {
}

/*for循环 和C语言的for(;;)一样*/
for {
}
```

范围循环：

```go
/*for 循环的 range 格式可以对 slice、map、数组、字符串等进行迭代循环*/
for key, value := range oldMap {
    newMap[key] = value
}

//数组和切片，字符串
for range a{}				//不关心索引和数据的情况
for i := range a{}			//只关心索引的情况
for i, elem := range a{}	//关心索引和数据的情况

//哈希表
for range a{}				//不关心键和值的情况
for k := range a{}			//只关心键的情况
for k, v := range a{}		//关心键和值的情况

//通道
for v := range ch {}
```



### 5 break/continue

break/continue除了单独使用外，还可以和标签在多重循环中使用；

```go
Lable:
	for(){
        for() {
            break Lable
        	continue Lable
        }
	}
```

### 6 goto跳转语句

goto只能在函数内跳转，并且不能跳过内部变量声明语句；

```go
	goto Lable	//bad, v := 3 这条语句不能跳过
	v := 3
Lable:
```

goto只能跳到同层或上层作用域，不能跳到内部作用域；

```go
if n % 2 == 1 {
    goto L1	//bad，不能跳到内部作用域
}
for n > 0 {
    f()
L1:
    f()
}
```



## 2.3 数据类型

### 1 基本数据类型

#### 布尔类型

bool类型数据只允许取值true或false，bool类型占1个字节；

#### 数字类型

```go
#整型11个
int int8 int16 int32 int64 
uint uint8 uint16 uint32 uint64 uintptr
#浮点型2个
float32 float64
#复数型2个
complex64 complex128
```

八进制整数，以0开头，十六进制整数，以0X或者是0x开头；

```go
fmt.Printf("%T", var_name) //输出变量量类型
unsafe.Sizeof(var_name) //查看变量量占⽤用字节
```

浮点数由整数部分、小数点和小数部分组成，整数部分和小数部分可以隐藏其中一种，也可以使用科学计数法表示；



#### 字符类型

用单引号包裹，储单个字符，一般使用byte/rune来保存，英文字母占一个字符，汉字占3个字符；

#### 字符串类型

双引号的形式可以识别转义字符；反引号的形式以原生形式输出；

Go中字符串一旦赋值了，就不能再修改，因为存储在只读的常量存储区中；

底层结构：

```go
type StringHeader struct {
	Data uintptr	// 8byte
	Len  int		// 8byte
}
```



#### 基本类型大小

|类型  |名称 |大小  |零值 |说明           |
|-----|----|------|-----|--------------|
|bool |布尔类型 |1 |false |其值不不为真即为假，不不可以⽤用数字代表true或false|
|byte |字节型 |1 |0 |uint8别名|
|int/uint |整型 |4/8 |0 |根据操作系统设定数据的值。|
|int8 |整型  |1 |0 |-128 |
|uint8 |整型 |1 |0 |0 |
|int16 |整型 |2 |0 |-32768 |
|uint16 |整型 |2 |0 |0 |
|int32 |整型 |4 |0 |-2147483648 |
|uint32 |整型 |4 |0 |0 |
|int64 |整型 |8 |0 |-9223372036854775808 |
|uint64 |整型 |8 |0 |0 |
|float32 |浮点型 |4 |0.0 |小数位精确到7位|
|float64 |浮点型 |8 |0.0 |小数位精确到15位|
|string |字符串 |8/16 |"" |底层为结构体，一个指向数据的指针，一个len|



### 2 派生数据类型

#### 数组

数组定义

```go
var array [5]int	//声明一个包含５个元素的整形数组
var array = [5]int{10, 20, 30, 40, 50}	//声明并初始化
array := [5]int{10, 20, 30, 40, 50} 	//声明并初始化省略写法
array := [5]int{10, 20, 30}				//部分初始化
array := [...]int{10, 20, 30, 40, 50}	//容量由初始化值的数量决定
array := [5]int{1:10, 2:20}				//初始化部分索引
array := [3]*int{new(int), new(int), new(int)} //指向整数的指针数组

//二维数组
var array [4][2]int
array := [4][2]int{{10, 11}, {20, 21}, {30, 31}, {40, 41}}
array := [4][2]int{1: {20, 21}, 3: {40, 41}}
array := [4][2]int{1: {0: 20}, 3: {1: 41}}
```



#### 切片

##### 切片定义

```go
var s []int				//创建nil整形切片
var s = *new([]int)		//创建nil整形切片

s := make([]int, 0)	//空的整形切片
s := []int{}		//空的整形切片

s := make([]string, 5)		//长度和容量都为5
s := make([]int, 3, 5)		//长度为3,容量为5
s := []int{1, 2, 3, 4, 5}	//长度和容量都为5
s := []string{99: ""}		//长度和容量都为100

s := [][]int{{10}, {100, 200}}	//二维切片
```

##### slice底层的数据结构

```go
type Slice struct {
    ptr   unsafe.Pointer        // Array pointer
    len   int                   // 当前存储长度
    cap   int                   // 可用长度
}
```
![](https://cdn.jsdelivr.net/gh/eaok/img/golang/go_slice.jpg)

在 cap 小于1024的情况下是每次扩大到 2 * cap ，当大于1024之后就每次扩大到 1.25 * cap 。



##### 长度和容量计算方法

```go
s1 := s[i:j:k]
len : j - i
cap : k - i , k为s1的长度
```

切片常见的操作：s[n]，s[n:m]，s[n:]，s[:m]，s[:]，s[:cap(s)]



##### 内置函数append/copy

**append()**

```go
slice = append(slice, 1)
slice = append(slice, 1, 2, 3)
slice = append(slice, slice2...)
```

**copy()**

```go
slice1 := []int{1, 2, 3, 4, 5} 
slice2 := []int{5, 4, 3} 
copy(slice2, slice1) // 只会复制slice1的前3个元素到slice2中 
copy(slice1, slice2) // 只会复制slice2的3个元素到slice1的前3个位置
```



##### slice排序

```go
sort.Ints(a []int)			// 整数切片从小到大排序
sort.Float64s(a []float64)	// 浮点数切片从小到大排序
sort.Search(n int, f func(int) bool) int //Search uses binary search to find and return the smallest index i in [0, n) at which f(i) is true
```



##### 总结：

* 如果知道了slice的长度，make 函数最好传递长度进去，防止 append 操作可能导致重新分配内存降低效率。
* 函数传参时数组会复制整个数组，所以一般用切片传参；
* 字节型的slice可以使用bytes.Equel进行比较，其他类型只能逐个比较了；
* 测试一个slice是否为空，不能使用nil进行判断，需要用len(s) == 0进行判断；



#### map

map定义

```go
var dict map[int]string			//dict == nil
dict := make(map[string]int)	//dict == map[]
dict := map[int]string{}		//dict == map[]
dict := make(map[string]int, 3)	//创建一个容量为3的map
dict := map[string]string{"Red": "#da1377", "Orange": "#e95a22"} //创建并初始化

//判断一个key是否存在
value, ok := dict["Red"]	//如果不存在时，ok == false
value := dict["Red"]		//如果不存在，会返回零值

//删除key
delete(dict, "Red") //删除key为"Red"的内容

//键值对的数目
len(dict)
```

用map实现set，让 map 的值是 bool 类型，标识是否存在即可：

```go
func UseMapAsSet() {
    m := make(map[string]bool)
    m["hello"] = true
    m["world"] = true
    key := "hello"
    if _, ok := m[key]; ok {
        fmt.Printf("%s key exists\n", key)
    }
}
```

总结：

* map中的key必须支持运算符“==”；
* 禁止对map的元素取址，不能取址是因为，随着元素数量的增加，可能会分配更大的内存空间，而导致之前的地址失效；



#### channel

```go
unbuffered := make(chan int) //无缓冲的整形通道
buffered := make(chan string, 10) //有缓冲的字符串通道
```





#### struct类型

##### 结构体定义

```go
type structName struct {
    member dataType `tag` `tag`	// 便签之间用空格分隔
    member dataType
    member dataType
}
```



##### 空结构体

空结构体不会占用内存空间：

```go
func main() {
	a := struct{}{}
	fmt.Println(unsafe.Sizeof(a))

	type S struct {
		A struct{}
		B struct{}
	}
	var s S
	fmt.Println(unsafe.Sizeof(s))
}
```

可以用来单纯的做控制信息，比如下面struct{}类型的channel，不能写入数据，只有close()操作：

```go
var sig = make(chan struct{})
```



##### 结构体标签

tag 是类型的⼀部分，主要用于通过反射获取字段的相关 tag 设置：

```go
type People struct {
	Name string `json:"name"`
	Age  uint   `json:"age"`
}

func main() {
	typeOfCat := reflect.TypeOf(People{})

	for i := 0; i < typeOfCat.NumField(); i++ {
		field := typeOfCat.Field(i)
		tag := field.Tag.Get("json")
		fmt.Println(tag)
	}
}
```



##### 匿名字段

如果我们想实现类似继承的功能来代码复用，go中类似的解决方案是组合，推崇的思想是『组合优于继承』，匿名字段就是将结构体名称作为另外结构体的成员，来实现组合；

```go
type Animal struct {
	Name    string
	Age     int
	petName string
}

type Dog struct {
	Animal // embedding
	Color  string
}
```

可以重写 Dog 自己的 Sleep 方法，来覆盖掉 Animal 的 Sleep 方法：

```go
func (a Animal) Sleep() {
	fmt.Printf("%s is sleeping\n", a.Name)
}

func (d Dog) Sleep() {
	fmt.Println("Dog method Sleep")
}

func main() {
	d := Dog{}
	d.Name = "dog"
	d.Sleep() // 输出的是 Dog 的 Sleep 方法而不是 Animal 的
}
```



##### 方法

go中的方法，就是在函数前面加了一个接收者，接收者必须为自定义类型；

```go
type Animal struct {
    Name    string
    Age     int
    petName string
}

// Sleep 值接收者
func (a Animal) Sleep() {
    fmt.Printf("%s is sleeping", a.Name)
}

// SetPetName 指针接收者
func (a *Animal) SetPetName(petName string) {
    a.petName = petName	// go简化了指针访问成员的方式
    // 使用以下这种方式也是可以的
    // (*a).petName = petName
}
```

一般如果要修改结构体，或者结构体数据成员比较多（减少复制成本）， 我们就需要使用指针接收者。



```go
//声明一个结构体类型
type user struct {
    name        string
    email       string
    ext         int
    privileged  bool
}

//顺序初始化，每个成员都要初始化
var bill = user{"Lisa", "lisa@email.com", 123, true}
bill := user{"Lisa", "lisa@email.com", 123, true}

//指定成员初始化，没有初始化的成员，自动为0值
lisa := user{name:"Lisa", email:"Lisa@email.com", ext:"123"}

//指针形式
var p1 *user = &user{"Lisa", "lisa@email.com", 123, true}
p2 := &user{name:"Lisa", email:"Lisa@email.com", ext:"123"}

//使用
//1定义结构体变量或者指针
var s Student
var p *Student    //p.id 和（*p）.id完全等价

//2通过new 申请一个结构体
p2 := new(Student)    //返回的是指针

//如果结构体的全部成员都是可以比较的，那么结构体也是可以比较的

//匿名字段
//匿名字段中有指针类型时，可以用new初始化
```



#### error类型

go一般最后一个返回值用来表示错误，调用者通过检查其是否为nil来处理；error 是 go 的一个内置的接口：

```go
type error interface {
    Error() string
}
```



使用内置的 errors库生成error信息：

```go
// Divide compute a/b
func Divide(a, b int) (int, error) {
    if b == 0 {
        return 0, errors.New("divide by zero")
    }
    return a / b, nil
}
```



**自定义错误类型**

在 python 之类的使用异常处理的编程语言里，我们可以通过继承 Exception 类来自定义自己的业务异常；在go中我们只需要自己定义一个结构体， 然后实现 `Error()` 方法就实现了 go 的 error 接口。

比如我们定义一个叫做 ArticleError 的错误类型：

```go
package errors

import (
    "fmt"
)

type ArticleError struct {
    Code    int32
    Message string
}

func (e *ArticleError) Error() string {
    return fmt.Sprintf("[ArticleError] Code=%d, Message=%s", e.Code, e.Message)
}

func NewArticleError(code int32, message string) error {
    return &ArticleError{
        Code:    code,
        Message: message,
    }
}
```



指针

函数

接口



### 3 类型转换

显示转换的转换格式：

```go
type(var)
type(expression)
```

隐式转换

通过函数传值来实现

通过断言

```go
a := interface.(int)
```





## 2.4 函数

### 定义一个函数

```go
func funcName() {	//无参数无返回值
}

func funcName(str string) {	//有固定参数
}

func funcName(str string, params ...int) {	//无固定参数
}

func funcName() int {	//单个无名返回值
}

func funcName() (age int) {	//单个有名返回值
}

func funcName() (int, string) {	//多个无名返回值
}

func funcName() (age int, name string) {	//多个有名返回值
}
```

例如：

```go

func func1(init int, vals ...int) int {
    sum := init
    for _, val := range vals { // vals is []int
        sum += val
    }
    
    return sum
}
// fmt.Println(sum3(0, 1, 2, 3))
// fmt.Println(sum3(0, []int{1,2,3}...))	// 还可以解包一个 slice 来作为参数传入
```



### 泛型

go 目前为止还没有直接提供泛型支持，我们可以使用空接口 interface{} 来实现，比如实现一个简单的可以打印多种类型的 MyPrint 函数：

```go
func MyPrint(i interface{}) {
    switch o := i.(type) {
    case int:
        fmt.Printf("%d\n", o)
    case float64:
        fmt.Printf("%f\n", o)
    case string:
        fmt.Printf("%s\n", o)
    default:
        fmt.Printf("%+v\n", o)
    }
}

func main() {
    MyPrint(1)
    MyPrint(4.2)
    MyPrint("hello")
    MyPrint(map[string]string{"hello": "go"})
}
```



### 默认参数

go不支持支持默认参数，但是有一些比较 trick 的方法来实现。 一种是通过传递零值并且代码里判断是否是零值来实现，另一种是通过传递一个结构体来实现。

例如：

```go
// Concat1 可以通过传递零值或者nil的方式来判断是否取默认值。
// Both parameters are optional, use empty string for default value
func Concat1(a string, b int) string {
    if a == "" {
        a = "default-a"
    }
    if b == 0 {
        b = 5
    }
    return fmt.Sprintf("%s%d", a, b)
}
```



### 函数的传参

go 里边所有的函数参数都是值拷贝，但是一些复合结构因为复制的结构体里包含指针，所以可以修改它的底层结构，比如slice底层结构：

```go
type slice struct {
    array unsafe.Pointer
    len   int
    cap   int
}
```



**传递内置类型**：

数值类型、字符串、布尔类型、数组。传递的是副本 (所以一般不用数组)，会拷贝原始值，无法修改



**传递引用类型**：

切片、映射、通道、接口和函数类型。传递的也是应用类型值的副本，但这类底层都包含指针，所以本质上是共享底层数据结构。可以修改，例如：

```go
func changeMap(m map[string]string) {
    m["王八"] = "绿豆"
}

func main() {
    m := map[string]string{"name": "lao wang"}
    changeMap(m)
    fmt.Println(m) // map[name:lao wang 王八:绿豆]
}
```



**传递指针**：

go 里边大大简化和限制了指针的使用，例如：

```go
func changeString(s *string) { // go 同样使用 * 声明指针类型
    *s = "new lao wang"
}

func main() {
    s := "lao wang"
    changeString(&s) // go 和 c 一样使用 & 作为取地址操作符
    fmt.Println(s)
}
```



### 函数类型

go里边函数本身也是一种类型，所以我们可以定义一个函数然后赋值给一个变量，比如：

```go
myPrint := func(s string) { fmt.Println(s) }
```

如此go的函数会非常灵活，比如定义一个 map 值为函数的映射：

```go
func testMapFunc() {
    funcMap := map[string]func(int, int) int{
        "add": func(a, b int) int { return a + b },
        "sub": func(a, b int) int { return a - b },
    }
    fmt.Println(funcMap["add"](3, 2))
    fmt.Println(funcMap["sub"](3, 2))
}
```

还可以作为函数的参数传递进去：

```go
func Double(n int) int {
    return n * 2
}

func Apply(n int, f func(int) int) int {
    return f(n) // f 的类型是 "func(int) int"
}

func funcAsParam() {
    fmt.Println(Apply(10, Double))
}
```



### go函数其它部分

**匿名函数**

go 中我们也可以使用匿名函数，经常用在一些临时的小函数中，比如：

```go
func testAnonymousFunc() {
    func(s string) {
        fmt.Println(s)
    }("hehe")
}
```



**闭包**

闭包就是一个函数“捕获”了和它在同一作用域的其他常量和变量。 当闭包被调用的时候，不管在程序什么地方调用，闭包能够使用这些常量或者变量，并且只要闭包还在使用它，这些变量就不会销毁，一直存在。

```go
func testClosure() {
    suffix := ".go"
    addSuffix := func(name string) string {
        return name + suffix // 这里使用到了 suffix 这个变量，所以 addSuffix 就是一个闭包
    }
    fmt.Println(addSuffix("hello_world"))
}
```



**递归函数**

go 也是支持递归函数的。比如我们经常看到的斐波那契数：

```go
func fib(n int) int {
    if n < 2 {
        return n
    }
    return fib(n-1) + fib(n-2)
}
```



**高阶函数**

高阶函数就是将一个或者多个其他函数作为自己的参数，并在函数体里调用它们。

比如从一个切片中获取所有奇数，可以这样写：

```go
func FilterIntSlice(intVals []int, predicate func(i int) bool) []int {
    res := make([]int, 0)
    for _, val := range intVals {
        if predicate(val) {
            res = append(res, val)
        }
    }
    return res
}

func main() {
    ints := []int{1, 2, 3, 4, 5}
    isOdd := func(i int) bool { return i%2 != 0 } // 是奇数
    fmt.Println(FilterIntSlice(ints, isOdd))      // [1 3 5]
}
```



## 2.5 接口

### 接口定义

 go的接口是一种抽象的自定义类型，没法直接实例化，它声明了一个或者多个方法的签名。如果一个 struct 实现了一个接口定义的所有方法，我们就说这个 struct 实现了这个接口。

```go
// Sleeper 接口声明
type Sleeper interface {
    Sleep() // 声明一个 Sleep() 方法
}

// Dog 自定义的结构体
type Dog struct {
    Name string
}

// Sleep 实现Sleep方法
func (d Dog) Sleep() {
    fmt.Printf("Dog %s is sleeping\n", d.Name)
}
```

一般都用er作为一个接口的后缀，比如Writer/Reader；



### 接口实现多态

多态就是同一个接口，对于不同的实例执行不同的操作。这里函数传参为接口类型来实现多态：

```go
// Sleeper 接口声明
type Sleeper interface {
    Sleep() // 声明一个 Sleep() 方法
}

type Dog struct {
    Name string
}

func (d Dog) Sleep() {
    fmt.Printf("Dog %s is sleeping\n", d.Name)
}

type Cat struct {
    Name string
}

func (c Cat) Sleep() {
    fmt.Printf("Cat %s is sleeping\n", c.Name)
}

func AnimalSleep(s Sleeper) { // 注意参数是一个 interface
    s.Sleep()
}

func main() {
    var s Sleeper
    dog := Dog{Name: "xiaobai"}
    cat := Cat{Name: "hellokitty"}
    s = dog
    AnimalSleep(s) // 使用 dog 的 Sleep()
    s = cat
    AnimalSleep(s) // 使用 cat 的 Sleep()

  // 创建一个 Sleeper 切片
    sleepList := []Sleeper{Dog{Name: "xiaobai"}, Cat{Name: "kitty"}}
    for _, s := range sleepList {
        s.Sleep()
    }
}
```



### 接口嵌入

go的接口也支持组合：

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}

type ReadWriter interface {
    Reader
    Writer
}
```

例子：

```go
// Sleeper 接口声明
type Sleeper interface {
    Sleep() // 声明一个 Sleep() 方法
}

type Eater interface {
    Eat(foodName string) // 声明一个Eat 方法
}

type LazyAnimal interface {
    Sleeper
    Eater
}

type Dog struct {
    Name string
}

func (d Dog) Sleep() {
    fmt.Printf("Dog %s is sleeping\n", d.Name)
}

func (d Dog) Eat(foodName string) {
    fmt.Printf("Dog %s is eating %s\n", d.Name, foodName)
}

type Cat struct {
    Name string
}

func (c Cat) Sleep() {
    fmt.Printf("Cat %s is sleeping\n", c.Name)
}

func (c Cat) Eat(foodName string) {
    fmt.Printf("Cat %s is eating %s\n", c.Name, foodName)
}

func main() {
    sleepList := []LazyAnimal{Dog{Name: "xiaobai"}, Cat{Name: "kitty"}}
    foodName := "food"
    for _, s := range sleepList {
        s.Sleep()
        s.Eat(foodName)
    }
}
```



### 类型断言(type assert)

上面传入一个具体的实现了接口的 struct 类型，我们可以通过类型断言来获取具体的struct类型，它的语法格式如下：

```go
// 如果 ok 为 true 的话，接口值就是RealType类型
instance, ok := interfaceVal.(RealType)
```

比如，在for循环里边使用类型断言获取了接口值的真正类型：

```go
func main() {
    sleepList := []LazyAnimal{Dog{Name: "xiaobai"}, Cat{Name: "kitty"}}
    foodName := "food"
    for _, s := range sleepList {
        s.Sleep()
        s.Eat(foodName)

        // 类型断言 type assert
        if dog, ok := s.(Dog); ok {
            fmt.Printf("I am a Dog, my name is %s", dog.Name)
        }
        if cat, ok := s.(Cat); ok {
            fmt.Printf("I am a Cat, my name is %s", cat.Name)
        }
    }
}
```



### 查看接口类型

可以通过`i.(type)` 来获取接口里面的数据类型：

```go
func main() {
	sleepList := []LazyAnimal{Dog{Name: "xiaobai"}, Cat{Name: "kitty"}}
	foodName := "food"
	for _, s := range sleepList {
		s.Sleep()
		s.Eat(foodName)

		switch animal := s.(type) {
		case Dog:
			fmt.Printf("I am a Dog, my name is %s", animal.Name)
		case Cat:
			fmt.Printf("I am a Cat, my name is %s", animal.Name)
		}
	}
}
```





### 空接口

如果一个 struct 实现了一个接口声明所有方法，我们就说这个 struct 实现了这个接口，对于空接口(empty interface)来说，所有类型都实现了空接口；

比如下面创建了一个空接口数组，它的元素可以是任何类型：

```go
type Dog struct {
    Name string
}

func (d Dog) Sleep() {
    fmt.Printf("Dog %s is sleeping\n", d.Name)
}

type Cat struct {
    Name string
}

func (c Cat) Sleep() {
    fmt.Printf("Cat %s is sleeping\n", c.Name)
}

func main() {
    animalList := []interface{}{Dog{Name: "xiaobai"}, Cat{Name: "kitty"}}
    for _, s := range animalList {
        if dog, ok := s.(Dog); ok {
            fmt.Printf("I am a Dog, my name is %s\n", dog.Name)
        }
        if cat, ok := s.(Cat); ok {
            fmt.Printf("I am a Cat, my name is %s\n", cat.Name)
        }
    }
}
```



### 方法集调用关系

#### 值调用方法

通过结构体示例对象去调用方法时，go里面会自动转换需要的格式，简化了指针；

```go
//Data ...
type Data struct{}

//value ...
func (Data) value() {
	fmt.Println("value")
}

//point ...
func (*Data) point() {
	fmt.Println("point")
}

func main() {
	var a Data = struct{}{}

	//值调用会自动转换
	a.value()
	(&a).value() //自动转换成a.value()
	a.point()    //自动转换成(&a).point()
	(&a).point()
}
```



#### 接口调用方法

可以简单的记为值不能调用指针方法；

```go
type valuer interface {
	value()
}

type pointer interface {
	point()
}

//Data ...
type Data struct{}

//value ...
func (Data) value() {
	fmt.Println("value")
}

//point ...
func (*Data) point() {
	fmt.Println("point")
}

// 通过接口调用
//Methods Receivers		values
//------------------------------
//(t T)					T and *T
//(t *T)				*T
func main() {
	var a Data = struct{}{}
	var v1 valuer = a
	var v2 valuer = &a
	// var p1 pointer = a //cannot use a (type Data) as type pointer
	var p2 pointer = &a

	v1.value()
	v2.value()
	// p1.point()
	p2.point()
}
```



代码参考`gogo/summary/methodSet.go`



## 2.6 面向对象编程

**面向对象编程(OOP)** 应该是近几十年最重要的编程范式之一，流行的编程语言 Java/C++/Python 等都支持 OOP。面向对象的一些概念，比如类，对象(实例)，访问控制，构造函数，继承，多态等。



### 内置类型的自定义类型

一般业务代码里边我们还会给所有状态定义对应的中文或者英文字符串，用示例如下：

```go
// 自定义一个 State 类型
type State int

const (
	Init State = iota
	Success
	Fail
)

// State对应的中文
var stateName = map[State]string{
	Init:    "初始化",
	Success: "成功",
	Fail:    "失败",
}

func (e State) Int() int {
	return int(e)
}

func (e State) String() string {
	return stateName[e]
}

func main() {
	status := 0
	fmt.Println(Init.Int() == status)

	status2 := Fail
	fmt.Println(status2.String())
}
```

除了基本类型，我们还可以自定义一些复杂类型，比如以下一些例子：

```go
func main() {
    // 定义一个 counter 类型
    type Counter map[string]int
    c := Counter{}
    c["word"]++
    fmt.Println(c)

    type Queue []int
    q := make(Queue, 0)
    q = append(q, 1)
    fmt.Println(q)
}
```



### struct自定义类型

虽然没有提供 class 关键词，但是提供了 struct 用来定义自己的类型，struct 里可以放入需要的数据成员，并且可以给自定义 struct 增加方法。

Go的访问控制是通过变量和方法的命名**首字母大小写**决定的，只有首字母大写的才可以被其它包使用；

```go
type Animal struct {
	Name    string
	Age     int
	petName string // 不能被外部包使用
}

func (a Animal) sleep() { // 不能被外部包使用
	fmt.Printf("%s is sleeping\n", a.Name)
}

func (a *Animal) SetPetName(petName string) {
	a.petName = petName
}

func main() {
	a := Animal{Name: "dog", Age: 3}
	fmt.Println(a, a.Name, a.Age)
	a.sleep()

	a.SetPetName("little dog")
	fmt.Println(a.petName)
}
```



### 构造函数

go没有直接提供构造函数，但是一般我们是通过定义一些 NewXXX 开头的函数来实现构造函数的功能的，比如我们可以定义一个 NewAnimal 函数：

```go
type Animal struct {
    Name    string
    Age     int
    petName string
}

func NewAnimal(name string, age int) *Animal {
    a := Animal{
        Name: name,
        Age:  age,
    }
    return &a
}

func main() {
    a := NewAnimal("cat", 3)
    fmt.Println(a)
}
```



### 多态

[接口实现多态](#接口实现多态)



### 继承vs组合

[匿名字段](#匿名字段)



泛型

```go
type HashMap[K comparable, V any] struct {
	hashmap map[K]V
}

func (h *HashMap[K, V]) Set(key K, value V) {
	h.hashmap[key] = value
}
func (h *HashMap[K, V]) Get(key K) (value V, ok bool) {
	value, ok = h.hashmap[key]
	return value, ok
}

func TestGenerics(t *testing.T) {
	//[string,string] 类型的 hashmap
	hashmap1 := &HashMap[string, string]{hashmap: make(map[string]string)}
	hashmap1.Set("k1", "v1")
	value, _ := hashmap1.Get("k1")
	fmt.Printf("value2: %v,type=%T\n", value, value) // value2: v1,type=string
    
	//[string,int] 类型的 hashmap
	hashmap2 := &HashMap[string, int]{hashmap: make(map[string]int)}
	hashmap2.Set("k1", 1)
	value2, _ := hashmap2.Get("k1")
	fmt.Printf("value2: %v,type=%T\n", value2, value2) // value2: 1,type=int
}

```



## 2.7 少见的用法

### 格式化输出%v、%+v、%#v

* %v 只输出所有值
* %+v 先输出字段名，再输出值
* %#v 先输出结构体的名字，再输出结构体（字段名+字段值）

```go
package main
import "fmt"
 
type student struct {
	id   int32
	name string
}
 
func main() {
	a := &student{id: 1, name: "xiaoming"}
 
	fmt.Printf("a=%v	\n", a)
	fmt.Printf("a=%+v	\n", a)
	fmt.Printf("a=%#v	\n", a)
}
```









# 三、并发编程

## groutine

## 上下文 Context