[toc]



# 基础

## 1 defer&panic执行顺序

写出下面代码输出内容。

```go
 package main
 
import (
    "fmt"
)
 
func main() {
    defer_call()
}
 
func defer_call() {
    defer func() { fmt.Println("打印前") }()
    defer func() { fmt.Println("打印中") }()
    defer func() { fmt.Println("打印后") }()
 
    panic("触发异常")
}
```

答案：

panic 需要等defer 结束后才会向上传递。 出现panic恐慌时候，会先按照defer的后入先出的顺序执行，最后才会执行panic。

```go
打印后
打印中
打印前
panic: 触发异常
```



## 2 for-range子元素的指针为遍历的最后一个子元素的地址

以下代码有什么问题，说明原因。

```go
type student struct {
    Name string
    Age  int
}
 
func pase_student() {
    m := make(map[string]*student)
    stus := []student{
        {Name: "zhou", Age: 24},
        {Name: "li", Age: 23},
        {Name: "wang", Age: 22},
    }
    for _, stu := range stus {
        m[stu.Name] = &stu
    }
}
```

答案：

foreach是使用副本的方式，所以m[stu.Name]=&stu实际上一致指向同一个指针， 最终该指针的值为遍历的最后一个struct的值拷贝。m的值为：

```
key=zhou,value=&{wang 22}
key=li,value=&{wang 22}
key=wang,value=&{wang 22}
```

正确的方法如下：

```go
	for i := 0; i < len(stus); i++ {
		m[stus[i].Name] = &stus[i]
	}

	for i, _ := range stus {
		stu := stus[i] //这里直接用key来取value赋值到stu变量中，这样stu的地址都是新的。
		m[stu.Name] = &stu
	}
```



## 3 groutine执行的顺序是随机的

下面的代码会输出什么，并说明原因。

```go
func main() {
    runtime.GOMAXPROCS(1)
    wg := sync.WaitGroup{}
    wg.Add(20)
    for i := 0; i < 10; i++ {
        go func() {
            fmt.Println("A: ", i)
            wg.Done()
        }()
    }
    for i := 0; i < 10; i++ {
        go func(i int) {
            fmt.Println("B: ", i)
            wg.Done()
        }(i)
    }
    wg.Wait()
}
```

答案：

groutine执行的顺序是随机的。 但是A:均为输出10，B:从0~9输出(顺序不定)。

第一个go func中i是外部for的一个变量，地址不变化。遍历完成后，最终i=10。 故go func执行时，i的值始终是10。

第二个go func中i是函数参数，与外部for中的i完全是两个变量，发生值拷贝，所以输出0-9。



## 4 go的匿名字段组合

下面代码会输出什么？

```go
type People struct{}
 
func (p *People) ShowA() {
    fmt.Println("showA")
    p.ShowB()
}
func (p *People) ShowB() {
    fmt.Println("showB")
}
 
type Teacher struct {
    People
}
 
func (t *Teacher) ShowB() {
    fmt.Println("teacher showB")
}
 
func main() {
    t := Teacher{}
    t.ShowA()
}
```

答案：

go的匿名字段组合，输出：

```
showA
showB
```



## 5 select的随机执行

下面代码会触发异常吗？请详细说明。

```go
func main() {
    runtime.GOMAXPROCS(1)
    int_chan := make(chan int, 1)
    string_chan := make(chan string, 1)
    int_chan <- 1
    string_chan <- "hello"
    select {
    case value := <-int_chan:
        fmt.Println(value)
    case value := <-string_chan:
        panic(value)
    }
}
```

答案：

select会随机选择一个可用通用做收发操作。 所以代码是有可能触发异常，也有可能不会。



## 6 defer执行顺序

下面代码输出什么？

```go
func calc(index string, a, b int) int {
    ret := a + b
    fmt.Println(index, a, b, ret)
    return ret
}
 
func main() {
    a := 1
    b := 2
    defer calc("1", a, calc("10", a, b))
    a = 0
    defer calc("2", a, calc("20", a, b))
    b = 1
}
```

答案：

defer执行顺序和值传递，输出：

```
10 1 2 3
20 0 2 2
2 0 2 2
1 1 3 4
```



## 7 make默认值和append

请写出以下输入内容。

```go
func main() {
    s := make([]int, 5)
    s = append(s, 1, 2, 3)
    fmt.Println(s)
}
```

答案：

make初始化是有默认值的，此处默认值为0，输出：

```
[0 0 0 0 0 1 2 3]
```



## 8 map并发安全

下面的代码有什么问题?

```go
type UserAges struct {
	ages map[string]int
	sync.Mutex
}
 
func (ua *UserAges) Add(name string, age int) {
	ua.Lock()
	defer ua.Unlock()
	ua.ages[name] = age
}
 
func (ua *UserAges) Get(name string) int {
	if age, ok := ua.ages[name]; ok {
		return age
	}
	return -1
}
```

答案：

map是线程不安全的,即使并发读写没有冲突也会报错`fatal error: concurrent map read and map write.` 第二个方法可一修改为：

```go
func (ua *UserAges) Get(name string) int {
    ua.Lock()
    defer ua.Unlock()
    if age, ok := ua.ages[name]; ok {
        return age
    }
    return -1
}
```



## 9 缓存通道

下面的迭代会有什么问题？

```go
func (set *threadSafeSet) Iter() <-chan interface{} {
	ch := make(chan interface{})
	go func() {
		set.RLock()
 
		for elem := range set.s {
			ch <- elem
		}
 
		close(ch)
		set.RUnlock()
 
	}()
	return ch
}
```

答案：

在遍历set.s中，ch是没有缓存的，写入一次就会阻塞，所以可以ch变为可缓存的`ch := make(chan interface{}, len(set.s))`；完整代码如下：

