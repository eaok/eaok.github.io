# strings包

## 一、strings包中的方法

```go
//查找
func HasPrefix(s, prefix string) bool	// 前缀判断
func HasSuffix(s, suffix string) bool	// 后缀判断
func Contains(s, substr string) bool	// 包含判断
func Index(s, substr string) int		// 返回子串第一次出现的位置
func LastIndex(s, substr string) int	// 返回字串最后依次出现的位置
func Count(s, substr string) int		// 统计字符串s中出现substr的次数

// 替换
func Replace(s, old, new string, n int) string

// 裁剪字符串
func Trim(s string, cutset string) string
func TrimLeft(s string, cutset string) string
func TrimRight(s string, cutset string) string
func TrimSpace(s string) string

// 字符串分割与拼接
func Fields(s string) []string			// 按照一个或多个连续的空格将字符串s进行分割
func Split(s, sep string) []string		// 按照指定字符串将目标字符串进行分割
func Join(a []string, sep string) string	// 使用sep拼接slice

// 将字符串s重复count次之后返回
func Repeat(s string, count int) string

// 大小写转换
func ToLower(s string) string
func ToLowerSpecial(c unicode.SpecialCase, s string) string
func ToUpper(s string) string
func ToUpperSpecial(c unicode.SpecialCase, s string) string
```

## 二、代码示例

```go
strings.HasPrefix("test.com", "te")		//true
strings.HasSuffix("test.com", "com")	//true
strings.Contains("test.com", ".c")		//true

strings.Index("test.com", ".c")			//4
strings.LastIndex("test.com", "t")		//3


s := "test.com.es"
res := strings.Replace(s, "es","oo",-1)	//toot.com.oo

s := "test.com.es"
res := strings.Count(s, "c")		//1

s := "Test.Com.Es"
res := strings.ToLower(s)			//test.com.es

s := "Test.Com.Es"
res := strings.ToUpper(s)			//TEST.COM.ES

s := "  Test.Com.Es \n"
res := strings.TrimSpace(s)			//Test.Com.Es

s := "A.Test.Com.Es.A"
res := strings.Trim(s,"A")			//.Test.Com.Es.

s := "A.Test.Com.Es.A"
res := strings.Split(s,".")			//[A Test Com Es A]

s := []string{"hello","world"}
res := strings.Join(s,",")			//hello,world
```



