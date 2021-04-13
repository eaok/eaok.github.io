# bufio包



## 一、bufio包原理

io操作本身的效率并不低，低的是频繁访问本地磁盘的文件。bufio提供了缓冲区，读和写都先再缓冲区中，最后再读写文件，来减低访问本地磁盘的次数，从而提高效率。



bufio封装了io.Reader和io.Writer接口对象，并创建另一个也实现了该接口的对象，io.Reader和io.Writer接口实现了read()和write()方法，对于实现了这个接口的对象都可以使用这两个方法。

![](https://cdn.jsdelivr.net/gh/eaok/img/golang/goStandardLibrary/bufio_%E5%8E%9F%E7%90%86.png)

Reader对象

bufio.Reader是bufio中对io.Reader的封装：

```go
// Reader implements buffering for an io.Reader object.
type Reader struct {
	buf          []byte
	rd           io.Reader // reader provided by the client
	r, w         int       // buf read and write positions
	err          error
	lastByte     int // last byte read for UnreadByte; -1 means invalid
	lastRuneSize int // size of last rune read for UnreadRune; -1 means invalid
}
```

bufio.Read(p []byte)相当于读取大小len(p)的内容，思路如下：

2. 当缓冲区没有内容时且len(p)>len(buf)，即读取的内容比缓冲区大，直接读取文件即可；
3. 当缓冲区没有内容时且len(p)<len(buf)，即读取的内容比缓冲区小，缓冲区从文件读取内容再将p填满，此时缓冲区还有剩余内容；
4. 以后再次读取缓冲区还有内容时，将缓冲区内容填入p，重复这个步骤直到缓冲区为空；

源码：

```go
// Read reads data into p.
// It returns the number of bytes read into p.
// The bytes are taken from at most one Read on the underlying Reader,
// hence n may be less than len(p).
// To read exactly len(p) bytes, use io.ReadFull(b, p).
// At EOF, the count will be zero and err will be io.EOF.
func (b *Reader) Read(p []byte) (n int, err error) {
	n = len(p)
	if n == 0 {
		return 0, b.readErr()
	}
	if b.r == b.w {
		if b.err != nil {
			return 0, b.readErr()
		}
		if len(p) >= len(b.buf) {
			// Large read, empty buffer.
			// Read directly into p to avoid copy.
			n, b.err = b.rd.Read(p)
			if n < 0 {
				panic(errNegativeRead)
			}
			if n > 0 {
				b.lastByte = int(p[n-1])
				b.lastRuneSize = -1
			}
			return n, b.readErr()
		}
		// One read.
		// Do not use b.fill, which will loop.
		b.r = 0
		b.w = 0
		n, b.err = b.rd.Read(b.buf)
		if n < 0 {
			panic(errNegativeRead)
		}
		if n == 0 {
			return 0, b.readErr()
		}
		b.w += n
	}

	// copy as much as we can
	n = copy(p, b.buf[b.r:b.w])
	b.r += n
	b.lastByte = int(b.buf[b.r-1])
	b.lastRuneSize = -1
	return n, nil
}
```



Writer对象

bufio.Writer是bufio中对io.Writer的封装：

```go
// Writer implements buffering for an io.Writer object.
// If an error occurs writing to a Writer, no more data will be
// accepted and all subsequent writes, and Flush, will return the error.
// After all data has been written, the client should call the
// Flush method to guarantee all data has been forwarded to
// the underlying io.Writer.
type Writer struct {
	err error
	buf []byte
	n   int
	wr  io.Writer
}
```

bufio.Write(p []byte)的思路如下

2. 判断buf中可用容量是否可以放下p，如果能放下，直接把p拼接到buf后面，即把内容放到缓冲区；
3. 如果不能放下且此时缓冲区是空的，直接把p写入文件即可；
4. 如果不能放下且此时缓冲区有内容，则用p把缓冲区填满，把缓冲区所有内容写入文件，并清空缓冲区；
5. 判断p的剩余内容大小能否放到缓冲区，如果能放下则把内容放到缓冲区；
6. 如果p的剩余内容依旧大于缓冲区，则把p的剩余内容直接写入文件；

源码：

```go
// Write writes the contents of p into the buffer.
// It returns the number of bytes written.
// If nn < len(p), it also returns an error explaining
// why the write is short.
func (b *Writer) Write(p []byte) (nn int, err error) {
	for len(p) > b.Available() && b.err == nil {
		var n int
		if b.Buffered() == 0 {
			// Large write, empty buffer.
			// Write directly from p to avoid copy.
			n, b.err = b.wr.Write(p)
		} else {
			n = copy(b.buf[b.n:], p)
			b.n += n
			b.Flush()
		}
		nn += n
		p = p[n:]
	}
	if b.err != nil {
		return nn, b.err
	}
	n := copy(b.buf[b.n:], p)
	b.n += n
	nn += n
	return nn, nil
}
```

## 二、bufio包

Reader对象

```go
func NewReader(rd io.Reader) *Reader

func (b *Reader) Read(p []byte) (n int, err error)
func (b *Reader) ReadBytes(delim byte) ([]byte, error)
func (b *Reader) ReadRune() (r rune, size int, err error)
func (b *Reader) ReadString(delim byte) (string, error)
```

Writer对象

```go
func NewWriter(w io.Writer) *Writer

func (b *Writer) Write(p []byte) (nn int, err error)
func (b *Writer) WriteByte(c byte) error
func (b *Writer) WriteRune(r rune) (size int, err error)
func (b *Writer) WriteString(s string) (int, error)
func (b *Writer) Flush() error
```



## 三、实列代码

Read

```go
fileName := `C:\Users\Administrator\go\src\package\a.txt`
file, err := os.Open(fileName)
if err != nil {
    fmt.Println(err)
}
defer file.Close()

//创建Reader对象
b1 := bufio.NewReader(file)

//Read()
p := make([]byte, 1024)
n1, err := b1.Read(p)
fmt.Println(n1)
fmt.Println(string(p[:n1]))

//ReadString()
s1, err := b1.ReadString('\n')
fmt.Println(s1)
fmt.Println(err)

//ReadBytes()
data, err := b1.ReadBytes('\n')
fmt.Println(string(data))
fmt.Println(err)
```

Write

```go
fileName := `C:\Users\Administrator\go\src\package\bufio.txt`
file, err := os.OpenFile(fileName, os.O_CREATE|os.O_WRONLY, os.ModePerm)
if err != nil {
    fmt.Println(err)
    return
}
defer file.Close()

w1 := bufio.NewWriter(file)
for i := 0; i < 1000; i++ {
    w1.WriteString(fmt.Sprintf("%d:hello\n", i))
}
w1.Flush()
```