```go
package main

import (
	"fmt"
	"sync"
)

type threadSafeSet struct {
	sync.RWMutex
	s []interface{}
}

func (set *threadSafeSet) Iter() <-chan interface{} {
	// ch := make(chan interface{}) // 解除注释看看！
	ch := make(chan interface{}, len(set.s))
	go func() {
		set.RLock()

		for elem, value := range set.s {
			ch <- elem
			println("Iter:", elem, value)
		}

		close(ch)
		set.RUnlock()
	}()
	return ch
}

func main() {
	th := threadSafeSet{
		s: []interface{}{"1", "2", "3", "4", "5", "6", "7", "8"},
	}
	v := <-th.Iter()
	fmt.Sprintf("%s%v", "ch", v)
}
```



## 10 接口调用的值不能调用指针方法

以下代码能编译过去吗？为什么？

```go
package main
 
import (
	"fmt"
)
 
type People interface {
	Speak(string) string
}
 
type Stduent struct{}
 
func (stu *Stduent) Speak(think string) (talk string) {
	if think == "bitch" {
		talk = "You are a good boy"
	} else {
		talk = "hi"
	}
	return
}

func main() {
	var peo People = Stduent{}
	think := "bitch"
	fmt.Println(peo.Speak(think))
}
```

答案：

初始化的是一个接口，接口调用的值不能调用指针方法，可改为：

```go
var peo People = &Stduent{}
```



## 11 接口的nil不等于nil

以下代码打印出来什么内容，说出为什么。

```go
package main
 
import (
	"fmt"
)
 
type People interface {
	Show()
}
 
type Student struct{}
 
func (stu *Student) Show() {
 
}
 
func live() People {
	var stu *Student // 这里只能用指针，因为返回值是接口类型，只有*Student实现了People接口，没有实现接口编译器会报错
	return stu
}
 
func main() {
	if live() == nil {
		fmt.Println("AAAAAAA")
	} else {
		fmt.Println("BBBBBBB")
	}
}
```

答案：

go中的接口有两种形式：

```go
// 空接口
var in interface{}

// 带有方法的接口
type People interface {
    Show()
}
```

两种形式的底层结构如下：

```go
type eface struct {      //空接口
    _type *_type         //类型信息
    data  unsafe.Pointer //指向数据的指针(go语言中特殊的指针类型unsafe.Pointer类似于c语言中的void*)
}

type _type struct {
    size       uintptr  //类型大小
    ptrdata    uintptr  //前缀持有所有指针的内存大小
    hash       uint32   //数据hash值
    tflag      tflag
    align      uint8    //对齐
    fieldalign uint8    //嵌入结构体时的对齐
    kind       uint8    //kind 有些枚举值kind等于0是无效的
    alg        *typeAlg //函数指针数组，类型实现的所有方法
    gcdata    *byte
    str       nameOff
    ptrToThis typeOff
}

type iface struct {      //带有方法的接口
    tab  *itab           //存储type信息还有结构实现方法的集合
    data unsafe.Pointer  //指向数据的指针(go语言中特殊的指针类型unsafe.Pointer类似于c语言中的void*)
}

type itab struct {
    inter  *interfacetype  //接口类型
    _type  *_type          //结构类型
    link   *itab
    bad    int32
    inhash int32
    fun    [1]uintptr      //可变大小 方法集合
}
```

可以看出iface比eface 中间多了一层itab结构，itab 存储_type信息和[]fun方法集，data指向了nil 并不代表interface 是nil， 所以返回值并不为空，结果：

```go
BBBBBBB
```



## 12 类型switch语句中的interface.(type)

是否可以编译通过？如果通过，输出什么？

```go
package main

func main() {
	i := GetValue()

	switch i.(type) {
	case int:
		println("int")
	case string:
		println("string")
	case interface{}:
		println("interface")
	default:
		println("unknown")
	}
}

func GetValue() int {
	return 1
}
```

答案：

编译失败，因为type只能用于interface，可以改为如下：

```go
func GetValue() interface{} {
	return 1
}
```



## 13 函数的返回值

下面函数有什么问题？

```go
func funcMui(x, y int) (sum int, error){
    return x + y, nil
}
```

答案：

函数有多个返回值时，只要有一个命名返回值，其它的也必须命名，可以改为如下：

```go
func funcMui(x, y int) (int, error)

// 或者
func funcMui(x, y int) (sum int, err error)
```



## 14 defer&return顺序

是否可以编译通过？如果通过，输出什么？

```go
package main
 
func main() {
	println(DeferFunc1(1))
	println(DeferFunc2(1))
	println(DeferFunc3(1))
}
 
func DeferFunc1(i int) (t int) { // t的作用域为整个函数
	t = i
	defer func() {
		t += 3
	}()
	return t
}
 
func DeferFunc2(i int) int {
	t := i
	defer func() {
		t += 3
	}()
	return t // 相当于把t赋值给一个临时变量，执行defer后，再返回临时变量的值
}
 
func DeferFunc3(i int) (t int) { // t的作用域为整个函数
	defer func() {
		t += i
	}()
	return 2 // 2赋值为t
}
```

答案：

```go
4
1
3
```



## 15 append&new

是否可以编译通过？如果通过，输出什么？

```go
func main() {
	list := new([]int)
	//    list := make([]int, 0)
	list = append(list, 1)
	fmt.Println(list)
}
```

答案：

new返回的是一个slice执政，append的第一 个参数必须时slice类型，所以可以改为：

```go
list := make([]int, 0)
list := []int{}
list []int
```



## 16 append

是否可以编译通过？如果通过，输出什么？

```go
package main
 
import "fmt"
 
func main() {
	s1 := []int{1, 2, 3}
	s2 := []int{4, 5}
	s1 = append(s1, s2)
	fmt.Println(s1)
}
```

