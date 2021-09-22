# time包

## 一、time包中的方法

Time对象：

```go
//获取Time对象
func Date(year int, month Month, day, hour, min, sec, nsec int, loc *Location) Time
func Now() Time
func Parse(layout, value string) (Time, error)
func ParseInLocation(layout, value string, loc *Location) (Time, error)
func Unix(sec int64, nsec int64) Time

//一些方法
func (t Time) Unix() int64
func (t Time) UnixNano() int64
func (t Time) Clock() (hour, min, sec int)
func (t Time) Date() (year int, month Month, day int)

func (t Time) Add(d Duration) Time
func (t Time) AddDate(years int, months int, days int) Time
func (t Time) Sub(u Time) Duration
```

time包中的一些函数：

```go
func Sleep(d Duration)
```



时间模板的时间是固定的：

```go
"2006/01/02 15:04:05"
```

Location结构体：

```go
type Location struct {
	name string
	zone []zone
	tx   []zoneTrans
	cacheStart int64
	cacheEnd   int64
	cacheZone  *zone
}
```

Time结构体：

```go
type Time struct {
	wall uint64
	ext  int64
	loc *Location
}
```

## 二、代码示例

获取当前时间

```go
time.Now()
```

获取指定时间

```go
time.Date(2009, 8, 17, 22, 30, 22, 0, time.Local)
```

time->string转换

```go
now := time.Now()
res := now.Format("2006-01-02 15:04:05")
```

string->time转换

```go
now := "2018/12/28 11:54:54"
res,_ := time.Parse("2006/01/02 15:04:05", now) //模板格式要和now一样
```

获取时间戳

```go
time.Now().Unix()
time.Now().UnixNano()
```

时间戳->time

```go
now := time.Now().Unix()
time.Unix(now, 0)

// 时间差值由time.Duration 转为 time.Time，然后格式化输出
timeSub := time.Since(namesList[i].time)
value := time.Unix(int64(timeSub), 0)
fmt.Sprintf("%d:%d:%d\n", value.Hour(), value.Minute(), value.Second())
```

设置时区

```go
time.LoadLocation("Asia/Shanghai")
```

time->string根据时区转换

```go
now := "2018/12/28 11:54:54"
loc, _ := time.LoadLocation("Asia/Shanghai")
res,_ := time.ParseInLocation("2006/01/02 15:04:05",now,loc)
```

睡眠随机几秒

```go
rand.Seed(time.Now().UnixNano())
randNum := rand.Intn(10) + 1
time.Sleep(time.Duration(randNum) * time.Second)
```

时间间隔

```go
t1 := time.Now()
t2 := t1.Add(10 * time.Minute)
t3 := t1.AddDate(1, 0, 0)
t2.Sub(t1)
```



[golang包time用法详解](https://blog.csdn.net/wschq/article/details/80114036)