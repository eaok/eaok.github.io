## 安装vim
### 通过包管理安装

`sudo apt-get install vim`

### vim命令
```
s   #删除光标所在字符，并进入输入模式
S   #删除光标所在行，并进入输入模式
R   #替换多个字符

ncb #剪切光标前n个单词
nyw #复制光标后n个单词
ndw #删除光标后n个单词

c$  #剪切从光标所在位置到行尾的字符串
y^  #复制从光标所在位置到行首的字符串
d$  #删除或者剪切从光标所在位置到行尾的字符串

gg=G            #自动排版

H               #移动到屏幕首行
M               #移动到屏幕中间
L               #移动到屏幕末行
gg              #移动到文件首行
G               #移动到文件末行

0               #移动到所在行最前的字符
^               #移动到所在行第一个非空字符
$               #移动到所在行最后一个字符

b               #移动到上一个单词的第一个字符
w               #移动到下一个单词的第一个字符
e               #移动到下一个单词的第一个字符

Ctrl + d        #光标向下移动半页
Ctrl + f        #光标向下移动一页
Ctrl + n        #补全单词
Ctrl + p        #补全单词
Ctrl + x + l    #补全一行
Ctrl + x + f    #插入当前目录下文件名
ctrl + o		#跳到原来的位置
ctrl + i		#与ctrl+o相反

/string         #向下查找
?string         #向上查找

:range y        #块复制
:range d        #块删除
:range s/old_string/new_string/gc      #替换
    #% 表示所有行
    #. 表示当前行
    #$ 表示末行
    #g 表示行中进行多个匹配
    #c 替换前询问

:vs file_name       #打开一个文件并左右分割窗口
:sp file_name       #打开一个文件并上下分割窗口
ctrl+w+w            #文件之间切换

set paste           #设置为粘贴模式
set nopaste         #关闭粘贴模式
set mouse=v         #设置鼠标模式为v

qa                  #将后续的命令记入寄存器a,q结束录制
@a                  #执行寄存器a中录制的内容
```

## vim配置
```
tabstop             # ts 定义tab所等同的空格长度，一般来说最好设置成8
shiftwidth          # sw 用于程序中自动缩进所使用的空白长度指示
softtabstop         # sts 逢8空格进1制表符”,前提是你tabstop=8
expandtab           # et 以空格替换

cindent             # 用C语言的缩进格式来处理程序的缩进结构
smartindent         # si 和前一行有相同的缩进量，同时能识别出花括号，函数等
autoindent          # ai 新增加的行和前一行使用相同的缩进形式

autocmd             # au 自动执行命令

空格和TAB的替换：
#TAB替换为空格：
:set ts=4
:set et
:%retab!

#空格替换为TAB：
:set ts=4
:set noet
:%retab!
#加!是用于处理非空白字符之后的TAB，即所有的TAB，若不加!，则只处理行首的TAB

#删除每行后面多余的空格，可以执行如下命令：
:%s/\s\+$//
#删除每行前面的空格，执行如下命令：
:%s/^\+\s//
```
`/etc/vim/vimrc`配置
```
syntax on

set nu
set pastetoggle=<F11>           "按f11打开或关闭粘贴模式
set fileencodings=utf-8,gb2312,gb18030,gbk,ucs-bom,cp936,latin1		"vim 文件编码

" \ should be followed by /, ? or &
set nocompatible

set foldenable              " 开始折叠
set fdm=syntax              " 设置语法折叠
set foldcolumn=0            " 设置折叠区域的宽度
setlocal foldlevel=1        " 设置折叠层数为
set foldlevelstart=99       " 打开文件是默认不折叠代码
set foldclose=all           " 设置为自动关闭折叠
nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>
"用空格键来开关折叠
"zM 折叠所有代码
"zR 取消所有代码折叠
"zC 递归折叠代码
"zO 递归取消折叠
"[z ]z zj zk 移动

au BufNewFile,BufRead *.c,*.cpp,*.h
    \ set cindent

au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=79 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix |
    \ set encoding=utf-8 |
    \ let python_highlight_all=1

au BufNewFile,BufRead *.js,*.html,*.css
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2

"标识不必要的空白字符
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd BufWinEnter * match ExtraWhitespace /\s\+$\| \+\ze\t\+\|\t\+\zs \+/
```

