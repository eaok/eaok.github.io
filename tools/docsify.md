# docsify文档生成工具
## 安装npm
* 下载安装包
> https://nodejs.org/zh-cn/download/

* 解压安装
> linux: https://github.com/nodejs/help/wiki/Installation

* 更换淘宝镜像
> - npm config get registry // https://registry.npmjs.org/
> - npm config set registry https://registry.npm.taobao.org

## 安装docsify
* docsify网址：
> https://docsify.js.org

* 中文安装文档：
> https://docsify.js.org/#/zh-cn/quickstart

* 基本操作:

```bash
sudo npm i docsify-cli -g   #安装
docsify init ./docs         #初始化文件夹
docsify serve -p 8890       #开启服务
```

* 每个页面和URL路径说明：

```bash
#如果你的目录结构如下：
-| ./
  -| README.md
  -| guide.md
  -| zh-cn/
    -| README.md
    -| guide.md

#那么对应的访问页面将是:
./README.md => http://domain.com
./guide.md => http://domain.com/guide
./zh-cn/README.md => http://domain.com/zh-cn/
./zh-cn/guide.md => http://domain.com/zh-cn/guide
```
