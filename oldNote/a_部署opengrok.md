---
title: 部署opengrok
date: 2016-11-27 15:30:55
tags: opengrok
categories: [tool]

---

OpenGrok地址：https://github.com/OpenGrok/OpenGrok

## ubuntu平台

### 安装jdk
java：http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
`sudo tar xvf jdk-8u112-linux-x64.tar.gz -C /opt/`
`sudo vi /etc/profile`
<!-- more -->
```
export JAVA_HOME=/opt/jdk1.8.0_112
export JRE_HOME=$JAVA_HOME/jre
export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH
```
`source /etc/profile`   使配置生效
`java -version` 测试
`javac` 测试

### 安装tomcat
tomcat：http://tomcat.apache.org/download-90.cgi
`sudo tar xvf apache-tomcat-9.0.0.M13.tar.gz -C /opt/`
`cd /opt`
`sudo mv apache-tomcat-9.0.0.M13 apache-tomcat`
`sudo chown ubuntu:ubuntu apache-tomcat -R`

`sudo vi bin/startup.sh`    #在最后一行上面添加
`sudo vi ./bin/shutdown.sh` #在最后一行上面添加
```
JAVA_HOME=/opt/jdk1.8.0_112
JRE_HOME=$JAVA_HOME/jre
PATH=$JAVA_HOME/bin:$PATH
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
CATALINA_HOME=/opt/apache-tomcat
```

启动tomcat ：
`sudo ./bin/startup.sh`

验证tomcat配置和安装是否成功
`localhost:8080/`
`ip:8080`

关闭tomcat：
`sudo ./bin/shutdown.sh`

修改端口
`sudo vi apache-tomcat/conf/server.xml`

### 安装ctags
ctags： https://ctags.io/
`git clone https://github.com/universal-ctags/ctags`
`cd ctags/`
`sudo apt-get install autoconf automake libtool`
`./autogen.sh`
`./configure`
`make && make install`


### 安装opengrok
下载地址：https://github.com/OpenGrok/OpenGrok/releases
`sudo tar xvf opengrok-0.13-rc4.tar.gz -C /opt/`
`cd /opt`
`sudo mv opengrok-0.13-rc4 opengrok`
`sudo chown ubuntu:ubuntu opengrok -R`

`sudo mkdir -p index/src`
`sudo ln -s /opt/opengrok/bin/OpenGrok /user/bin/opengrok`

**OpenGrok的配置**
`sudo vi opengrok/bin/OpenGrok`
```
LOGGER_CONF_SOURCE=/opt/opengrok/doc/logging.properties
OPENGROK_DISTRIBUTION_BASE=/opt/opengrok/lib
OPENGROK_INSTANCE_BASE=/opt/opengrok/index      #产生索引的位置
OPENGROK_TOMCAT_BASE=/opt/apache-tomcat
EXUBERANT_CTAGS=/usr/local/bin/ctags
JAVA_HOME=/opt/jdk1.8.0_112
```

**创建索引**
`./bin/OpenGrok index <absolute_path_to_your_SRC_ROOT>`
**部署**
`./bin/OpenGrok deploy`

`sudo cp /opt/opengrok/lib/source.war /opt/apache-tomcat/webapps/xxx.war`
修改自解压后文件夹中`WEB-INF/web.xml`对应的路径
```
   <context-param>
     <description>Full path to the configuration file where OpenGrok can read its configuration</description>
     <param-name>CONFIGURATION</param-name>
     <param-value>/opt/opengrok/index/etc/configuration.xml</param-value>
   </context-param>
```

`index/src`中可以放源码，但是放源码的符号链接就会出现各种问题
