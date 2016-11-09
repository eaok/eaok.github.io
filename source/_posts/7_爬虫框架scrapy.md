---
title: 爬虫框架scrapy
date: 2016-11-08 15:03:23
tags: scrapy
categories: [python,crawler]

---


官方网站：http://scrapy.org/
官网教程：https://doc.scrapy.org/en/latest/index.html
中文版：http://scrapy-chs.readthedocs.io/zh_CN/1.0/index.html
## 安装scrapy
### windows平台
twisted lxml 下载地址: http://www.lfd.uci.edu/~gohlke/pythonlibs/
```
python -m pip install --upgrade pip     #升级pip版本
pip install C:\Users\Administrator\Downloads\Twisted-16.5.0-cp35-cp35m-win_amd64.whl        #安装twisted
pip install C:\Users\Administrator\Downloads\lxml-3.6.4-cp35-cp35m-win_amd64.whl            #安装lxml
pip install scrapy                      #安装scrapy
pip install pypiwin32                   #安装关联模块pypiwin32
```

### ubuntu平台
```
sudo apt-get install python3-pip
sudo pip3 install --upgrade pip
sudo apt-get install python-dev python-pip libxml2-dev libxslt1-dev zlib1g-dev libffi-dev libssl-dev
sudo apt-get install python3 python3-dev
sudo pip3 install scrapy
```

## scrapy命令
scrapy startproject project             #创建项目
scrapy crawl name                       #启动spider
scrapy crawl name-o items.json          #保存爬取到的数据
scrapy genspider mydomain mydomain.com	#创建一个新的spider

scrapy -h								#查看所有可用的命令
scrapy <command> -h							#查看命令的详细内容
```
#Scrapy全局命令:
startproject				#scrapy startproject <project_name>
settings				#scrapy settings [options]
runspider				#scrapy runspider <spider_file.py>
shell					#scrapy shell [url]
fetch					#scrapy fetch <url>
view					#scrapy view <url>
version					#scrapy version [-v]

#Scrapy项目(Project-only)命令:
crawl					#scrapy crawl <spider>
check					#scrapy check [-l] <spider>
list					#scrapy list
edit					#scrapy edit <spider>
parse					#scrapy parse <url> [options]
genspider				#scrapy genspider [-t template] <name> <domain>
bench					#scrapy bench

scrapy parse <url> [options]	#。如果提供 --callback 选项，则使用spider的该方法处理，否则使用 parse 。
	--spider=SPIDER: #跳过自动检测spider并强制使用特定的spider
	--a NAME=VALUE: #设置spider的参数(可能被重复)
	--callback or -c: #spider中用于解析返回(response)的回调函数
	--pipelines: #在pipeline中处理item
	--rules or -r: #使用 CrawlSpider 规则来发现用来解析返回(response)的回调函数
	--noitems: #不显示爬取到的item
	--nolinks: #不显示提取到的链接
	--nocolour: #避免使用pygments对输出着色
	--depth or -d: #指定跟进链接请求的层次数(默认: 1)
	--verbose or -v: #显示每个请求的详细信息
```

**默认的Scrapy项目结构**
```
.
├── bing
│   ├── __init__.py
│   ├── items.py							#项目中的item文件
│   ├── pipelines.py							#项目中的pipelines文件
│   ├── __pycache__
│   │   ├── __init__.cpython-35.pyc
│   │   └── settings.cpython-35.pyc
│   ├── settings.py							#项目的设置文件
│   └── spiders								#放置spider代码的目录
│       ├── bing.py
│       ├── __init__.py
│       └── __pycache__
│           ├── bing.cpython-35.pyc
│           └── __init__.cpython-35.pyc
└── scrapy.cfg								#项目的配置文件
```

[scrapy data flow](http://ofat4idzj.bkt.clouddn.com/scrapy_architecture.png)

