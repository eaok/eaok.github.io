[toc]

> win10中的各种配置和小工具

# 一、终端

## cmd

### 启动方式

* `win+r` 输入cmd回车

* 再文件管理器的地址栏中输入cmd再回车

* 给`cmd.exe`文件添加快捷键属性，用快捷键启动

* 在终端中启动

  ```bat
  cmd			#在当前终端起一个
  start cmd	#另起一个cmd
  ```



### 终端中的操作

* exit   	     退出终端
* cls              清屏，类似于linux中的clear



快捷键

* ctrl+c         中断操作，新起一行
* F7               显示所有使用过的命令，类似linux中的`ctrl+r`



### doskey

Windows下的命令别名工具

```bash
doskey /m		#查看已经定义的宏
```



bat文件路径`C:\Users\Administrator\.config\custom`\cmd_auto.bat

```bat
@echo off
doskey ls=dir /b $*
doskey gogo=cd C:\Users\Administrator\Documents\gogo
doskey dogo=cd C:\Users\Administrator\Documents\dogo

doskey dd=docker run --rm -it ^
-e GOPROXY=https://goproxy.cn,direct ^
-v /c/Users/Administrator/Documents/dogo:/home/dogo ^
-w /home/dogo ^
golang $*
```



修改注册表，使cmd启动时自动执行该bat文件

```bash
#找到注册表中的位置
计算机\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Command Processor
#添加一个键值对
AutoRun
C:\Users\Administrator\.config\custom\cmd_auto.bat
```





## powershell

文档：https://docs.microsoft.com/zh-cn/powershell/



## windows terminal

快捷键

```bash
ctrl + -/=/0	#缩放

alt + shift + -		#横向分屏
alt + shift + =		#纵向分屏
alt + shift + d		#自动分屏
alt + up/down/left/right	#切换分屏中的窗口

ctrl + shift + w	#关闭当前分屏窗口
```

命令

```bash
wt -d .						#在当前目录下新开一个终端程序
wt -p "Ubuntu-18.04" -d .	#在当前目录下新开一个终端程序，指定为wsl
```



自定义的设置

```json
	"confirmCloseAllTabs": false,
	"profiles":
    {  
		"defaults":
        {
            // Put settings here that you want to apply to all profiles.
            "colorScheme": "Tango Dark",
            "useAcrylic" : true,
            "acrylicOpacity" : 0.75,
            
            "backgroundImage" : "C:/Users/Administrator/Pictures/壁纸/win10-4.png",
            "backgroundImageAlignment" : "center",
            "backgroundImageOpacity" : 0.25,
            "backgroundImageStretchMode" : "uniformToFill",

            "padding" : "0, 0, 0, 0",
            "fontFace": "Consolas",
            "fontSize": 11
        },
    }
    "keybindings":
    [
        { "command": "newTab", "keys": "alt+o" },
        { "command": { "action": "switchToTab", "index": 0 }, "keys": "alt+1" },
        { "command": { "action": "switchToTab", "index": 1 }, "keys": "alt+2" },
        { "command": { "action": "switchToTab", "index": 2 }, "keys": "alt+3" },
        { "command": { "action": "switchToTab", "index": 3 }, "keys": "alt+4" }
    ]
```



去掉蜂鸣音

vim中在`.vimrc`中添加

```
set vb t_vb=                    " 去掉警告音
```

wsl中在`/etc/inputrc`文件中取消注释行`set bell-style none`

在`.bashrc`中添加

```bash
# Disable beeping in the man page
export LESS="$LESS -R -Q"
```





# 二、工具

## wsl

wsl文档：https://docs.microsoft.com/zh-cn/windows/wsl/

windows10 ubuntu18.04子系统配置

```bash
vi /etc/ssh/sshd_config
PasswordAuthentication yes

sudo service ssh restart
```



WSL 服务自动启动

1 创建并编辑文件：/etc/init.wsl

```bash
#! /bin/sh
/etc/init.d/cron $1
/etc/init.d/ssh $1
/etc/init.d/supervisor $1
```

