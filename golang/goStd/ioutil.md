# ioutil包

导入包时使用如下方法：

```go
import "io/ioutil"
```

## 一、ioutil包的方法

里面的方法：

```go
//ReadAll读取io.Reader中的的内容
func ReadAll(r io.Reader) ([]byte, error)

//ReadFile读取文件中的所有数据，里面调用的是
//os.Open(filename)
//ioutil.readAll(r io.Reader, capacity int64)
func ReadFile(filename string) ([]byte, error)

//readDir 列出文件夹和文件名，返回一个os.FileInfo切片
func ReadDir(dirname string) ([]os.FileInfo, error)
func WriteFile(filename string, data []byte, perm os.FileMode) error

func TempDir(dir, prefix string) (name string, err error)
func TempFile(dir, pattern string) (f *os.File, err error)
```

FileInof结构体如下：

```go
type FileInfo interface {
    Name() string       // base name of the file
    Size() int64        // length in bytes for regular files;
    Mode() FileMode     // file mode bits
    ModTime() time.Time // modification time
    IsDir() bool        // abbreviation for Mode().IsDir()
    Sys() interface{}   // underlying data source (can return nil)
}
```



## 二、示例代码

```go
//ReadFile() 读取文件中的所有数据
fileName := `C:\Users\Administrator\go\src\package\a.txt`
data, err := ioutil.ReadFile(fileName)
fmt.Println(string(data))
fmt.Println(err)

//WriteFile() 写出数据
fileName1 := `C:\Users\Administrator\go\src\package\aa.txt`
s1 := "床前明月光，凝是地上霜。"
err = ioutil.WriteFile(fileName1, []byte(s1), os.ModePerm)
fmt.Println(err)

//ReadAll() 从io.Reader读取数据
s2 := "君子坦荡荡，小人长戚戚。"
r1 := strings.NewReader(s2)
data, err = ioutil.ReadAll(r1)
fmt.Println(string(data))
fmt.Println(err)

//ReadDir() 返回目录文件
dirName := `C:\Users\Administrator\go\src\package`
fileInfos, err := ioutil.ReadDir(dirName)
if err != nil {
    log.Fatal(err)
    return
}
for _, value := range fileInfos {
    fmt.Println(value.Name(), value.IsDir())
}

//TempDir() 生成临时文件夹
dir, err := ioutil.TempDir(`C:\Users\Administrator\go\src\package`, "TestTemp")
if err != nil {
    log.Fatal(err)
    return
}
defer os.Remove(dir)
fmt.Println(dir)

//TempFile() 生成临时文件
file, err := ioutil.TempFile(dir, "Test")
if err != nil {
    log.Fatal(err)
    return
}
defer os.Remove(file.Name())
defer file.Close()

if _, err := file.Write([]byte("菜粉别来跳脚昂")); err != nil {
    log.Fatal(err)
}
fmt.Println(file.Name())
```

