

[toc]



# 内存对齐

## 内存对齐原因

1. 提高代码平台兼容性

   不是所有的硬件平台都能访问任意地址上的任意数据的；某些硬件平台只能在某些地址处取某些特定类型的数据，否则抛出硬件异常。

2. 优化数据对内存的使用

   数据结构应该尽可能地在自然边界上对齐。原因在于，为了访问未对齐的内存，处理器需要作**两次内存访问**；而对齐的内存访问仅需要**一次访问**。

   



## 内存对齐的相关概念

| 概念说明            |                                        |
| ------------------- | -------------------------------------- |
| 位 bit              | 计算机内部数据存储的最小单位           |
| 字节 byte           | 计算机处理的基本单位                   |
| 机器字 machine word | 计算机用来一次性处理事务的一个固定长度 |



## 结构对齐

数据结构对齐的相关工具

```bash
#layout
go get github.com/ajstarks/svgo/structlayout-svg
go get -u honnef.co/go/tools
go install honnef.co/go/tools/cmd/structlayout
go install honnef.co/go/tools/cmd/structlayout-pretty

#optimize
go install honnef.co/go/tools/cmd/structlayout-optimize
```



根据结构体生成svg图

```go
//structlayout -json . Ag|structlayout-svg -t "align-guarantee" > ag.svg
type Ag struct {
	arr [2]int8  // 2
	bl  bool     // 1 padding 5
	sl  []int16  // 24
	ptr *int64   // 8
	st  struct { // 16
		str string
	}
	m map[string]int16
	i interface{}
}
```



go底层相关数据结构

```go
// reflect/value.go
// stringHeader is a safe version of StringHeader used within this package.
type stringHeader struct {
	Data unsafe.Pointer
	Len  int
}

// SliceHeader is the runtime representation of a slice.
type SliceHeader struct {
	Data uintptr
	Len  int
	Cap  int
}

// runtime/map.go
// A header for a Go map.
type hmap struct {
	count     int
	flags     uint8
	B         uint8
	noverflow uint16
	hash0     uint32
	buckets    unsafe.Pointer
	oldbuckets unsafe.Pointer 
	nevacuate  uintptr
	extra *mapextra
}

// runtime/runtime2.go
type iface struct {
	tab  *itab
	data unsafe.Pointer
}

type eface struct {
	_type *_type
	data  unsafe.Pointer
}
```



零大小字段对齐

零大小字段（zero sized field）是指struct{}，如果有指针指向这个`final zero field`, 返回的地址将在结构体之外（即指向了别的内存），如果此指针一直存活不释放对应的内存，就会有内存泄露的问题（该内存不因结构体释放而释放）所以，Go就对这种`final zero field`也做了填充，使对齐。

```go
// zeroSizeField
func zeroSizeField() {
	type T1 struct {
		a struct{}
		x int64
	}

	type T2 struct {
		x int64
		a struct{}
	}
	a1 := T1{}
	a2 := T2{}
	fmt.Printf("zero size struct{} in field:\n"+
		"T1 (not as final field) size: %d\n"+
		"T2 (as final field) size: %d\n",
		unsafe.Sizeof(a1), // 8
		unsafe.Sizeof(a2)) // 64位：16；32位：12
}
```







内存对齐检测

```bash
golangci-lint.exe run --disable-all --enable maligned .\structs.go
```



## 地址对齐

计算机结构可能会要求内存地址进行对齐;也就是说，一个变量的 地址是一个因子的倍数，也就是该变量的类型是对齐值。




总结

● 内存对齐是为了cpu更 高效访问内存中数据
● 结构体对齐依赖类型的 大小保 证和 对齐 保 证
● 地址对齐保证是：如果类型 t 的对齐保证是 n，那么类型 t 的每个值的 地址在运行时必须是 n 的倍数。
● struct内字段如果 填充过多，可以尝试 重排，使字段排列更紧密，减少内存浪费
● 零大小字段要避免作为struct最后一个字段，会有内存浪 费
● 32位系统上对64位字的原子访问要保证其是8bytes对齐的；当然如果不必要的话，还是用加锁（mutex）的方式更清晰简单





参考

* http://blog.newbmiao.com/2020/02/10/dig101-golang-struct-memory-align.html

* https://github.com/NewbMiao/Dig101-Go/blob/master/struct_align_demo.go