# Kubernetes 生态各软件的 License 分析

## 1. 引言

`Kubernetes` 是云原生计算基金会（`CNCF`）的核心项目。根据 `CNCF` `2021` 年度调查，**89% 的企业**在生产环境中使用 `Kubernetes`，其生态系统中包含了数百个开源项目。这些项目的许可证种类繁多，给开发者和企业带来了合规性挑战。本文旨在梳理 `Kubernetes` 生态相关软件的 `License` 类型及其影响，为开发者基于 `Kubernetes` 开发和发布软件提供参考。

## 2. 常见软件 `License` 概述

### 2.1 定义和作用

以下是开源社区常见 `License` 的概述：

- **GPL (GNU General Public License)**:
  - **特点**: Copyleft License，强制衍生作品开源。
  - **使用限制**: 修改和分发代码时，必须以 GPL 的形式开放源代码。
  - **历史背景**: GPL 有两个主要版本，GPLv2 和 GPLv3。GPLv3 引入了针对数字版权管理（DRM）和专利授权的额外规定。
  - **参考链接**: [GNU GPL 官方说明](https://www.gnu.org/licenses/gpl-3.0.html)

- **Apache 2.0**:
  - **特点**: 宽松的许可协议，允许修改和闭源分发。
  - **使用限制**: 需保留版权声明和 License 文件，并提供 NOTICE 文件（如适用）。
  - **适用场景**: 广泛用于企业级开源项目。
  - **参考链接**: [Apache 2.0 License 官方说明](https://www.apache.org/licenses/LICENSE-2.0)

- **MIT**:
  - **特点**: 高度宽松，仅需保留原始版权声明。
  - **使用限制**: 无强制性要求，可闭源发布。
  - **参考链接**: [MIT License 官方说明](https://opensource.org/licenses/MIT)

- **BSD**:
  - **特点**: 分为 2-Clause 和 3-Clause 版本，后者要求不得用于推广目的。
  - **使用限制**: 较宽松，但需保留版权声明。
  - **参考链接**: [BSD License 官方说明](https://opensource.org/licenses/BSD-3-Clause)

- **MPL (Mozilla Public License)**:
  - **特点**: 要求修改后的文件须开源，但可与闭源代码结合。
  - **适用范围**: 主要用于 Mozilla 相关项目。
  - **参考链接**: [MPL 2.0 官方说明](https://www.mozilla.org/en-US/MPL/2.0/)

- **CDDL (Common Development and Distribution License)**:
  - **特点**: 与 MPL 类似，但多用于 Sun Microsystems 的软件（如 ZFS）。
  - **参考链接**: [CDDL 官方说明](https://opensource.org/licenses/CDDL-1.0)

- **LGPL (GNU Lesser General Public License)**:
  - **特点**: 较 GPL 宽松，允许与闭源软件动态链接。
  - **使用限制**: 修改后的库文件需开源，但使用库的应用程序无需开源。
  - **参考链接**: [LGPL 官方说明](https://www.gnu.org/licenses/lgpl-3.0.html)

- **AGPL (GNU Affero General Public License)**:
  - **特点**: 类似于 GPL，但增加了网络服务触发条款。
  - **使用限制**: 通过网络提供服务时，需提供源代码。
  - **参考链接**: [AGPL 官方说明](https://www.gnu.org/licenses/agpl-3.0.html)

### 2.2 第三方使用限制

| License 类型       | 是否允许修改 | 是否允许闭源分发 | 主要限制                                   |
|--------------------|--------------|------------------|-------------------------------------|
| **GPL**            | 是           | 否               | 衍生作品必须开源                        |
| **LGPL**           | 是           | 是               | 修改后的库文件需开源，应用程序无需开源     |
| **AGPL**           | 是           | 否               | 衍生作品必须开源，网络服务需提供源代码     |
| **Apache 2.0**     | 是           | 是               | 保留版权声明，提供 NOTICE 文件           |
| **MIT**            | 是           | 是               | 保留版权声明                               |
| **BSD (2-Clause)** | 是           | 是               | 保留版权声明                               |
| **BSD (3-Clause)** | 是           | 是               | 保留版权声明，不得用于推广用途             |
| **MPL**            | 是           | 是               | 修改后的文件需开源，但可与闭源代码结合     |
| **CDDL**           | 是           | 是               | 修改后的文件需开源，但可与闭源代码结合     |

### 2.3 OSS License 选择

* 《**Everything you need to know about Open Source & Third-party Software Policy Guidelines**》
	- **地址**：https://www.bridgenext.com/blog/everything-you-need-to-know-about-open-source-third-party-software-policy-guidelines/ 
 ![](https://resources.bridgenext.com/wp-content/uploads/2024/02/OSS-components-guidance.png)

* 《**如何选择开源许可证？**》
	- **作者**：`阮一峰`
	- **地址**：https://www.ruanyifeng.com/blog/2011/05/how_to_choose_free_software_licenses.html
![License 区别](https://www.ruanyifeng.com/blogimg/asset/201105/bg2011050101.png)

## 3. `Kubernetes` 生态各软件的 `License` 分类整理

### 3.1 `Kubernetes` 核心组件

| 软件名称               | 功能             | License    | 修改闭源分发 | 附加要求                     | License 地址                                                                 |
|------------------------|------------------|------------|--------------|------------------------------|------------------------------------------------------------------------------|
| kube-apiserver         | 处理API请求       | Apache 2.0 | 是           | 保留版权声明                 | [GitHub - kubernetes/kubernetes/LICENSE](https://github.com/kubernetes/kubernetes/blob/master/LICENSE) |
| kube-scheduler         | 调度Pod           | Apache 2.0 | 是           | 保留版权声明                 | 同上                                                                         |
| kube-controller-manager| 控制器管理        | Apache 2.0 | 是           | 保留版权声明                 | 同上                                                                         |
| kubelet                | 节点管理          | Apache 2.0 | 是           | 保留版权声明                 | 同上                                                                         |
| kube-proxy             | 服务网络代理      | Apache 2.0 | 是           | 保留版权声明                 | 同上                                                                         |
| etcd                   | 分布式存储        | Apache 2.0 | 是           | 保留版权声明                 | [GitHub - etcd-io/etcd/LICENSE](https://github.com/etcd-io/etcd/blob/main/LICENSE) |

### 3.2 容器运行时

| 软件名称   | 功能             | License    | 修改闭源分发 | 附加要求                     | License 地址                                                                 |
|------------|------------------|------------|--------------|------------------------------|------------------------------------------------------------------------------|
| containerd | 容器运行时       | Apache 2.0 | 是           | 保留版权声明                 | [GitHub - containerd/containerd/LICENSE](https://github.com/containerd/containerd/blob/main/LICENSE) |
| runc       | 容器运行工具     | Apache 2.0 | 是           | 保留版权声明                 | [GitHub - opencontainers/runc/LICENSE](https://github.com/opencontainers/runc/blob/main/LICENSE) |
| Docker CE  | 容器化平台       | Apache 2.0 | 是           | 保留版权声明                 | [GitHub - docker/docker-ce/LICENSE](https://github.com/docker/docker-ce/blob/master/LICENSE) |

### 3.3 网络相关

| 软件名称 | 功能             | License    | 修改闭源分发 | 附加要求                     | License 地址                                                                 |
|----------|------------------|------------|--------------|------------------------------|------------------------------------------------------------------------------|
| CoreDNS  | DNS服务         | Apache 2.0 | 是           | 保留版权声明                 | [GitHub - coredns/coredns/LICENSE](https://github.com/coredns/coredns/blob/master/LICENSE) |
| flannel  | 网络插件         | Apache 2.0 | 是           | 保留版权声明                 | [GitHub - flannel-io/flannel/LICENSE](https://github.com/flannel-io/flannel/blob/master/LICENSE) |
| calico   | 网络与安全       | Apache 2.0 | 是           | 保留版权声明                 | [GitHub - projectcalico/calico/LICENSE](https://github.com/projectcalico/calico/blob/master/LICENSE) |
| cilium   | 高性能网络       | Apache 2.0 | 是           | 保留版权声明                 | [GitHub - cilium/cilium/LICENSE](https://github.com/cilium/cilium/blob/master/LICENSE) |

### 3.4 监控

| 软件名称       | 功能             | License    | 修改闭源分发 | 附加要求                     | License 地址                                                                 |
|----------------|------------------|------------|--------------|------------------------------|------------------------------------------------------------------------------|
| Prometheus     | 指标采集与监控   | Apache 2.0 | 是           | 保留版权声明                 | [GitHub - prometheus/prometheus/LICENSE](https://github.com/prometheus/prometheus/blob/main/LICENSE) |
| Grafana        | 数据可视化       | AGPLv3     | 否           | 衍生作品需开源               | [GitHub - grafana/grafana/LICENSE](https://github.com/grafana/grafana/blob/main/LICENSE) |
| metrics-server | 资源指标采集     | Apache 2.0 | 是           | 保留版权声明                 | [GitHub - kubernetes-sigs/metrics-server/LICENSE](https://github.com/kubernetes-sigs/metrics-server/blob/main/LICENSE) |

### 3.5 微服务治理

| 软件名称 | 功能             | License    | 修改闭源分发 | 附加要求                     | License 地址                                                                 |
|----------|------------------|------------|--------------|------------------------------|------------------------------------------------------------------------------|
| istio    | 服务网格         | Apache 2.0 | 是           | 保留版权声明                 | [GitHub - istio/istio/LICENSE](https://github.com/istio/istio/blob/master/LICENSE) |
| Linkerd  | 服务网格         | Apache 2.0 | 是           | 保留版权声明                 | [GitHub - linkerd/linkerd2/LICENSE](https://github.com/linkerd/linkerd2/blob/main/LICENSE) |

### 3.6 无服务计算

| 软件名称 | 功能             | License    | 修改闭源分发 | 附加要求                     | License 地址                                                                 |
|----------|------------------|------------|--------------|------------------------------|------------------------------------------------------------------------------|
| Knative  | 无服务器框架     | Apache 2.0 | 是           | 保留版权声明                 | [GitHub - knative/serving/LICENSE](https://github.com/knative/serving/blob/main/LICENSE) |
| OpenFaaS | 无服务器平台     | MIT        | 是           | 保留版权声明                 | [GitHub - openfaas/faas/LICENSE](https://github.com/openfaas/faas/blob/master/LICENSE) |

### 3.7 以 `Grafana` 为例进行 `License` 风险分析

`Grafana` 是一个开源的可视化工具，其核心代码采用 **AGPLv3** 许可证。`AGPLv3` 是一种强 `Copyleft` 许可证，对使用和分发有严格的要求。以下针对您的问题进行详细分析：

#### 3.7.1 **使用场景描述**
- **直接使用 `Grafana` 安装包**：假设我们使用的是官方发布的 `Grafana` 二进制安装包，未对源码进行任何修改。
- **加载自定义 `Dashboard`**：假设我们创建了自己的 Dashboard（仪表盘），并将其加载到 `Grafana` 中。


### 3.7.2 **AGPLv3 的核心要求**
AGPLv3 的主要要求包括：
- **修改源码并分发**：如果您修改了 `Grafana` 的源码并分发（包括通过网络提供服务），则必须公开修改后的源码。
- **网络服务触发条款**：即使您未分发软件，但通过网络提供服务（如 `SaaS`），也需要提供源码。
- **衍生作品的定义**：`AGPLv3` 要求衍生作品（即基于 `AGPLv3` 代码的修改或扩展）也必须遵循 `AGPLv3`。

#### 3.7.3 **上述使用场景是否触发 `AGPLv3` 的要求？**

##### 3.7.3.1 **未修改源码**
- 如果我们使用的是官方发布的 Grafana 安装包，且未对源码进行任何修改，那么我们并未创建衍生作品。
- **结论**：未触发 `AGPLv3` 的源码公开要求。

##### 3.7.3.2 **加载自定义 Dashboard**
- `Dashboard` 是 `Grafana` 的配置文件（`JSON` 格式），通常被视为**数据**而非**代码**。
- 根据 `AGPLv3` 的定义，数据（如配置文件、用户生成内容）不属于衍生作品。
- **结论**：加载自定义 `Dashboard` 不会触发 `AGPLv3` 的要求。

##### 3.7.3.3 **网络服务场景**
- 如果您将 `Grafana` 部署为网络服务（如 `SaaS`），`AGPLv3` 要求您向用户提供 `Grafana` 的源码。
- 由于您未修改源码，只需提供原始 `Grafana` 的源码链接即可满足要求。
- **结论**：网络服务场景下，您需要提供 `Grafana` 的源码链接，但无需公开您的 `Dashboard`。

#### 3.7.4. **是否存在 License 风险？**
- **无源码修改**：如果我们未修改 `Grafana` 的源码，且仅使用官方安装包，不会触发 `AGPLv3` 的衍生作品条款。
- **自定义 Dashboard**：`Dashboard` 是数据而非代码，不会被视为衍生作品，因此不会触发 `AGPLv3` 的要求。
- **网络服务**：如果我们通过网络提供服务，需要提供 `Grafana` 的源码链接，我们只需指向 `Grafana` 的官方仓库即可。

**总结**：在您的使用场景中，**不存在 License 风险**，只要您遵守 `AGPLv3` 的基本要求（如提供源码链接）。

#### 3.7.5 **建议**

- **明确源码来源**：如果您通过网络提供服务，确保在您的服务中提供 `Grafana` 的源码链接（例如指向 [Grafana GitHub 仓库](https://github.com/grafana/grafana)）。
- **避免修改源码**：如果您需要扩展 `Grafana` 的功能，建议通过插件或外部服务实现，而不是直接修改 Grafana 的源码。
- **监控 License 变更**：关注 `Grafana` 的 `License` 变化，确保我们的使用方式始终符合其最新要求。

## 4. 基于 Kubernetes 开发和发布的 License 使用建议

### 4.1 不同 License 的使用建议

- **GPL软件**：避免与闭源模块混用，否则可能违反开源协议。
- **Apache 2.0软件**：适合闭源场景，但需满足版权声明要求。
- **MIT/BSD软件**：限制较少，适合商业化使用。

### 4.2 不同软件结合使用的潜在风险

- **GPL与闭源冲突**：不得将 `GPL` 软件与闭源模块静态链接。
- **AGPLv3的限制**：`Grafana` 等软件的修改版本需公开源代码。

### 4.3 开发者合规建议

为了确保在使用 `Kubernetes` 生态中的开源软件时符合 `License` 要求，开发者可以采取以下措施：

#### 4.3.1 **使用 License 扫描工具**
使用自动化工具扫描代码库和依赖项，识别潜在的 `License` 冲突和合规性问题。

- **推荐工具**：
  - **FOSSA**: 提供全面的开源依赖管理和 License 合规性分析。
    - 官网: [https://fossa.com/](https://fossa.com/)
  - **SPDX**: 提供标准化的 License 标识和工具链支持。
    - 官网: [https://spdx.dev/](https://spdx.dev/)
  - **Snyk**: 专注于安全性和 License 合规性。
    - 官网: [https://snyk.io/](https://snyk.io/)
  - **Black Duck**: 提供开源组件管理和 License 风险分析。
    - 官网: [https://www.synopsys.com/software-integrity/security-testing/software-composition-analysis/black-duck.html](https://www.synopsys.com/software-integrity/security-testing/software-composition-analysis/black-duck.html)

#### 4.3.2 **遵守各 License 的附加要求**
不同的 `License` 有不同的附加要求，开发者需特别注意以下几点：

- **Apache 2.0**:
  - 保留原始版权声明。
  - 提供 `NOTICE` 文件（如果适用）。
  - 参考: [Apache 2.0 License 官方说明](https://www.apache.org/licenses/LICENSE-2.0)

- **GPL/AGPL**:
  - 确保衍生作品开源。
  - 避免与闭源模块静态链接。
  - 参考: [GNU GPL 官方说明](https://www.gnu.org/licenses/gpl-3.0.html)

- **MIT/BSD**:
  - 保留原始版权声明。
  - 参考: [MIT License 官方说明](https://opensource.org/licenses/MIT)

- **MPL/CDDL**:
  - 修改后的文件需开源，但可与闭源代码结合。
  - 参考: [MPL 2.0 官方说明](https://www.mozilla.org/en-US/MPL/2.0/)

#### 4.3.3 **建立 License 管理流程**
制定并实施 License 管理流程，确保合规性贯穿整个开发周期。

- **关键步骤**：
  1. **依赖项管理**：
     - 使用工具（如 `go mod`、`npm`、`pip`）明确记录所有依赖项。
     - 定期更新依赖项，避免使用过时或存在风险的版本。
  2. **License 审计**：
     - 定期检查项目中的开源组件及其 License。
     - 确保所有组件的 License 与项目目标兼容。
  3. **文档化**：
     - 在项目中添加 `LICENSE` 和 `NOTICE` 文件，明确声明使用的开源组件及其 License。
     - 参考: [Kubernetes NOTICE 文件示例](https://github.com/kubernetes/kubernetes/blob/master/NOTICE)

- **工具支持**：
  - **License Compliance Checker**: 用于检查代码库中的 License 合规性。
    - GitHub: [https://github.com/facebookincubator/FBSourceTools/tree/master/oss/third-party-license-compliance](https://github.com/facebookincubator/FBSourceTools/tree/master/oss/third-party-license-compliance)
  - **REUSE**: 帮助项目遵循 SPDX 标准，管理 License 信息。
    - 官网: [https://reuse.software/](https://reuse.software/)

## 5. 总结

`Kubernetes` 生态中的开源软件以 **Apache 2.0** 为主，同时也包含 **MIT**、**GPL** 等其他协议。开发者应深入了解所用软件的 `License` 要求，在修改和分发时严格遵守相应规则，以确保合规性并降低法律风险。随着 `Kubernetes` 生态的持续发展，`License` 管理将成为开发者社区的重要课题。

## 6. 参考文献

1. **Kubernetes 官方文档**  
   - 链接: [https://kubernetes.io/docs/](https://kubernetes.io/docs/)

2. **开源社区 License 指南**  
   - Open Source Initiative (OSI): [https://opensource.org/licenses](https://opensource.org/licenses)  
   - Choose a License: [https://choosealicense.com/](https://choosealicense.com/)

3. **CNCF 开源指南**  
   - 链接: [https://www.cncf.io/oss/](https://www.cncf.io/oss/)