## vim插件
### ctags
ctags网址：http://ctags.sourceforge.net/
1、安装:
`sudo apt-get install ctags`
2、生成索引文件:
去需要查找的目录执行:`ctags -R .`
3、配置vim`sudo vim /etc/vim/vimrc`
`set tags+=建立索引文件的目录/tags`
也可以临时添加索引：
`settags=建立索引文件的目录/tags`
4、使用
```
ctrl + ]        #跟进
Ctrl＋W + ］    #新窗口显示当前光标下单词的标签，光标跳到标签处
ctrl + o        #返回
ctrl + t        #返回

vi -t tag_name  #打开定义tag_name的文件，并把光标定位到这一行
ts + tag_name   #搜索tag_name
tp              #上一个
tn              #下一个
```

### cscope
cscope网址：http://cscope.sourceforge.net/
Cscope tutorial：http://cscope.sourceforge.net/cscope_vim_tutorial.html

1、安装cscope
`./configure --with-flex`
`make && sudo make install`
2、配置vim `sudo vi /etc/vim/vimrc` 添加以下内容
```
if has("cscope")

    """"""""""""" Standard cscope/vim boilerplate

    " use both cscope and ctag for 'ctrl-]', ':ta', and 'vim -t'
    set cscopetag

    " check cscope for definition of a symbol before checking ctags: set to 1
    " if you want the reverse search order.
    set csto=0

    " add any cscope database in current directory
    if filereadable("cscope.out")
        cs add cscope.out
    " else add the database pointed to by environment variable
    elseif $CSCOPE_DB != ""
        cs add $CSCOPE_DB
    endif

    " show msg when any other cscope db added
    set cscopeverbose


    """"""""""""" My cscope/vim key mappings
    "
    " The following maps all invoke one of the following cscope search types:
    "
    "   's'   symbol: find all references to the token under cursor
    "   'g'   global: find global definition(s) of the token under cursor
    "   'c'   calls:  find all calls to the function name under cursor
    "   't'   text:   find all instances of the text under cursor
    "   'e'   egrep:  egrep search for the word under cursor
    "   'f'   file:   open the filename under cursor
    "   'i'   includes: find files that include the filename under cursor
    "   'd'   called: find functions that function under cursor calls
    "
    " Below are three sets of the maps: one set that just jumps to your
    " search result, one that splits the existing vim window horizontally and
    " diplays your search result in the new window, and one that does the same
    " thing, but does a vertical split instead (vim 6 only).
    "
    " I've used CTRL-\ and CTRL-@ as the starting keys for these maps, as it's
    " unlikely that you need their default mappings (CTRL-\'s default use is
    " as part of CTRL-\ CTRL-N typemap, which basically just does the same
    " thing as hitting 'escape': CTRL-@ doesn't seem to have any default use).
    " If you don't like using 'CTRL-@' or CTRL-\, , you can change some or all
    " of these maps to use other keys.  One likely candidate is 'CTRL-_'
    " (which also maps to CTRL-/, which is easier to type).  By default it is
    " used to switch between Hebrew and English keyboard mode.
    "
    " All of the maps involving the <cfile> macro use '^<cfile>$': this is so
    " that searches over '#include <time.h>" return only references to
    " 'time.h', and not 'sys/time.h', etc. (by default cscope will return all
    " files that contain 'time.h' as part of their name).


    " To do the first type of search, hit 'CTRL-\', followed by one of the
    " cscope search types above (s,g,c,t,e,f,i,d).  The result of your cscope
    " search will be displayed in the current window.  You can use CTRL-T to
    " go back to where you were before the search.
    "

    nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>


    " Using 'CTRL-spacebar' (intepreted as CTRL-@ by vim) then a search type
    " makes the vim window split horizontally, with search result displayed in
    " the new window.
    "
    " (Note: earlier versions of vim may not have the :scs command, but it
    " can be simulated roughly via:
    "    nmap <C-@>s <C-W><C-S> :cs find s <C-R>=expand("<cword>")<CR><CR>

    nmap <C-@>s :scs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>g :scs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>c :scs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>t :scs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>e :scs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>f :scs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-@>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-@>d :scs find d <C-R>=expand("<cword>")<CR><CR>


    " Hitting CTRL-space *twice* before the search type does a vertical
    " split instead of a horizontal one (vim 6 and up only)
    "
    " (Note: you may wish to put a 'set splitright' in your .vimrc
    " if you prefer the new window on the right instead of the left

    nmap <C-@><C-@>s :vert scs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>g :vert scs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>c :vert scs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>t :vert scs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>e :vert scs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>f :vert scs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-@><C-@>i :vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-@><C-@>d :vert scs find d <C-R>=expand("<cword>")<CR><CR>


    """"""""""""" key map timeouts
    "
    " By default Vim will only wait 1 second for each keystroke in a mapping.
    " You may find that too short with the above typemaps.  If so, you should
    " either turn off mapping timeouts via 'notimeout'.
    "
    "set notimeout
    "
    " Or, you can keep timeouts, by uncommenting the timeoutlen line below,
    " with your own personal favorite value (in milliseconds):
    "
    "set timeoutlen=4000
    "
    " Either way, since mapping timeout settings by default also set the
    " timeouts for multicharacter 'keys codes' (like <F1>), you should also
    " set ttimeout and ttimeoutlen: otherwise, you will experience strange
    " delays as vim waits for a keystroke after you hit ESC (it will be
    " waiting to see if the ESC is actually part of a key code like <F1>).
    "
    "set ttimeout
    "
    " personally, I find a tenth of a second to work well for key code
    " timeouts. If you experience problems and have a slow terminal or network
    " connection, set it higher.  If you don't set ttimeoutlen, the value for
    " timeoutlent (default: 1000 = 1 second, which is sluggish) is used.
    "
    "set ttimeoutlen=100

endif
```
3、使用
建立一个cscope数据库:
`find . -name "*.h" -o -name "*.c" -o -name "*.cpp" > cscope.files`
`cscope -Rbkq -i cscope.files`
`ctags -R`
添加一个cscope链接库:
`:cs add cscope.out`
查找:
`:cs find s name` 查找
`:cw` 查看查找结果的列表
```
cscope -Rbkq
R 表示把所有子目录里的文件也建立索引
b 表示cscope不启动自带的用户界面，而仅仅建立符号数据库
q 生成cscope.in.out和cscope.po.out文件，加快cscope的索引速度
k 在生成索引文件时，不搜索/usr/include目录

：cs find s ---- 查找C语言符号，即查找函数名、宏、枚举值等出现的地方
：cs find g ---- 查找函数、宏、枚举等定义的位置，类似ctags所提供的功能
：cs find d ---- 查找本函数调用的函数
：cs find c ---- 查找调用本函数的函数
：cs find t ---- 查找指定的字符串
：cs find e ---- 查找egrep模式，相当于egrep功能，但查找速度快多了
：cs find f ---- 查找并打开文件，类似vim的find功能
：cs find i ---- 查找包含本文件的文
Ctrl+\ 可以代替 ：cs find

:cs show            #显示cscope的链接
:cs reset           #重新初始化所有的cscope链接
:cs kill            #杀掉一个cscope链接
:cs help            #显示一个简短的摘要
```

### vundle
Vundle地址：https://github.com/VundleVim/Vundle.vim
在vi中执行命令

```
:PluginList       - lists configured plugins
:PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
:PluginSearch foo - searches for foo; append `!` to refresh local cache
:PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
:h vundle         - more details
```

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



参考：

https://www.cnblogs.com/yangjig/p/6014198.html