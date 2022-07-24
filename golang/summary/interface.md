[toc]



# 空接口

## 空接口底层结构和定义

底层结构：

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
```

定义：

```go
// 空接口
var in interface{}

type any interface{}
```



每一个接口都包含两个属性，一个是值，一个是类型，而对于空接口来说，这两者都是 nil：

```go
package main

import (
    "fmt"
)

func main() {
    var i interface{}
    fmt.Printf("type: %T, value: %v", i, i)
}

// type: <nil>, value: <nil>
```



## 空接口用法

### 1 使用interface{}作为类型声明一个实例

```go
type rectangle struct {  
  	height float64  
 	width float64  
}  
  
type Any interface{}  
  
func main() {  
  	var any Any  
    
 	any = 5  
 	fmt.Printf("%v,%[1]T\n", any)//5,int
    
 	any = "Hello,World"  
 	fmt.Printf("%v,%[1]T\n", any)//Hello,World,string
    
  	any = &rectangle{height: 4, width: 5}  
  	fmt.Printf("%v,%[1]T\n", any) //&{4 5},*main.rectangle
}
```



### 2 作为函数参数接收任意类型的值

```go
func myfunc(iface interface{}){
    fmt.Println(iface)
}

func main()  {
    a := 10
    b := "hello"
    c := true

    myfunc(a)
    myfunc(b)
    myfunc(c)
}
```

接收任意个任意类型的值

```go
func myfunc(ifaces ...interface{}){
    for _,iface := range ifaces{
        fmt.Println(iface)
    }
}

func main()  {
    a := 10
    b := "hello"
    c := true

    myfunc(a, b, c)
}
```



### 3 接收不同类型变量的 array、slice、map、strcut

```go
func main() {
    any := make([]interface{}, 5)
    any[0] = 11
    any[1] = "hello world"
    any[2] = []int{11, 22, 33, 44}
    for _, value := range any {
        fmt.Println(value)
    }
}

// 输出结果
//11
//hello world
//[11 22 33 44]
//<nil>
//<nil>
```

空接口底层是两个指针，所以不能直接拷贝，可以用for-range的方式完成拷贝：

```go
package main

import "fmt"

func main() {
	testSlice := []int{11,22,33,44}

	// 正常类型的拷贝
	var newSlice []int
	newSlice = testSlice
	fmt.Println(newSlice)

	// 空接口数据的拷贝
	var any []interface{}
	//for _,value := range testSlice{
	//	any = append(any,value)
	//}
    for i, d := range testSlice{  
		any[i] = d  
	}
    
	fmt.Println(any)
}
```

用切片来对原数组进行修改，不仅可以修改数据的值，同时也可以修改数据的类型。

```go
package main

import "fmt"

type Any interface{}

type Container struct {
	a []Any
}
type rectangle struct {
	height float64
	width  float64
}

func (p *Container) Set(i int, e Any) {
	p.a[i] = e
}

func (p *Container) At(i int) Any {
	return p.a[i]
}

func main() {
	var a = new([3]Any)
	a[0] = "Hello,World"
	a[1] = 32
	a[2] = &rectangle{3, 4}
	b := Container{a[:]}
	// b := Container{
	// 	[]Any{"hello", 1, &rectangle{3, 4}},
	// }
	b.Set(0, "Hello")
	b.Set(1, 123.4)
	for c := range a {
		fmt.Printf("%v\t%[1]T\n", b.At(c))
	}
}

// 输出结果
//Hello   string
//123.4   float64
//&{3 4}  *main.rectangle
```





用空接口来接收任意类型的参数时，它的静态类型是 interface{}，但动态类型（是 int，string 还是其他类型）并不知道，因此需要使用类型断言。

```go
func myfunc(i interface{})  {
    switch i.(type) {
    case int:
        fmt.Println("参数的类型是 int")
    case string:
        fmt.Println("参数的类型是 string")
    }
}

func main() {
    a := 10
    b := "hello"
    myfunc(a)
    myfunc(b)
}
```



### 4 使用空接口实现的一个二叉树：

```go
type Node struct {  
	left *Node  
	data interface{}  
	right *Node  
}  
func NewNode(left,right *Node) *Node{  
	return &Node{left,nil,right}  
}  
func (n *Node) SetData(data interface{}){  
	n.data = data  
}
func main(){
	root := NewNode(nil,nil)  
	root.SetData("Root Node")  
	leftChild := NewNode(nil,nil)  
	leftChild.SetData("Left Node")  
	rightChile := NewNode(nil,nil)  
	rightChile.SetData("Right Node")  
	root.left = leftChild  
	root.right = rightChile 
    
	fmt.Printf("%v",root)
}
————————————————
//输出结果为：
//&{0xc000022060 Root Node 0xc000022080}
```





# 有方法的接口

底层结构：

```go
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
```

定义：

```go
// 带有方法的接口
type People interface {
    Show()
}
```

