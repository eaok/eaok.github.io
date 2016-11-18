---
title: 用hexo搭建github博客
date: 2016-9-29 20:19:57
tags: [hexo,npm]
categories: [linux,hexo]

---

### 安装hexo
Hexo官网 https://hexo.io/zh-cn/

安装Node.js npm git-core
`npm install hexo-deployer-git --save`
安装 hexo
`npm install -g hexo-cli`
<!-- more -->
### 使用hexo
#### 生成文件
`hexo init hexo`
`cd hexo`
`npm install`
`sudo apt-get install nodejs npm git`
安装 hexo-deployer-git，否则会报 ERROR Deployer not found: git 的错误。
#### hexo命令
```
hexo new "postName"		#新建文章
hexo new page "pageName"	#新建页面
hexo generate			#生成静态页面至public目录
hexo server			#开启预览访问端口（默认端口4000）
hexo deploy			#将.deploy目录部署到GitHub
hexo help			#查看帮助
hexo version			#查看Hexo的版本

#命令的简写为：
hexo n == hexo new
hexo g == hexo generate
hexo s == hexo server
hexo d == hexo deploy

hexo d -g		#生成加部署
hexo s -g		#生成加预览，localhost:4000，查看搭建效果

hexo clean && hexo d -g #部署
```
#### 部署到Github和Coding上
在Github和Coding上添加密匙，设置好终端中的用户名和邮箱，测试是否连接成功
`git config --global user.name "Your Name"`
`git config --global user.email "email@example.com"`
`ssh-keygen -t rsa -C "youremail@example.com"` 把~/.ssh/id_rsa.pub的内容添加到网站上
`ssh -T git@git.coding.net`
`ssh -T git@github.com`
修改_config.yml文件
```
# Deployment
## Docs: http://hexo.io/docs/deployment.html
deploy:
- type: git
  repo: git@github.com:kcoewoys/kcoewoys.github.io.git
  branch: master
- type: git
  repo: git@git.coding.net:kcoewoys/kcoewoys.git
  branch: master
```
#### 绑定域名
先到阿里云上申请一个域名，top域名第一年只要2块钱，解析设置如图：
![万网解析设置](http://ofat4idzj.bkt.clouddn.com/%E4%B8%87%E7%BD%91%E8%A7%A3%E6%9E%90%E8%AE%BE%E7%BD%AE.png)
github实现域名绑定，需要在项目根目录有一个CNAME文件，为此，在hexo/source/下新建一个CNAME文件，内容为你要绑定的域名。
coding实现域名绑定，需要到项目里面进行设置，如图：
![coding page 设置](http://ofat4idzj.bkt.clouddn.com/coding%20page%20%E8%AE%BE%E7%BD%AE.png)
#### git管理
新建一个hexo分支，用于保存源文件，并将github上的hexo分支设为默认分支;
git clone默认会把远程仓库整个给clone下来,但只会在本地默认创建一个默认分支
`git branch -r`    查看远程分支
`git branch -a`    查看所有分支
建立本地对应分支
`git checkout --track origin/hexo`
`git checkout -b hexo origin/hexo`
`git checkout origin/hexo`
推送分支
`git push origin hexo`
撤销本地所有的修改
`git checkout . && git clean -xdf`

### 使用主题和一些修改
hexo的可用主题 https://hexo.io/themes/
next主题网站 http://theme-next.iissnan.com/
`git clone https://github.com/iissnan/hexo-theme-next.git themes/next`
修改配置文件 _config.yml
`theme: next`
```
next\source\css\_variables\base.styl			#修改颜色变量
next\source\css\_custom\custom.styl			#自定义
next\source\css\_common\components\sidebar\sidebar.styl	#修改侧边栏
next\source\css\_common\components\highlight\theme.styl #修改代码主题
```
**添加背景动画**
编辑`next/layout/_layout.swig`，在`</body>`标签上方添加
```
<script type="text/javascript" color="20,20,20" opacity='0.6' zIndex="-2" count="100" src="//cdn.bootcss.com/canvas-nest.js/1.0.0/canvas-nest.min.js"></script>
```
**添加点击导航栏外面自动关闭**
编辑`\source\js\src\motion.js`，在倒数第二行添加js方法
```
// $('.sidebar-inner').css({'height':'100%'});
$('body').on('click',function(e){
    var bSidebarShow = $('#sidebar').css('display')==='block' && $('#sidebar').width() > 0;
    var bFlag = $(e.target).parents('#sidebar,.sidebar-toggle').length > 0;
    if(bSidebarShow && !bFlag){
          $('.sidebar-toggle-line-wrap').trigger('click');
          e.preventDefault();
    }
});
```
**添加网易云音乐**
编辑`next/layout/_macro/sidebar.swig`，在`theme.links`下一段添加外链播放器代码
```
<iframe frameborder="no" border="0" marginwidth="0" marginheight="0" width=330 height=86 src="http://music.163.com/outchain/player?type=2&id=493911&auto=0&height=66"></iframe>
```

### 本地调试
`hexo s -s -i 192.168.60.222 &`		在后台开启服务
`hexo clean && hexo g`			每次修改后执行，在浏览器可以查看变化

### npm相关
```
npm安装
wget https://npmjs.org/install.sh
sudo chmod 777 install.sh & ./install.sh

npm install -g nrm	//安装npm源管理器nrm
nrm ls			//列出可选的源
nrm test		//测试所有源的响应时间
nrm test npm		//测试当前源的响应时间
nrm use taobao		//切换到taobao

npm install pkg 			//本地安装
npm install -g pkg 			//全局安装
npm uninstall pkg 			//卸载
npm remove pkg 				//移除
npm update pkg 				//package更新
npm search pkg 				//搜索

npm ls				//查看安装了哪些包
npm root 			//查看当前包的安装路径
npm root -g 			//查看全局的包的安装路径
npm help 			//帮助，如果要单独查看install命令的帮助，可以使用的npm help install
npm install --help 		//列出所有 npm install 可能的参数形式

npm set proxy 127.0.0.1:8123 	//设置proxy
npm get proxy 			//查看proxy
npm config delete proxy		//删除proxy

npm install 			//方法就可以根据package.json安装所有的依赖包
npm install pkg--save 		//安装的同时将信息写入package.json中项目路径中
```
