---
title: python网络爬虫
date: 2016-11-01 12:04:14
tags: [crawler]
categories: [python,crawler]

---


### 网络爬虫基本原理
![python爬虫](http://ofat4idzj.bkt.clouddn.com/python%E7%88%AC%E8%99%AB.png)
robots协议用来告知搜索引擎哪些页面能被抓取，哪些页面不能被抓取，结构可以参考 http://www.robotstxt.org/orig.html
例如淘宝网页的robots协议：
<!-- more -->
```
https://www.taobao.com/robots.txt
User-agent: Baiduspider
Allow: /article
Allow: /oshtml
Allow: /product
Allow: /spu
Allow: /dianpu
Allow: /wenzhang
Allow: /oversea
Disallow: /
User-Agent: Googlebot
Allow: /article
Allow: /oshtml
Allow: /product
Allow: /spu
Allow: /dianpu
Allow: /wenzhang
Allow: /oversea
Disallow: /
User-agent: Bingbot
Allow: /article
Allow: /oshtml
Allow: /product
Allow: /spu
Allow: /dianpu
Allow: /wenzhang
Allow: /oversea
Disallow: /
User-Agent: 360Spider
Allow: /article
Allow: /oshtml
Allow: /wenzhang
Disallow: /
User-Agent: Yisouspider
Allow: /article
Allow: /oshtml
Allow: /wenzhang
Disallow: /
User-Agent: Sogouspider
Allow: /article
Allow: /oshtml
Allow: /product
Allow: /wenzhang
Disallow: /
User-Agent: Yahoo! Slurp
Allow: /product
Allow: /spu
Allow: /dianpu
Allow: /wenzhang
Allow: /oversea
Disallow: /
User-Agent: *
Disallow: /
```

### urullib库
```
>>> import urllib.request
>>> file=urllib.request.urlopen("http://www.baidu.com")    #方法1
>>> data=file.read()
>>> len(data)
100314
>>> fh=open("D:/Python35/gkk/a1.html","wb")
>>> fh.write(data)
100314
>>> fh.close()
>>> urllib.request.urlretrieve("http://news.sohu.com/",filename="D:/python35/gkk/a2.html")    #方法2
('D:/python35/gkk/a2.html', <http.client.HTTPMessage object at 0x000000000376AC18>)
>>> urllib.request.urlcleanup()
```

### 异常处理可以防止程序意外终止
```
import urllib.request
import urllib.error
try:
    urllib.request.urlopen("http://blog.csdn.net")
except urllib.error.URLError as e:
    if hasattr(e,"code"):
        print(e.code)
    if hasattr(e,"reason"):
        print(e.reason)
    urllib.request.urlopen("http://www.baidu.com")
```

### 获取user-agent
chrome查询user-agent  在地址栏中输入：about:version
firefox查询user-agent 进F12可以查看
通过网址测试查询user-agent： http://www.useragentstring.com/

### 例1 爬取糗事百科段子：
```
import urllib.request
import re
def getcontent(url,page):
    #模拟成浏览器
    headers=("User-Agent","Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.122 Safari/537.36 SE 2.X MetaSr 1.0")
    opener = urllib.request.build_opener()
    opener.addheaders = [headers]
    #将opener安装为全局
    urllib.request.install_opener(opener)
    data=urllib.request.urlopen(url).read().decode("utf-8")
    #构建段子内容提取的正则表达式
    contentpat='<div class="content">(.*?)</div>'
    #寻找出所有的内容
    contentlist=re.compile(contentpat,re.S).findall(data)
    x=1
    #通过for循环遍历段子内容
    for content in contentlist:
        content=content.replace("\n","")
        print(content)
        print("---------------------")
#分别获取各页的段子，通过for循环可以获取多页
for i in range(1,30):
    url="http://www.qiushibaike.com/8hr/page/"+str(i)
    getcontent(url,i)
```

### 例2 爬取京东商城图片：
```
import re
import urllib.request
def craw(url,page):
    html1=urllib.request.urlopen(url).read()
    html1=str(html1)
    pat1='<div id="plist".+? <div class="page clearfix">'
    result1=re.compile(pat1).findall(html1)
    result1=result1[0]
    pat2='<img width="220" height="220" data-img="1" data-lazy-img="//(.+?\.jpg)">'
    imagelist=re.compile(pat2).findall(result1)
    x=1
    for imageurl in imagelist:
        imagename="C:/jd/"+str(page)+str(x)+".jpg"
        imageurl="http://"+imageurl
        try:
            urllib.request.urlretrieve(imageurl,filename=imagename)
        except urllib.error.URLError as e:
            if hasattr(e,"code"):
                x+=1
            if hasattr(e,"reason"):
                x+=1
        x+=1
for i in range(1,5):
    url="http://list.jd.com/list.html?cat=9987,653,655&page="+str(i)
    craw(url,i)
```
