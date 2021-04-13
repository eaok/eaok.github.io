[toc]

> 记录Linux常用的工具，命令，操作！

# 一、环境

终端中常用操作

## 终端中的快捷键

```
CTRL + A: 将光标移动到行的开头。
CTRL + E: 将光标移动到行尾。

CTRL + U: 从光标处删除文本直到行首
CTRL + K: 从光标处删除文本直到行尾
CTRL + W: 剪切光标前一个单词
CTRL + Y: 粘贴前面删除的文本
Shift + Insert: 将剪切板中的文本粘贴到终端中

CTRL + F: 光标移动到后一个字符
CTRL + B: 光标移动到前一个字符

CTRL + R: 在历史命令中搜索命令

Ctrl + P    前一条命令，可以替换上方向键
Ctrl + N    后一条命令，可以替换下方向键
Ctrl + C    终止正在运行的命令
Ctrl + L    清屏 等于 clear
Ctrl + D	退出shell
Shift + up/down		上下滚动
```



## 终端中的命令操作

### 少见但有用的命令

* !!                重复执行上一条命令

  ```bash
  !!
  sudo !!
  !-1			#重复执行上一条命令
  !-2			#重复执行前面的第二条命令
  ```

* &               在后台执行

  ```bash
  [命令] &
  ```

* ;/&&/||

  ```bash
  echo a;echo b				#一行执行多条命令
  ls foo && cd foo			#前面执行成功才执行后面的
  mkdir foo || mkdir bar		#前面执行失败才执行后面的
  ```

  

* nohup       让后台工作在离开操作终端时，也能够正确地在后台执行

  ```bash
   nohup [命令] &
  ```

* shutdwon      关机

  ```bash
  
  shutdown -c		#取消关机任务
  ```

  

*  iconv          转换文件的编码

  ```bash
  iconv --help
  iconv --usage
  
  #将utf-8编码的file1转换成gb18030编码的file2
  iconv -f utf-8 -t gb 18030 file1.txt -o file2.txt
  ```



### 常用的基础命令

* mkdir            创建文件夹

  ```bash
  mkdir -p a/b/{a,b}		#递归创建目录
  ```



* apt-get

  ```bash
  apt-cache search xxx     #在缓存中搜索包
  ```

