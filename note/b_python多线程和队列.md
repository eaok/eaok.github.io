---
title: python多线程和队列
date: 2016-12-15 09:26:50
tags: [thread]
categories: [python, syntax]

---

## 多线程
python中由于GIL的机制致使多线程不能利用机器多核的特性，但是多线程对于我们理解并发模型以及底层操作非常有用，线程的有两种使用方法，一种是在函数使用，一种是放在类中使用。

### 在函数中使用多线程
<!-- more -->
语法如下:
```
thread.start_new_thread(function, args[, kwargs])
function    #线程函数。
args        #传递给线程函数的参数,必须是个tuple类型。
kwargs      #可选参数。
```
例子:
```
import threading
def run(num):
    print('hi , i am a thread.', num)
def main():
    threads = []
    for i in range(4):
        t = threading.Thread(target=run, args=(i,))
        threads.append(t)
        t.start()
    for t in threads:
        t.join()
if __name__ == '__main__':
    print('thread start -->')
    main()
    print('thread go here -->')
======================================
thread start -->
hi , i am a thread. 0
hi , i am a thread. 1
hi , i am a thread. 2
hi , i am a thread. 3
thread go here -->
```

### 在类中多使用线程
```python
class threading.Thread(group=None, target=None, name=None, args=(), kwargs={}, *, daemon=None):
	start()				#启动线程
	run()				#需要重写，编写代码实现所需要的功能
	join(timeout=None)		#等待另一线程结束后再运行
	name
	getName()			#获得线程对象名称
	setName()			#设置线程对象名称
	ident
	is_alive()			#检查线程是否在运行中
	daemon
	isDaemon()			#判断线程是否随主线程一起结束
	setDaemon()			#设置子线程是否随主线程一起结束，必须在start() 之前调用
```
例子:
```
#!/usr/bin/env python3
#-*- coding:utf-8 -*-
'a function thread example'
__author__ = 'kcoewoys'

import threading

def run(num):
    print('hi , i am a thread.', num)
def main():
    threads = []
    for i in range(4):
        t = threading.Thread(target=run, args=(i,))
        threads.append(t)
        t.start()
    for t in threads:
        t.join()

if __name__ == '__main__':
    print('thread start -->')
    main()
    print('thread go here -->')
======================================
thread start -->
hi , i am a thread. 0
hi , i am a thread. 1
hi , i am a thread. 2
hi , i am a thread. 3
thread go here -->
```

### 锁和重入锁
```
class threading.Lock():
	acquire(blocking=True, timeout=-1)
	release()
class threading.RLock():
	acquire(blocking=True, timeout=-1)
	release()
```
可重入锁的例子:
```
import time
import threading

mutex = threading.RLock()
class MyThread(threading.Thread):
    def run(self):
        if mutex.acquire(1):
            print('threading get mutex:',self.name)
            time.sleep(1)
            mutex.acquire()
            mutex.release()
            mutex.release()
def main():
    print('start main threading:')
    threads = [MyThread() for i in range(9)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    print('end main threading.')

if __name__ == '__main__':
    main()
=================================
start main threading:
threading get mutex: Thread-1
threading get mutex: Thread-2
threading get mutex: Thread-3
threading get mutex: Thread-4
end main threading.
```
如果两个线程分别占有一部分资源并且同时等待对方的资源，就会造成死锁。一旦发生就会造成应用的停止响应，如下：
```
import time
import threading

mutex_a = threading.Lock()
mutex_b = threading.Lock()
class MyThread(threading.Thread):
    def task_b(self):
        if mutex_a.acquire():
            print('thread get a mutex_a',self.name)
            time.sleep(1)
            if mutex_b.acquire():
                print('get a mutex_b',self.name)
                mutex_b.release()
            mutex_a.release()
    def task_a(self):
        if mutex_b.acquire():
            print('thread get a mutex_b',self.name)
            time.sleep(1)
            if mutex_a.acquire():
                print('get a mutex_a',self.name)
                mutex_a.release()
            mutex_b.release()
    def run(self):
        self.task_a()
        self.task_b()

if __name__ == '__main__':
    threads = [MyThread() for i in range(2)]
    print(threads)
    for t in threads:
        t.start()
====================================
[<MyThread(Thread-1, initial)>, <MyThread(Thread-2, initial)>]
thread get a mutex_b Thread-1
get a mutex_a Thread-1
thread get a mutex_a Thread-1
thread get a mutex_b Thread-2
```

