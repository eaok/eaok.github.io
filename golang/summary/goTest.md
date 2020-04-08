# go test

### 0x00 传统测试
```go
func TestFib(t *testing.T) {
	var (
		in       = 7
		expected = 13
	)
	actual := Fib(in)
	if actual != expected {
		t.Errorf("Fib(%d) = %d; expected %d", in, actual, expected)
	}
}
```

### 0x01 表格驱动测试
```go
func TestFib(t *testing.T) {
	var fibTests = []struct {
		in       int // input
		expected int // expected result
	}{
		{1, 1},
		{2, 1},
		{3, 2},
	}

	for _, tt := range fibTests {
		actual := Fib(tt.in)
		if actual != tt.expected {
			t.Errorf("Fib(%d) = %d; expected %d", tt.in, actual, tt.expected)
		}
	}
}
```

用插件gotests生成的表格驱动测试
```go
func Test_fibonacciIterative(t *testing.T) {
	type args struct {
		n int
	}
	tests := []struct {
		name string
		args args
		want int
	}{
		// TODO: Add test cases.
		{
			name: "test1",
			args: args{3},
			want: 2,
		},
		{
			name: "test2",
			args: args{4},
			want: 3,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := fibonacciIterative(tt.args.n); got != tt.want {
				t.Errorf("fibonacciIterative() = %v, want %v", got, tt.want)
			}
		})
	}
}
```

### 0x02 样本测试
```go
func ExampleFibonacciIterative() {
	fmt.Println(fibonacciIterative(4))
	// Output:
	// 3
}

```

### 0x03 TestMain
```go
func TestMain(m *testing.M) {
	setUp()
	exitCode := m.Run()
	tearDown()

	os.Exit(exitCode)
}

func setUp() {
	fmt.Println("setUp")
}

func tearDown() {
	fmt.Println("tearDown")
}
```

### 0x04 基准测试
```go
func BenchmarkFibonacciIterative(b *testing.B) {
	for n := 0; n < b.N; n++ {
		fibonacciIterative(10)
	}
}
```
测试更多情况
```go

func BenchmarkFibonacciIterative5(b *testing.B) {
	benchmarkFibonacciIterative(5, b)
}
func BenchmarkFibonacciIterative10(b *testing.B) {
	benchmarkFibonacciIterative(10, b)
}

func benchmarkFibonacciIterative(i int, b *testing.B) {
	for n := 0; n < b.N; n++ {
		fibonacciIterative(i)
	}
}
```



#### 性能测试的结果分析工具 benchstat

benchstat 用于对性能测试的结果进行统计分析，对测量结果进行假设检验，从而消除结果的观测误差；

```bash
go get golang.org/x/perf/cmd/benchstat

go test -run=none -bench=Benchmarkxxx -count=10 | tee old.txt
git stash pop
go test -run=none -bench=Benchmarkxxx -count=10 | tee new.txt
benchstat old.txt new.txt
```



生成编译过程的网页

```bash
GOSSAFUNC=函数名 go build .
```



#### 降低系统噪音工具 perflock

perflock的作用是限制cpu的频率，从而一定程度上消除系统对性能测试的影响，仅支持linux；

```bash
go get github.com/aclements/perflock/cmd/perflock
sudo install $GOPATH/bin/perflock /usr/bin/perflock
sudo -b perflock -daemon

perflock -governor 70% go test -test=none -bench=.
```



#### 严肃的性能测试一般流程

1. 限制系统资源，降低测试噪声
   * 限制cpu时钟频率 perflock
   * 限制runtime消耗的内存上限 runtime.SetMaxhelp
   * 关闭无关程序和进程

2. 确定测试代码的正确性
   * 考虑Goroutine的终止性，当某些并发在基准测试之后，那么结果就不准
   * 考虑编译器进行了过度优化，或者基准测试代码本身编写错误导致结果不准

3. 实施性能基准测试
   * 使用benchstat对前后的性能测试进行假设检验
   * 验证结果的有效性，比如确认结果的波动，比较随时间推移造成的性能回归等等



### 0x05 第三方测试库

- [goconvey](https://github.com/smartystreets/goconvey)

```go
import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
)

func TestAdd_Two(t *testing.T) {
	Convey("test add", t, func() {
		Convey("0 + 0", func() {
			So(Add(0, 0), ShouldEqual, 0)
		})
		Convey("-1 + 0", func() {
			So(Add(-1, 0), ShouldEqual, -1)
		})
	})
}
```

- [assert](https://github.com/bmizerany/assert)

```go
import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestFibonacciIterative(t *testing.T) {
	var (
		in       = 6
		expected = 13
	)
	actual := fibonacciIterative(in)
	assert.Equal(t, actual, expected)
}
```



代码文件：`gogo/demo/test_demo`