答案：

append第二个参数如果是silce，要加`...`



## 17 结构体比较

是否可以编译通过？如果通过，输出什么？

```go
func main() {
	sn1 := struct {
		age  int
		name string
	}{age: 11, name: "qq"}

	sn2 := struct {
		age  int
		name string
	}{age: 11, name: "qq"}

	if sn1 == sn2 {
		fmt.Println("sn1 == sn2")
	}

	sm1 := struct {
		age int
		m   map[string]string
	}{age: 11, m: map[string]string{"a": "1"}}

	sm2 := struct {
		age int
		m   map[string]string
	}{age: 11, m: map[string]string{"a": "1"}}

	if sm1 == sm2 {
		fmt.Println("sm1 == sm2")
	}
}
```

答案：

结构体比较的前提是子元素是可比较的，并且顺序要一样，不能比较的如：map,slice；如果要比较可用如下方法：

```go
if reflect.DeepEqual(sm1, sm2) {
    fmt.Println("sm1 == sm2")
} else {
    fmt.Println("sm1 == sm2")
}
```



18 nil可赋值的类型

是否可以编译通过？如果通过，输出什么？

```go
func GetValue(m map[int]string, id int) (string, bool) {
	if _, exist := m[id]; exist {
		return "存在数据", true
	}
	return nil, false
}

func main()  {
	intmap:=map[int]string{
		1:"a",
		2:"bb",
		3:"ccc",
	}
 
	v,err:=GetValue(intmap,3)
	fmt.Println(v,err)
}
```

答案：

nil可以用作interface, function, pointer, map, slice, channel的空值，不能用作string的值，可以改为：

```go
return "", false
```



## 19 iota

是否可以编译通过？如果通过，输出什么？

```go
const (
	a = iota //0
	b        //1
	c        //2
	d = "ha" //独立值，iota += 1
	e        //"ha"   iota += 1
	f = 100  //iota +=1
	g        //100  iota +=1
	h = iota //7,恢复计数
	i        //8
)

func main() {
	fmt.Println(a, b, c, d, e, f, g, h, i)
}
```

答案：

输出：

```
0 1 2 ha ha 100 100 7 8
```



## 20 变量的简短模式的限制

编译执行下面代码会出现什么?

```go
package main
var(
    size :=1024
    max_size = size*2
)

func main()  {
    println(size,max_size)
}
```

答案：

变量的简短模式只能用在函数内部；



## 21 常量没有地址

下面函数有什么问题？

```go
package main

const cl = 100
var bl = 123

func main() {
	println(&bl, bl)
	println(&cl, cl) // cannot take address of cl (untyped int constant 100)
}
```

答案：

常量不同于变量的在运行期分配内存，常量通常会被编译器在预处理阶段直接展开，作为指令数据使用



## 22 goto的用法

编译执行下面代码会出现什么?

```go
package main
 
func main()  {
    for i:=0;i<10 ;i++  {
    loop:
        println(i)
    }
    goto loop
}
```

答案：

goto只能跳到同层或上层作用域，不能跳到内部作用域；



## 23 defintion类型和alias类型

编译执行下面代码会出现什么?

```go
package main

import "fmt"

func main() {
	type MyInt1 int // defintion
	type MyInt2 = int // alias
	var i int = 9
	var i1 MyInt1 = i
	//    var i1 MyInt1 = MyInt1(i) // 需要强制转换才能赋值
	var i2 MyInt2 = i
	fmt.Println(i1, i2)
}
```

答案：

基于一个类型创建一个新类型，称之为defintion；基于一个类型创建一个别名，称之为alias。

MyInt1为称之为defintion，虽然底层类型为int类型，但是不能直接赋值，需要强转； MyInt2称之为alias，可以直接赋值。



## 24 alias类型也有基础类型的方法

编译执行下面代码会出现什么?

```go
package main

import "fmt"

type User struct {
}
type MyUser1 User
type MyUser2 = User

func (i MyUser1) m1() {
	fmt.Println("MyUser1.m1")
}

func (i User) m2() {
	fmt.Println("User.m2")
}

func main() {
	var i1 MyUser1
	var i2 MyUser2
	i1.m1()
	i2.m2()
}
```

答案：

User的alias类型MyUser2，完全等价于User，所以具有其方法；输出结果：

```
MyUser1.m1
User.m2
```



## 25 alias类型方法字段调用

编译执行下面代码会出现什么?

```go
package main

import "fmt"

type T1 struct {
}

func (t T1) m1() {
	fmt.Println("T1.m1")
}

type T2 = T1
type MyStruct struct {
	T1
	T2
}

func main() {
	my := MyStruct{}
	my.m1() // ambiguous selector my.m1
}
```

答案：

type alias 本质上是一样的，源类型怎么用，别名类型就怎么用，具有源类型的方法，字段等；这里因为T1字段和T2字段一样，所以调用不知道调哪一个，可以改为：

```go
my.T1.m1()
my.T2.m1()
```



## 26 变量的作用域

编译执行下面代码会出现什么?

```go
package main
 
import (
    "errors"
    "fmt"
)
 
var ErrDidNotWork = errors.New("did not work")
 
func DoTheThing(reallyDoIt bool) (err error) {
    if reallyDoIt {
        result, err := tryTheThing()
        if err != nil || result != "it worked" {
            err = ErrDidNotWork
        }
    }
    return err
}
 
func tryTheThing() (string,error)  {
    return "",ErrDidNotWork
}
 
func main() {
    fmt.Println(DoTheThing(true))
    fmt.Println(DoTheThing(false))
}
```

答案：

if语句内的err会覆盖函数作用域内的err，所以输出结果：

```go
<nil>
<nil>
```

DoTheThing函数可以修改为：

