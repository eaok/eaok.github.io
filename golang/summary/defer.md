[toc]



# 一、在有命名返回值的函数中

## 1. retern后有变量或值

return x 这条语句经过编译后会变成三条指令：

```go
//有名返回值
返回的变量 = x
调用 defer函数
return
```

例如：

```go
// nameRetVar1() 闭包引用
/*
r = 0
defer
return
*/
func nameRetVar1() (r int) {
	defer func() {
		r++
	}()

	return 0 // 1
}

// nameRetVar2()
/*
r = t
defer
return
*/
func nameRetVar2() (r int) {
	t := 5
	defer func() {
		t = t + 5
	}()

	return t // 5
}

// nameRetVar3() 函数调用
/*
r = 1
defer
return
*/
func nameRetVar3() (r int) {
	defer func(r int) {
		r = r + 5
	}(r)

	return 1 // 1
}
```



## 2. return后没有变量或值

例如：

```go
// nameRetNone1 闭包引用
func nameRetNone1() (r int) {
	r = 5
	defer func() {
		r = r + 5
	}()

	return // 10
}

// nameRetNone2 函数调用
func nameRetNone2() (r int) {
	r = 1
	defer func(r int) {
		r = r + 5
	}(r)

	return // 1
}
```



# 二、在有匿名返回值的函数中

return x 这条语句经过编译后会变成三条指令：

```go
//匿名返回值
annoy := x
调用 defer函数
return
```

例如：

```go
// anonymityRet1
/*
annoy := i
defer
return
*/
func anonymityRet1() int {
	var i int
	defer func() {
		i++
	}()

	return i // 0
}
```



# 三、defer函数中的参数会被实时解析

例如：

```go
// deferCall 参数会被实时解析
func deferCall() {
	a, b := 1, 2
	defer calc("1", a, calc("10", a, b))

	a = 0
	defer calc("2", a, calc("20", a, b))
	b = 1
}

func calc(index string, a, b int) int {
    ret := a + b
    fmt.Println(index, a, b, ret)
    return ret
}
```



# 四、总结

外部变量作为函数参数时，在defer定义时把值传给defer并缓存起来；

外部变量作为闭包引用时，会在defer函数真正调用时根据上下文确定当前值；



一个例子：

```go
type Person struct {
    age int
}

func main() {
    person := &Person{28}
    
    defer fmt.Println(person.age)	//把28缓存到栈中，defer执行时取出，输出28
    defer func (p *Person) {		//缓存的时结构体的地址，输出29
        fmt.Println(p.age)
    } (person)
    defer func() {					//闭包引用，输出29
        fmt.Println(person.age)
    } ()
    
    person.age = 29
    //person.age = &Person{29}		//更改了结构体地址，第二个defer仍然输出28
}
```



代码文件：`gogo/summary/deferSum.go`