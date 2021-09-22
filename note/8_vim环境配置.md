[toc]

# 安装vim

## 通过包管理安装

`sudo apt-get install vim`





# 配置vim

先下载配置文件 https://github.com/eaok/dotfiles

```shell
# 先配置.bashrc文件，并开启代理
vi -O .bashrc dotfiles/wsl/.bashrc

# 配置.vimrc，并安装插件
mkdir -p ~/.vim/bundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vi -O .vimrc dotfiles/wsl/.vimrc
vim +PluginInstall +qall
```





# vim命令
```
i/a		#从光标处/从光标下一个字符处编辑
I/A		#从行首/行尾处编辑
o/O		#从下一行/上一行编辑

s/S     #删除光标所在字符/行，并进入输入模式
r/R     #替换单个字符/多个字符
x/X     #删除当前字符/前一个字符

.	    #重复上个操作

ncb/ncw #剪切光标前/后n个单词
nyb/nyw #复制光标前/后n个单词
ndb/ndw #删除光标前/后n个单词

c^/$    #剪切从光标所在位置到行首/行尾的字符串
y^/$    #复制从光标所在位置到行首行尾的字符串
d^/$    #删除或者剪切从光标所在位置到行首/行尾的字符串

gg=G            #自动排版
range =			#选定内容自动排版
range U/u		#选定内容变为大写/小写
gg/G            #移动到文件首行/末行
H/M/L           #移动到屏幕首行/中间行/末行
zt/zz/zb		#移动当前行到顶端/中央/底端


0/^/$           #移动到所在行最前的字符/第一个非空字符/最后一个字符

b/w             #移动到上/下一个单词的首字母
e               #移动到下一个单词的尾字母

n%				#到文件n%的位置。
n + enter		#向后跳n行
:n/n+G			#移动到第n行


Ctrl + u/d        #光标向上/下移动半页
Ctrl + b/f        #光标向上/下移动一页
ctrl + e/y		  #光标向上/下移动一行
Ctrl + n/p        #补全单词
Ctrl + x + l      #补全一行
Ctrl + x + f      #插入当前目录下文件名
ctrl + o/i		  #跳到原来的位置
ctrl + u/r		  #撤销/取消撤销


q + :			#进入命令历史缓冲区
q + //?			#进入查找的历史纪录
/string         #向下查找
?string         #向上查找

range y        #块复制
range d        #块删除
:range s/old_string/new_string/gc      #替换
    #% 表示所有行
    #. 表示当前行
    #g 表示行中进行多个匹配
    #c 替换前询问
    #e 不显示错误
    #i 不区分大小写
#删除行尾多余的空格，可以执行如下命令：
:%s/\s\+$//g
#删除每行前面的空格，执行如下命令：
:%s/^\+\s//g


vi -o/O file1 file2 #水平/垂直打开两个文件
:vs file_name       #打开一个文件并左右分割窗口
:sp file_name       #打开一个文件并上下分割窗口
ctrl+w+w            #文件之间切换

:set paste           #设置为粘贴模式
:set nopaste         #关闭粘贴模式


qa                  #将后续的命令记入寄存器a,q结束录制
@a                  #执行寄存器a中录制的内容
```



vim 文件编码

```shell
set fileencodings=utf-8,gb2312,gb18030,gbk,ucs-bom,cp936,latin1
```

Vim 有四个跟字符编码方式有关的选项，encoding、fileencoding、fileencodings、termencoding

encoding: Vim 内部使用的字符编码方式，包括 Vim 的 buffer (缓冲区)、菜单文本、消息文本等。

fileencoding: Vim 中当前编辑的文件的字符编码方式，Vim 保存文件时也会将文件保存为这种字符编码方式 (不管是否新文件都如此)。

fileencodings: Vim 启动时会按照它所列出的字符编码方式逐一探测即将打开的文件的字符编码方式，并且将 fileencoding 设置为最终探测到的字符编码方式。因此最好将 Unicode 编码方式放到这个列表的最前面，将拉丁语系编码方式 latin1 放到最后面。

termencoding: Vim 所工作的终端 (或者 Windows 的 Console 窗口) 的字符编码方式。这个选项在 Windows 下对我们常用的 GUI 模式的 gVim 无效，而对 Console 模式的 Vim 而言就是 Windows 控制台的代码页，并且通常我们不需要改变它。



同一个文件中出现多种换行时

```shell
#转换文件换行方式，设置fileformat属性
:set ff=dos (\r\n win换行)
:set ff=unix (\n unix/linux换行)
:set ff=mac (\r Mac换行)

#统一换行符，去掉\r
:%s/\r//g
```



代码中Tab和空格混排

```shell
#将代码中原有的Tab转成4个空格
:set ts=4  sw=4 et
:%ret!

#可将代码中原有的4个空格转成Tab
:set ts=4  sw=4 noet
:%ret!
```



# vim插件

python相关插件
```
"python相关插件
"自动缩进
Plugin 'vim-scripts/indentpython.vim'
"自动补全
Plugin 'Valloric/YouCompleteMe'
"每次保存文件时Vim都会检查代码的语法
Plugin 'scrooloose/syntastic'
"PEP8代码风格检查
Plugin 'nvie/vim-flake8'
```



ctrlp插件使用

```bash
一旦ctrlp打开了：
   按F5清除当前目录的缓冲以便获取新文件，移除被删掉的文件以及应用新的忽略选项。
    按<ctrl-f>和<ctrl-b>在两种模式间循环
    按<ctrl-d>切换到仅搜索文件名而不是完整路径
    按<ctrl-r>切换到正则表达式模式
    使用<ctrl-j>，<ctrl-k>或者方向键在结果列表移动
    使用<ctrl-t>或<ctrl-v>,<ctrl-x>以新表，新窗口分割方式打开选定项
    使用<ctrl-n>,<ctrl-p>在历史记录里选择上一项或下一项
    使用<ctrl-y>来创建新文件和它的父目录
    使用<ctrl-z>来标记（取消标记）多个文件，使用<ctrl-o>来打开它们
在ctrlp中执行:help ctrlp-mappings或？获取更多快捷键映射帮助。

    使用两个或多个符号..来升起单层或多层目录树

    使用:25会跳转到打开文件的第25行，当打开多个文件的时候使用:diffthis，会在最开始的4个文件里执行。
```



vim打开没有sudo文件时，要保存可以用下面的命令：

```
:w !sudo tee %
```