```go
func DoTheThing(reallyDoIt bool) (err error) {
    var result string
    if reallyDoIt {
        result, err = tryTheThing()
        if err != nil || result != "it worked" {
            err = ErrDidNotWork
        }
    }
    return err
}
```



## 27 闭包延迟求值

编译执行下面代码会出现什么?

```go
package main
 
func test() []func()  {
    var funs []func()
    for i:=0;i<2 ;i++  {
        funs = append(funs, func() {
            println(&i,i)
        })
    }
    return funs
}
 
func main(){
    funs:=test()
    for _,f:=range funs{
        f()
    }
}
```

答案：

for循环复用局部变量i，每一次放入匿名函数的应用都是想一个变量。输出：

```go
0xc000014070 2
0xc000014070 2
```

test函数可以修改为：

```go
func test() []func()  {
    var funs []func()
    for i:=0;i<2 ;i++  {
        x:=i
        funs = append(funs, func() {
            println(&x,x)
        })
    }
    return funs
}
```



## 28 闭包引用相同的变量

编译执行下面代码会出现什么?

```go
package main

func test(x int) (func(), func()) {
	return func() {
			println(x)
			x += 10
		}, func() {
			println(x)
		}
}

func main() {
	a, b := test(100)
	a()
	b()
}
```

答案：

输出结果：

```
100
110
```



## 29 panic仅有最后一个可以被revover捕获

编译执行下面代码会出现什么?

```go
package main

import (
	"fmt"
)

func main() {

	defer func() {
		if err := recover(); err != nil {
			fmt.Println(err)
		} else {
			fmt.Println("fatal")
		}
	}()

	defer func() {
		panic("defer panic")
	}()
	panic("panic")
}
```

答案：

defer中的panic会覆盖之前的panic，会输出：

```go
defer panic
```



## 30 往已经关闭的channel写入数据会panic的。

执行下面的代码发生什么？

```go
func main() {
	ch := make(chan int, 1000)
	go func() {
		for i := 0; i < 10; i++ {
			ch <- i
		}
	}()

	go func() {
		for {
			a, ok := <-ch
			if !ok {
				fmt.Println("close")
				return
			}
			fmt.Println("a: ", a)
		}
	}()

	close(ch)
	fmt.Println("ok")
	time.Sleep(time.Second * 1)
}
```

往已经关闭的channel写入数据会panic的。输出：

```go
ok
close
panic: send on closed channel
```



## 31 fmt.Sprintf，类型的String()方法中用v%

执行下面的代码发生什么？

```go
package main

import "fmt"

type ConfigOne struct {
	Daemon string
}

func (c *ConfigOne) String() string {
	return fmt.Sprintf("print: %v", c)
}

func main() {
	c := &ConfigOne{}
	c.String()
}
```

答案：

因为%v格式化字符串是本身会调用String()方法，这里重写了String()方法，会导致无限递归。所以会报错：

```
runtime: goroutine stack exceeds 1000000000-byte limit
runtime: sp=0xc020160528 stack=[0xc020160000, 0xc040160000]
fatal error: stack overflow
```



## 32 编码长度

输出什么？

```go
package main

import (
	"fmt"
)

func main() {
	fmt.Println(len("你好bj!"))
}
```

答案：

输出：

```
9
```



## 33 修改map中struct成员的值

编译并运行如下代码会发生什么？

```go
package main

import "fmt"

type Test struct {
	Name string
}

var list map[string]Test

func main() {
	list = make(map[string]Test)
    
	name := Test{"xiaoming"}
	list["name"] = name
	list["name"].Name = "Hello"
    
	fmt.Println(list["name"])
}
```

答案：

编程报错`cannot assign to struct field list["name"].Name in map。`

map的value本身是不可寻址的，因为map中的值会在内存中移动，并且旧的指针地址在map改变时会变得无效。

定义的Test不是指针，而且map是可以自动扩容的，那么原来的存储name的Test可能在地址A，但是如果map扩容了地址A就不是原来的Test了，所以go就不允许我们写数据。

可以改为如下：

```go
package main

import "fmt"

type Test struct {
	Name string
}

var list map[string]*Test

func main() {
	list = make(map[string]*Test)
    
	name := Test{"xiaoming"}
	list["name"] = &name
	list["name"].Name = "Hello"
    
	fmt.Println(list["name"])
}
```



## 34 *interface{}

ABCD中哪一行存在错误？

```go
package main

type S struct {
}

func f(x interface{}) {
}

func g(x *interface{}) {
}

func main() {
	s := S{}
	p := &s
	f(s) //A
	g(s) //B
	f(p) //C
	g(p) //D
}
```

答案：

函数中`func f(x interface{})`的`interface{}`可以支持传入golang的任何类型，包括指针；

但是函数`func g(x *interface{})`的`*interface{}`是指向接口的指针，只能传入`*interface{}`指针，所以BD错误，可以修改为如下：

```go
	g(nil)
	g((*interface{})(nil))
```



## 35 WaitGroup

编译并运行如下代码会发生什么？

```go
package main

import (
	"sync"
)

const N = 10

var wg = &sync.WaitGroup{}

func main() {
	for i := 0; i < N; i++ {
		go func(i int) {
			wg.Add(1)
			println(i)
			defer wg.Done()
		}(i)
	}
	wg.Wait()
}
```

答案：

执行的太快，可能导致`wg.Add(1)`还没有执行main函数就执行完毕了，可以改为：

```go
func main() {
	for i := 0; i < N; i++ {
		wg.Add(1)
		go func(i int) {
			println(i)
			defer wg.Done()
		}(i)
	}
	wg.Wait()
}
```



## 36 map初始值为nil时，不能添加键值对

下面代码能运行吗？为什么

```go
type Param map[string]interface{}

type Show struct {
	Param
}

func main() {
	s := new(Show)
	s.Param["RMB"] = 10000
	fmt.Println(s)
}
```

