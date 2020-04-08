[toc]

# 0x00 k8s介绍

单节点部署多个容器可以使用 docker-compose；而针对多节点的部署方案，docker-compose 无能为力，这时就要用到kubernetes。**k8s是一个跨主机集群的开源容器调度平台，可以自动化的应用容器的部署、扩展和操作，提供以容器为中心的基础架构。**



kubernetes官网 [kubernetes.io](https://kubernetes.io/)

尝试使用 k8s的工具 [Play With k8s](https://labs.play-with-k8s.com/)





# 0x01 k8s架构

k8s 的架构借鉴了 Google 内部的大规模集群管理系统 Borg，整体上来说： k8s 包含两个部分：Master 节点， Node 节点。

<img src="http://blog.maser.top/web/docker/k8sFramework.jpg" style="zoom:30%;" />

**就 Master 而言包含，其包含4个部分：**

- APIServer: 内部的 web 服务，资源操作的入口
- Scheduler: 调度器：负责资源的调度，比如把部署的应用部署在哪个节点上
- Controller manager 负责集群的状态，比如故障诊断、自动扩展等
- etcd 保存集群的整个信息



**就 Node 节点而言，主要包含：**

- kubelet : 节点代理，维护容器的生命周期（整个操作过程中，我们都不太会显式的操作 kubelet)
- kube_proxy: 转发代理，负责服务的发现和负载均衡
- docker: 容器



# 0x02 集群部署

1. master节点

   ```bash
   kubeadm init --apiserver-advertise-address $(hostname -i)
   ```

2. 网络初始化

   ```bash
   kubectl apply -n kube-system -f  "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
   ```

   

3. 获取配置文件

   ```bash
   mkdir -p $HOME/.kube
   cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   chown $(id -u):$(id -g) $HOME/.kube/config
   ```



安装部署依赖这几个软件：

- kubeadm: 一键式的安装部署集群的工具，社区推荐
- kubelet: 维护容器生命周期
- docker: 操作容器
- kubectl: 操作集群的命令行工具



安装部署后其中有几个目录值得我们关注下：

```bash
// master 节点
>> ls /etc/kubernetes

admin.conf  controller-manager.conf  kubelet.conf  manifests  pki  scheduler.conf

>> ls manifests
etcd.yaml  kube-apiserver.yaml  kube-controller-manager.yaml  kube-scheduler.yaml

>> ls pki
apiserver-etcd-client.crt
apiserver-etcd-client.key
apiserver-kubelet-client.crt
apiserver-kubelet-client.key
apiserver.crt
apiserver.key
ca.crt
ca.key
etcd
front-proxy-ca.crt
front-proxy-ca.key
front-proxy-client.crt
front-proxy-client.key
sa.key
sa.pub
```

k8s 安装组件，是使用配置文件的形式，一般选择 yaml 的形式



查看节点信息：

```bash
>> kubectl get nodes
NAME    STATUS   ROLES    AGE   VERSION
node1   Ready    <none>   15m   v1.14.9
node2   Ready    master   16m   v1.14.9

#包含两个节点，其中一个角色是 master 节点，另一个是普通 node 节点。
```



# 0x03 minikube

minikube是一款快速在本地笔记本电脑上开启一个虚拟机搭建kubernets单节点kubernetes集群的工具；

[Install Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)

[Minikube的安装](https://yq.aliyun.com/articles/691500)



参考

https://zhuanlan.zhihu.com/p/96005360