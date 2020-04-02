---
title: python中使用cookie
date: 2016-12-28 16:16:14
tags: [cookiejar]
categories: [python, syntax]

---

## 查看 cookie
chorme 中查看 cookie
使用 EditThisCookie 插件
点击网址前面的图标可以查看
ctrl + shift + delete -> 取消 -> 内容设置 -> 所有cookie和网站数据

firefox 中查看 cookie
使用插件 Cookies manager+ 插件
选项 -> 隐私 -> 移除单个 Cookie 中可以查看
<!-- more -->
获取表单提交的地址：开发工具中查看post方法；用fiddler抓包工具查看

## 模块中的类和方法
```
http.cookiejar has the following classes:
    exception http.cookiejar.LoadError
    class http.cookiejar.CookieJar(policy=None)
    class http.cookiejar.FileCookieJar(filename, delayload=None, policy=None)
    class http.cookiejar.CookiePolicy
    class http.cookiejar.DefaultCookiePolicy(blocked_domains=None, allowed_domains=None, ...)
    class http.cookiejar.Cookie
CookieJar has the following methods:
    CookieJar.add_cookie_header(request)
    CookieJar.extract_cookies(response, request)
    CookieJar.set_policy(policy)
    CookieJar.make_cookies(response, request)
    CookieJar.set_cookie_if_ok(cookie, request)
    CookieJar.set_cookie(cookie)
    CookieJar.clear([domain[, path[, name]]])
    CookieJar.clear_session_cookies()
FileCookieJar implements the following additional methods:
    FileCookieJar.save(filename=None, ignore_discard=False, ignore_expires=False)  # 把cookie保存到文件
    FileCookieJar.load(filename=None, ignore_discard=False, ignore_expires=False)  # 从文件中读取cookie
    FileCookieJar.revert(filename=None, ignore_discard=False, ignore_expires=False)
    FileCookieJar.filename
    FileCookieJar.delayload
FileCookieJar的子类  # 这种FileCookieJar能以the libwww-perl library’s Set-Cookie3 文件形式把cookie存取到磁盘上。
class http.cookiejar.MozillaCookieJar(filename, delayload=None, policy=None)
class http.cookiejar.LWPCookieJar(filename, delayload=None, policy=None)
==========================================================================================

#文档中的例子：
# the most common usage of http.cookiejar:
import http.cookiejar, urllib.request
cj = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))
r = opener.open("http://example.com/")

# open a URL using your cookies:
import os, http.cookiejar, urllib.request
cj = http.cookiejar.MozillaCookieJar()
cj.load(os.path.join(os.path.expanduser("~"), ".netscape", "cookies.txt"))
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))
r = opener.open("http://example.com/")
```

## 使用
```
#封装cookie信息
cookie = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cookie))
# response = opener.open(request)  # 方法一：每次用opener.open打开网页
urllib.request.install_opener(opener)  # 方法二：安装为全局，每次用urlopen打开网页
response = urllib.request.urlopen(request)
======================================================================
#写header和postdata数据
data = {
    "Logon_Password": "sunmin",
    "Logon_PostCode": "fghc",
    "Logon_RememberMe": "false",
    "Logon_UserEmail": "sun121@qq.com"
}
header = {
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Encoding": "utf-8",
    "Accept-Language": "zh-cn,zh;q=0.8,en-us;q=0.5,en;q=0.3",
    "Connection": "keep-alive",
    "Host": "c.highpin.cn",
    "Referer": "http://c.highpin.cn/",
    "User-Agent": "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:32.0) Gecko/20100101 Firefox/32.0"
}
========================================================================
#两种方式获取cookie
cookie = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cookie))
postdata = urllib.parse.urlencode(data).encode()  # need bytes type
request = urllib.request.Request(login_url, postdata, headers=header)
response = opener.open(request)
for item in cookie:
    print('Name = ' + item.name)
    print('Value = ' + item.value)
========================
cookie_filename = 'cookie.txt'
cookie = http.cookiejar.MozillaCookieJar(cookie_filename)
handler = urllib.request.HTTPCookieProcessor(cookie)
opener = urllib.request.build_opener(handler)
postdata = urllib.parse.urlencode(data).encode()  # need bytes type
request = urllib.request.Request(login_url, postdata, headers=header)
response = opener.open(request)
cookie.save(ignore_discard=True, ignore_expires=True)  # 保存到文件中
for item in cookie:
    print('Name = ' + item.name)
    print('Value = ' + item.value)
```

## 登录伯乐在线的例子
```
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""记录cookie，登录伯乐在线"""

import http.cookiejar
import urllib.request, urllib.parse, urllib.error
from lxml import etree


login_url = 'http://www.jobbole.com/wp-admin/admin-ajax.php'
get_url = 'http://www.jobbole.com/'

data = {'action': 'user_login',
        'user_login': 'kcoewoys',
        'user_pass': 'fDx%wT95YaDf!iQ&'}

header = {'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0'}


def get_cookie(login_url, data, header):
    postdata = urllib.parse.urlencode(data).encode()  # need bytes type
    request = urllib.request.Request(login_url, postdata, headers=header)

    try:
        # urllib.request.install_opener(opener)  # method 1
        # response = urllib.request.urlopen(request)
        response = opener.open(request)  # method 2
    except urllib.error.URLError as e:
        print(e.code, ':', e.reason)
    else:
        print(response.read().decode())

    # cookie.save(ignore_discard=True, ignore_expires=True)  # 保存到文件中
    for item in cookie:
        print('Name = ' + item.name)
        print('Value = ' + item.value)

def get_request(get_url, header):
    request = urllib.request.Request(get_url, headers=header)
    response = opener.open(request)

    et = etree.HTML(response.read().decode())
    print(et.xpath('/html/head/title/text()')[0])  # print the html's title

if __name__ == '__main__':
    # cookie_filename = 'cookie.txt'  # 保存cookie文件的名字
    # cookie = http.cookiejar.MozillaCookieJar(cookie_filename)
    # handler = urllib.request.HTTPCookieProcessor(cookie)
    # opener = urllib.request.build_opener(handler)

    cookie = http.cookiejar.CookieJar()
    opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cookie))

    get_cookie(login_url, data, header)
    get_request(get_url, header)
```