答案：

会报错，字典`Param`的默认值为`nil`，当给字典`nil`增加键值对是就会发生运行时错误`panic: assignment to entry in nil map`。可以修改为：

```go
type Param map[string]interface{}

type Show struct {
	Param
}

func main() {
	s := new(Show)
	s.Param = Param{} // 为字典Param赋初始值
	s.Param["RMB"] = 10000 // 修改键值对
	fmt.Println(s)
}
```



## 37 接口只能调用方法，不能调用属性

请说出下面代码存在什么问题

```go
package main

type student struct {
	Name string
}

func f(v interface{}) {
	switch msg := v.(type) {
	case *student, student:
		msg.Name
	}
}
```

答案：

问题一：interface{}是一个没有声明任何方法的接口。
问题二：Name是一个属性，而不是方法，interface{}类型的变量无法调用属性

可以改为：

```go
s := v.(student)
s.Name = "qq"
```



## 38 首字母大小写的访问控制

写出打印的结果。

```go
package main

import (
	"encoding/json"
	"fmt"
)

type People struct {
	name string `json:"name"`
//    Name string `json:"name"`
}

func main() {
	js := `{
        "name":"11"
    }`
	var p People
	err := json.Unmarshal([]byte(js), &p)
	if err != nil {
		fmt.Println("err: ", err)
		return
	}
	fmt.Println("people: ", p)
}
```

答案：

输出结果：

```
people:  {}
```

p中的属性值为空是因为，name的首字母小写，json包访问不到，所以首字母修改成大写即可。



## 39 函数传参

请说明下面代码书写是否正确

```go
var value int32

func SetValue(delta int32) {
	for {
		v := value
		if atomic.CompareAndSwapInt32(&value, v(v+delta)) {
			break
		}
	}
}
```

答案：

函数声明是`func CompareAndSwapInt32(addr *int32, old, new int32) (swapped bool)`，少了一个参数，可以改为：

```go
func SetValue(delta int32) {
	for {
		v := value
		// 比较并交换
		if atomic.CompareAndSwapInt32(&value, v, v+delta) {
			fmt.Println(value)
			break
		}
	}
}
```



## 40 断言语句

下面程序运行后会有什么异常？

```go
package main

import (
    "fmt"
    "time"
)

type Project struct{}

func (p *Project) deferError() {
    if err := recover(); err != nil {
        fmt.Println("recover: ", err)
    }
}

func (p *Project) exec(msgchan chan interface{}) {
    for msg := range msgchan {
        m := msg.(int)
        fmt.Println("msg: ", m)
    }
}

func (p *Project) run(msgchan chan interface{}) {
    for {
        defer p.deferError()
        go p.exec(msgchan)
        time.Sleep(time.Second * 2)
    }
}

func (p *Project) Main() {
    a := make(chan interface{}, 100)
    go p.run(a)
    go func() {
        for {
            a <- "1"
            time.Sleep(time.Second)
        }
    }()
    time.Sleep(time.Second * 100)
}

func main() {
    p := new(Project)
    p.Main()
}
```

答案：

入到管道的数据类型为`string`，而方法`exec`中的断言语句`m := msg.(int)`却断言成了`int`，所以需要改为：

```go
m := msg.(string)
```



## 41 读取缓存通道

请说出下面代码哪里写错了。

```go
func main() {
    abc := make(chan int, 1000)
    for i := 0; i < 10; i++ {
        abc <- i
    }
    go func() {
        for {
            a := <-abc
            fmt.Println("a: ", a)
        }
    }()
    close(abc)
    fmt.Println("close")
    time.Sleep(time.Second * 100)
}
```

答案：

`goroutine`中的for循环没有出口，因该设置出口：

```go
	go func() {
		for {
			a, ok := <-abc
			if !ok {
				fmt.Println("结束！")
				return
			}
			fmt.Println("a: ", a)
		}
	}()
```



## 42 修改字典中结构体属性的值

请说出下面代码，执行时为什么会报错

```go
type Student struct {
    name string
}

func main() {
    m := map[string]Student{"people": {"liyuechun"}}
    m["people"].name = "wuyanzu"
}
```

报错是因为不能修改字典中value为结构体的属性值。可改为如下：

```go
func main() {
	m := map[string]Student{"people": {"liyuechun"}}

	// 不能修改字典中结构体属性的值
	//m["people"].name = "wang"

    // 结构体整体更新
	m["people"] = Student{"wang"}
	fmt.Println(m)
    
    // map中改为结构体指针
    m1 := map[string]*Student{"people": &Student{"liyuechun"}}
    m["people"].name = "wang"
    fmt.Println(m["people"])
}
```



## 43 channel读取

说出下面的代码存在什么问题

```go
type query func(string) string

func exec(name string, vs ...query) string {
    ch := make(chan string)
    fn := func(i int) {
        ch <- vs[i](name)
    }
    for i, _ := range vs {
        go fn(i)
    }
    return <-ch
}

func main() {
    ret := exec("111", func(n string) string {
        return n + "func1"
    }, func(n string) string {
        return n + "func2"
    }, func(n string) string {
        return n + "func3"
    }, func(n string) string {
        return n + "func4"
    })
    fmt.Println(ret)
}
```

答案：

`return <-ch`只之执行一次，所以不管传入多少query函数，都只是读取最先执行完的ch。



## 44 defer中方法调用顺序

下面程序运行的结果是什么？

```go
type Slice []int

func NewSlice() Slice {
	return make(Slice, 0)
}

func (s *Slice) Add(elem int) *Slice {
	*s = append(*s, elem)
	fmt.Println(elem)
	return s
}

func main() {
	s := NewSlice()
    defer s.Add(1).Add(2) // Add(1)会先执行成结果
	s.Add(3)
}
```

