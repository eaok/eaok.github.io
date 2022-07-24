[toc]



# 互斥锁Mutex

适用于读写不确定，读写次数差不多，并且只有一个读或者写的场景。

基本用法：

```go
// 初始化Mutex对象
lk := sync.Mutex{}
// 加锁
lk.Lock()
	
// 处理业务逻辑
	
// 解锁
lk.Unlock()
```



例子：

```go
package main

import (
	"fmt"
	"sync"
)

var count int = 0

func main() {
	// 初始化锁
	lk := sync.Mutex{}

	done := make(chan bool)

	for i:=0; i < 100; i++ {
	    // 并发的累加count
		go func() {
			// 加锁
			lk.Lock()
			// 延迟解锁
			defer lk.Unlock()

			// 处理业务逻辑
			count++
			done <- true
		}()
	}

	for i:=0; i < 100; i++ {
		<-done
	}
	fmt.Println(count)
}
```





# 读写锁RWMutex

RWMutex是读写锁，适用于读多写少的场景，该锁可以被同时多个读取者持有或唯一个写入者持有。

基本用法：

```go
// 初始化RWMutex对象
lk := sync.RWMutex{}
// 加写锁
lk.Lock()
	
// 处理业务逻辑
	
// 解除写锁
lk.Unlock()

// 加读锁
lk.RLock()

// 处理业务逻辑

// 解除读锁
lk.RUnlock
```



读写锁的互斥关系如下：

| 协程 1 | 协程 2 | 阻塞状态 |
| :----- | :----- | :------- |
| 读锁   | 读锁   | 不阻塞   |
| 读锁   | 写锁   | 阻塞     |
| 写锁   | 写锁   | 阻塞     |



