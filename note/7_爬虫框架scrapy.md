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
<!-- more -->
### windows平台
twisted lxml 下载地址: http://www.lfd.uci.edu/~gohlke/pythonlibs/
```
python -m pip install --upgrade pip     #升级pip版本
pip install C:\Users\Administrator\Downloads\Twisted-16.5.0-cp35-cp35m-win_amd64.whl        #安装twisted
pip install C:\Users\Administrator\Downloads\lxml-3.6.4-cp35-cp35m-win_amd64.whl            #安装lxml
pip install pypiwin32                   #安装关联模块pypiwin32
pip install scrapy                      #安装scrapy
scrapy bench                            #验证Scrapy
```

### ubuntu平台
```
sudo apt-get install python3 python3-dev python3-pip
sudo pip3 install --upgrade pip
sudo apt-get install libxml2-dev libxslt1-dev zlib1g-dev libffi-dev libssl-dev
sudo pip3 install scrapy                #安装scrapy
scrapy bench                            #验证Scrapy
```

## scrapy命令
```
scrapy startproject project                 #创建项目
scrapy genspider -l                         #查看可用模板
scrapy genspider -t basic name baidu.com    #依据模板创建文件
scrapy genspider mydomain mydomain.com      #创建一个新的spider文件
scrapy crawl name --nolog                   #启动spider并不显示log
scrapy crawl name -o items.json             #保存爬取到的数据

scrapy fetch http://www.baidu.com --nolog       #下载给定的URL，并将获取到的内容送到标准输出。
scrapy runspider name.py                        #在未创建项目时，运行一个编写在Python文件中的spider
scrapy shell http://www.baidu.com --nolog       #调试并不显示日志信息
scrapy view http://www.baidu.com                #在浏览器中打开网页

scrapy check  name                              #运行contract检查
scrapy list                                     #列出当前文件夹下的爬虫文件
scrapy edit name                                #编辑
scrapy parse http://www.baidu.com               #获取给定的URL并使用相应的spider分析处理。如果提供 --callback，则使用spider处理

scrapy -h					#查看所有可用的命令
scrapy <command> -h				#查看命令的详细内容

#Scrapy全局命令:
bench         #Run quick benchmark test
fetch         #Fetch a URL using the Scrapy downloader
genspider     #Generate new spider using pre-defined templates
runspider     #Run a self-contained spider (without creating a project)
settings      #Get settings values
shell         #Interactive scraping console
startproject  #Create new project
version       #Print Scrapy version
view          #Open URL in browser, as seen by Scrapy

#Scrapy项目(Project-only)命令:
check         #Check spider contracts
crawl         #Run a spider
edit          #Edit spider
list          #List available spiders
parse         #Parse URL (using its spider) and print the results

scrapy parse <url> [options]	#如果提供 --callback 选项，则使用spider的该方法处理，否则使用 parse
	--spider=SPIDER:    #跳过自动检测spider并强制使用特定的spider
	--a NAME=VALUE:     #设置spider的参数(可能被重复)
	--callback or -c:   #spider中用于解析返回(response)的回调函数
	--pipelines:        #在pipeline中处理item
	--rules or -r:      #使用 CrawlSpider 规则来发现用来解析返回(response)的回调函数
	--noitems:          #不显示爬取到的item
	--nolinks:          #不显示提取到的链接
	--nocolour:         #避免使用pygments对输出着色
	--depth or -d:      #指定跟进链接请求的层次数(默认: 1)
	--verbose or -v:    #显示每个请求的详细信息
```

## xpath基本用法
```
/                       #根节点
//                      #匹配所有的
text()                  #提取文本
@属性名                 #提取属性
标签[@属性=属性值]      #匹配该属性的标签
```

## 默认的Scrapy项目结构
```python
.
├── bing
│   ├── __init__.py
│   ├── items.py                        #定义要爬取的内容结构
│   ├── pipelines.py                    #处理提取的内容
│   ├── __pycache__
│   ├── settings.py                     #项目的参数设置文件
│   └── spiders
│  	├── getimg.py                   #项目的主文件
│       ├── __init__.py
│       └── __pycache__
└── scrapy.cfg                          #项目的配置文件
```
---

**scrapy data flow**
![scrapy data flow](https://cdn.jsdelivr.net/gh/eaok/img/note/scrapy_architecture.png)