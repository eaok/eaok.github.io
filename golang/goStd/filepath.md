# filepath包

导入包

```go
import "path/filepath"
```

## 一、filepath包常用的函数

```go
func Abs(path string) (string, error)
func IsAbs(path string) bool
func Join(elem ...string) string
```



## 二、代码示例

```go
fileName1 := "C:\\Users\\Administrator\\go\\src\\package\\a.txt"
fileName2 := "b.txt"
fmt.Println(filepath.IsAbs(fileName1)) //true
fmt.Println(filepath.IsAbs(fileName2)) //false
fmt.Println(filepath.Abs(fileName2)) //获取绝对路径
fmt.Println("获取父目录", filepath.Join(fileName1, ".."))
```

