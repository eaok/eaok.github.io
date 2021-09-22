

过滤规则

过滤源ip、目的ip

```
ip.dst==192.168.101.8		#查找目的地址为192.168.101.8的包
ip.src==1.1.1.1				#查找源地址为1.1.1.1的包
```

端口过滤。

```bash
tcp.port==80
tcp.dstport==80			#只过滤目的端口为80的
tcp.srcport==80			#只过滤源端口为80的包
```

协议过滤

```bash
http
```

http模式过滤

```bash
http.request.method=="GET"			#过滤get包
http.request.method=="POST"			#过滤post包
```

连接符and的使用

```bash
ip.src==192.168.101.8 and http		#过滤ip为192.168.101.8并且为http协议的
```

