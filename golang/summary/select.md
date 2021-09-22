[toc]

# 一、select基本用法

多个chan有数据时，会随机选择执行，都没数据时才会执行default

```go
	select {
	case <-ch:
		fmt.Println("random 01")
	case <-ch:
		fmt.Println("random 02")
	default:
		fmt.Println("exit")
	}
```



# 二、Timeout 超时机制

```go
	timeout := make(chan bool, 1)
	go func() {
		time.Sleep(2 * time.Second)
		timeout <- true
	}()
	ch := make(chan int)

	//1.通过timeout通道来控制超时
	select {
	case <-ch:
	case <-timeout:
		fmt.Println("timeout 01")
	}

	//2.通过time.After来控制超时
	select {
	case <-ch:
	case <-time.After(time.Second * 1):
		fmt.Println("timeout 02")
	}
```



# 三、检查 channel 是否已满

```go
	ch := make(chan int, 2)
	ch <- 1
	ch <- 2
	select {
	case ch <- 2:
		fmt.Println("channel value is", <-ch)
		fmt.Println("channel value is", <-ch)
	default:
		fmt.Println("channel blocking")
	}
```



# 四、select for loop 用法

如果你有多个 channel 需要读取，而读取是不间断的，就必须使用 for + select 机制来实现

```go
	go func(wg *sync.WaitGroup) {
		for i := 1; i <= 9; i++ {
			ch <- i
		}
		time.Sleep(2 * time.Second)
		out <- "stop"
		wg.Done()
	}(&wg)

	go func(wg *sync.WaitGroup) {
	LOOP:
		for {
			select {
			case m := <-ch:
				println(m)
			case <-out:
				break LOOP
			default:
			}
		}
		wg.Done()
	}(&wg)
```



# 五、总结

select 只能接收 channel，否则会出错



代码文件：`gogo/summary/selectSum.go`