# 治理

创建、管理和管理命名空间的最佳实践。

## 命名空间限制

当我们决定在命名空间中隔离我们的集群时，我们应该防止资源的滥用。

我们不应该允许用户使用比提前约定的更多的资源。

集群管理员可以通过配额和限制范围来设置约束，以限制在项目中使用的命名空间中的对象数量或计算资源的数量。

如果大家需要复习限制范围，请查看官方文档  [Limit Range](https://kubernetes.io/docs/concepts/policy/limit-range/)。

## 命名空间具有限制范围

没有限制的容器可能会导致与其他容器的资源争夺，以及计算资源的非优化消耗。

Kubernetes有两个功能可以限制资源使用：`ResourceQuota`和`LimitRange`。

通过 `LimitRange` 对象，我们可以为命名空间内的各个容器定义资源请求和限制的默认值。

在该命名空间内创建的任何容器，如果没有明确指定请求和限制值，将被分配默认值。

如果大家需要复习资源配额，请查看官方文档 [Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)。

## 命名空间具有资源配额

通过`ResourceQuotas`，我们可以限制命名空间内所有容器的总资源消耗。

为命名空间定义资源配额限制了属于该命名空间的所有容器可以消耗的CPU、内存或存储资源的总量。

我们还可以为当前命名空间中的其他 Kubernetes 对象设置配额，例如 Pod 的数量。

如果大家认为有人可能会利用集群并创建 20000 个 ConfigMaps，使用`LimitRange`就是我们可以防止这种情况的方法。

## Pod安全策略

当 Pod 部署到集群中时，我们应该防范：

- 容器被破坏
- 容器使用节点上不允许的资源，如进程、网络或文件系统

更一般地说，我们应该限制 Pod 能做的最少。

### 启用Pod安全策略

例如，我们可以使用Kubernetes Pod安全策略来限制：

- 访问主机进程或网络命名空间
- 运行特权容器
- 容器运行的用户
- 访问主机文件系统
- Linux 功能、Seccomp 或 SELinux 配置文件

选择正确的策略取决于集群的性质。

以下[文章](https://resources.whitesourcesoftware.com/blog-whitesource/kubernetes-pod-security-policy)介绍了一些 Kubernetes Pod 安全策略的最佳实践。

### 禁用特权容器

在 Pod 中，容器可以以“特权”模式运行，几乎无限制地访问主机系统上的资源。

虽然有特定用例需要这种级别的访问，但通常，让我们的容器这样做是一种安全风险。

特权Pod的有效用例包括使用节点上的硬件，如 GPU。

我们可以从这篇[文章](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)中了解更多关于安全上下文和容器特权的信息。

### 在容器中使用只读文件系统

在容器中运行只读文件系统会强制容器变得不可变。

这不仅减少了一些旧的（且有风险的）做法，如热修补，还有助于防止恶意进程在容器内存储或操纵数据。

在容器中运行只读文件系统听起来很简单，但它可能带来一些复杂性。

如果我们需要写入日志或在临时文件夹中存储文件怎么办？

我们可以在这篇[文章](https://medium.com/@axbaretto/running-docker-containers-securely-in-production-98b8104ef68)中了解在生产中安全运行容器的权衡。

### 阻止容器以 root 身份运行

在容器中运行的进程与主机上的任何其他进程没有区别，除了它有一小段元数据声明它在容器中。

因此，容器中的 root 与主机机器上的`root（uid 0）`相同。

如果用户设法突破在容器中以 root 身份运行的应用程序，他们可能能够以相同的 root 用户访问主机。

配置容器使用非特权用户是防止权限提升攻击的最佳方法。

如果大家想了解更多，以下[文章](https://medium.com/@mccode/processes-in-containers-should-not-run-as-root-2feae3f0df3b)提供了一些详细解释了当以root身份运行容器时会发生什么。

### 限制功能

Linux功能使进程能够执行默认只有root用户才能执行的一些特权操作。

例如，`CAP_CHOWN`允许进程“随意更改文件 `UID` 和` GID`”。

即使我们的进程不以 root 身份运行，也有可能通过提升权限来使用这些类似root的功能。

换句话说，如果我们不想被破坏，我们应该只启用需要的功能。

但是应该启用哪些功能，为什么？

以下两篇文章深入探讨了Linux内核中功能的理论以及实践最佳实践：

- [Linux功能：它们为什么存在以及它们如何工作](https://blog.container-solutions.com/linux-capabilities-why-they-exist-and-how-they-work)
- [Linux功能在实践中](https://blog.container-solutions.com/linux-capabilities-in-practice)

### 防止权限提升

我们应该在关闭权限提升的情况下运行容器，以防止使用 `setuid` 或 `setgid` 二进制文件提升权限。

## 网络策略

Kubernetes网络必须遵守三个基本规则：

- 容器可以与网络中的任何其他容器通信，过程中没有地址转换——即不涉及NAT
- 集群中的节点可以与网络中的任何其他容器通信，反之亦然。即使在这种情况下，也没有地址转换——即不涉及NAT
- 无论从另一个容器还是从容器本身看，容器的IP地址始终相同。

如果我们计划将集群分割成更小的部分并在命名空间之间实现隔离，第一条规则并没有帮助。

想象一下，如果我们的集群中的用户能够使用集群中的任何其他服务。

现在，想象一下，如果恶意用户获得了对集群的访问权限——他们可以向整个集群发出请求。

为了解决这个问题，我们可以定义 Pod 在当前命名空间和跨命名空间中应该如何被允许通信，使用网络策略。

### 启用网络策略

Kubernetes网络策略指定了对一组Pod的访问权限，就像云中用于控制对VM实例访问的安全组一样。

换句话说，它在Kubernetes集群上运行的Pod之间创建了防火墙。

如果大家不熟悉网络策略，可以阅读[保护Kubernetes集群网络](https://ahmet.im/blog/kubernetes-network-policy/)。

### 每个命名空间都有一个保守的网络策略

此存储库包含各种 Kubernetes 网络策略用例和样本 YAML 文件，可以在设置中利用。如果大家想知道如何在 Kubernetes 上运行的应用程序上丢弃/限制流量，请继续[阅读](https://github.com/ahmetb/kubernetes-network-policy-recipes)。

## 基于角色的访问控制（RBAC）策略

基于角色的访问控制（RBAC）允许我们定义如何访问集群中的资源。

通常的做法是提供最少的权限，但什么是实用的，以及如何量化最少权限？

细粒度策略提供更大的安全性，但需要更多的管理努力。

更广泛的授权可能会给服务帐户提供不必要的API访问权限，但更容易控制。

我们应该为每个命名空间创建一个单一策略并共享它吗？

或者，也许在更细粒度的基础上拥有它们更好？

没有放之四海而皆准的方法，我们应该根据要求逐个判断。

但是从哪里开始呢？

如果我们从一个带有空规则的角色开始，我们可以逐个添加所需的所有资源，并且仍然确信我们没有提供太多。

### 禁用默认 ServiceAccount 的自动挂载

请注意，默认 ServiceAccount 会[自动挂载到所有 Pod 的文件系统中](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#use-the-default-service-account-to-access-the-api-server)。

我们可能希望禁用它并提供更细粒度的策略。

### RBAC策略设置为所需的最少权限

关于如何设置我们的 RBAC 规则，很难找到好的建议。在[Kubernetes RBAC的3种现实方法](https://thenewstack.io/three-realistic-approaches-to-kubernetes-rbac/)中，我们可以找到三种实用场景和实用建议，了解如何开始。

### RBAC策略是细粒度的，不共享

Zalando有一个简洁的政策来定义角色和服务帐户。

首先，他们描述了他们的需求：

- 用户应该能够部署，但他们不应该被允许读取例如 Secrets
- 管理员应该获得所有资源的完全访问权限
- 应用程序默认不应获得写入 Kubernetes API 的权限
- 某些用途应该能够写入 Kubernetes API。

这四个需求转化为五个单独的角色：

- ReadOnly
- PowerUser
- Operator
- Controller
- Admin

大家可以在这个[链接](https://kubernetes-on-aws.readthedocs.io/en/latest/dev-guide/arch/access-control/adr-004-roles-and-service-accounts.html)中阅读他们的决定。

## 自定义策略

即使我们能够在集群中将策略分配给资源，如 Secrets 和 Pods，但在某些情况下，Pod 安全策略（PSPs）、基于角色的访问控制（RBAC）和网络策略可能不够。

例如，我们可能想要避免从公共互联网下载容器，并希望首先批准这些容器。

也许我们有一个内部镜像仓库，只有这个镜像仓库中的镜像才能在集群中部署。

我们如何强制只部署受信任的容器？

没有 RBAC 策略可以做到这一点。

网络策略不会起作用。

我们该怎么办？

我们可以使用[准入控制器](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)来审查提交到集群的资源。

### 只允许从已知镜像仓库部署容器

我们可能要考虑的最常见的自定义策略之一是限制可以在集群中部署的镜像。

以下[教程](https://blog.openpolicyagent.org/securing-the-kubernetes-api-with-open-policy-agent-ce93af0552c3#3c6e)解释了如何使用 Open Policy Agent 来限制未经批准的镜像。

### 强制 Ingress 主机名的唯一性

当用户创建 Ingress 清单时，他们可以使用任何主机名。

```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: example-ingress
spec:
  rules:
    - host: first.example.com
      http:
        paths:
          - backend:
              serviceName: service
              servicePort: 80
```

然而，大家可能希望防止用户**多次使用相同的主机名**并相互覆盖。

Open Policy Agent 的官方文档有一个[教程](https://www.openpolicyagent.org/docs/latest/kubernetes-tutorial/#4-define-a-policy-and-load-it-into-opa-via-kubernetes)，说明如何将 Ingress 资源作为验证 Webhook 的一部分进行检查。

### 只有在 Ingress 主机名中使用已批准的域名

当用户创建 Ingress 清单时，他们可以使用任何主机名。

```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: example-ingress
spec:
  rules:
    - host: first.example.com
      http:
        paths:
          - backend:
              serviceName: service
              servicePort: 80
```

然而，我们可能希望防止用户使用**无效的主机名**。

Open Policy Agent 的官方文档有一个[教程]((https://www.openpolicyagent.org/docs/latest/kubernetes-tutorial/#4-define-a-policy-and-load-it-into-opa-via-kubernetes))，说明如何将 Ingress 资源作为验证 Webhook 的一部分进行检查。

