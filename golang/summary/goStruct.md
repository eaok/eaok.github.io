

结构体使用指针和值的传递



值传递：

```go
package main

type T struct{
	Value 		int
}

func main(){
	myT := T{Value:666}

	change(myT)

	println(myT.Value)

}
func change(t T){
	t.Value = 999
}
// 666
```

指针传递：

```go
package main

type T struct{
	Value 		int
}

func main(){
	myT := T{Value:666}

	change(&myT)

	println(myT.Value)

}
func change(t *T){
	t.Value = 999
}
// 999
```

实际上这里传递的依然是一个副本，只不过这个副本是一个地址，它指向原来的值；所以，你可以修改 t.Value的值，但你无法修改 t；

```go
package main

type T struct{
	Value 		int
}

func main(){
	myT := T{Value:666}

	change(&myT)

	println(myT.Value)

}
func change(t *T){
	t = &T{Value:999}
}
// 666
```



当你的函数本意是改变原始数据时，那么肯定用指针转递；

当你的结构非常大时，比如包含庞大的切片、map时，也需要用指针转递；

但是如果你的结构体非常小，且不打算修改结构体内容，那么应该考虑使用值传递；