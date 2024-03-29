---
title: 动态网页解决方法
date: 2016-12-28 16:14:38
tags: [selenium, splash, phantomjs]
categories: [python, crawler, selenium]

---
## phantomjs
源码地址：https://github.com/ariya/phantomjs/
windows上，解压后把二进制文件放到`C:\Windows`下
ubuntu中，解压后把二进制文件放到`/usr/bin`下
<!-- more -->
## splash
Splash官方文档：http://splash.readthedocs.org/en/latest/scripting-tutorial.html
Github中ScrapyJS项目：https://github.com/scrapinghub/scrapyjs

## selenium
源码地址：https://github.com/SeleniumHQ/selenium
Selenium with Python：http://selenium-python.readthedocs.io/index.html
Selenium Documentation：https://seleniumhq.github.io/selenium/docs/api/py/api.html

安装：sudo pip3 install -U selenium -i https://pypi.tuna.tsinghua.edu.cn/simple

### selenium的方法
![](https://cdn.jsdelivr.net/gh/eaok/img/note/selenum.png)
```
>>> from selenium import webdriver
>>> dir(webdriver.PhantomJS)
['application_cache',
'back',						#后退
'close',
'create_web_element',
'current_url',
'current_window_handle',
'delete_all_cookies',
'delete_cookie',
'desired_capabilities',
'execute',
'execute_async_script',
'execute_script',
'file_detector',
'file_detector_context',
'find_element',
'find_element_by_class_name',         #通过属性'class'定位
'find_element_by_css_selector',
'find_element_by_id',                 #通过属性'id'定位
'find_element_by_link_text',          #通过文本链接定位
'find_element_by_name',               #通过属性'name'定位
'find_element_by_partial_link_text',  #通过部分内容的文本链接定位
'find_element_by_tag_name',           #通过属性标签名定位
'find_element_by_xpath',
'find_elements',
'find_elements_by_class_name',
'find_elements_by_css_selector',
'find_elements_by_id',
'find_elements_by_link_text',
'find_elements_by_name',
'find_elements_by_partial_link_text',
'find_elements_by_tag_name',
'find_elements_by_xpath',
'forward',					#前进
'get',
'get_cookie',
'get_cookies',
'get_log',
'get_screenshot_as_base64',
'get_screenshot_as_file',
'get_screenshot_as_png',
'get_window_position',
'get_window_size',
'implicitly_wait',
'log_types',
'maximize_window',			#设置浏览器最大化
'mobile',
'name',
'orientation',
'page_source',
'quit',
'refresh',					#刷新
'save_screenshot',
'set_page_load_timeout',
'set_script_timeout',
'set_window_position',
'set_window_size',			#设置浏览器宽高
'start_client',
'start_session',
'stop_client',
'switch_to',
'switch_to_active_element',
'switch_to_alert',
'switch_to_default_content',
'switch_to_frame',
'switch_to_window',
'title',
'window_handles']
```

### 元素相关操作
```
#操作元素方法
clear       #清除元素的内容
send_keys   #模拟按键输入
click       #点击元素
submit      #提交表单

#元素接口获取值
size            #获取元素的尺寸
text            #获取元素的文本
get_attribute(name)     #获取属性值
location                #获取元素坐标，先找到要获取的元素，再调用该方法
page_source     #返回页面源码
driver.title    #返回页面标题
current_url     #获取当前页面的URL
is_displayed()  #设置该元素是否可见
is_enabled()    #判断元素是否被使用
is_selected()   #判断元素是否被选中
tag_name        #返回元素的tagName

#鼠标操作
context_click(elem)             #右击鼠标点击元素elem，另存为等行为
double_click(elem)              #双击鼠标点击元素elem，地图web可实现放大功能
drag_and_drop(source,target)    #拖动鼠标，源元素按下左键移动至目标元素释放
move_to_element(elem)           #鼠标移动到一个元素上
click_and_hold(elem)            #按下鼠标左键在一个元素上
perform()                       #在通过调用该函数执行ActionChains中存储行为

#键盘操作
send_keys(Keys.ENTER)           #按下回车键
send_keys(Keys.TAB)             #按下Tab制表键
send_keys(Keys.SPACE)           #按下空格键space
send_keys(Kyes.ESCAPE)          #按下回退键Esc
send_keys(Keys.BACK_SPACE)      #按下删除键BackSpace
send_keys(Keys.SHIFT)           #按下shift键
send_keys(Keys.CONTROL)         #按下Ctrl键
send_keys(Keys.ARROW_DOWN)      #按下鼠标光标向下按键
send_keys(Keys.CONTROL,'a')     #组合键全选Ctrl+A
send_keys(Keys.CONTROL,'c')     #组合键复制Ctrl+C
send_keys(Keys.CONTROL,'x')     #组合键剪切Ctrl+X
send_keys(Keys.CONTROL,'v')     #组合键粘贴Ctrl+V
```

### driver.get_cookies()取得cookie
```
cookie = "; ".join([item["name"] + "=" + item["value"] +"\n" for item in driver.get_cookies()])
print cookie
#然后带上cookie登录后的页面去请求页面
```

### frame问题解决
```
switch_to_frame("name值")           #有name时用
switch_to_frame("id值")             #有id时用

switch_to_frame(1)                  #按索引查找，chorme是从0开始

iframe = find_element_by_xpath（'//div[@id="loginDiv"]/iframe')     #通用
switch_to_frame(iframe)             # 进入iframe

driver.switch_to_default_content()  # 跳出iframe，回到主content
```

### 操作元素的例子：
```
#自动访问FireFox浏览器自动登录163邮箱:
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import time

# Login 163 email
driver = webdriver.Firefox()
driver.get("http://mail.163.com/")

elem_user = driver.find_element_by_name("username")
elem_user.clear
elem_user.send_keys("15201615157")
elem_pwd = driver.find_element_by_name("password")
elem_pwd.clear
elem_pwd.send_keys("******")
elem_pwd.send_keys(Keys.RETURN)
#driver.find_element_by_id("loginBtn").click()
#driver.find_element_by_id("loginBtn").submit()
time.sleep(5)
assert "baidu" in driver.title
driver.close()
driver.quit()
=========================================================

#元素接口获取值例子：
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import time

driver = webdriver.PhantomJS(executable_path="G:\phantomjs-1.9.1-windows\phantomjs.exe")
driver.get("http://www.baidu.com/")
size = driver.find_element_by_name("wd").size
print size
#尺寸: {'width': 500, 'height': 22}
news = driver.find_element_by_xpath("//div[@id='u1']/a[1]").text
print news
#文本: 新闻
href = driver.find_element_by_xpath("//div[@id='u1']/a[2]").get_attribute('href')
name = driver.find_element_by_xpath("//div[@id='u1']/a[2]").get_attribute('name')
print href,name
#属性值: http://www.hao123.com/ tj_trhao123
location = driver.find_element_by_xpath("//div[@id='u1']/a[3]").location
print location
#坐标: {'y': 19, 'x': 498}
print driver.current_url
#当前链接: https://www.baidu.com/
print driver.title
#标题: 百度一下， 你就知道
result = location = driver.find_element_by_id("su").is_displayed()
print result
#是否可见: True
================================================================

#鼠标操作例子：
import time
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.action_chains import ActionChains

driver = webdriver.Firefox()
driver.get("http://www.baidu.com")

#鼠标移动至图片上 右键保存图片
elem_pic = driver.find_element_by_xpath("//div[@id='lg']/img")
print elem_pic.get_attribute("src")
action = ActionChains(driver).move_to_element(elem_pic)
action.context_click(elem_pic)

#重点:当右键鼠标点击键盘光标向下则移动至右键菜单第一个选项
action.send_keys(Keys.ARROW_DOWN)
time.sleep(3)
action.send_keys('v') #另存为
action.perform()

#获取另存为对话框(失败)
alert.switch_to_alert()
alert.accept()
================================================================

#键盘操作例子：
import time
from selenium import webdriver
from selenium.webdriver.common.keys import Keys

driver = webdriver.Firefox()
driver.get("http://www.baidu.com")
#输入框输入内容
elem = driver.find_element_by_id("kw")
elem.send_keys("Eastmount CSDN")
time.sleep(3)
#删除一个字符CSDN 回退键
elem.send_keys(Keys.BACK_SPACE)
elem.send_keys(Keys.BACK_SPACE)
elem.send_keys(Keys.BACK_SPACE)
elem.send_keys(Keys.BACK_SPACE)
time.sleep(3)
#输入空格+"博客"
elem.send_keys(Keys.SPACE)
elem.send_keys(u"博客")
time.sleep(3)
#ctrl+a 全选输入框内容
elem.send_keys(Keys.CONTROL,'a')
time.sleep(3)
#ctrl+x 剪切输入框内容
elem.send_keys(Keys.CONTROL,'x')
time.sleep(3)
#输入框重新输入搜索
elem.send_keys(Keys.CONTROL,'v')
time.sleep(3)
#通过回车键替代点击操作
driver.find_element_by_id("su").send_keys(Keys.ENTER)
time.sleep(3)
driver.quit()
```

### 通过JS脚本控制滚动页面
```
from selenium import webdriver
import time
#访问百度
driver=webdriver.Firefox()
driver.get("http://www.baidu.com")
#搜索
driver.find_element_by_id("kw").send_keys("selenium")
driver.find_element_by_id("su").click()
time.sleep(3)
#将页面滚动条拖到底部
js="var q=document.documentElement.scrollTop=100000"
driver.execute_script(js)
time.sleep(3)
#将滚动条移动到页面的顶部
js="var q=document.documentElement.scrollTop=0"
driver.execute_script(js)
time.sleep(3)
#将页面滚动条移动到页面任意位置，改变等于号后的数值即可
js="var q=document.documentElement.scrollTop=50"
driver.execute_script(js)
time.sleep(999999)
'''
#若要对页面中的内嵌窗口中的滚动条进行操作，要先定位到该内嵌窗口，在进行滚动条操作
js="var q=document.getElementById('id').scrollTop=100000"
driver.execute_script(js)
time.sleep(3)
'''
driver.quit()
```

### 登录yeah邮箱的例子：
```
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
'''
Login yeah email
'''

import time
from selenium import webdriver


def work(driver):
    driver.maximize_window()
    browser.set_page_load_timeout(10)
    driver.get("http://yeah.net/")
    time.sleep(5)

    try:
        driver.get_screenshot_as_file("login_before.jpg")

        # driver.switch_to_frame('x-URS-iframe')  # 进入到iframe
        driver.switch_to_frame(1)
        driver.find_element_by_name("email").clear()
        driver.find_element_by_name("email").send_keys("kcoewoys")

        elem_pwd = driver.find_element_by_name("password")
        elem_pwd.clear()
        elem_pwd.send_keys("**")

        # elem_pwd.send_keys(webdriver.common.keys.Keys.ENTER)
        driver.find_element_by_id("dologin").click()
        driver.switch_to_default_content()  # 跳出iframe，回到主content

    except Exception as e:
        print(e)
    else:
        time.sleep(5)
        driver.get_screenshot_as_file("login_after.jpg")
        print(driver.title)


if __name__ == "__main__":
    # browser = webdriver.Firefox()
    browser = webdriver.PhantomJS()
    # browser = webdriver.Chrome()

    work(browser)

    browser.quit()
```

### 三种等待方式
1、强制等待，就是直接用time.sleep()
2、隐性等待
如果在规定时间内网页加载完成，则执行下一步，否则一直等到时间截止，再执行下一步。
`driver.implicitly_wait(30)  # 隐性等待，最长等30秒`
3、 显性等待
如果条件成立了，则执行下一步，否则继续等待，直到超过设置的最长时间，然后抛出`TimeoutException`。用到了`WebDriverWait`类与`expected_conditions`模块
`selenium.webdriver.support.wait.WebDriverWait` 显性等待的类
```
__init__(self, driver, timeout, poll_frequency=0.5, ignored_exceptions=None)
    driver: 传入WebDriver实例
    timeout: 超时时间（同时要考虑隐性等待时间）
    poll_frequency: 调用until或until_not中的方法的间隔时间，默认0.5秒
    ignored_exceptions: 抛出这个元组中的异常，不中断代码继续等待，默认只有 NoSuchElementException。
untill(self, method, message='')  #当某元素出现或什么条件成立则继续执行
    method: 在等待期间，每隔一段时间调用这个传入的方法，直到返回值不是False
    message: 如果超时，抛出TimeoutException，将message传入异常
until_not(self, method, message='')  #当某元素消失或什么条件不成立则继续执行

#method参数一定要有 __call__() 方法，否则会抛出异常，可以用 expected_conditions 模块中的各种条件，
#也可以用 WebElement 的 is_displayed() 、is_enabled()、is_selected()方法，或者用自己封装的方法都可以
#调用方法如下：
WebDriverWait(driver, 超时时长, 调用频率, 忽略异常).until(可执行方法, 超时时返回的信息)
```
`elenium.webdriver.support.expected_conditions` 模块中包含一系列可用于判断的条件
```
>>> from selenium.webdriver.support import expected_conditions
>>> dir(expected_conditions)
['NoAlertPresentException',
'NoSuchElementException',
'NoSuchFrameException',
'StaleElementReferenceException',
'WebDriverException',

'alert_is_present',                         #判断是否有alert出现
'element_located_selection_state_to_be',    #传入locator以及状态，相等返回True，否则返回False
'element_located_to_be_selected',           #判断元素是否被选中，传入locator元组
'element_selection_state_to_be',            #传入WebElement对象以及状态，相等返回True，否则返回False
'element_to_be_clickable',                  #判断元素是否可点击，传入locator
'element_to_be_selected',                   #判断元素是否被选中，传入WebElement对象

#判断frame是否可切入，可传入locator元组或者直接传入定位方式：id、name、index或WebElement
'frame_to_be_available_and_switch_to_it',

'new_window_is_opened',
'number_of_windows_to_be',
'presence_of_all_elements_located',         #所有符合条件的元素都加载出来才通过
'presence_of_element_located',              #只要符合一个条件的元素加载出来就通过
'staleness_of',                             #判断元素是否仍在DOM中，传入WebElement对象，可以判断页面是否刷新
'text_to_be_present_in_element',            #判断元素的text是否出现某段文本
'text_to_be_present_in_element_value',      #判断元素的value是否出现某段文本
'title_contains',                           #title是否包含于driver.title
'title_is',                                 #title是否等于driver.title
'invisibility_of_element_located',          #验证元素是否可见，传入参数是元组类型的locator
'visibility_of',                            #验证元素是否可见，传入WebElement
'visibility_of_any_elements_located',
'visibility_of_element_located']            #验证元素是否可见，传入参数是元组类型的locator
```
例子：
```
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from selenium import webdriver
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec
from selenium.webdriver.common.by import By

driver = webdriver.Firefox()
driver.implicitly_wait(10)  # 隐性等待和显性等待可以同时用，但等待的最长时间取两者之中的大者
driver.get('https://www.baidu.com/')
locator = (By.LINK_TEXT, 'hao123')
try:
    WebDriverWait(driver, 20, 0.5).until(ec.presence_of_element_located(locator))
    print(driver.find_element_by_link_text('hao123').get_attribute('href'))
finally:
    driver.close()
```

