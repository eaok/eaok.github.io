

[TOC]



# 类型转换整理

字符串转整型

```go
// string到int
num1, err := strconv.Atoi(str)				//第一种
num1, err := strconv.ParseInt(str, 10, 0)	//第二种

// string到int64
num2, err := strconv.ParseInt(str, 10, 64)	//转为int64
```

整型转字符串

```go
// int到string 
str1 := strconv.Itoa(num1)					//第一种
str1 := fmt.Sprintf("%d", num1)				//第二种

// int64到string 
str1 := strconv.FormatInt(int64(num1), 10)	//第三种
```

字符串转浮点型

```go
f1, err := strconv.ParseFloat(str, 64)
```

浮点型转字符串

```go
str := strconv.FormatFloat(f, 'f', -1, 64)
```

其它类型直接用类型转换的格式

```go
f1 := float32(num)
f2 := float64(num)
num := int(f)
```



代码文件：`gogo/summary/typeConver.go`





在go中，数组作为函数参数传递时是值拷贝，不是地址：

```go
// 数组使用值拷贝传参
func main() {
	x := [3]int{1,2,3}
		func(arr [3]int) {
		arr[0] = 7
		fmt.Println(arr) // [7 2 3]
	}(x)
	fmt.Println(x) // [1 2 3] // 并不是你以为的 [7 2 3]
}

// 传址会修改原数据
func main() {
	x := [3]int{1,2,3}
	func(arr *[3]int) {
		(*arr)[0] = 7
		fmt.Println(arr) // &[7 2 3]
    }(&x)
	fmt.Println(x) // [7 2 3]
}
```



访问 map 中不存在的 key时，go会返回元素对应数据类型的零值，所以判断是否存在要看返回的第二个参数：

```go
func main() {
	x := map[string]string{"one": "2", "two": "", "three": "3"}
	if _, ok := x["two"]; !ok {
		fmt.Println("key two is no entry")
	}
}
```



字符串长度：

```go
func main() {
	char := "♥"
    fmt.Println(len(char)) // 3
	fmt.Println(utf8.RuneCountInString(char)) // 1
    
    //RuneCountInString 并不总是返回我们看到的字符数，因为有的字符会占用 2 个 rune
    char := "é"
    fmt.Println(len(char)) // 3
    fmt.Println(utf8.RuneCountInString(char)) // 2
}
```



按位操作，`^` 即时按位取反，也是按位异或(XOR)，go中还多了一个ANDNOT `&^` 操作符，不同位取1：

```go
func main() {
    var a uint8 = 0x2
    var b uint8 = 0x1

    fmt.Printf("%08b (NOT B)\n", ^b)
    fmt.Printf("%08b ^ %08b = %08b [A XOR B]\n", a, b, a^b)
    fmt.Printf("%08b & %08b = %08b [A AND B]\n", a, b, a&b)
    fmt.Printf("%08b &^%08b = %08b [A 'AND NOT' B]\n", a, b, a&^b)
    fmt.Printf("%08b&(^%08b)= %08b [A AND (NOT B)]\n", a, b, a&(^b))
}
```



字符串拼接：

```
//用加号连接
str += ""

// 用fmt.Sprintf
str = fmt.Sprintf("%s %s", str1, str2)

// 用strings.join
fmt.Println(strings.Join(os.Args[1:], " "))
```

