[toc]

# 安装

官网地址：https://www.electronjs.org/

文档地址：https://www.electronjs.org/docs



## npm

安装npm，npm是随同NodeJS一起安装的包管理工具

```shell
wget https://nodejs.org/dist/v14.17.0/node-v14.17.0-linux-x64.tar.xz
sudo tar -xvf node-v14.17.0-linux-x64.tar.xz -C /usr/local/
sudo ln -s /usr/local/node-v14.17.0-linux-x64/bin/node /usr/local/bin/node
sudo ln -s /usr/local/node-v14.17.0-linux-x64/bin/npm /usr/local/bin/npm
node -v
npm -v
```



npm常用指令

```shell
# 安装模块
npm i/install moduleName安装模块；i是install的缩写，两者功能是一样的
npm i moduleName@0.0.1 安装模块的指定版本
npm i moduleName --save 安装并保存至package.json文件的dependencies中
npm i moduleName --save-dev 安装并保存至package.json文件的devDependencies中
npm i moduleName -g 全局安装模块

# 查看已安装模块
npm ls 查看所有局部安装的模块
npm ls -g 查看所有全局安装的模块
npm ls moduleName 查看指定模块的局部安装情况
npm ls moduleName -g 查看指定模块的全局安装情况
npm view moduleName 查看当前源中指定模块的信息
npm view moduleName versions 查看当前源中指定模块的所有历史版本
npm view moduleName version 查看当前源中指定模块的最新版本

# 卸载模块
npm uninstall moduleName 卸载指定模块

# 更新模块
npm update 按照package.json中的描述更新模块，且会在package.json文件中保存更新后的版本描述；^a.b.c更新至a下的最新版本，~a.b.c更新至a.b下的最新版本，a.b.c不会做任何更新
npm update moduleName 更新指定模块
npm源查看与修改
npm config get registry #查看当前npm源地址
npm config set registry https://registry.npm.taobao.org #将npm源设置成淘宝镜像

# 万能的help
npm help 当忘记了相应命令后，查看帮助
```







## 安装electron

```shell
npm install electron --save-dev
```

