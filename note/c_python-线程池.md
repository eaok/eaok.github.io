---
title: python 线程池
date: 2016-12-15 09:27:34
tags: [thread]
categories: [python, syntax]

---
一个典型的线程池，应该包括如下几个部分：
1、线程池管理器（ThreadPool），用于启动、停用，管理线程池
2、工作线程（WorkThread），线程池中的线程
3、请求接口（WorkRequest），创建请求对象，以供工作线程调度任务的执行
4、请求队列（RequestQueue）,用于存放和提取请求
5、结果队列（ResultQueue）,用于存储请求执行后返回的结果
<!-- more -->
![线程池工作模型](https://cdn.jsdelivr.net/gh/eaok/img/note/thread_pool.png)

## 用python自己实现
```
#!/usr/bin/env python3
#-*- coding:utf-8 -*-

import time
import queue
import threading

class WorkManager(object):
    def __init__(self, work_num=99,thread_num=9):
        self.work_queue = queue.Queue()
        self.threads = []
        self.__init_work_queue(work_num)
        self.__init_thread_pool(thread_num)
    """初始化线程"""
    def __init_thread_pool(self,thread_num):
        for i in range(thread_num):
            self.threads.append(Work(self.work_queue))
    """初始化工作队列"""
    def __init_work_queue(self, jobs_num):
        for i in range(jobs_num):
            self.add_job(do_job, i)
    """添加一项工作入队"""
    def add_job(self, func, *args):
        self.work_queue.put((func, list(args)))#任务入队，Queue内部实现了同步机制
    """等待所有线程运行完毕"""
    def wait_allcomplete(self):
        for item in self.threads:
            if item.isAlive():item.join()

class Work(threading.Thread):
    def __init__(self, work_queue):
        threading.Thread.__init__(self)
        self.work_queue = work_queue
        self.start()
    def run(self):
        #死循环，从而让创建的线程在一定条件下关闭退出
        while True:
            try:
                do, args = self.work_queue.get(block=False)#任务异步出队，Queue内部实现了同步机制
                do_job(self.name, args)
                self.work_queue.task_done()#通知系统任务完成
            except:
                break

#具体要做的任务
def do_job(name, args):
    time.sleep(0.1)
    print((name, args)

if __name__ == '__main__':
    start = time.time()
    work_manager =  WorkManager(999, 99)
    work_manager.wait_allcomplete()
    end = time.time()
    print("cost all time: %s" % (end-start))
```

## 使用第三方包threadpool
源码地址：https://github.com/SpotlightKid/threadpool
安装：
sudo pip install threadpool

一个简单的例子：
```
#!usr/bin/env python3
#-*- coding:utf-8 -*-

import time
import random
import threadpool

#定义线程函数
def threadfun(data):
    time.sleep(0.1)
    return data

def print_result(request, result):
    print("the result is %s %r" % (request.requestID, result))

def main():
    pool = threadpool.ThreadPool(9) #创建线程池
    data = [random.randint(1, 10) for i in range(99)]
    requests = threadpool.makeRequests(threadfun, data, print_result) #创建线程池要处理的任务
    [pool.putRequest(req) for req in requests] #将任务放到线程池中
    pool.wait() #等待线程池处理完

if __name__=="__main__":
    start = time.time()
    main()
    end = time.time()
    print("cost all time: %s" % (end-start))
```

### threadpool源码分析
threadpool类具有的方法如下：
```
class ThreadPool:
    def __init__(self, num_workers, q_size=0, resq_size=0, poll_timeout=5):
        pass
    def createWorkers(self, num_workers, poll_timeout=5):
        pass
    def dismissWorkers(self, num_workers, do_join=False):
        pass
    def joinAllDismissedWorkers(self):
        pass
    def putRequest(self, request, block=True, timeout=None):
        pass
    def poll(self, block=False):
        pass
    def wait(self):
        pass
```
1、线程池的创建
```
task_pool=threadpool.ThreadPool(num_works)
def __init__(self, num_workers, q_size=0, resq_size=0, poll_timeout=5):
	self._requests_queue = Queue.Queue(q_size)	#任务队列，通过threadpool.makeReuests(args)创建的任务都会放到此队列中
	self._results_queue = Queue.Queue(resq_size)	#字典，任务对应的任务执行结果
	self.workers = []				#工作线程list，通过self.createWorkers()函数内创建的工作线程会放到此工作线程list中
	self.dismissedWorkers = []			#被设置线程事件并且没有被join的工作线程
	self.workRequests = {}				#字典，记录推送到线程池的任务，结构为requestID:request
	self.createWorkers(num_workers, poll_timeout)

num_works:		#线程池中线程个数
q_size:			#任务队列的长度限制
resq_size:		#任务结果队列的长度
poll_timeout:		#工作线程如果从request队列中，读取不到request,则会阻塞poll_timeout,如果仍没request则直接返回
```
2、工作线程的启动和线程处理任务
```
def createWorkers(self, num_workers, poll_timeout=5):
    for i in range(num_workers):
        self.workers.append(WorkerThread(self._requests_queue,
            self._results_queue, poll_timeout=poll_timeout))

WorkerThread()继承自thread,即python内置的线程类，将创建的WorkerThread对象放入到self.workers队列中
class WorkerThread(threading.Thread):
    def __init__(self, requests_queue, results_queue, poll_timeout=5, **kwds):
        threading.Thread.__init__(self, **kwds)
        self.setDaemon(1)
        self._requests_queue = requests_queue		#任务队列
        self._results_queue = results_queue		#任务结果队列
        self._poll_timeout = poll_timeout		#run函数中从任务队列中get任务时的超时时间，如果超时则继续while(true)
        self._dismissed = threading.Event()		#线程事件，如果set线程事件则run会执行break,直接退出工作线程
        self.start()
    def run(self):
        while True:
            if self._dismissed.isSet():			#如果设置了self._dismissed则退出工作线程
                break
            try:
                request = self._requests_queue.get(True, self._poll_timeout)
            except Queue.Empty:				#从任务队列self._requests_queue 中get任务，如果队列为空，则continue
                continue
            else:
                if self._dismissed.isSet():		#检测此工作线程事件是否被set,如果被设置，则结束此工作线程
                    self._requests_queue.put(request)
                    break
                try:	#如果线程事件没有被设置，那么执行任务处理函数request.callable，并将返回的result 压入到任务结果队列中
                    result = request.callable(*request.args, **request.kwds)
                    self._results_queue.put((request, result))
                except:
                    request.exception = True
                    self._results_queue.put((request, sys.exc_info()))	#如果任务处理函数出现异常，则将异常压入到队列中
    def dismiss(self):
        """Sets a flag to tell the thread to exit when done with current job."""
        self._dismissed.set()
```
3、任务的创建（makeRequests）
```
def makeRequests(callable_, args_list, callback=None, exc_callback=_handle_thread_exception):
    requests = []
    for item in args_list:
        if isinstance(item, tuple):
            requests.append(
                WorkRequest(callable_, item[0], item[1], callback=callback,
                    exc_callback=exc_callback)
            )
        else:
            requests.append(
                WorkRequest(callable_, [item], None, callback=callback,
                    exc_callback=exc_callback)
            )
    return requests
callable_：	#任务处理函数,会把任务结果放入到任务结果队列中 self._resutls_queue
args_list：	#任务列表,元素类型为元组，item[0]为位置参数，item[1]为字典类型关键字参数
callback：	#在poll函数中调用，当从self._resutls_queue队列中get某个结果后，会执行此callback(request, result)
		#其中result是request任务返回的结果。
exc_callback：	#异常回调函数，在poll函数中，如果某个request对应有执行异常，那么会调用此异常回调。
任务对象的结构：
class WorkRequest:
    def __init__(self, callable_, args=None, kwds=None, requestID=None, callback=None, exc_callback=_handle_thread_exception):
        if requestID is None:
            self.requestID = id(self)	#获取自身内存首地址作为任务的全局唯一标识
        else:
            try:
                self.requestID = hash(requestID)
            except TypeError:
                raise TypeError("requestID must be hashable.")
        self.exception = False		#如果执行self.callable()过程中出现异常，那么此变量会标设置为True
        self.callback = callback
        self.exc_callback = exc_callback
        self.callable = callable_
        self.args = args or []
        self.kwds = kwds or {}
    def __str__(self):
        return "<WorkRequest id=%s args=%r kwargs=%r exception=%s>" % \
            (self.requestID, self.args, self.kwds, self.exception)
```
4、任务推送到线程池（putRequest）
```
def putRequest(self, request, block=True, timeout=None):
	"""Put work request into work queue and save its id for later."""
	assert isinstance(request, WorkRequest)
	# don't reuse old work requests
	assert not getattr(request, 'exception', None)
	self._requests_queue.put(request, block, timeout)
	self.workRequests[request.requestID] = request	#通过线程池的self.workReuests 字典来存储，结构为 request.requestID:request
```
5、任务结束处理
线程池提供了wait（）以及poll（）函数
```
def wait(self):
	"""Wait for results, blocking until all have arrived."""
	while 1:
		try:
			self.poll(True)
		except NoResultsPending:
			break
def poll(self, block=False):
	"""Process any new results in the queue."""
	while True:
		# still results pending?
		if not self.workRequests:		#检测任务字典{request.requestID:request}是否为空
			raise NoResultsPending
		# are there still workers to process remaining requests?
		elif block and not self.workers:	#检测工作线程是否为空
			raise NoWorkersAvailable
		try:
			# get back next results
			request, result = self._results_queue.get(block=block)	#从任务结果队列中get任务结果
			# has an exception occured?
			if request.exception and request.exc_callback:
				request.exc_callback(request, result)
			# hand results to callback, if any
			if request.callback and not \
				   (request.exception and request.exc_callback):
				request.callback(request, result)
			del self.workRequests[request.requestID]
		except Queue.Empty:
			break
```
6、工作线程的退出
工作线程退出的的操作有dismissWorkers()和joinAllDismissedWorker()
```
def dismissWorkers(self, num_workers, do_join=False):
	"""Tell num_workers worker threads to quit after their current task."""
	dismiss_list = []
	for i in range(min(num_workers, len(self.workers))):
		worker = self.workers.pop()
		worker.dismiss()
		dismiss_list.append(worker)
	if do_join:
		for worker in dismiss_list:
			worker.join()
	else:
		self.dismissedWorkers.extend(dismiss_list)
def joinAllDismissedWorkers(self):
	"""Perform Thread.join() on all worker threads that have been dismissed."""
	for worker in self.dismissedWorkers:
		worker.join()
	self.dismissedWorkers = []
```

### Python的多线程问题
python 的GIL规定每个时刻只能有一个线程访问python虚拟机，所以你要用python的多线程来做计算是很不合算的，但是对于IO密集型的应用，例如网络交互来说，python的多线程还是非常给力的。

如果你是一个计算密集型的任务，非要用python来并行执行的话，有以下几个方法：
1 使用python的multiprocessing 模块，能够发挥多核的优势。
2 使用ironPython，但是这个只能在windows下用
3 使用pypy，这个可以实现真正的多线程。

