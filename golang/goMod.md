[toc]



# 0x00 go mod 命令

```
go mod help
    download    下载依赖的module到本地cache
    edit        编辑go.mod文件
    graph       打印模块依赖图
    init        在当前文件夹下初始化一个新的module, 创建go.mod文件
    tidy        增加丢失的module，去掉未用的module
    vendor      将依赖复制到vendor下
    verify      校验依赖
    why         解释为什么需要依赖
```



# 0x01 设置 GO111MODULE

* GO111MODULE=off 无模块支持，go 会从 GOPATH 和 vendor 文件夹寻找包。
* GO111MODULE=on 模块支持，忽略 GOPATH 和 vendor，只根据 go.mod 下载依赖。
* GO111MODULE=auto 在 GOPATH/src 外面且根目录有 go.mod 文件时，开启模块支持。
> 在使用模块的时候，下载的依赖储存在 GOPATH/pkg/mod 中，go install 的结果放在 $GOPATH/bin 中。Mod Cache 路径在GOPATH/pkg/mod/cache下面。



# 0x02 使用go mod

1 创建go.mod文件
> go mod init github.com/kcoewoys/project

2 根据go.mod文件来处理依赖关系
> go mod tidy   
生成go.sum,并且会更新go.mod

3 replace
> 在国内访问golang.org/x的各个包都需要翻墙，我们可以在go.mod中使用replace替换成github上对应的库。
```
replace (
    golang.org/x/crypto v0.0.0-20180820150726-614d502a4dac => github.com/golang/crypto v0.0.0-20180820150726-614d502a4dac
    golang.org/x/net v0.0.0-20180821023952-922f4815f713 => github.com/golang/net v0.0.0-20180826012351-8a410e7b638d
    golang.org/x/text v0.3.0 => github.com/golang/text v0.3.0
)
```

4 引入本地包的方法
```
require (
    test v0.0.0
)

replace (
    test => ../test
)

注意:1.引入的包必须也是gomod的(有.mod文件)
     2.replace时必须使用相对路径比如../ ./
     3.require 的包后必须带版本号,replace中可带可不带
```

go mod 代理
```
export GOPROXY=https://mirrors.aliyun.com/goproxy/
export GOPROXY=https://goproxy.io
```



# 0x03 工作区

项目目录如下

```
workspace-demo
├── project
│   ├── go.mod      // 项目模块,mod子模块
│   └── main.go
├── go.work         // 工作区,work上层模块
└── tools
    ├── fish.go
    └── go.mod      // 工具模块,mod子模块
```



初始化工作区

```shell
# 新建工作区文件夹
mkdir workspace-demo
cd workspace-demo

# 克隆项目 project 和开发的模块 tools, 这里仅作参考,请替换为合适的 git 仓库
git clone https://github.com/me/project
git clone https://github.com/me/tools

# 初始化工作区
go work init ./project ./tools
```



修改 go.work 并且 replace 远程 tools 模块到本地

```go
go 1.18

use (
        ./project
        ./tools
)

//修改远程模块为本地替换
replace github.com/me/tools => ./tools
```

