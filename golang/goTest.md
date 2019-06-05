# go test

### 0x00 传统测试
```golang
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
```golang
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
```golang
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
```golang
func ExampleFibonacciIterative() {
	fmt.Println(fibonacciIterative(4))
	// Output:
	// 3
}

```

### 0x03 TestMain
```golang
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
```golang
func BenchmarkFibonacciIterative(b *testing.B) {
	for n := 0; n < b.N; n++ {
		fibonacciIterative(10)
	}
}
```
测试更多情况
```golang

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

### 0x05 第三方测试库
- [goconvey](https://github.com/smartystreets/goconvey)

```golang
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

```golang
import (
	"testing"

	"github.com/bmizerany/assert"
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
