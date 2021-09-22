



**golangci-lint**是一个Go静态代码检查工具
网站地址：https://github.com/golangci/golangci-lint



运行

```go
golangci-lint run
golangci-lint run dir1 dir2/... dir3/file1.go
```



Pass `-E/--enable` to enable linter and `-D/--disable` to disable:

```bash
golangci-lint run --disable-all -E errcheck
golangci-lint run --disable-all -E maligned		#只检查结构体对齐
```