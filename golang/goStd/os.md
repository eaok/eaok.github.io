# os包

os 包提供了不依赖平台的操作系统函数接口。

## 一、os包常用的系统函数

常用系统函数

```go

func Hostname() (name string, err error) 	// Hostname返回内核提供的主机名
func Environ() []string 	// Environ返回表示环境变量的格式为”key=value”的字符串的切片拷贝
func Getenv(key string) string 	// Getenv检索并返回名为key的环境变量的值
func Getpid() int 	// Getpid返回调用者所在进程的进程ID

func Exit(code int) 
func Stat(name string) (fi FileInfo, err error) 	// 获取文件信息
func Getwd() (dir string, err error) 	// Getwd返回一个对应当前工作目录的根路径

func Mkdir(name string, perm FileMode) error
func MkdirAll(path string, perm FileMode) error
func Remove(name string) error	// 删除name指定的文件或目录
func TempDir() string	// 返回一个用于保管临时文件的默认目录
```



File 结构体相关的函数方法

```go
func Create(name string) (file *File, err error) //采用模式0666
func Open(name string) (file *File, err error) 
func OpenFile(name string, flag int, perm FileMode) (*File, error)	//指定模式打开一个文件

func (f *File) Stat() (fi FileInfo, err error) 
func (f *File) Readdir(n int) (fi []FileInfo, err error)
func (f *File) Read(b []byte) (n int, err error) 
func (f *File) WriteString(s string) (ret int, err error)
func (f *File) Seek(offset int64, whence int) (ret int64, err error)
func (f *File) Sync() (err error) // Sync递交文件的当前内容进行稳定的存储。
func (f *File) Close() error
```

File结构体

```go
// File represents an open file descriptor.
type File struct {
	*file // os specific
}

// file is the real representation of *File.
// The extra level of indirection ensures that no clients of os
// can overwrite this data, which could cause the finalizer
// to close the wrong file descriptor.
type file struct {
	fd      int
	name    string
	dirinfo *dirInfo // nil unless directory being read
}
```

FileInfo接口

```go
// A FileInfo describes a file and is returned by Stat and Lstat.
type FileInfo interface {
	Name() string       // base name of the file
	Size() int64        // length in bytes for regular files; system-dependent for others
	Mode() FileMode     // file mode bits
	ModTime() time.Time // modification time
	IsDir() bool        // abbreviation for Mode().IsDir()
	Sys() interface{}   // underlying data source (can return nil)
}
```

## 二、代码示例

获取文件信息

```go
fileInfo, err := os.Stat("C:\\Users\\Administrator\\go\\src\\package\\a.txt")
if err != nil {
    log.Fatal("err:", err)
}
fmt.Println(fileInfo.Name(), fileInfo.Size(), fileInfo.IsDir())
```

创建目录

```go
err = os.Mkdir("C:\\Users\\Administrator\\go\\src\\package\\c", os.ModePerm)
if err != nil {
    log.Fatal(err)
}

err = os.MkdirAll("C:\\Users\\Administrator\\go\\src\\package\\d/a/b/c", os.ModePerm)
if err != nil {
    log.Fatal(err)
}
```

创建文件

```go
file1, err := os.Create("C:\\Users\\Administrator\\go\\src\\package\\b.txt")
if err != nil {
    log.Fatal(err)
}
```

打开并关闭文件

```go
file1, err := os.Open(fileName1) //只读
if err != nil {
    log.Fatal(err)
}
defer file1.Close()
fmt.Println("file1", file1)

file2, _ := os.OpenFile(fileName1, os.O_RDONLY|os.O_WRONLY, os.ModePerm)
if err != nil {
    log.Fatal(err)
}
defer file2.Close()
fmt.Println("file2", file2)
```

删除文件或文件夹

```go
err = os.Remove("C:\\Users\\Administrator\\go\\src\\package\\b.txt")
if err != nil {
    log.Fatal(err)
}
err = os.Remove("C:\\Users\\Administrator\\go\\src\\package\\c")
if err != nil {
    log.Fatal(err)
}
err = os.RemoveAll("C:\\Users\\Administrator\\go\\src\\package\\d")
if err != nil {
    log.Fatal(err)
}
```

读取文件中指定位置字符

```go
fileName := "C:\\Users\\Administrator\\go\\src\\package\\a.txt"
file, err := os.OpenFile(fileName, os.O_RDWR, os.ModePerm)
if err != nil {
    log.Fatal(err)
}
defer file.Close()

bs := []byte{0}
file.Seek(4, io.SeekStart)
file.Read(bs)
fmt.Println(string(bs))
```

## 三、断点续传

```go
func loadFile(srcFile, desFile string) {
	fmt.Println(desFile)
	tempFile := desFile + "temp.txt"

	file1, _ := os.Open(srcFile)
	file2, _ := os.OpenFile(desFile, os.O_CREATE|os.O_WRONLY, os.ModePerm)
	file3, _ := os.OpenFile(tempFile, os.O_CREATE|os.O_RDWR, os.ModePerm)
	defer file1.Close()
	defer file2.Close()

	//先读临时文件中的数据在seek
	file3.Seek(0, io.SeekStart)
	bs := make([]byte, 100)
	n1, _ := file3.Read(bs)
	countStr := string(bs[:n1])
	count, err := strconv.ParseInt(countStr, 10, 64)
	fmt.Println(count)

	//设置偏移量
	file1.Seek(count, io.SeekStart)
	file2.Seek(count, io.SeekStart)
	data := make([]byte, 1024)
	n2, n3 := -1, -1
	total := int(count)

	//复制文件
	for {
		n2, err = file1.Read(data)
		if err == io.EOF || n2 == 0 {
			fmt.Println("copy succes", total)
			file3.Close()
			os.Remove(tempFile)
			break
		}
		n3, err = file2.Write(data[:n2])
		total += n3

		file3.Seek(0, io.SeekStart)
		file3.WriteString(strconv.Itoa(total))
		fmt.Println("total:", total)

		//假装断开
		//if total > 8000 {
		//	panic("panic")
		//}
	}
}

func main() {
	srcFile := "C:\\Users\\Administrator\\go\\src\\package\\a.jpg"
	desFile := "load" + srcFile[strings.LastIndex(srcFile, "\\") + 1:]
	loadFile(srcFile, desFile)
}
```