答案：

```
1
3
2
```



## 45 有方向的channel不能关闭

以下代码有什么问题？

```go
package main

func Stop(stop <-chan bool) {
	close(stop)
}
```

答案：

有方向的 channel 不可被关闭



## 46 range 副本机制

执行下面代码输出什么？

```go
func main() {
	five := []string{"Annie", "Betty", "Charley", "Doug", "Edward"}

	for _, v := range five {
		five = five[:2]
		fmt.Printf("v[%s]\n", v)
	}
}
```

答案：

循环内的切片长度会缩减为 2，但循环是在切片值的自身副本上进行操作的，原切片仍然没变，所以输出结果：

```go
v[Annie]
v[Betty]
v[Charley]
v[Doug]
v[Edward]
```



## 47 map key 类型

编译并运行如下代码会发生什么？

```go
package main

import "fmt"

func main() {
	mmap := make(map[map[string]string]int, 0)
	mmap[map[string]string{"a": "a"}] = 1
	mmap[map[string]string{"b": "b"}] = 1
	mmap[map[string]string{"c": "c"}] = 1
	fmt.Println(mmap)
}
```

答案：

map 的 key 可以是很多种类型，比如 bool, 数字，string, 指针，channel , 还有 只包含前面几个类型的 interface types, structs, arrays。

slice， map， function，底层含指针的struct，这几个没法用 == 来判断，即不可比较类型就不能作为key。

可以修改`map[map[string]string]int` 改为`map[struct]int`：

```go
type MyStruct struct {
	a int
	s string
}

func main() {
	mmap := make(map[MyStruct]int, 0)
	mmap[MyStruct{1, "a"}] = 1
	fmt.Println(mmap)
}
```



## 48 string赋值给Int类型的情况

 fun1 和 fun2 fun3分别输出什么，为什么?

```go
func fun1()  {
    a := 2
    c := (*string) (unsafe.Pointer(&a))
    *c = "44"
    fmt.Println(*c)
}
func fun2()  {
    a := "654"
    c := (*string) (unsafe.Pointer(&a))
    *c = "44"
    fmt.Println(*c)
}
func fun3()  {
    a := 3
    c := *(*string) (unsafe.Pointer(&a))
    c = "445"
    fmt.Println(c)
}
```

答案：

```go

44
445
```

解析：

string的结构：

```go
type StringHeader struct {
	Data uintptr	// 8byte
	Len  int		// 8byte
}
```



```go
func fun1() {
	a := 2                             // 申请一个int类型，占用8byte，其内容为2
	fmt.Println(&a)                    // 0xc000014070
	c := (*string)(unsafe.Pointer(&a)) // c为*string类型，占用8byte，指向a的指针，a的内容为2
	fmt.Println(&c, c)                 // 0xc00000e030 0xc000014070
	*c = "44"                          // 16 byte的string类型填充到a的地址，8 byte的 Len字段会溢出
	fmt.Println(&c, c)                 // 0xc00000e030 0xc000014070
	fmt.Println(*c)                    // 因为c的Len字段是溢出到无效内存中，所以如果其他指令有变量定义的操作，很可能把Len字段给覆盖掉，
                                       //一旦Len被覆盖，这时输出c，很大概率就会panic，没有覆盖就能正常输出
}
func fun2()  {
    a := "654"
    c := (*string) (unsafe.Pointer(&a))
    *c = "44"
    fmt.Println(*c)
}
func fun3() {
	a := 3
	fmt.Println(&a)                     // 0xc000014078
	c := *(*string)(unsafe.Pointer(&a)) // 这里获取的是a地址里的string值，操作失败，但c被定义成了string型变量
	fmt.Println(&c)                     // 0xc000010260
	c = "445"                           // 给string型变量赋string值
	fmt.Println(&c)                     // 0xc000010260
}
```



## 49 rand并发

下面代码有什么问题？

```go
func main() {
	rank := rand.New(rand.NewSource(time.Now().UnixNano()))
	for i := 0; i < 15; i++ {
		go func(i int) {
			for {
				_ = rank.Int()
			}
		}(i)
	}
	time.Sleep(10 * time.Second)
}
```

答案：

出现panic，因为并发时候rand会出现并发读写导致`index out of range`。

可以改为：

```go
func main() {
	for i := 0; i < 15; i++ {
		go func(i int) {
			for {
				_ = rand.Int() // 函数中含有全局锁，协程中单独生成rand有利于降低损耗
                //_ = rand.New(rand.NewSource(time.Now().UnixNano())).Int()
			}
		}(i)
	}
	time.Sleep(10 * time.Second)
}
```



## 50 函数的参数传值方式

```go
type IdType struct {
	Id   int
	Name string
}

func main() {
	list := []IdType{}
	fmt.Println(list)
	func(list []IdType) { // 参数通过值传递到函数中，并没有改变原切片内容
		list = append(list, IdType{
			Id:   1,
			Name: "a",
		})
	}(list)
	fmt.Println(list)

	func(list *[]IdType) { // 参数通过指针传递到函数中，改变了切片内容
		*list = append(*list, IdType{
			Id:   2,
			Name: "b",
		})
	}(&list)
	fmt.Println(list)

	func() { // 直接用外部的变量，改变了切片内容
		list = append(list, IdType{
			Id:   3,
			Name: "c",
		})
	}()
	fmt.Println(list)
}
```

在Go语言中，函数参数都是以复制的方式（不支持以引用的方式）传递（比较特殊的是，Go语言闭包函数对外部变量是以引用的方式使用的），输出内容：

```
[]
[]
[{4 d}]
[{4 d} {5 e}]
```



## 51 append

输出结果是什么？

