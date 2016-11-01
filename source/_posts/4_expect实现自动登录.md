---
title: expect实现自动登录
date: 2016-10-22 17:28:24
tags: [expect]
categories: [script,shell]

---


### 安装expect
`sudo apt-get -y install expect`

### expect基本语法
`spawn`: 后面加上需要执行的shell 命令，比如说spawn sudo touch testfile
`expect`: 只有spawn 执行的命令结果才会被expect 捕捉到，因为spawn 会启动一个进程，只有这个进程的相关信息才会被捕捉到，主要包括：标准输入的提示信息，eof 和timeout。
`send 和send_user`：send 会将expect 脚本中需要的信息发送给spawn 启动的那个进程，而`send_user` 只是回显用户发出的信息，类似于shell 中的echo 而已。
`expect` 与“{ ”之间直接必须有空格或则TAB间隔；
`interact` 执行完成后保持交互状态，把控制权交给控制台，如果没有这一句登录完成后会退出，而不是留在远程终端上；
`$argc`表示参数的数目，`$argv`表示参数，比如取第一个参数就是[lindex $argv 0]；
<!-- more -->

如果需要计算的话必须用`expr`，如计算2-1，则必须用[expr 2-1]；

### 例1：linux自动登录
```
#!/usr/bin/env expect
set timeout 5
#spawn ssh -C -p 22222 ubuntu@52.198.212.57
#spawn mosh ubuntu@52.198.212.57 --ssh="ssh -p 22" 	#有错，-p会识别为mosh的参数
spawn mosh ubuntu@52.198.212.57
expect {
        "*yes*no*" {
		send "yes\n"
		expect {
			"*assword*" {
	 			send "$passwd\n"
			}
		}
		"*assword*" {
			send "$passwd\n"
		}
	}
}

interact 			#登录成功后留在远程终端上

#expect "*$ " 			#匹配提示符，注意空格，要和远程终端一致
#send "mkdir kk\n"  		#远程执行命令用send发送，不用spawn
#exit
#输入密码后并没有expect eof，这是因为ssh这个spawn并没有结束，所以你只能expect bash的提示符或机器名等

#expect eof
```

### 例2： linux下建立账户
```
#!/usr/bin/expect
#Useage: ./account.sh newaccout
#用于linux 下账户的建立

set passwd "mypasswd"
set timeout 60
if {$argc != 1} {
	send "usage ./account.sh \$newaccount\n"
	exit
}
set user [lindex $argv [expr $argc-1]]

spawn sudo useradd -s /bin/bash -g mygroup -m $user
expect {
	"assword" {
		send_user "sudo now\n"
		send "$passwd\n"
		exp_continue
	}
	eof {
		send_user "eof\n"
	}
}

spawn sudo passwd $user
expect {
	"assword" {
		send "$passwd\n"
		exp_continue
	}
	eof {
		send_user "eof"
	}
}

spawn sudo smbpasswd -a $user
expect {
	"assword" {
		send "$passwd\n"
		exp_continue
	}
	eof {
		send_user "eof"
	}
}
```