* chmod

  ```bash
  sudo chmod 777 xxx
  sudo chmod a+x d
  ```

  [文件权限属性](#文件权限属性)

* chown

  ```bash
  chown yeah:yeah kernel    #改变kernel文件夹的所有者和所有组
  ```

  

* ln

  ```bash
  ln -s src_file link_file_name    #符号链接（symobl)
  ln src_file link_file_name    	 #硬连接
  ```

  

* tar                 解压缩的工具

  ```bash
  #查看压缩包里面的文件
  tar tvf lua-5.3.5.tar.gz
  
  #解压缩tar.gz文件
  tar cvf xxx.tar.gz xxx/
  tar xvf xxx.tar.gz
  
  #解压缩tar.xz文件
  tar cvJf xxx.tar.xz xxx/
  tar xvJf xxx.tar.xz
  
  #删除意外在当前文件夹下解压的文件
  rm -f "$(tar ztf /path/to/file.tar.gz)"
  ```

  

* zip/unzip     zip格式的解压缩工具

  ```bash
  sudo unzip protoc-3.10.0-rc-1-linux-x86_64.zip -d /usr/local/
  ```



* man

  ```bash
  man ascii       #查看ascii表
  ```

  



### 进程相关

* ps

  ```bash
  ps -aux
  ```

  

* pstree         显示进程树

* top

* kill

  ```bash
  kill -9 pid
  ```

  

### 查询搜索

* whereis/which		#显示命令文件所在的位置

  ```bash
  whereis micro
  which micro
  ```

* w                看服务器上目前已登录的用户信息

* df               查看磁盘消耗情况

  ```bash
  df -h
  ```

* free           查看内存消耗情况

  ```bash
  free -h
  ```

* du              查看当前目录下所有文件和目录大小

  ```bash
  du -h
  ```

* locate         文件搜索命令

  ```bash
  locate 文件名
  
  #数据库位置/var/lib/mlocate/mlocate.db
  updatedb      #更新数据库
  
  #配置文件/etc/updatedb.conf
  PRUNE_BIND_MOUNTS    =    "YES"    #以下规则全部生效，no，规则全部不生效
  PRUNEFS    	  #搜索时，不搜索的文件系统
  PRUNENAMES    #搜索时，不搜索的文件类型
  PRUNEPATHS    #搜索时，不搜索的文件路径
  
  locate /etc/sh      #查找etc目录下所有以sh开头的文件
  locate -c /etc/*.sh #统计etc目录下所有以sh文件数量
  locate -ir gogo.*readme.md	#用正则搜索
  ```

  

* find              搜索符合条件的文件名

  ```bash
  #不区分大小写搜索gogo目录下名字为readme的文件
  find gogo -iname readme*
  
  #只更改文件夹权限:
  find -type d -exec chmod 755 {} \;
  find -type d | xargs chmod 755
  
  #只更改文件权限:
  find -not -type d -exec chmod 644 {} \; 
  find -not -type d | xargs chmod644
  
  find -name *.orig -exec rm {} \;
  find -name *.orig | xargs rm
  ```

  

* grep               主要用于在文件中查找指定模式的字符串

  ```bash
  grep -n '^$' a.go    	#搜索空行
  grep '\<range\>' a.go	#只匹配‘range’字符串。 
  grep -n "ra.*e" a.go
  grep -rl '\<range\>' gogo   #递归搜索文件件中包含字符串的文件
  grep -irn hello,world       #递归搜索当前目录下所有文件中包含字符串的行，省略了目录参数
  
  find -type f -name '*.php'|xargs grep 'GroupRecord'
  ```

  





### 网络相关

* ifconfig            查询ip

* route                查看路由表

  ```bash
  route
  ```

* dig                   查询DNS包括NS记录，A记录，MX记录等相关信息的工具

  ```bash
  dig baidu.com
  dig baidu.com CNAME			#查询CNAME记录
  dig @8.8.8.8 baidu.com      #在指定dns服务器中查询
  dig -x 8.8.8.8 +short       #反向查询ip对应的dns域名服务器
  dig +trace baidu.com		#跟踪DNS查询过程
  ```

  



### 定时任务

* at 				定时执行命令

  ```bash
  yeah@ubuntu:~ $ at 11:30
  at> ls
  at> <EOT>
  
  atq		#查询定时任务
  ```

  

* crontab       循环定时任务

  ```bash
  crontab -e
  crontab -l				#查询当前用户的循环定时任务
  crontab -r				#删除定时任务文件
  
  sudo vi/etc/crontab		#可以直接修改这个文件
  ```

  [crontab内容的格式](#crontab内容的格式)







暂停命令并在后台运行命令

```bash
CTRL+Z		#暂停当前运行的程序
jobs		#查看后台挂起的程序
fg/bg		#继续/在后台执行最近暂停的程序
fg/bg %1	#继续/在后台执行%1程序

#放入后台执行的命令不能和前台用户有交互或需要前台输入，否则只能放入后台暂停，而不能执行。
```







## 常用的第三方工具

* htop			类似于top查看和管理进程，界面更友好
* ranger		使用命令行浏览文件系统
* most			美化man手册的工具，需要加环境变量`export PAGER=most`



* tree             按照树形显示文件

  ```bash
  tree
  tree xxx -L 2	#只显示两层
  ```



* cowsay       类似于echo，多了只奶牛
* sl                 终端中跑火车





# 附录

## crontab内容的格式

crontab 时间表示

| 项目      | 含义                           | 范围                  |
| --------- | ------------------------------ | --------------------- |
| 第一个"*" | 一小时当中的第几分钟（minute） | 0~59                  |
| 第二个"*" | 一天当中的第几小时（hour）     | 0~23                  |
| 第三个"*" | 一个月当中的第几天（day）      | 1~31                  |
| 第四个"*" | 一年当中的第几个月（month）    | 1~12                  |
| 第五个"*" | 一周当中的星期几（week）       | 0~7（0和7都代表星期日 |

时间特殊符号

| 特殊符号    | 含义                                                         |
| ----------- | ------------------------------------------------------------ |
| *（星号）   | 代表任何时间。比如第一个"*"就代表一小时种每分钟都执行一次的意思。 |
| ,（逗号）   | 代表不连续的时间。比如"0 8，12，16***命令"就代表在每天的 8 点 0 分、12 点 0 分、16 点 0 分都执行一次命令。 |
| -（中杠）   | 代表连续的时间范围。比如"0 5 ** 1-6命令"，代表在周一到周六的凌晨 5 点 0 分执行命令。 |
| /（正斜线） | 代表每隔多久执行一次。比如"*/10****命令"，代表每隔 10 分钟就执行一次命令。 |

crontab举例

```bash
#每1分钟执行一次command
* * * * * command
#每小时的第3和第15分钟执行
3,15 * * * * command
#8点到11点的第3和第15分钟执行
3,15 8-11 * * * command
#每隔两天的8点到11点的第3和第15分钟执行
3,15 8-11 */2 * * command
#每个星期一的8点到11点的第3和第15分钟执行
3,15 8-11 * * 1 command
#每周六、周日的1 : 10执行
10 1 * * 6,0 command
#每小时执行/etc/cron.hourly目录内的脚本
01 * * * * root run-parts /etc/cron.hourly

#在 22 点 45 分执行命令
45 22 ***命令

#在每周一的 17 点 0 分执行命令
0 17 ** 1命令
#在每月 1 日和 15 日的凌晨 5 点 0 分执行命令
0 5 1，15**命令
#在每周一到周五的凌晨 4 点 40 分执行命令
40 4 ** 1-5命令
#在每天的凌晨 4 点，每隔 10 分钟执行一次命令
*/10 4 ***命令
```



## 文件权限属性

文件权限属性

第一个字母代表文件类型

​    \-  代表普通文件

​    d  代表目录

​    l   代表符号链接文件

​    p  代表管道

​    s  代表socket文件

从第二个开始，后面的9个表示文件权限，分为三组，每组依次为rwx，表示可读，可写，可执行

​    第一组表示文件属主的权限

​    第二组表示文件属主所在组的权限

​    第三组表示其他用户的权限



用u表示属主

用g表示属主所在的组

用o表示其他用户

用a表示所有用户