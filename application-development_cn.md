# 应用开发（Application development）

Kubernetes 上应用开发的最佳实践（Best practices for application development on Kubernetes）

## 健康检查（Health checks）

Kubernetes 提供了两种机制来跟踪容器和 Pod 的生命周期：**存活探针** 和**就绪探针**（Kubernetes offers two mechanisms to track the lifecycle of your containers and Pods: **liveness** and **readiness** probes）。

**就绪探针决定容器何时可以接收流量（The readiness probe determines when a container can receive traffic）。**

kubelet 执行相关检查，并决定应用是否可以接收流量（The kubelet executes the checks and decides if the app can receive traffic or not）。

**存活探针决定何时应该重启容器（The liveness probe determines when a container should be restarted）。**

kubelet 执行相关检查，并决定是否应该重启容器（The kubelet executes the check and decides if the container should be restarted）。

**资源（Resources）:**

- 官方 Kubernetes 文档提供了一些实用建议，介绍如何配置存活、就绪和启动探针（The official Kubernetes documentation offers some practical advice on how to [configure Liveness, Readiness and Startup Probes）](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)）。
- [存活探针设置不当可能很危险（Liveness probes are dangerous）](https://srcco.de/posts/kubernetes-liveness-probes-are-dangerous.html) 提供了如何设置（或不设置）就绪探针中的依赖项的一些信息（has some information on how to set (or not) dependencies in your readiness probes）。

### 具有就绪探针的容器（Containers have Readiness probes）

> 请注意，就绪和存活探针没有默认值（Please note that there's no default value for readiness and liveness）。

如果我们没有设置就绪探针，kubelet 假定应用一旦容器启动就可以接收流量（If you don't set the readiness probe, the kubelet assumes that the app is ready to receive traffic as soon as the container starts）。

如果容器启动需要 2 分钟，那么在这 2 分钟内所有请求都会**失败**（If the container takes 2 minutes to start, all the requests to it will fail for those 2 minutes）。

### 容器因为发生致命错误崩溃时（Containers crash when there's a fatal error）

如果应用程序遇到到无法恢复的错误时，我们应该让它崩溃（If the application reaches an unrecoverable error, [you should let it crash](https://blog.colinbreck.com/kubernetes-liveness-and-readiness-probes-revisited-how-to-avoid-shooting-yourself-in-the-other-foot/#letitcrash) ）。

无法恢复的错误包括（Examples of such unrecoverable errors are）：

- 一个未捕获的异常（an uncaught exception）
- 动态代码中的一个错别字（a typo in the code (for dynamic languages)）
- 无法加载头文件或依赖项（unable to load a header or dependency）

请注意，我们不应让存活探针发出失败的信号（Please note that you should not signal a failing Liveness probe）。

相反，我们应立即退出进程，让 kubelet 重启容器（Instead, you should immediately exit the process and let the kubelet restart the container）。

### 配置被动存活探针（Configure a passive Liveness probe）

存活探针旨在在容器卡住时重启容器（The Liveness probe is designed to restart your container when it's stuck）。

考虑以下场景：如果我们的应用程序正在处理一个无限循环，因此没有办法退出或请求帮助（Consider the following scenario: if your application is processing an infinite loop, there's no way to exit or ask for help）。

当进程消耗 100% 的 CPU 时，它不会有时间响应（其他）就绪探针检查，最终将被从 Kubernetes 的服务中剔除（When the process is consuming 100% CPU, it won't have time to reply to the (other) Readiness probe checks, and it will be eventually removed from the Service）。

然而，Pod 仍然被注册为当前部署的活跃副本（However, the Pod is still registered as an active replica for the current Deployment）。

如果没有存活探针，Pod 就会处于 _Running_ 状态，但实际上已经从 Service 列表中被剔除（If you don't have a Liveness probe, it stays _Running_ but detached from the Service.）

换句话说，不仅进程不处理任何请求，而且还消耗资源（In other words, not only is the process not serving any requests, but it is also consuming resources）。

_我们应该做什么？_（_What should you do?_）

1. 从我们的应用程序公开一个端点（Expose an endpoint from your app）
1. 端点总是回复成功响应（The endpoint always replies with a success response）
1. 从存活探针中使用该端点（Consume the endpoint from the Liveness probe）

请注意，我们不应使用存活探针来处理应用程序中的致命错误，并请求 Kubernetes 重启应用（Please note that you should not use the Liveness probe to handle fatal errors in your app and request Kubernetes to restart the app）。

相反，我们应该让应用程序崩溃（Instead, you should let the app crash）。

存活探针应仅在进程无响应时用作恢复机制（The Liveness probe should be used as a recovery mechanism only in case the process is not responsive）。

### 存活探针的值与就绪探针不同（Liveness probes values aren't the same as the Readiness）

当存活和就绪探针指向同一端点时，探针的效果会组合起作用（When Liveness and Readiness probes are pointing to the same endpoint, the effects of the probes are combined）。

当应用程序发出它尚未准备好或存活的信号时，kubelet 将从服务中剔除容器并**同时**删除它（When the app signals that it's not ready or live, the kubelet detaches the container from the Service and delete it **at the same time**）。

我们可能会注意到连接中断，因为容器没有足够的时间来排空当前连接或处理新连接（You might notice dropping connections because the container does not have enough time to drain the current connections or process the incoming ones）。

我们可以在以下文章中深入了解**优雅关闭**（You can dig deeper in the following [article that discussed graceful shutdown](https://freecontent.manning.com/handling-client-requests-properly-with-kubernetes/)）。

## 应用是独立的（Apps are independent）

我们可能会被误导，例如只有在所有依赖项如数据库或后端 API 也准备好后，才发出应用程序的就绪信号（You might be tempted to signal the readiness of your app only if all of the dependencies such as databases or backend API are also ready）。

如果我们的应用程序连接到数据库，我们可能会认为在数据库 _准备好_ 之前返回失败的就绪探针是个好主意 —— 这并不是（If the app connects to a database, you might think that returning a failing readiness probe until the database is _ready_ is a good idea — it is not）。

考虑以下场景：我们有一个依赖后端 API 的前端应用程序（Consider the following scenario: you have one front-end app that depends on a backend API).

如果 API 不稳定（例如，由于 Bug 导致间歇性不可用），就绪探针失败，前端应用程序中的依赖就绪也会失败（If the API is flaky (e.g. it's unavailable from time to time due to a bug), the readiness probe fails, and the dependent readiness in the front-end app fail as well）。

然后业务就会出现停机时间（And you have downtime）。

更一般地说，*下游依赖项的故障可能会传播到所有上游应用程序*，并最终可能使我们的前端面向层也崩溃（More in general, **a failure in a dependency downstream could propagate to all apps upstream** and eventually, bring down your front-end facing layer as well）。

### 就绪探针是独立的（The Readiness probes are independent）

就绪探针不包括对服务的依赖项，例如（The readiness probe doesn't include dependencies to services such as）：

- 数据库（databases）
- 数据库迁移（database migrations）
- APIs
- 第三方服务（third party services）

我们可以在如下文档中探索**就绪探针中存在依赖项**时会发生什么（You can [explore what happens when there're dependencies in the readiness probes in this essay](https://blog.colinbreck.com/kubernetes-liveness-and-readiness-probes-how-to-avoid-shooting-yourself-in-the-foot/#shootingyourselfinthefootwithreadinessprobes)）。

### 应用重试连接它的依赖服务（The app retries connecting to dependent services）

当应用启动时，它不应该因为依赖项（如数据库）未准备好而崩溃（When the app starts, it shouldn't crash because a dependency such as a database isn't ready）。

相反，应用应该不断尝试连接数据库，直到成功（Instead, the app should keep retrying to connect to the database until it succeeds）。

Kubernetes 期望应用的组件可以按**任意顺序**启动（Kubernetes expects that application components can be started in any order）。

当我们确保应用可以重连到依赖项（如数据库）时，我们将能够提供更强大和弹性的服务（When you make sure that your app can reconnect to a dependency such as a database you know you can deliver a more robust and resilient service）。

## 优雅关闭（Graceful shutdown）

当 Pod 被删除时，我们不希望突然终止所有的连接（When a Pod is deleted, you don't want to terminate all connections abruptly）。

相反，我们应该等待现有连接排空并停止处理新的连接（Instead, you should wait for the existing connection to drain and stop processing new ones）。

请注意，当 Pod 被终止时，该 Pod 的端点将从 Kubernetes 的服务中剔除（Please notice that, when a Pod is terminated, the endpoints for that Pod are removed from the Service）。

然而，在诸如 kube-proxy 或入口控制器之类的组件被通知更改之前可能需要一些时间（However, it might take some time before component such as kube-proxy or the Ingress controller is notified of the change）。

我们可以在 _正确处理 Kubernetes 中的客户端请求_ 中找到关于**优雅关闭如何工作**的详细解释（You can find a detail explanation on how graceful shutdown works in [handling client requests correctly with Kubernetes](https://freecontent.manning.com/handling-client-requests-properly-with-kubernetes/)）。

正确的优雅关闭顺序是（The correct graceful shutdown sequence is）：

1. 收到 SIGTERM 信号时（upon receiving SIGTERM）
1. 服务器停止接受新连接（the server stops accepting new connections）
1. 完成所有活动请求（completes all active requests）
1. 然后立即终止所有 keepalive 的连接并（then immediately kills all keepalive connections and）
1. 进程退出（the process exits）

我们可以使用 _此工具_ 测试我们的应用程序是否是优雅关闭的：kube-sigterm-test（You can [test that your app gracefully shuts down with this tool: kube-sigterm-test](https://github.com/mikkeloscar/kube-sigterm-test)）。

### 应用不会在 SIGTERM 信号下关闭，但会优雅地终止连接（The app doesn't shut down on SIGTERM, but it gracefully terminates connections）

像 kube-proxy 或 Ingress 控制器这样的组件可能需要一些时间才能收到端点变化的通知（It might take some time before a component such as kube-proxy or the Ingress controller is notified of the endpoint changes）。

因此，尽管 Pod 被标记为终止，但流量可能仍会流向该 Pod（Hence, traffic might still flow to the Pod despite it being marked as terminated）。

应用应停止接受所有剩余连接上的新请求，并在响应队列清空后关闭这些连接（The app should stop accepting new requests on all remaining connections, and close these once the outgoing queue is drained）。

如果大家想要了解端点在集群中的传播方式，请阅读这篇关于**如何正确处理客户端请求**的文章（If you need a refresher on how endpoints are propagated in your cluster, [read this article on how to handle client requests properly](https://freecontent.manning.com/handling-client-requests-properly-with-kubernetes/)）。

### 应用仍在宽限期内处理传入请求（The app still processes incoming requests in the grace period）

大家可能需要考虑使用容器生命周期事件，如 _preStop 处理程序_ 来定制 Pod 被删除前的行为（You might want to consider using the container lifecycle events such as [the preStop handler](https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/#define-poststart-and-prestop-handlers) to customize what happens before a Pod is deleted）。

### `Dockerfile` 中的 CMD 可以将 SIGTERM 转发到进程（The CMD in the `Dockerfile` forwards the SIGTERM to the process）

我们可以通过在应用程序中捕获 SIGTERM 信号来在 Pod 即将被终止时收到通知（You can be notified when the Pod is about to be terminated by capturing the SIGTERM signal in your app）。

我们还应注意将信号转发到容器中的**其他（例如子进程）**进程（You should also pay attention to [forwarding the signal to the right process in your container](https://pracucci.com/graceful-shutdown-of-kubernetes-pods.html)）。

### 关闭所有空闲的 keep-alive 套接字（Close all idle keep-alive sockets）

如果调用应用程序没有关闭 TCP 连接（例如使用 TCP keep-alive 或连接池），它将连接到一个即将被销毁的 Pod 而不是使用该 Service 中的其他 Pod（If the calling app is not closing the TCP connection (e.g. using TCP keep-alive or a connection pool) it will connect to one Pod and not use the other Pods in that Service）。

_但当一个 Pod 被删除时会发生什么？_(_But what happens when a Pod is deleted?_）

理想情况下，请求应该转到另一个 Pod（Ideally, the request should go to another Pod）。

然而，调用程序如果与即将终止的 Pod 使用了长连接，将会继续使用这个长连接（However, the calling app has a long-lived connection open with the Pod that is about to be terminated, and it will keep using it）。

另一方面，我们不应该突然终止长期连接（On the other hand, you shouldn't abruptly terminate long-lived connections）。

相反，我们应该在关闭应用程序之前终止这些连接（Instead, you should terminate them before shutting down the app）。

我们可以在这篇关于 _优雅关闭 Nodejs HTTP 服务器_ 的文章中阅读处理有关 keep-alive 连接的内容（You can read about keep-alive connections on this article about [gracefully shutting down a Nodejs HTTP server](http://dillonbuchanan.com/programming/gracefully-shutting-down-a-nodejs-http-server/)）。

## 容错性（Fault tolerance）

我们的集群节点可能因多种原因随时丢失（Your cluster nodes could disappear at any time for several reasons）：

- 物理机器的硬件故障（a hardware failure of the physical machine）
- 云服务提供商或虚拟机管理程序故障（cloud provider or hypervisor failure）
- 内核崩溃（a kernel panic）

部署在这些节点上的 Pods 也会丢失（Pods deployed in those nodes are lost too）。

此外，还有其他场景可能会删除 Pods（Also, there are other scenarios where Pods could be deleted）：

- 直接删除 Pod（意外操作）（directly deleting a pod (accident)）
- 清空节点（draining a node）
- 从节点移除一个 Pod，以允许另一个 Pod 可以调度到该节点（removing a pod from a node to permit another Pod to fit on that node）

上述任何一种情况都可能影响我们应用程序的可用性并可能导致出现停机时间（Any of the above scenarios could affect the availability of your app and potentially cause downtime）。

我们应该防止所有 Pod 都不可用，从而导致无法提供实时流量服务的情况（You should protect from a scenario where all of your Pods are made unavailable, and you aren't able to serve live traffic）。

### 为我们的 Deployment 运行多个副本（Run more than one replica for your Deployment）

永远不要单独运行一个 Pod（Never run a single Pod individually）。

相反，请考虑将 Pod 作为 Deployment、DaemonSet、ReplicaSet 或 StatefulSet 的一部分进行部署（Instead consider deploying your Pod as part of a Deployment, DaemonSet, ReplicaSet or StatefulSet）。

运行多个 Pod 实例可以确保删除一个 Pod 不会导致出现停服时间（[Running more than one instance of your Pods guarantees that deleting a single Pod won't cause downtime](https://cloudmark.github.io/Node-Management-In-GKE/#replicas)）。

### 避免 Pod 被部署到单一节点上（Avoid Pods being placed into a single node）

**即使我们运行了多个 Pod 副本，也不能保证丢失一个节点不会使我们的服务瘫痪（Even if you run several copies of your Pods, there are no guarantees that losing a node won't take down your service）。**

考虑以下情况：我们在一个集群的单一节点上有 11 个副本（Consider the following scenario: you have 11 replicas on a single cluster node）。

如果该节点不可用，则 11 个副本将丢失，我们将面临停服（If the node is made unavailable, the 11 replicas are lost, and you have downtime）。

我们应该对部署的应用使用反亲和性规则，以便将 Pod 分散到集群的所有节点中（[You should apply anti-affinity rules to your Deployments so that Pods are spread in all the nodes of your cluster](https://cloudmark.github.io/Node-Management-In-GKE/#pod-anti-affinity-rules)）。

_Pod 间亲和性和反亲和性_ 文档描述了如何使 Pod 位于同一节点上（或不位于同一节点上）（The [inter-pod affinity and anti-affinity](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#inter-pod-affinity-and-anti-affinity) documentation describe how you can you could change your Pod to be located (or not) in the same node）。

### 设置 Pod 中断预算（Set Pod disruption budgets）

当一个节点被排空时，该节点上的所有 Pod 都会被删除并重新调度（When a node is drained, all the Pods on that node are deleted and rescheduled）。

_但是，如果系统正处于高负载状态，不能失去超过50%的 Pod 该怎么办？_ (_But what if you are under heavy load and you can't lose more than 50% of your Pods?_)

排空事件可能会影响应用的可用性（The drain event could affect your availability）。

为了保护部署免受可能同时导致多个 Pod 瘫痪的意外事件的影响，我们可以定义 Pod 的中断预算（To protect the Deployments from unexpected events that could take down several Pods at the same time, you can define Pod Disruption Budget）。

想象一下说："_Kubernetes，请确保我的应用始终至少有5个 Pod 在运行_ 。"（Imagine saying: _"Kubernetes, please make sure that there are always at least 5 Pods running for my app"_ ）。

如果最终状态导致该部署的 Pod 少于 5 个，Kubernetes 将阻止排空事件（Kubernetes will prevent the drain event if the final state results in less than 5 Pods for that Deployment）。

官方文档是理解 **Pod 中断预算及其设置方法**的绝佳起点（The official documentation is an excellent place to start to understand [Pod Disruption Budgets](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/)）。

## 资源利用（Resources utilisation）

我们可以将 Kubernetes 视为一个熟练的俄罗斯方块玩家（You can think about the Kubernetes as a skilled Tetris player）。

Docker 容器是块；服务器是棋盘，调度器是玩家（Docker containers are the blocks; servers are the boards, and the scheduler is the player）。

![Kubernetes is the best Tetris player](tetris.svg)

为了最大化调度器的效率，我们应该与 Kubernetes 分享资源利用、工作负载优先级和开销等详细信息（To maximise the efficiency of the scheduler, you should share with Kubernetes details such as resource utilisation, workload priorities and overheads）。

### 为所有容器设置内存限制和请求（Set memory limits and requests for all containers）

资源限制用于限制容器可以使用的 CPU 和内存量，并使用 `containerSpec` 的 resources 属性设置（Resource limits are used to constrain how much CPU and memory your containers can utilise and are set using the resources property of a `containerSpec`）。

调度程序使用这些作为决定当前 Pod 最适合哪个节点的指标之一（The scheduler uses those as one of metrics to decide which node is best suited for the current Pod）。

一个没有内存限制的容器，调度程序认为其内存利用率为零（A container without a memory limit has memory utilisation of zero — according to the scheduler）。

如果无限数量的 Pods 可以在任何节点上调度，最终将导致资源超卖和潜在的节点（和 kubelet）崩溃（An unlimited number of Pods if schedulable on any nodes leading to resource overcommitment and potential node (and kubelet) crashes）。

这同样适用于 CPU 限制（The same applies to CPU limits）。

_但是，我们是否总是应该为内存和 CPU 设置 requests 和 limits ？ _（ _But should you always set limits and requests for memory and CPU?_ ）

是，也不是（Yes and no）。

如果我们的进程超出内存限制，进程将被终止（If your process goes over the memory limit, the process is terminated）。

由于 CPU 是一种可压缩资源，如果容器超出限制，进程将被节流（Since CPU is a compressible resource, if your container goes over the limit, the process is throttled）。

即使它当时还可以使用一些可用的 CPU（Even if it could have used some of the CPU that was available at that moment）。

**设置 CPU limits 是让人头疼的（[CPU limits are hard.](https://www.reddit.com/r/kubernetes/comments/cmp7jj/multithreading_in_a_container_with_limited/ew52fcj/)）**

如果大家希望深入了解 CPU 和内存限制，我们可以查看以下文章（If you wish to dig deeper into CPU and memory limits you should check out the following articles）：

- 理解 Kubernetes 中的资源限制：内存（[Understanding resource limits in kubernetes: memory](https://medium.com/@betz.mark/understanding-resource-limits-in-kubernetes-memory-6b41e9a955f9)）
- 理解 Kubernetes 中的资源限制：CPU 时间（[Understanding resource limits in kubernetes: cpu time](https://medium.com/@betz.mark/understanding-resource-limits-in-kubernetes-cpu-time-9eff74d3161b)）

> 请注意，如果我们不确定 _正确的_ CPU 或内存限制是什么，我们可以使用 Kubernetes 中的垂直 Pod 自动伸缩器，并将建议模式打开。自动伸缩器会分析应用程序并推荐限制（Please note that if you are not sure what should be the _right_ CPU or memory limit, you can use the [Vertical Pod Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler) in Kubernetes with the recommendation mode turned on. The autoscaler profiles your app and recommends limits for it）。

### 将 CPU 请求设置为 1 CPU 或以下（（Set CPU request to 1 CPU or below）

除非是计算密集型作业，否则建议将请求设置为 1 CPU 或以下（Unless you have computational intensive jobs, [it is recommended to set the request to 1 CPU or below](https://www.youtube.com/watch?v=xjpHggHKm78)）。

### 除非有充分的理由，否则禁用 CPU 限制（Disable CPU limits — unless you have a good use case）

CPU 以每个时间单位的 CPU 时间单位来衡量（CPU is measured as CPU timeunits per timeunit）。

`cpu: 1` 表示每秒 1 个 CPU 秒（`cpu: 1` means 1 CPU second per second）。

如果有 1 个线程，则每秒消耗不能超过 1 个 CPU 秒（If you have 1 thread, you can't consume more than 1 CPU second per second).

如果有 2 个线程，则可以在 0.5 秒内消耗 1 个 CPU 秒（If you have 2 threads, you can consume 1 CPU second in 0.5 seconds).

8 个线程可以在 0.125 秒内消耗 1 个 CPU 秒（8 threads can consume 1 CPU second in 0.125 seconds）。

之后，进程将被节流（After that, your process is throttled）。

如果我们不确定应用程序的最佳设置是什么，最好不设置 CPU 限制（If you're not sure about what's the best settings for your app, it's better not to set the CPU limits）。

如果大家希望了解更多，可参考**深入挖掘了 CPU 请求和限制**（If you wish to learn more, [this article digs deeper in CPU requests and limits](https://medium.com/@betz.mark/understanding-resource-limits-in-kubernetes-cpu-time-9eff74d3161b)）。

### 命名空间具有 LimitRange（The namespace has a LimitRange）

如果认为大家可能会忘记设置内存和 CPU 限制，我们应该考虑使用 LimitRange 对象来定义当前命名空间中部署的容器的标准大小（If you think you might forget to set memory and CPU limits, you should consider using a LimitRange object to define the standard size for a container deployed in the current namespace）。

官方文档关于 LimitRange 是一个很好的起点（[The official documentation about LimitRange](https://kubernetes.io/docs/concepts/policy/limit-range/) is an excellent place to start）。

### 为 Pods 设置适当的服务质量（QoS）（Set an appropriate Quality of Service (QoS) for Pods）

当节点进入超卖状态（即使用了太多资源）时，Kubernetes 将会尝试驱逐该节点上的一些 Pods（When a node goes into an overcommitted state (i.e. using too many resources) Kubernetes tries to evict some of the Pod in that Node）。

Kubernetes 根据一个明确定义的逻辑对 Pods 进行排名和驱逐（Kubernetes ranks and evicts the Pods according to a well-defined logic）。

大家可以在官方文档上找到更多关于配置 **Pods 的 QoS** 的信息（You can find more about [configuring the quality of service for your Pods](https://kubernetes.io/docs/tasks/configure-pod-container/quality-service-pod/) on the official documentation）。

## 为资源打标签（Tagging resources）

标签是用来组织 Kubernetes 对象的机制（Labels are the mechanism you use to organize Kubernetes objects）。

标签是没有预定义含义的键值对（A label is a key-value pair without any pre-defined meaning）。

它们可以应用于集群中的所有资源，从 Pods 到服务、入口清单、端点等（They can be applied to all resources in your cluster from Pods to Service, Ingress manifests, Endpoints, etc）。

我们可以使用标签按目的、所有者、环境或其他标准对资源进行分类（You can use labels to categorize resources by purpose, owner, environment, or other criteria）。

所以我们可以选择一个标签来标记一个 Pod 在环境中，例如“这个 Pod 正在生产中运行”或“支付团队拥有该部署”（So you could choose a label to tag a Pod in an environment such as "this pod is running in production" or "the payment team owns that Deployment"）。

我们也可以完全忽略标签（You can also omit labels altogether）。

然而，我们可以考虑使用标签来涵盖以下类别（However, you might want to consider using labels to cover the following categories）：

- 技术标签，如环境（technical labels such as the environment）
- 自动化的标签（labels for automation）
- 与业务相关的标签，如成本中心分配（label related to your business such as cost-centre allocation）
- 与安全相关的标签，如合规性要求（label related to security such as compliance requirements）

### 具有技术标签定义的资源（Resources have technical labels defined）

我们可以使用以下标签标记 Pods（You could tag your Pods with）：

- `名称`，应用程序的名称，如“用户 API”（`name`, the name of the application such "User API"）
- `实例`，标识应用程序实例的唯一名称（可以使用容器镜像标签）（`instance`, a unique name identifying the instance of an application (you could use the container image tag)
- `版本`，应用程序的当前版本（递增计数器）（`version`, the current version of the appl (an incremental counter)）
- `组件`，在架构中的组件，如“API”或“数据库”（`component`, the component within the architecture such as "API" or "database"）
- `组成部分`，更高级别应用程序的名称，该应用程序是其中的一部分，如“支付网关”（`part-of`, the name of a higher-level application this one is part of such as "payment gateway")
- `被管理`，用于管理应用程序操作的工具，如 “kubectl” 或 “Helm”（`managed-by`, the tool being used to manage the operation of an application such as "kubectl" or "Helm"）

以下是一个如何在部署中使用这些标签的示例（Here's an example on how you could use such labels in a Deployment）：

```yaml|highlight=6-11,20-24|title=deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment
  labels:
    app.kubernetes.io/name: user-api
    app.kubernetes.io/instance: user-api-5fa65d2
    app.kubernetes.io/version: "42"
    app.kubernetes.io/component: api
    app.kubernetes.io/part-of: payment-gateway
    app.kubernetes.io/managed-by: kubectl
spec:
  replicas: 3
  selector:
    matchLabels:
      application: my-app
  template:
    metadata:
      labels:
        app.kubernetes.io/name: user-api
        app.kubernetes.io/instance: user-api-5fa65d2
        app.kubernetes.io/version: "42"
        app.kubernetes.io/component: api
        app.kubernetes.io/part-of: payment-gateway
    spec:
      containers:
      - name: app
        image: myapp
```

这些标签是由官方文档推荐的（Those labels are [recommended by the official documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/)）。

> 请注意，我们建议您标记**所有资源**（Please note that you're recommended to tag **all resources**）。

### 具有业务标签定义的资源（Resources have business labels defined)

我们可以使用以下标签标记 Pods（You could tag your Pods with）：

- `所有者`，用于识别谁负责该资源（`owner`, used to identify who is responsible for the resource）
- `项目`，用于确定资源所属的项目（`project`, used to determine the project that the resource belongs to）
- `商业单元`，用于识别与资源相关的成本中心或商业单元；通常用于成本分配和跟踪（`business-unit`, used to identify the cost centre or business unit associated with a resource; typically for cost allocation and tracking)

以下是一个如何在部署中使用这些标签的示例（Here's an example on how you could use such labels in a Deployment):

```yaml|highlight=6-8,17-19|title=deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment
  labels:
    owner: payment-team
    project: fraud-detection
    business-unit: "80432"
spec:
  replicas: 3
  selector:
    matchLabels:
      application: my-app
  template:
    metadata:
      labels:
        owner: payment-team
        project: fraud-detection
        business-unit: "80432"
    spec:
      containers:
      - name: app
        image: myapp
```

我们可以在 AWS 标签策略页面上探索标签和资源标记（You can explore labels and [tagging for resources on the AWS tagging strategy page](https://aws.amazon.com/answers/account-management/aws-tagging-strategies/)）。

文章不是特定于 Kubernetes 的，但探讨了标记资源最常见的一些策略（The article isn't specific to Kubernetes but explores some of the most common strategies for tagging resources）。

> 请注意，建议您标记所有资源（Please not that you're recommended to tag **all resources**）。

### 具有安全标签定义的资源（Resources have security labels defined）

我们可以使用以下标签标记 Pods（You could tag your Pods with）：

- `保密性`，标识资源支持特定数据保密性级别的标识符（`confidentiality`, an identifier for the specific data-confidentiality level a resource supports）
- `合规性`，标识旨在遵守特定合规性要求的工作负载的标识符（`compliance`, an identifier for workloads designed to adhere to specific compliance requirements)

以下是一个如何在部署中使用这些标签的示例（Here's an example on how you could use such labels in a Deployment）：

```yaml|highlight=6-11,20-24|title=deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment
  labels:
    confidentiality: official
    compliance: pci
spec:
  replicas: 3
  selector:
    matchLabels:
      application: my-app
  template:
    metadata:
      labels:
        confidentiality: official
        compliance: pci
    spec:
      containers:
      - name: app
        image: myapp
```

我们可以在 AWS 标签策略页面上探索标签和资源标记（You can explore labels and [tagging for resources on the AWS tagging strategy page](https://aws.amazon.com/answers/account-management/aws-tagging-strategies/)）。

文章不是特定于 Kubernetes 的，但探讨了标记资源最常见的一些策略（The article isn't specific to Kubernetes but explores some of the most common strategies for tagging resources）。

> 请注意，建议您标记所有资源（Please not that you're recommended to tag **all resources**）。

## 日志记录（Logging）

应用日志可以帮助我们了解应用程序内部发生了什么（Application logs can help you understand what is happening inside your app）。

日志特别适用于调试问题和监控应用程序的活动（The logs are particularly useful for debugging problems and monitoring app activity）。

### 应用日志输出到 `stdout` 和 `stderr`（The application logs to `stdout` and `stderr`）

有两种日志记录策略：_被动_ 和 _主动_ （There are two logging strategies: _passive_ and _active_）。

使用被动日志记录的应用不知道日志记录基础设施，并将日志消息记录到标准输出（Apps that use passive logging are unaware of the logging infrastructure and log messages to standard outputs).

这种最佳实践是**十二因素（The 12-Factor）**应用程序的一部分（This best practice is part of [the twelve-factor app](https://12factor.net/logs)).

在主动日志记录中，应用建立到中间聚合器的连接，将数据发送到第三方日志服务，或直接写入数据库或索引（In active logging, the app makes network connections to intermediate aggregators, sends data to third-party logging services, or writes directly to a database or index).

主动日志记录被认为是反模式，应该避免（Active logging is considered an antipattern, and it should be avoided）。

### 如果可以的话，避免使用 sidecar 进行日志记录（Avoid sidecars for logging (if you can)）

如果需要对具有非标准日志事件模型的应用进行日志转换，我们可能会想到使用 sidecar 容器（If you wish to [apply log transformations to an application with a non-standard log event model](https://rclayton.silvrback.com/container-services-logging-with-docker#effective-logging-infrastructure), you may want to use a sidecar container）。

使用 sidecar 容器，我们可以在将日志条目发送到其他地方之前对其进行规范化（With a sidecar container, you can normalise the log entries before they are shipped elsewhere）。

例如，我们可以在将其发送到日志基础设施之前，将 Apache 日志转换为 Logstash JSON 格式（For example, you may want to transform Apache logs into Logstash JSON format before shipping it to the logging infrastructure）。

如果我们可以控制应用的话，就应该在一开始就输出正确的日志格式（However, if you have control over the application, you could output the right format, to begin with）。

这样我们可以节省在每个 Pod 中运行额外容器的费用（You could save on running an extra container for each Pod in your cluster）。

## 扩展（Scaling）

### 容器不应该在其本地文件系统中存储任何状态（Containers do not store any state in their local filesystem）

容器具有本地文件系统，我们可能会自然而然使用它来持久化数据（Containers have a local filesystem and you might be tempted to use it for persisting data）。

然而，将持久化数据存储在容器的本地文件系统中会使 Pod 水平扩展（即，通过添加或删除 Pod 的副本）等功能无法使用（However, storing persistent data in a container's local filesystem prevents the encompassing Pod from being scaled horizontally (that is, by adding or removing replicas of the Pod)）。

这是因为，使用本地文件系统，每个容器都维护自己的“状态”，这意味着 Pod 副本的状态可能随时间而出现分歧。这导致用户视角下的行为不一致（例如，当请求命中一个 Pod 时，特定用户信息是可用的，但当请求命中另一个 Pod 时却不是）（This is because, by using the local filesystem, each container maintains its own "state", which means that the states of Pod replicas may diverge over time. This results in inconsistent behaviour from the user's point of view (for example, a specific piece of user information is available when the request hits one Pod, but not when the request hits another Pod)）。

相反，任何持久化信息都应该保存在 Pod 外部的集中位置。例如，在集群中的 PersistentVolume，或者更好的是在集群外的某些存储服务中（Instead, any persistent information should be saved at a central place outside the Pods. For example, in a PersistentVolume in the cluster, or even better in some storage service outside the cluster）。

### 使用水平 Pod 自动伸缩器适用于具有可变负载模式的应用（Use the Horizontal Pod Autoscaler for apps with variable usage patterns）

水平 Pod 自动伸缩器（HPA）是 Kubernetes 的内置功能，它监控应用程序，并根据当前使用情况自动添加或删除 Pod 副本（The [Horizontal Pod Autoscaler (HPA)](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) is a built-in Kubernetes feature that monitors your application and automatically adds or removes Pod replicas based on the current usage)

配置 HPA 允许应用程序在任何流量条件下保持可用性和响应性，包括意外的流量激增（Configuring the HPA allows your app to stay available and responsive under any traffic conditions, including unexpected spikes）。

要配置 HPA 自动伸缩应用程序，我们需要创建一个 HorizontalPodAutoscaler 资源，它定义了监控应用程序的指标（To configure the HPA to autoscale your app, you have to create a [HorizontalPodAutoscaler](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.16/#horizontalpodautoscaler-v1-autoscaling) resource, which defines what metric to monitor for your app）。

HPA 可以监控内置的资源指标（Pods 的 CPU 和内存使用情况）或自定义指标。如果是自定义指标，程序负责收集和暴露这些指标，我们可以使用 Prometheus 和 Prometheus 适配器来完成指标收集操作（The HPA can monitor either built-in resource metric (CPU and memory usage of your Pods) or custom metrics. In the case of custom metrics, you are also responsible for collecting and exposing these metrics, which you can do, for example, with [Prometheus](https://prometheus.io/) and the [Prometheus Adapter](https://github.com/DirectXMan12/k8s-prometheus-adapter)）。

### 不要使用还处于 beta 版本的垂直 Pod 自动伸缩器（Don't use the Vertical Pod Autoscaler while it's still in beta）

与水平 Pod 自动伸缩器（HPA）类似，我们还有垂直 Pod 自动伸缩器（VPA）（Analogous to the [Horizontal Pod Autoscaler (HPA)](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/), there exists the [Vertical Pod Autoscaler (VPA)](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler)）。

VPA 可以自动调整 Pods 的资源请求和限制，以便当 Pod 需要更多资源时，可以自动获取（增加/减少单个 Pod 的资源称为 _垂直扩展_ ，与 _水平扩展_ 相反，水平扩展意味着增加/减少 Pod 的副本数量）（The VPA can automatically adapt the resource requests and limits of your Pods so that when a Pod needs more resources, it can get them (increasing/decreasing the resources of a single Pod is called _vertical scaling_, as opposed to _horizontal scaling_, which means increasing/decreasing the number of replicas of a Pod）。

这对无法水平扩展的应用很有用（This can be useful for scaling applications that can't be scaled horizontally）。

然而，VPA 当前处于 beta 版本，并且有一些已知的限制（例如，通过更改资源需求来扩展 Pod，需要杀死并重新启动 Pod）（However, the VPA is curently in beta and it has [some known limitations](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler#limitations-of-beta-version) (for example, scaling a Pod by changing its resource requirements, requires the Pod to be killed and restarted)）。

鉴于这些限制，以及大多数 Kubernetes 上的应用程序基本上都可以水平扩展，因此建议不要在生产中使用 VPA（至少在有稳定版本之前）（Given these limitations, and the fact that most applications on Kubernetes can be scaled horizontally anyway, it is recommended to not use the VPA in production (at least until there is a stable version)）。

### 如果有数量变化剧烈的工作负载，请使用集群自动伸缩器（Use the Cluster Autoscaler if you have highly varying workloads）

集群自动伸缩器是另一种“自动伸缩器”（除水平 Pod 自动伸缩器和垂直 Pod 自动伸缩器之外）（The [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) is another type of "autoscaler" (besides the [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) and [Vertical Pod Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler))）。

集群自动伸缩器可以通过添加或删除工作节点，来自动调整集群大小（The Cluster Autoscaler can automatically scale the size of your cluster by adding or removing worker nodes）。

当现有工作节点上的资源不足，无法调度 Pod 时，会执行扩容操作。在这种情况下，集群自动伸缩器会创建一个新的工作节点，以便 Pod 可以被调度。类似地，当现有工作节点的利用率很低时，集群自动伸缩器可以通过驱逐工作节点上的所有工作负载并将其移除来缩小规模（A scale-up operation happens when a Pod fails to be scheduled because of insufficient resources on the existing worker nodes. In this case, the Cluster Autoscaler creates a new worker node, so that the Pod can be scheduled. Similarly, when the utilisation of the existing worker nodes is low, the Cluster Autoscaler can scale down by evicting all the workloads from one of the worker nodes and removing it）。

对于业务量剧烈变化将的工作负载，使用集群自动伸缩器是有意义的，例如当 Pod 的数量可能在短时间内增加，然后又回到先前的值时。在这种情况下，集群自动伸缩器允许在不通过过度配置工作节点而浪费资源的情况下满足需求高峰（Using the Cluster Autoscaler makes sense for highly variable workloads, for example, when the number of Pods may multiply in a short time, and then go back to the previous value. In such scenarios, the Cluster Autoscaler allows you to meet the demand spikes without wasting resources by overprovisioning worker nodes）。

如果工作负载变化不大，那就不建议设置集群自动伸缩器，因为它可能永远不会被触发。如果工作负载缓慢且单调地增长，可能只需要监控现有工作节点的利用率，并在它们达到临界值时手动添加一个额外的工作节点就足够了（However, if your workloads do not vary so much, it may not be worth to set up the Cluster Autoscaler, as it may never be triggered. If your workloads grow slowly and monotonically, it may be enough to monitor the utilisations of your existing worker nodes and add an additional worker node manually when they reach a critical value）。

## 配置和密钥（Configuration and secrets）

### 外部化所有配置（Externalise all configuration）

配置应维护在应用程序的代码之外（Configuration should be maintained outside the application code）。

这样做有几个好处。首先，更改配置不需要重新编译应用程序。其次，可以在应用程序运行时更新配置。第三，相同的代码可以在不同环境中使用（This has several benefits. First, changing the configuration does not require recompiling the application. Second, the configuration can be updated when the application is running. Third, the same code can be used in different environments）。

在 Kubernetes 中，配置可以保存在 ConfigMaps 中，然后可以将其作为卷挂载到容器中，或作为环境变量传递（In Kubernetes, the configuration can be saved in ConfigMaps, which can then be mounted into containers as volumes are passed in as environment variables）。

只在 ConfigMaps 中保存非敏感配置。对于敏感信息（如凭据），使用 Secret 资源（Save only non-sensitive configuration in ConfigMaps. For sensitive information (such as credentials), use the Secret resource）。

### 将 Secret 作为卷挂载，而不是作为环境变量（Mount Secrets as volumes, not enviroment variables）

Secret 资源的内容应作为卷挂载到容器中，而不是作为环境变量传递（The content of Secret resources should be mounted into containers as volumes rather than passed in as environment variables）。

这是为了防止机密值出现在启动容器时使用的命令中，这会让不应该有权限的个人访问到该机密值（This is to prevent that the secret values appear in the command that was used to start the container, which may be inspected by individuals that shouldn't have access to the secret values）。