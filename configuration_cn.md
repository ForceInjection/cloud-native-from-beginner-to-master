# 集群配置（Cluster configuration）

集群配置的最佳实践（Cluster configuration best practices）。

## 批准的 Kubernetes 配置（Approved Kubernetes configuration）

Kubernetes 是灵活的，并且可以以多种不同的方式进行配置（Kubernetes is flexible and can be configured in several different ways）。

但是，大家如何知道什么配置是我们集群的推荐配置呢？（But how do you know what's the recommended configuration for your cluster?）

最佳选择是将我们的集群与标准参考配置进行比较（The best option is to compare your cluster with a standard reference）。

对于 Kubernetes，我们可以参考互联网安全中心（CIS）基准测试（In the case of Kubernetes, the reference is the Centre for Internet Security (CIS) benchmark）。

### 集群通过 CIS 基准测试（The cluster passes the CIS benchmark）

互联网安全中心（CIS）提供多个指导和基准测试，用作确保代码安全的最佳实践（The Center for Internet Security provides several guidelines and benchmark tests for best practices in securing your code）。

他们还维护了一个 Kubernetes 的基准，我们可以从官方网站下载（They also maintain a benchmark for Kubernetes which you can [download from the official website](https://www.cisecurity.org/benchmark/kubernetes/)）。

除了阅读长篇指南并手动检查集群是否符合标准，最简单快速的方法是下载并执行 `kube-bench`（While you can read the lengthy guide and manually check if your cluster is compliant, an easier way is to download and execute [`kube-bench`](https://github.com/aquasecurity/kube-bench)）

`kube-bench` 是一个设计用来自动化执行 CIS Kubernetes 基准测试并报告集群中的错误配置的工具（[`kube-bench`](https://github.com/aquasecurity/kube-bench) is a tool designed to automate the CIS Kubernetes benchmark and report on misconfigurations in your cluster）。

示例输出（Example output）：

```terminal|title=bash
[INFO] 1 Master Node Security Configuration
[INFO] 1.1 API Server
[WARN] 1.1.1 Ensure that the --anonymous-auth argument is set to false (Not Scored)
[PASS] 1.1.2 Ensure that the --basic-auth-file argument is not set (Scored)
[PASS] 1.1.3 Ensure that the --insecure-allow-any-token argument is not set (Not Scored)
[PASS] 1.1.4 Ensure that the --kubelet-https argument is set to true (Scored)
[PASS] 1.1.5 Ensure that the --insecure-bind-address argument is not set (Scored)
[PASS] 1.1.6 Ensure that the --insecure-port argument is set to 0 (Scored)
[PASS] 1.1.7 Ensure that the --secure-port argument is not set to 0 (Scored)
[FAIL] 1.1.8 Ensure that the --profiling argument is set to false (Scored)
```

> 请注意，使用 kube-bench 无法检查 GKE、EKS 和 AKS 等托管集群的主机节点。主机节点由云服务提供商控制和管理（Please note that it is not possible to inspect the master nodes of managed clusters such as GKE, EKS and AKS, using `kube-bench`. The master nodes are controlled and managed by the cloud provider）。

### 禁用元数据云服务提供商的元数据 API（Disable metadata cloud providers metadata API）

云厂商（AWS、Azure、GCE 等）经常向本地实例暴露元数据服务（Cloud platforms (AWS, Azure, GCE, etc.) often expose metadata services locally to instances）。

默认情况下，这些 API 可以被运行在主机实例上的 pod 访问，并且可能包含该节点的云凭证，或诸如 kubelet 凭证之类的配置数据（By default, these APIs are accessible by pods running on an instance and can contain cloud credentials for that node, or provisioning data such as kubelet credentials）。

这些凭证可以用来在集群内升级权限或访问同一账户下的其他云服务（These credentials can be used to escalate within the cluster or to other cloud services under the same account）。

### 限制对 alpha 或 beta 功能的使用（Restrict access to alpha or beta features）

Alpha 和 beta 版本的 Kubernetes 功能表明它们正在被积极开发中，因此可能存在限制或错误，导致安全漏洞（Alpha and beta Kubernetes features are in active development and may have limitations or bugs that result in security vulnerabilities）。

始终评估 alpha 或 beta 功能可能提供的价值与可能对集群安全态势构成的风险（Always assess the value an alpha or beta feature may provide against the possible risk to your security posture）。

如果有疑问，禁用我们不使用的功能（When in doubt, disable features you do not use）。

## 认证（Authentication）

当我们使用 `kubectl` 时，我们需要对 kube-api 服务器组件进行身份验证（When you use `kubectl`, you authenticate yourself against the kube-api server component）。

ubernetes 支持不同的认证策略（Kubernetes supports different authentication strategies）：

- **静态令牌**：难以使它们失效，应避免使用（**Static Tokens**: are difficult to invalidate and should be avoided）
- **引导令牌**：与上述静态令牌相同 （**Bootstrap Tokens**: same as static tokens above）
- **基本认证**：以明文传输网络凭据（**Basic Authentication** transmits credentials over the network in cleartext）
- **X509 客户端证书**：需要定期更新和重新分发客户端证书（**X509 client certs** requires renewing and redistributing client certs regularly）
- **服务帐户令牌**：是集群中运行的应用程序和工作负载的首选认证策略（**Service Account Tokens** are the preferred authentication strategy for applications and workloads running in the cluster）
- **OpenID Connect (OIDC) 令牌**：由于 OIDC 与身份提供商（如 AD、AWS IAM、GCP IAM 等）集成，因此它是最终用户的最佳身份验证策略（**OpenID Connect (OIDC) Tokens**: best authentication strategy for end-users as OIDC integrates with your identity provider such as AD, AWS IAM, GCP IAM, etc）。

我们可以在官方文档中更详细地了解这些策略（You can learn about the strategies in more detail [in the official documentation](https://kubernetes.io/docs/reference/access-authn-authz/authentication/)）。

### 使用 OpenID（OIDC）令牌作为用户认证策略（Use OpenID (OIDC) tokens as a user authentication strategy）

Kubernetes 支持包括 OpenID Connect（OIDC）在内的多种认证方法（Kubernetes supports various authentication methods, including OpenID Connect (OIDC)）。

OpenID Connect 允许单点登录（SSO），例如您的 Google 身份，连接到 Kubernetes 集群和其他开发工具（OpenID Connect allows single sign-on (SSO) such as your Google Identity to connect to a Kubernetes cluster and other development tools）。

我们不需要单独记住或管理凭据（You don't need to remember or manage credentials separately）。

我们可以让多个集群连接到同一个 OpenID 提供者（You could have several clusters connect to the same OpenID provider）。

我们可以在本文中了解更多关于 Kubernetes 中的 OpenID 连接（You can [learn more about the OpenID connect in Kubernetes](https://thenewstack.io/kubernetes-single-sign-one-less-identity/) in this article）。

## 基于角色的访问控制（Role-Based Access Control (RBAC)）

基于角色的访问控制（RBAC）允许您定义如何访问集群中的资源的策略（Role-Based Access Control (RBAC) allows you to define policies on how to access resources in your cluster）。

### 服务帐户令牌**仅**用于应用程序和控制器（ServiceAccount tokens are for applications and controllers **only**）

服务帐户令牌不应用于尝试与 Kubernetes 集群交互的最终用户，但它们是 Kubernetes 上运行的应用程序和工作负载的首选认证策略（Service Account Tokens should not be used for end-users trying to interact with Kubernetes clusters, but they are the preferred authentication strategy for applications and workloads running on Kubernetes）。

## 日志设置（Logging setup）

我们应该收集并集中存储集群中运行的所有工作负载以及集群组件本身的日志（You should collect and centrally store logs from all the workloads running in the cluster and from the cluster components themselves）。

### 日志应该有保留和归档策略（There's a retention and archival strategy for logs）

您应该保留 30-45 天的历史日志（You should retain 30-45 days of historical logs）。

### 日志收集来自节点、控制平面、审计（Logs are collected from Nodes, Control Plane, Auditing）

要收集日志的内容（What to collect logs from）：

- 节点（kubelet，容器运行时）- Nodes (kubelet, container runtime)
- 控制平面（API 服务器，调度器，控制器管理器）- Control plane (API server, scheduler, controller manager)
- Kubernetes 审计（对 API 服务器的所有请求）- Kubernetes auditing (all requests to the API server)

我们应该收集的内容（What you should collect）：

- 应用程序名称。从元数据标签中检索（Application name. Retrieved from metadata labels）。
- 应用程序实例。从元数据标签中检索（Application instance. Retrieved from metadata labels）。
- 应用程序版本。从元数据标签中检索（Application version. Retrieved from metadata labels）。
- 集群 ID。从 Kubernetes 集群中检索（Cluster ID. Retrieved from Kubernetes cluster）。
- 容器名称。从 Kubernetes API 中检索（Container name. Retrieved from Kubernetes API）。
- 运行此容器的集群节点。从 Kubernetes 集群中检索获得（Cluster node running this container. Retrieved from Kubernetes cluster）。
- 运行容器的 Pod 名称。从 Kubernetes 集群中检索获得（Pod name running the container. Retrieved from Kubernetes cluster）。
- 命名空间。从 Kubernetes 集群中检索获得（The namespace. Retrieved from Kubernetes cluster）。

### 优先使用每个节点上的守护进程来收集日志，而不是 sidecar（Prefer a daemon on each node to collect the logs instead of sidecars）

应用程序应该将日志记录到 stdout 而不是文件（Applications should log to stdout rather than to files）。

每个节点上的守护进程可以从容器运行时收集日志，如果记录到文件，每个 Pod 可能需要一个 sidecar 容器来收集日志（[A daemon on each node can collect the logs from the container runtime](https://rclayton.silvrback.com/container-services-logging-with-docker#effective-logging-infrastructure) (if logging to files, a sidecar container for each pod might be necessary)）。

### 配置日志聚合工具（Provision a log aggregation tool）

使用日志聚合工具，例如 EFK 堆栈(Elasticsearch, Fluentd, Kibana)，DataDog，Sumo Logic，Sysdig，GCP Stackdriver，Azure Monitor，AWS CloudWatch 等（Use a log aggregation tool such as EFK stack (Elasticsearch, Fluentd, Kibana), DataDog, Sumo Logic, Sysdig, GCP Stackdriver, Azure Monitor, AWS CloudWatch）。