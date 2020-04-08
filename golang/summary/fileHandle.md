[toc]

# 一、相关结构体和接口

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

# 二、文件相关处理

## 2.1 文件目录基本操作

### 获取文件信息

```go
fileInfo, err := os.Stat("C:\\Users\\Administrator\\go\\src\\package\\a.txt")
if err != nil {
    log.Fatal("err:", err)
}
fmt.Println(fileInfo.Name(), fileInfo.Size(), fileInfo.IsDir())
```

### 创建目录

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

### 创建文件

```go
file1, err := os.Create("C:\\Users\\Administrator\\go\\src\\package\\b.txt")
if err != nil {
    log.Fatal(err)
}
```

### 打开并关闭文件

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

### 删除文件或文件夹

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

## 2.2 读取文件

### 1.按字节读取

该文件必须适合内存，也需要知道文件的大小，以便实例化一个足够大的缓冲区来保存它。

```go
file, err := os.Open("filetoread.txt")
if err != nil {
  fmt.Println(err)
  return
}
defer file.Close()

fileinfo, err := file.Stat()
if err != nil {
  fmt.Println(err)
  return
}

filesize := fileinfo.Size()
buffer := make([]byte, filesize)

bytesread, err := file.Read(buffer)
if err != nil {
  fmt.Println(err)
  return
}

fmt.Println("bytes read: ", bytesread)
fmt.Println("bytestream to string: ", string(buffer))
```

### 以块的形式读取文件

```go
const BufferSize = 100
file, err := os.Open("filetoread.txt")
if err != nil {
  fmt.Println(err)
  return
}
defer file.Close()

buffer := make([]byte, BufferSize)

for {
  bytesread, err := file.Read(buffer)

  if err != nil {
    if err != io.EOF {
      fmt.Println(err)
    }

    break
  }

  fmt.Println("bytes read: ", bytesread)
  fmt.Println("bytestream to string: ", string(buffer[:bytesread]))
}
```

### 3.同时读取多个文件块

```go
const BufferSize = 100
file, err := os.Open("filetoread.txt")
if err != nil {
  fmt.Println(err)
  return
}
defer file.Close()

fileinfo, err := file.Stat()
if err != nil {
  fmt.Println(err)
  return
}

filesize := int(fileinfo.Size())
// Number of go routines we need to spawn.
concurrency := filesize / BufferSize

// check for any left over bytes. Add one more go routine if required. //如果没除尽，就要加1
if remainder := filesize % BufferSize; remainder != 0 {
  concurrency++
}

var wg sync.WaitGroup
wg.Add(concurrency)

for i := 0; i < concurrency; i++ {
  go func(chunksizes []chunk, i int) {
    defer wg.Done()

    chunk := chunksizes[i]
    buffer := make([]byte, chunk.bufsize)
    bytesread, err := file.ReadAt(buffer, chunk.offset)

    if err != nil && err != io.EOF {
      fmt.Println(err)
      return
    }

    fmt.Println("bytes read, string(bytestream): ", bytesread)
    fmt.Println("bytestream to string: ", string(buffer[:bytesread]))
  }(chunksizes, i)
}

wg.Wait()
```

### 4.使用bufio.Scanner

```go
file, err := os.Open("filetoread.txt")
if err != nil {
  fmt.Println(err)
  return
}
defer file.Close()

scanner := bufio.NewScanner(file)
scanner.Split(bufio.ScanLines)

// This is our buffer now
var lines []string

for scanner.Scan() {
  lines = append(lines, scanner.Text())
}

fmt.Println("read lines:")
for _, line := range lines {
  fmt.Println(line)
}
```

### 5.使用ioutil中的ReadFile

```go
bytes, err := ioutil.ReadFile("_config.yml")
if err != nil {
  log.Fatal(err)
}

fmt.Println("Bytes read: ", len(bytes))
fmt.Println("String read: ", string(bytes))
```



### 6.读取文件中指定位置字符

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



## 2.3 文件复制

### 使用io包的Read和Write

```go
func copyFile1(srcFile, desFile string) (int, error) {
	file1, err := os.Open(srcFile)
	if err != nil {
		return 0, err
	}
	file2, err := os.OpenFile(desFile, os.O_WRONLY|os.O_CREATE, os.ModePerm)
	if err != nil {
		return 0, err
	}
	defer file1.Close()
	defer file2.Close()

	bs := make([]byte, 1024)
	n := -1
	total := 0
	for {
		n, err = file1.Read(bs)
		if err == io.EOF || n == 0 {
			fmt.Println("copy succes")
			break
		} else if err != nil {
			fmt.Println("copy error")
			return total, err
		}
		total += n
		file2.Write(bs[:n])
	}

	return total, nil
}
```

### 使用io包中的Copy方法

```go
func copyFile2(srcFile, desFile string) (int64, error) {
	file1, err := os.Open(srcFile)
	if err != nil {
		return 0, err
	}
	file2, err := os.OpenFile(desFile, os.O_CREATE|os.O_WRONLY, os.ModePerm)
	if err != nil {
		return 0, err
	}
	defer file1.Close()
	defer file2.Close()

	return io.Copy(file2, file1)
}
```

### 使用ioutil包的ReadFile和WriteFile

由于使用一次性读取写入，不适用大文件，容易内存溢出。

```go
func copyFile3(srcFile, desFile string) (int, error) {
	bs, err := ioutil.ReadFile(srcFile)
	if err != err {
		return 0, err
	}
	err = ioutil.WriteFile(desFile, bs, os.ModePerm)
	if err != nil {
		return 0, err
	}

	return len(bs), nil
}
```

# 三、断点续传

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



# 四、json文件处理

# 五、xlsx表格处理