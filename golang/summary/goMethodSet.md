[toc]

# go方法集

值赋给接口

![](https://cdn.jsdelivr.net/gh/eaok/img/golang/valueAssignment.jpg)

指针赋给接口

![](https://cdn.jsdelivr.net/gh/eaok/img/golang/pointerAssignment.jpg)

## 通过接口调用

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

//interfaceCall 通过接口调用
func interfaceCall() {
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

方法集规则

```go
//Methods Receivers		Values
//------------------------------
//  (t T)				T and *T
//  (t *T)				*T
//
//Values				Methods Receivers
//---------------------------------------
//  T					(t T)
//  *T					(t T) and (t *T)
```

## 通过类型变量调用

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

//typeVariableCall 通过类型变量进行值调用和表达式调用
func typeVariableCall() {
	var a Data = struct{}{}

	//表达式调用不会自动转换
	Data.value(a)
	//Data.point(a) //needs pointer receiver: (*Data).point
	(*Data).point(&a)
	(*Data).value(&a)

	//值调用会自动转换
	a.value()
	(&a).value() //自动转换成a.value()
	a.point()    //自动转换成(&a).point()
	(&a).point()
}
```

## 通过类型字面量调用

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

// literalCall 通过类型字面量显式地进行值调用和表达式调用
func typeLiteralCall() {
	//表达式调用
	Data.value(struct{}{})
	//Data.point(struct{}{}) //needs pointer receiver: (*Data).point
	//(*Data).point(&struct{}{}) //cannot use &struct {} literal as type *Data
	//(*Data).value(*struct{}{}) //cannot use &struct {} literal as type *Data

	//值调用
	(*Data)(&struct{}{}).point()
	(*Data)(&struct{}{}).value()
	(Data)(struct{}{}).value()
	//(Data)(struct{}{}).point() //cannot call pointer method on Data(struct {} literal)
}
```



代码文件：`gogo/summary/methodSet.go`