```go
package main

import "fmt"

func main() {
	var nums1 []interface{}
	nums2 := []int{1, 2, 3}
	num3 := append(nums1, nums2)
	fmt.Println(len(num3), num3)
}
```

答案：

nums2作为一个整体添加到切片中，输出：

```
1 [[1 2 3]]
```







# 编程题

## 1 在utf8字符串判断是否包含指定字符串，并返回下标。

例子：

“北京天安门最美丽” , “天安门”

结果：2

```go
package main

import (
	"fmt"
	"strings"
)

func Utf8Index(str, substr string) int {
	asciiPos := strings.Index(str, substr)
	if asciiPos == -1 || asciiPos == 0 {
		return asciiPos
	}

	pos := 0
	totalSize := 0
	reader := strings.NewReader(str)
	for _, size, err := reader.ReadRune(); err == nil; _, size, err = reader.ReadRune() {
		totalSize += size
		pos++
		// 匹配到
		if totalSize == asciiPos {
			return pos
		}
	}
	return pos
}

func main() {
	fmt.Println(Utf8Index("北京天安门最美丽", "天安门"))
	fmt.Println(strings.Index("北京天安门最美丽", "男"))
	fmt.Println(strings.Index("", "男"))
	fmt.Println(Utf8Index("12ws北京天安门最美丽", "天安门"))
}
```



## 2 反转整数

反转一个整数，例如：

例子1: x = 123, return 321
例子2: x = -123, return -321

输入的整数要求是一个 32bit 有符号数，如果反转后溢出，则输出 0

```go
func reverse(x int) (num int) {
	for x != 0 {
		num = num*10 + x%10
		x = x / 10
	}
	// 使用 math 包中定义好的最大最小值
	if num > math.MaxInt32 || num < math.MinInt32 {
		return 0
	}
	return
}
```



## 3 合并重叠区间

给定一组 区间，合并所有重叠的 区间。

例如：
给定：[1,3],[2,6],[8,10],[15,18]
返回：[1,6],[8,10],[15,18]

```go
type Interval struct {
	Start int
	End   int
}

func merge(intervals []Interval) []Interval {
	if len(intervals) <= 1 {
		return intervals
	}

	sort.Slice(intervals, func(i, j int) bool {
		return intervals[i].Start < intervals[j].Start
	})

	res := make([]Interval, 0)
	swap := Interval{}
	for k, v := range intervals {
		if k == 0 {
			swap = v
			continue
		}
		if v.Start <= swap.End {
			swap.End = v.End
		} else {
			res = append(res, swap)
			swap = v
		}
	}
	res = append(res, swap)
	return res
}
```



## 4 根据指定的 size 切割切片为多个小切片

实现一个函数可以根据指定的 size 切割切片为多个小切片

```go
func main() {
	lenth := 11
	size := 5
	list := make([]int, 0, lenth)
	for i := 0; i < lenth; i++ {
		list = append(list, i)
	}
	SpiltList(list, size)
}

func SpiltList(list []int, size int) {
	lens := len(list)
	mod := math.Ceil(float64(lens) / float64(size))
	spliltList := make([][]int, 0)
	for i := 0; i < int(mod); i++ {
		tmpList := make([]int, 0, size)
		fmt.Println("i=", i)
		if i == int(mod)-1 {
			tmpList = list[i*size:]
		} else {
			tmpList = list[i*size : i*size+size]
		}
		spliltList = append(spliltList, tmpList)
	}
	for i, sp := range spliltList {
		fmt.Println(i, " ==> ", sp)
	}
}
```



## 5 轮流输出

实现两个 go 轮流输出：A1B2C3.....Z26

方法一，使用缓冲chan

```go
func ChannelFunc() {
	zimu := make(chan int, 1)
	suzi := make(chan int, 1)
	zimu <- 0
	// zimu
	go func() {
		for i := 65; i <= 90; i++ {
			<-zimu
			fmt.Printf("%v", string(rune(i)))
			suzi <- i
		}
		return
	}()

	go func() {
		for i := 1; i <= 26; i++ {
			<-suzi
			fmt.Printf("%v", i)
			zimu <- i
		}
		return
	}()

	time.Sleep(1 * time.Second)
	fmt.Println()
}
```



方法二，使用无缓冲chan

```go
func Channel1Func() {
	zimu := make(chan int)
	suzi := make(chan int)

	// zimu
	go func() {
		for i := 65; i <= 90; i++ {
			fmt.Printf("%v", string(rune(i)))
			zimu <- i
			<-suzi
		}
		return
	}()

	go func() {
		for i := 1; i <= 26; i++ {
			<-zimu
			fmt.Printf("%v", i)
			suzi <- i
		}
		return
	}()

	time.Sleep(10 * time.Second)
	fmt.Println()
}
```



方法三，使用锁



## 6 [ssss [1 2 3 4]] 输出为 [ssss 1 2 3 4]

解决下面问题：输出 MutilParam= [ssss [1 2 3 4]] 如何做到输出为 [ssss 1 2 3 4]？

```go
func MutilParam(p ...interface{}) {
	fmt.Println("MutilParam=", p)
}
func main() {
	MutilParam("ssss", 1, 2, 3, 4) //[ssss 1 2 3 4]
	iis := []int{1, 2, 3, 4}
	MutilParam("ssss", iis) //输出MutilParam= [ssss [1 2 3 4]]如何做到输出为[ssss 1 2 3 4]
}
```

答案：

这样的情况会在开源类库如 xorm 升级版本后出现 Exce 函数不兼容的问题。 解决方式有两个：

方法一，interface{}

```go
tmpParams := make([]interface{}, 0, len(iis)+1)
tmpParams = append(tmpParams, "ssss")
for _, ii := range iis {
    tmpParams = append(tmpParams, ii)
}
MutilParam(tmpParams...)
```



方法二，反射

