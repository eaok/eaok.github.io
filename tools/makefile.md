[toc]

# 变量

makefile中的变量只有一种类型，字符串；

## 简单变量

`:=` 表示变量的值决定于它在makefile中的位置，而不是整个makefile展开后的最终值。

```makefile
x := foo
y := $(x) bar
x := xyz

#在上例中，y的值将会是 foo bar ，而不是 xyz bar 了。
```

`?=`表示如果没有被赋值过就赋予等号后面的值



## 递归定义变量

`=` make会将整个makefile展开后，再决定变量的值。也就是说，变量的值将会是整个makefile中最后被指定的值。

```bash
x = foo
y = $(x) bar
x = xyz

#在上例中，y的值将会是 xyz bar ，而不是 foo bar 。
```



## 预定义变量

```makefile
CC = gcc
CFLAGS = -Wall -g -o0
```



自动化变量

| 变量 | 说明                                         |
| :--: | -------------------------------------------- |
|  $@  | 表示规则中的目标文件集                       |
|  $^  | 所有的依赖目标的集合                         |
|  $%  | 当目标是函数库文件中，表示规则中的目标成员名 |
|  $<  | 依赖目标中的第一个目标                       |
|  $?  | 所有比目标新的依赖目标的集合                 |



# make命令参数

| 参数 | 说明                       |
| :--: | -------------------------- |
|  -f  | 指定文件作为Makefile       |
|  -n  | 显示要执行的命令，但不执行 |
|  -s  | 执行命令时不显示           |



# 符号

| 符号 | 说明                                               |
| :--: | :------------------------------------------------- |
|  @   | 命令不回显示                                       |
|  -   | 忽略错误继续执行                                   |
|  $   | 展开makefile中定义的变量                           |
|  $$  | 展开makefile中定义的shell变量，比如for循环中会用到 |



# 模板

```makefile
%.o:%.c
	$(CC) $(CFLAGS) -c -o $@ @^
```



# 循环

语法格式：

```makefile
#foreach循环
$(foreach VAR,LIST,\
  CMD 1;\
  CMD 2;\
)

#for循环
for VAR in LIST; do \
  CMD 1; \
  CMD 2; \
done
```

两种方法的区别，for循环不支持函数运算，例如：

```makefile
SOURCE:=a.c b.c

all: testfor testforeach

testfor:
    @# LIST use variable
    @for var in $(SOURCE); do \
        echo $$var; \
        echo $(subst .c,.txt,$$var); \
    done

testforeach:
    @$(foreach var,$(SOURCE),\
        echo $(var); \
        echo $(subst .c,.txt,$(var)); \
    )
```





# 函数

函数调用方式

```makefile
#以“$”来标识，参数间以逗号“,”分隔，而函数名和参数之间以“空格”分隔。
$(<function> <arguments>)
或是
${<function> <arguments>}
```



## wildcard

匹配指定规则的文件列表，例如可以使用“$(wildcard *.c)”来获取工作目录下的所有的.c文件列表；复杂一些用法，可以使用“$(patsubst %.c,%.o,$(wildcard *.c))”，例如：

```makefile
objects := $(patsubst %.c,%.o,$(wildcard *.c))

foo : $(objects)
	cc -o foo $(objects)
```



patsubst

替换通配符，语法格式为

```makefile
$(patsubst %.c, %.o, $(dir))

#也可以用替换引用规则，效果一样
$(dir:%.c=%.o)
${dir:%.c=%.o}
```





notdir

去除路径，例如`$(notdir $(src))`



例子：

```makefile
#.
#├── a.c
#├── b.c
#└── sub
#    ├── sa.c
#    └── sb.c

src=$(wildcard *.c ./sub/*.c)
dir=$(notdir $(src))
obj=$(patsubst %.c,%.o,$(dir) )

all:
	#a.c b.c ./sub/sa.c ./sub/sb.c
	@echo $(src)
	
	#a.c b.c sa.c sb.c
	@echo $(dir)
	
	#a.o b.o sa.o sb.o
	@echo $(obj)
	@echo "end"
```





参考

[https://wiki.ubuntu.org.cn/%E8%B7%9F%E6%88%91%E4%B8%80%E8%B5%B7%E5%86%99Makefile:%E4%B9%A6%E5%86%99%E8%A7%84%E5%88%99](https://wiki.ubuntu.org.cn/跟我一起写Makefile:书写规则)