### threading模块的一些方法和其他类
```python
threading.active_count()		#返回当前激活线程的个数，数量等于enumerate()返回列表的长度
threading.current_thread()		#返回当前Thread对象
threading.get_ident()			#返回当前线程的标识符
threading.enumerate()			#返回当前激活Thread对象的列表
threading.main_thread()			#返回主Thread对象
threading.settrace(func)		#为从线程模块启动的所有线程设置跟踪函数，在run之前调用
threading.setprofile(func)		#为从线程模块启动的所有线程设置说明函数，在run之前调用
threading.stack_size([size])		#返回创建新的线程时该线程使用的栈的大小
threading.TIMEOUT_MAX			#允许超时的最大值

class threading.Condition(lock=None):
	acquire(*args)
	release()
	wait(timeout=None)
	wait_for(predicate, timeout=None)
	notify(n=1)
	notify_all()

class threading.Semaphore(value=1):
	acquire(blocking=True, timeout=None)
	release()
class threading.BoundedSemaphore(value=1)

class threading.Event():
	is_set()
	set()
	clear()
	wait(timeout=None)

#创建一个timer，在interval秒过去之后，它将以参数args和关键字参数kwargs运行function
class threading.Timer(interval, function, args=None, kwargs=None
	cancel()		#停止timer，并取消timer动作的执行

class threading.Barrier(parties, action=None, timeout=None)
	wait(timeout=None)
	reset()
	abort()
	parties
	n_waiting
	broken
```
信号量例子:
```
maxconnections = 5
pool_sema = BoundedSemaphore(value=maxconnections)

with pool_sema:
    conn = connectdb()
    try:
        # ... use connection ...
    finally:
        conn.close()
```
使用锁，条件变量，信号量在代码段中下面两个是等效的:
```
with some_lock:
    # do something...
================================
some_lock.acquire()
try:
    # do something...
finally:
    some_lock.release()
```

## 队列
Python 的 queue 模块中提供了同步的、线程安全的队列类，包括FIFO（先入先出)队列Queue，LIFO（后入先出）队列LifoQueue，和优先级队列 PriorityQueue。这些队列都实现了锁原语，能够在多线程中直接使用，可以使用队列来实现线程间的同步。
queue模块中的类和表达式
```python
class queue.Queue(maxsize=0)			#先入先出队列
class queue.LifoQueue(maxsize=0)		#后入先出队列
class queue.PriorityQueue(maxsize=0)		#优先级队列
exception queue.Empty
exception queue.Full
```
类中的方法
```
Queue.qsize()		#返回队列的大小
Queue.empty()		#如果队列为空，返回True,反之False
Queue.full()		#如果队列满了，返回True,反之False Queue.full 与 maxsize 大小对应
Queue.put(item, block=True, timeout=None)		#写入队列
Queue.put_nowait(item)					#相当Queue.put(item, False)
Queue.get(block=True, timeout=None)			#获取队列
Queue.get_nowait()					#相当Queue.get(False)
Queue.task_done()					#完成一项工作之后，向任务已经完成的队列发送一个信号
Queue.join()						#等到队列为空，再执行别的操作
```

例子:
```
import time
import queue
import threading

class MyThread (threading.Thread):
    def __init__(self, workqueue):
        threading.Thread.__init__(self)
        self.workqueue = workqueue
    def run(self):
        print ("thread start", self.name)
        print ("%s processing %s" % (self.name, self.workqueue))
        time.sleep(1)
        print ("thread stop", self.name)
        workqueue.task_done() #发送完成任务的信号

if __name__ == '__main__':
    nameList = ["One", "Two", "Three", "Four", "Five"]
    workqueue = queue.Queue()
    threads = []

    [workqueue.put(word) for word in nameList] #生成任务队列

    #获取队列任务并生成线程
    threads = [MyThread(workqueue.get()) for i in range(workqueue.qsize())]
    for t in threads:
        t.setDaemon(True) #设置线程随主线程一起结束
        t.start()

    #等待所有线程结束
    for t in threads:
        t.join()

    print(workqueue.qsize())

    #等待队列清空
    workqueue.join()

    print("exit thread")
```
