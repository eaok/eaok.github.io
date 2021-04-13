[toc]

# 0x00 k8s介绍

单节点部署多个容器可以使用 docker-compose；而针对多节点的部署方案，docker-compose 无能为力，这时就要用到kubernetes。**k8s是一个跨主机集群的开源容器调度平台，可以自动化的应用容器的部署、扩展和操作，提供以容器为中心的基础架构。**



kubernetes官网 [kubernetes.io](https://kubernetes.io/zh/)

尝试使用 k8s的工具 [Play With k8s](https://labs.play-with-k8s.com/)

在线Kubernetes 试用集群 [Kubernetes Playground](https://www.katacoda.com/courses/kubernetes/playground)





## k8s应用场景

自动化运维平台

充分利用服务器资源

服务无缝迁移



服务部署模式的变迁：

> 物理机部署
>
> 虚拟化方式部署(openstack管理)
>
> 容器化方式部署(k8s管理)

SOA架构，微服务架构模式下，服务拆分越来越多，用k8s可以解决的问题

> 如何对服务进行横向扩展
>
> 容器宕机，数据怎么恢复
>
> 重新发布新的版本如何更新，更新后不影响业务
>
> 如何监控容器
>
> 容器如何调度创建
>
> 如何保证数据安全性





## 云相关概念

随着应用的规模变得越来越庞大，逻辑也越来越复杂，迭代更新也越来越频繁，这时就会有一些问题，比如：资源利用率低，迁移成本高，环境不一致；



Kubernetes 使用了声明式API，所谓声明式，就是指你只需要提交一个定义好的 API 对象来声明你所期望的对象是什么样子即可，而无须过多关注如何达到最终的状态。Kubernetes 可以在无外界干预的情况下，完成对实际状态和期望状态的调和（Reconcile）工作。



### 云

云就是使用容器构建的一套服务集群网络，由大量容器构成；k8s就是用来管理云中的容器的；



### 云架构

* iaas

  IaaS（Infrastructure as a Service，基础设施即服务）

  用户角度：租用云主机，不需要考虑网络，DNS，存储，硬件方面的问题；

  运营商角度：提供网络，DNS，存储，这样的服务就叫基础设施服务；

* pass

  PaaS（Platform as a Service，平台即服务）docker就是基于pass产生的一个容器技术

  MYSQL/ES/MQ...

* sass

  SaaS（Software as a Service，软件即服务）

  OA/钉钉/财务管理软件

* serverless 

  站在用户角度考虑，用户只需要使用云服务器即可，云服务器所有的基础环境和软件环境都不需要用户自己考虑；

  

### 云原生

为了让应用程序都运行在云上的解决方案，这样的方案就叫云原生；

云原生的特点：

* 容器化(所有服务都必须部署在容器中)
* 微服务(web服务架构是微服务)
* CI/CD(可持续交付/可持续部署)
* DevOps(开发和运维密不可分)



# 0x01 k8s架构

k8s 的架构借鉴了 Google 内部的大规模集群管理系统 Borg，整体上来说： k8s 包含两个部分：Master 节点， Node 节点。

![](https://cdn.jsdelivr.net/gh/eaok/img/docker/components-of-kubernetes.png)

**Master节点：**

- kube-apiserver: 负责提供 Kubernetes API 服务的组件，它是 Kubernetes 控制面的前端。
- kube-scheduler: 负责资源的调度，比如把部署的应用部署在哪个节点上
- kube-controller-manager: 负责集群的状态，比如故障诊断、自动扩展等
- cloud-controller-manager: 运行于特定云平台的控制回路。
- etcd: 保存集群的整个信息



**Node节点：**

- kubelet : 维护pod的生命周期，同时也负责存储和网络的管理。
- kube_proxy: 负责 Kubernetes 内部的服务通信，在主机上维护网络规则并提供转发及负载均衡能力；
- docker: 容器运行时
- fluentd: 日志收集服务
- pod: k8s管理的基本单元



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





# 0x03 K8s集群搭建

## kind

Kind，它的名字取自 Kubernetes IN Docker 的简写，Kind 最初仅仅是用来在 Docker 中搭建本地的 Kubernetes 开发测试环境，适合本地没有太多的物理资源的情况；

kind安装文档：https://kind.sigs.k8s.io/



## minikube

minikube是一款快速在本地电脑上开启一个虚拟机搭建kubernets单节点kubernetes集群的工具；

[安装 Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)

[安装 kubectl](https://kubernetes.io/zh/docs/tasks/tools/install-kubectl/)



用choco安装

```bash
choco install minikube			//会自动安装kubernetes-cli
choco install kubernetes-cli
```

查看kubectl版本

```bash
kubectl version
minikube version
```



创建kubectl配置文件

```bash
# 如果你在使用 cmd.exe，运行 cd %USERPROFILE%
cd ~
mkdir .kube
cd .kube
New-Item config -type file
```

启动minikube

```bash
minikube start --vm-driver=hyperv --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers

#查看minikube的运行状态
minikube status
```



Minikube 也支持和 Kind 相似的能力，直接利用 Docker 创建集群：

```bash
$ minikube start --driver=docker \
  --imageRepository=registry.cn-hangzhou.aliyuncs.com/google_containers \
  --imageMirrorCountry=cn 
```



参考

https://zhuanlan.zhihu.com/p/96005360



## Kubeadm

Kubeadm 是社区官方持续维护的集群搭建工具，它跟着 Kubernetes 的版本一起发布，目前 Kubeadm 代码放在 Kubernetes 的主代码库中。



Kubeadm文档：https://kubernetes.io/zh/docs/reference/setup-tools/kubeadm/kubeadm/



Kubeadm的优势如下：

> * Kubeadm 可以快速搭建出符合[一致性测试认证](https://www.cncf.io/certification/software-conformance/)（Conformance Test）的集群
> * Kubeadm 用户体验非常优秀，使用起来非常方便，并且可以用于搭建生产环境，支持[搭建高可用集群](https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/high-availability/)
> * Kubeadm 的代码设计**采用了可组合的模块方式**，所以你可以只使用 Kubeadm 的部分功能
> * **Kubeadm 可以向下兼容低一个小版本的 Kubernetes**，也就意味着，你可以用 v1.18.x 的 kubeadm 搭建 v1.17.y 版本的 Kubernetes
> * **kubeadm 还支持集群平滑升级到高版本**，即你可以使用 v1.17.x 版本的 Kubeadm 将 v1.16.y 版本的 Kubernetes 集群升级到 v1.17.z。



## 集群升级

Kubernetes 以 x.y.z 的格式来发布版本，其中 x 是主版本号（major version），y 是小版本号（minor version），而 z 是补丁版本号（patch version）；每隔三个月就会发布一个小版本，比如从 v1.18 到 v1.19。官方只会维护最新的三个小版本，比如目前最新的小版本是 v1.18，官方就只维护 v1.18、 v1.17 和 v1.16。



升级策略

* 永远升级到最高最新的版本。一般每次新的小版本出来后，比如 v1.19.0，通常会带有一些新功能，也隐含着一些 bug，我们可以等后续对应的补丁版本出来后再升级。

* 每半年升级一次，这样会落后社区 1~2 个小版本。等到各个小版本的补丁版本稳定后，再对集群做升级操作，这样比较保险。

* 一年升级一次小版本，或者更长。这样会导致集群落后社区太多，毕竟一年内社区会发布 4 个小版本。



集群升级的建议

* 最好通过“轮转+灰度”的升级策略来逐个集群升级。
* 升级前请务必备份所有重要组件及数据，例如 etcd 的数据备份、各组件的启动配置等。
* 千万不要跨小版本进行升级，比如直接把 Kubernetes 从 v1.16.x 的版本升到 v1.18.x 的版本。因为社区的一些 API 以及行为改动有些只会保留两个大版本，跨版本升级很容易导致集群故障。
* 注意观察容器的状态，避免引发某些有状态业务发生异常。在 v1.16 版本以前，升级的时候，如果 Pod spec 的哈希值已更改，则会引发 Pod 重建。
* 每次升级之前，切记一定要认真阅读官方的 release note，重点关注中间的 highlight 说明，一般文档中会注明哪些变化会对集群升级产生影响。
* 谨慎使用还在 alpha 阶段的功能。社区迭代的时候，这些 alpha 阶段的功能会随时发生变化，比如启动参数、配置方式、工作模式等等。甚至有些 alpha 阶段的功能会被下线掉。



社区推荐的集群升级基本流程：先升级主控制平面节点，再升级其他控制平面节点，最后升级工作节点。



Kubeadm集群升级文档：https://kubernetes.io/zh/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/





# 0x04 pod

Kubernetes中的不可变基础设施就是 Pod。Pod 由一个或多个容器组成，如下图所示。Pod 中的容器不可分割，会作为一个整体运行在一个 Node 节点上，也就是说 Pod 是你在 Kubernetes 中可以创建和部署的最原子化的单位。

![](https://cdn.jsdelivr.net/gh/eaok/img/docker/module_03_pods.png)

使用一个新的逻辑对象 Pod 来管理容器，可以在不重载容器信息的基础上，添加更多的属性，而且也方便跟容器运行时进行解耦，兼容度高。比如：

- 存活探针（Liveness Probe）可以从应用程序的角度去探测一个进程是否还存活着，在容器出现问题之前，就可以快速检测到问题；
- 容器启动后和终止前可以进行的操作，比如，在容器停止前，可能需要做一些清理工作，或者不能马上结束进程；
- 定义了容器终止后要采取的策略，比如始终重启、正常退出才重启等；



在一个 Pod 内运行多个容器，比较适应于以下这些场景：

* 容器之间会发生文件交换等，比如一个写文件，一个读文件。
* 容器之间需要本地通信，比如通过 localhost 或者本地的 Socket。
* 容器之间需要发生频繁的 RPC 调用，出于性能的考量，将它们放在一个 Pod 内。
* 希望为应用添加其他功能，比如日志收集、监控数据采集、配置中心、路由及熔断等功能。这时候可以考虑利用边车模式（Sidecar Pattern），既不需要改动原始服务本身的逻辑，还能增加一系列的功能。比如 Fluentd 就是利用边车模式注入一个对应 log agent 到 Pod 内，用于日志的收集和转发。 Istio 也是通过在 Pod 内放置一个 Sidecar 容器，来进行无侵入的服务治理。



## 如何声明一个 Pod

在 Kubernetes 中，所有对象都可以通过一个相似的 API 模板来描述，即**元数据 （metadata）**、**规范（spec）**和**状态（status）**。Kubernetes 有了这种统一风格的 API 定义，方便了通过 REST 接口进行开发和管理。



### 元数据（metadata）

metadata 中一般要包含如下 3 个对该对象至关重要的元信息：namespace（命名空间）、name（对象名）和 uid（对象 ID）。

* **namespace** 是对一组资源和对象的抽象集合，主要用于逻辑上的隔离。Kubernetes 中有几个内置的 namespace：
  * **default**，这是默认的缺省命名空间；
  * **kube-system**，主要是部署集群最关键的核心组件，比如一般会将 CoreDNS 声明在这个 namespace 中；
  * **kube-public**，是由 kubeadm 创建出来的，主要是保存一些集群 bootstrap 的信息，比如 token 等；
  * **kube-node-lease**，它用于 node 汇报心跳，每一个节点都会有一个对应的 Lease 对象。

* **name** 用来标识对象的名称，在 namespace 内具有唯一性，在不同的 namespace 下，可以创建相同名字的对象。
* **uid** 是由系统自动生成的，主要用于 Kubernetes 内部标识使用，比如某个对象经历了删除重建，单纯通过名字是无法判断该对象的新旧，这个时候就可以通过 uid 来进行唯一确定。



kubernetes 中并不是所有对象都是 namespace 级别的，还有一些对象是集群级别的，并不需要 namespace 进行隔离，比如 Node 资源等。除此以外，还可以在 metadata 里面用各种标签 （labels）和注释（annotations）来标识和匹配不同的对象，比如用户可以用标签`env=dev`来标识开发环境，用`env=testing`来标识测试环境。



### 规范 （Spec）

描述了该对象的详细配置信息，Kubernetes 中的各大组件会根据这个配置进行一系列的操作，将这种定义从“抽象”变为“现实”。



### 状态（Status）

包含了该对象的一些状态信息，会由各个控制器定期进行更新。



## 一个 Pod 的例子

Yaml 中一个 Pod 的定义：

```yaml
apiVersion: v1 #指定当前描述文件遵循v1版本的Kubernetes API
kind: Pod #我们在描述一个pod
metadata:
  name: twocontainers #指定pod的名称
  namespace: default #指定当前描述的pod所在的命名空间
  labels: #指定pod标签
    app: twocontainers
  annotations: #指定pod注释
    version: v0.5.0
    releasedBy: david
    purpose: demo
spec:
  containers:
  - name: sise #容器的名称
    image: quay.io/openshiftlabs/simpleservice:0.5.0 #创建容器所使用的镜像
    ports:
    - containerPort: 9876 #应用监听的端口
  - name: shell #容器的名称
    image: centos:7 #创建容器所使用的镜像
    command: #容器启动命令
      - "bin/bash"
      - "-c"
      - "sleep 10000"
```

通过 kubectl 命令在集群中创建这个 Pod：

```shell
$ kubectl create -f ./twocontainers.yaml
kubectl get pods
NAME                      READY     STATUS    RESTARTS   AGE
twocontainers             2/2       Running   0          7s
```

通过 exec 进入shell这个容器，来访问sise服务：

```shell
$ kubectl exec twocontainers -c shell -i -t -- bash
[root@twocontainers /]# curl -s localhost:9876/info
{"host": "localhost:9876", "version": "0.5.0", "from": "127.0.0.1"}
```



副本控制器

ReplicaSet & ReplicationController 前者支持单选和复选，后者只能单选，作用是控制pod副本的数量；



部署对象 Deployment

![](https://cdn.jsdelivr.net/gh/eaok/img/docker/k8sDeployment.png)

​	服务部署结构模型

​	滚动更新



StatefulSet 为了解决有状态服务使用容器化部署的问题

​	部署模型

​	有状态服务



通常情况下，Deployment部署模型用来部署无状态服务，有状态服务要使用StatefulSet来部署；

有状态服务

​	有实时的数据需要存储

​	有状态服务集群中，把某一个服务抽离出去，一段时间后再加入网络，集群网络无法使用；

无状态服务

​	没有实时的数据需要存储

​	无状态服务集群中，把某一个服务抽离出去，一段时间后再加入网络，集群网络没有影响；	



StatefulSet 保证Pod重建后，hostname不会发生变化，Pod就可以通过hostname来关联数据；



Service

Service资源对象

* POD IP Pod的ip地址
* NODE IP 物理机的ip地址
* cluster IP 虚拟ip，service对象就是一个VIP的资源对象



service和一组Pod副本是通过标签选择器进行关联的；kube-proxy会监听所有Pod，一旦Pod发生变化，就会更新ETCD中保存的endpoints，也就是ip映射表；service使用iptables和ipvs来做数据分发；