```go
f := MutilParam
value := reflect.ValueOf(f)
pps := make([]reflect.Value, 0, len(iis)+1)
pps = append(pps, reflect.ValueOf("ssss"))
for _, ii := range iis {
    pps = append(pps, reflect.ValueOf(ii))
}
value.Call(pps)
```







# 问答题

## 1 for 和 for range 有什么区别？

当map的key为string类型时，应该用for range，这样可以同事获得key和value；

for range 遍历 channel；

for range 使用值拷贝的方式代替被遍历的元素本身，是一个值拷贝，而不是元素本身。



## 2 讲述一下WaitGroup与Context控制并发的区别？

WaitGroup控制的goroutine并发，典型实例：

```go
func main() {
	var wg sync.WaitGroup
	wg.Add(2)
	go func() {
        defer wg.Done()
		time.Sleep(2*time.Second)
		fmt.Println("1号睡醒")
	}()
	go func() {
        defer wg.Done()
		time.Sleep(3*time.Second)
		fmt.Println("2号睡醒")
	}()
	wg.Wait()
	fmt.Println("==over==")
}
```



## 3 go语言中的引用类型包含哪些？

切片(slice)、字典(map)、通道（channel）、接口（interface）



## 4 go语言的channel特性？

A. 给一个 nil channel 发送数据，造成永远阻塞
B. 从一个 nil channel 接收数据，造成永远阻塞
C. 给一个已经关闭的 channel 发送数据，引起 panic
D. 从一个已经关闭的 channel 接收数据，如果缓冲区中为空，则返回一个零值
E. 无缓冲的channel是同步的，而有缓冲的channel是非同步的



## 5 进程、线程、协程之间的区别？

进程是资源的分配和调度的一个独立单元，而线程是CPU调度的基本单元；
同一个进程中可以包括多个线程；
进程结束后它拥有的所有线程都将销毁，而线程的结束不会影响同个进程中的其他线程的结束；
线程共享整个进程的资源（寄存器、堆栈、上下文），一个进程至少包括一个线程；
进程的创建调用fork或者vfork，而线程的创建调用pthread_create；
线程中执行时一般都要进行同步和互斥，因为他们共享同一进程的所有资源；
进程是资源分配的单位 

线程是操作系统调度的单位 
进程切换需要的资源很最大，效率很低 
线程切换需要的资源一般，效率一般 
协程切换任务资源很小，效率高 
多进程、多线程根据cpu核数不一样可能是并行的 也可能是并发的。协程的本质就是使用当前进程在不同的函数代码中切换执行，可以理解为并行。 协程是一个用户层面的概念，不同协程的模型实现可能是单线程，也可能是多线程。

进程拥有自己独立的堆和栈，既不共享堆，亦不共享栈，进程由操作系统调度。（全局变量保存在堆中，局部变量及函数保存在栈中）
线程拥有自己独立的栈和共享的堆，共享堆，不共享栈，线程亦由操作系统调度(标准线程是这样的)。
协程和线程一样共享堆，不共享栈，协程由程序员在协程的代码里显示调度。

一个应用程序一般对应一个进程，一个进程一般有一个主线程，还有若干个辅助线程，线程之间是平行运行的，在线程里面可以开启协程，让程序在特定的时间内运行。

协程和线程的区别是：协程避免了无意义的调度，由此可以提高性能，但也因此，程序员必须自己承担调度的责任，同时，协程也失去了标准线程使用多CPU的能力。



# 陷阱

https://github.com/basicExploration/blog/blob/master/go/go/important/README.md





# 总结

1. golang中的指针

> * 什么时候用”\*“？
>   在定义指针类型时用
>   已有指针类型，但需要返回实体类型，这时需要把指针转化为实体
> * 什么时候用”&“？
>   在需要把实体转化为指针时
> * 为什么要把函数的参数和返回值定义为指针？
>   为了能在函数中修改参数的值；
>   当返回值为空时，指针可以设为nil，很容易。实体要设为空值（结构体的空值），很麻烦。
> * Go语言中，”map, channel, slice，interface“是引用类型，”array，struct“是值类型（value type). 引用类型类似指针，但不是指针，前面不能加”\*“把它变成实体。

2. go是强类型语言

> * 不同类型数值不能相加
> * 类型定义与类型别名中，类型定义要转换类型才能赋值

3. map

> * 打印一个map中不存在的值时，返回元素类型的零值

4. 可比较类型和不可比较类型

> * 可比较类型有bool、数值类型、字符、指针、数组、接口
> * 不可比较类型有slice、map、函数
> * 结构体比较时，要成员和顺序都相同，并且成员都可比较
> * slice/struct/map可用reflect.DeepEqual来判断是否相等

5. i.(type)中的i是接口
6. 字符串连接

> * strings.Join()
> * buffer.WriteString()
> * str := "abc" + "123"
> * fmt.Sprintf("abc%d", 123)

7. nil

> * nil只能赋值给指针，chan，func，interface，map，slice

8. 简短模式声明的限制条件

> * 必须使用显示初始化
> * 不能提供数据类型
> * 只能在函数内部使用

9. new和make

> * new(T)返回T的指针\*T并指向T的零值
> * make(T)返回初始化后的T，这个值不是零值，也不是指针，是初始化后T的引用，只能用于slice，map，channel

10. 返回值

> * 有多个返回值时，只要有一个返回值有命令，其他的也必须命名

11. 接口类型

> * 不要使用指针指向接口类型，因为他以己经是一个指针
>
>   ```go
>   type S struct {
>   }
>   func f(x interface{}) {}
>   func g(x *interface{}) {}
>   func main() {
>   s := S{}
>   p := &s
>   f(s)
>   //g(s)    //有错
>   f(p)
>   //g(p)    //有错
>   }
>   ```
>
>   

