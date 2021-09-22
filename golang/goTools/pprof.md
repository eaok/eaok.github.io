### 1 在程序中引用pprof

```go
package main

import (
        _ "net/http/pprof"
        "net/http"

)

func main() {

        go func() {
                log.Println(http.ListenAndServe(":8080", nil))
        }()

        select{}
}
```

运行后可以访问 `http://dev.com:8080/debug/pprof/`





### 2 可视化

sudo aptget install graphviz



1、查看运行时cpu 的情况

```shell
go tool pprof http://127.0.0.1:8899/debug/pprof/profile
```

会进入30 秒的数据收集时间结束后再程序中输入`web`命令会自动使用打开浏览器查看生成好的报告



查看运行时堆内存分配的的情况

```shell
go tool pprof http://127.0.0.1:8899/debug/pprof/heap
```

输入`web`也一样会打开浏览器查看报告