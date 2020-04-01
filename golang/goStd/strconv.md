# strconv包

## 一、strconv包中的函数

```go
// 将布尔值转换为字符串 true 或 false
func FormatBool(b bool) string

// 将字符串转换为布尔值
// 它接受真值：1, t, T, TRUE, true, True
// 它接受假值：0, f, F, FALSE, false, False
// 其它任何值都返回一个错误。
func ParseBool(str string) (bool, error)

// 将整数转换为字符串形式。base 表示转换进制，取值在 2 到 36 之间。
func FormatInt(i int64, base int) string

// 将字符串解析为整数，ParseInt 支持正负号，ParseUint 不支持正负号。
// base 表示进位制（2 到 36），如果 base 为 0，则根据字符串前缀判断，
// 前缀 0x 表示 16 进制，前缀 0 表示 8 进制，否则是 10 进制。
// bitSize 表示结果的位宽（包括符号位），0 表示最大位宽。
func ParseInt(s string, base int, bitSize int) (i int64, err error)
func ParseUint(s string, base int, bitSize int) (uint64, error)

// 将整数转换为十进制字符串形式（即：FormatInt(i, 10) 的简写）
func Itoa(i int) string

// 将字符串转换为十进制整数，即：ParseInt(s, 10, 0) 的简写）
func Atoi(s string) (int, error)
```

## 二、代码示例

```go
i, err := strconv.Atoi("-42")
s := strconv.Itoa(-42)

b, err := strconv.ParseBool("true")
f, err := strconv.ParseFloat("3.1415", 64)
i, err := strconv.ParseInt("-42", 10, 64)
u, err := strconv.ParseUint("42", 10, 64)

s := strconv.FormatBool(true)
s := strconv.FormatFloat(3.1415, 'E', -1, 64)
s := strconv.FormatInt(-42, 16)
s := strconv.FormatUint(42, 16)

slice := make([]byte,0,1024)
slice = strconv.AppendBool(slice, true)
slice = strconv.AppendInt(slice, 1234,10)    //以10进制方式追加
slice = strconv.AppendQuote(slice, "abcd")

q := strconv.Quote("Hello, 世界")
q := strconv.QuoteToASCII("Hello, 世界")
```



