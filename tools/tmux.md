# tmux

## 一、基本用法

* 安装tmux

  ```bash
  #ubuntu
  sudo apt-get install tmux
  
  #mac
  brew install tmux
  ```

* 启动与退出

  ```shell
  tmux
  
  exit/Ctrl + d
  ```

* 系统指令

  ```bash
  tmux list-keys		# 列出所有快捷键，及其对应的 Tmux 命令
  tmux list-commands	# 列出所有 Tmux 命令及其参数
  tmux info			# 列出当前所有 Tmux 会话的信息
  tmux source-file ~/.tmux.conf		# 重新加载当前的 Tmux 配置
  ```

  |   前缀   |   指令   |                   描述                   |
  | :------: | :------: | :--------------------------------------: |
  | `Ctrl+b` |   `?`    |            显示快捷键帮助文档            |
  | `Ctrl+b` |   `:`    | 进入命令行模式，此时可直接输入`ls`等命令 |
  | `Ctrl+b` |   `[`    |         进入复制模式，按`q`退出          |
  | `Ctrl+b` |   `]`    |         粘贴复制模式中复制的文本         |
  | `Ctrl+b` |   `~`    |             列出提示信息缓存             |
  | `Ctrl+b` |   `t` |                           显示时钟         |

* 配置文件

  > ~/.tmux_conf

  

## 二、会话操作

```bash
tmux								#新建一个无名字的会话
tmux new -s <session-name>			#新建一个有名字的会话
tmux detach	/Ctrl + b d				#分离会话，在后台运行
tmux ls								#查看当前所有会话

tmux a								#重新进入第一个会话
tmux attach -t <session-name>		#重新接入会话
tmux kill-session -t <session-name>	#杀死某个会话
tmux kill-server 					#关闭服务器，所有的会话都将关闭

tmux switch -t <session-name>		#切换到某个会话
tmux rename-session -t <session-name>	#重命名会话
```

|   前缀   |   指令   |                   描述                   |
| :------: | :------: | :--------------------------------------: |
| `Ctrl+b` |   `d`    |               断开当前会话               |
| `Ctrl+b` |   `D`    |             选择要断开的会话             |
| `Ctrl+b` | `Ctrl+z` |               挂起当前会话               |
| `Ctrl+b` |   `r`    |             强制重载当前会话             |
| `Ctrl+b` |   `s`    |        显示会话列表用于选择并切换        |
| `Ctrl+b` |   `$`    |        重命名当前会话        |

## 三、窗格操作

```shell
tmux split-window		# 上下划分
tmux split-window -h	# 左右划分

tmux select-pane -U		# 光标切换到上方窗格
tmux select-pane -D		# 下
tmux select-pane -L		# 左
tmux select-pane -R		# 右

tmux swap-pane -U		# 当前窗格上移
tmux swap-pane -D		# 当前窗格下移
```

窗格操作的快捷键

|   前缀   |     指令      |                             描述                             |
| :------: | :-----------: | :----------------------------------------------------------: |
| `Ctrl+b` |      `"`      |              当前面板上下一分为二，下侧新建面板              |
| `Ctrl+b` |      `%`      |              当前面板左右一分为二，右侧新建面板              |
| `Ctrl+b` |      `x`      |          关闭当前面板（关闭前需输入`y` or `n`确认）          |
| `Ctrl+b` |      `z`      |   最大化当前面板，再重复一次按键后恢复正常（v1.8版本新增）   |
| `Ctrl+b` |      `!`      | 将当前面板移动到新的窗口打开（原窗口中存在两个及以上面板有效） |
| `Ctrl+b` |      `;`      |                   切换到最后一次使用的面板                   |
| `Ctrl+b` |      `o`      |                     逆时针切换到下一面板                     |
| `Ctrl+b` |   `Ctrl+o`    |                顺时针旋转当前窗口中的所有面板                |
| `Ctrl+b` |      `q`      |  显示面板编号，在编号消失前输入对应的数字可切换到相应的面板  |
| `Ctrl+b` |      `{`      |                       向前置换当前面板                       |
| `Ctrl+b` |      `}`      |                       向后置换当前面板                       |
| `Ctrl+b` |   `方向键`    |                       移动光标切换面板                       |
| `Ctrl+b` |   `空格键`    |                  在自带的面板布局中循环切换                  |
| `Ctrl+b` | `Alt+方向键`  |              以5个单元格为单位调整当前面板边缘               |
| `Ctrl+b` | `Ctrl+方向键` |  以1个单元格为单位调整当前面板边缘（Mac下被系统快捷键覆盖）  |



## 四、窗口操作

```bash
#新建窗口
tmux new-window
tmux new-window -n <window-name>

#切换窗口
tmux select-window -t <window-number>
tmux select-window -t <window-name>

#重命名窗口
tmux rename-window <new-name>
```

窗口指令

|   前缀   | 指令  |                    描述                    |
| :------: | :---: | :----------------------------------------: |
| `Ctrl+b` |  `c`  |                  新建窗口                  |
| `Ctrl+b` |  `&`  | 关闭当前窗口（关闭前需输入`y` or `n`确认） |
| `Ctrl+b` | `0~9` |               切换到指定窗口               |
| `Ctrl+b` |  `p`  |               切换到上一窗口               |
| `Ctrl+b` |  `n`  |               切换到下一窗口               |
| `Ctrl+b` |  `w`  |        打开窗口列表，用于且切换窗口        |
| `Ctrl+b` |  `,`  |               重命名当前窗口               |
| `Ctrl+b` |  `.`  |   修改当前窗口编号（适用于窗口重新排序）   |
| `Ctrl+b` |  `f`  |  快速定位到窗口（输入关键字匹配窗口名称）  |





参考文章：https://louiszhai.github.io/2017/09/30/tmux/

