

正则在线工具：https://c.runoob.com/front-end/854/





MatchString函数

```go
match,_:=regexp.MatchString("p([a-z]+)ch","peddach") 
fmt.Println(match)  //结果为true
```





Compile函数或MustCompile函数

```go
r,_:=regexp.Compile("p([a-z]+)ch")
b:=r.MatchString("peach")
fmt.Println(b)  //结果为true

r1:=regexp.MustCompile("p([a-z]+)ch")
b1:=r1.MatchString("peach")
fmt.Println(b)   //结果为true
```



Regexp结构体中一些常用的方法

```go
	r, _ := regexp.Compile("p([a-z]+)ch")
	fmt.Println(r.MatchString("peach")) //j结果：true

	//查找匹配的字符串
	fmt.Println(r.FindString("peach punch")) //打印结果：peach

	//查找匹配字符串开始和结束位置的索引，而不是匹配内容[0 5]
	fmt.Println(r.FindStringIndex("peach punch")) //打印结果： [0 5]

	//返回完全匹配和局部匹配的字符串，例如，这里会返回  p([a-z]+)ch 和 `([a-z]+) 的信息
	fmt.Println(r.FindStringSubmatch("peach punch")) //打印结果：[peach ea]

	//返回完全匹配和局部匹配的索引位置
	fmt.Println(r.FindStringSubmatchIndex("peach punch")) //打印结果： [0 5 1 3]

	//返回所有的匹配项，而不仅仅是首次匹配项。正整数用来限制匹配次数
	fmt.Println(r.FindAllString("peach punch pinch", -1)) //打印结果：[peach punch pinch]
	fmt.Println(r.FindAllString("peach punch pinch", 2))  //匹配两次   打印结果：[peach punch]

	//返回所有的完全匹配和局部匹配的索引位置
	fmt.Println(r.FindAllStringSubmatchIndex("peach punch pinch", -1))
	//打印结果： [[0 5 1 3] [6 11 7 9] [12 17 13 15]]

	//上面的例子中，我们使用了字符串作为参数，并使用了如 MatchString 这样的方法。我们也可以提供 []byte参数并将 String 从函数命中去掉。
	fmt.Println(r.Match([]byte("peach"))) //打印结果：true

	r1 := regexp.MustCompile("p([a-z]+)ch")

	//将匹配的结果，替换成新输入的结果
	fmt.Println(r1.ReplaceAllString("a peach", "<fruit>")) //打印结果： a <fruit>

	//Func 变量允许传递匹配内容到一个给定的函数中，
	in := []byte("a peach")
	out := r1.ReplaceAllFunc(in, bytes.ToUpper)
	fmt.Printf(string(out)) //打印结果：   a PEACH
```