2 增加可执行权限

```bash
sudo chmod +x /etc/init.wsl
```

3 在win10启动菜单中添加脚本

```cmd
shell: startup

#在Ubuntu-20.04.vbs添加下面两行
Set ws = CreateObject("Wscript.Shell")
ws.run "wsl -d Ubuntu-20.04 -u root /etc/init.wsl start", vbhide

#查看发行版的名字
wslconfig/l
```



访问wsl中的文件

```
\\wsl$\Ubuntu-18.04\home\beaver
```

在wsl里打开当前文件夹

```
explorer.exe .
```





wsl2

更新地址：https://docs.microsoft.com/zh-cn/windows/wsl/install-win10

下载内核组件：https://docs.microsoft.com/zh-cn/windows/wsl/wsl2-kernel

```bash
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
wsl -l -v
wsl --set-version Ubuntu-18.04 2
wsl --set-default-version 2		//所有版本都默认使用wsl2
wsl -s Ubuntu-18.04				//设置默认分发版
```



启动 WSL 2时警告“参考的对象类型不支持尝试的操作”

```powershell
//参考https://zhuanlan.zhihu.com/p/151392411
netsh winsock reset
```





## scoop

官网：https://scoop.sh/

## chocolatey

官网：https://chocolatey.org/

## utools

## AutoHotKey

中文文档：https://wyagd001.github.io/zh-cn/docs/AutoHotkey.htm

设置的快捷键

```ahk
;Ctrl+Alt+w 运行Windows Terminal
^!w::                         
Run wt.exe
Return

;Ctrl+Alt+t 运行cmd
^!t::                         
Run cmd.exe
Return
```

设置开机自启，需要把文件放到启动文件夹中，文件夹位置在`shell:startup`；



# 三、win自带

## Administrator默认以管理员权限运行

`gpedit.msc`进入策略组

计算机配置->windows设置->安全设置->->本地策略->安全选项

禁用“用户账户控制：用于内置管理员账户的管理员批准模式”



## 分屏/虚拟桌面

快速屏：Win + 上/下左/右

任务视图：Win + Tab(松键盘界面消失)

创建新虚拟桌面：Win + Ctrl + D

关闭前虚拟桌面：Win + Ctrl + F4

切换虚拟桌面：Win + Ctrl +左/右      四指左右滑动



# 四、脚本

## bat脚本

脚本例子，`ipchaxun.bat`

```cmd
@echo off &setlocal enabledelayedexpansion 
title 局域网空闲IP查询
Rem '/*========获取本机的IP地址(局域网)=========*/ 
echo 正在获取本机的IP地址，请稍等... 
for /f "tokens=3 skip=2 delims=: " %%i in ('nbtstat -n') do ( 
    set "IP_addr=%%i" 
    set IP_addr=!IP_addr:~1,-1! 
    echo 本机IP为：!IP_addr! 
    goto :next 
) 

:next 
for /f "delims=. tokens=1,2,3,4" %%i in ("%IP_addr%") do set IP_fd=%%i.%%j.%%k 
Rem '/*========获取计算机名============*/ 
echo.&echo 正在获取局域网内计算机名，请稍等... 
echo 处于网段 %IP_fd%.* 的计算机有：&echo. 
for /f "delims=" %%i in ('net view') do ( 
    set "var=%%i" 
    rem ----------获取计算机名称------------ 
    if "!var:~0,2!"=="\\" ( 
        set "var=!var:~2!" 
        echo !var! 
        Rem ----------ping计算机名-------------- 
        ping -n 1 !var!>nul 
    ) 
) 
echo.&echo ----------------------------- 
Rem '/*========提取arp缓存=========*/ 
echo.&echo 正在获取局域网内计算机IP，请稍等...& echo. 
for /f "skip=3 tokens=1,* delims= " %%i in ('arp -a') do echo IP： %%i 已经使用 

echo.&echo ----------------------------- 
echo 程序完成,谢谢使用! 
pause>nul
```

