Docker 镜像、容器和存储卷清理指南（Docker Cleanup - A Guide for Clearing Images, Containers, and Volumes）
=====================================================================

Docker has revolutionized application deployment, offering flexibility and efficiency through its containerization technology.

Docker 彻底改变了应用程序部署，通过其容器化技术提供了灵活性，并提升了效率。

As Docker environments evolve and grow, managing resources like containers, images, volumes, and networks becomes increasingly challenging.

随着 Docker 环境越用越久，管理容器、镜像、卷和网络等资源变得越来越具有挑战性。

Docker Cleanup addresses this challenge by providing a systematic approach to identify and remove unused or unnecessary resources.

***Docker 清理*** 通过提供一种系统方法来识别和删除未使用或不必要的资源来解决这一挑战。

In this blog, Let us explore the essential commands and techniques for cleaning up Docker resources effectively. Additionally, we will also see the significance of regular Docker cleanup routines in preventing resource clutter and mitigating security risks.

在这篇博客中，让我们探索有效清理 Docker 资源的基本命令和方法。此外，我们还将看到定期 Docker 清理在防止资源混乱和降低安全风险方面的重要性。

Lets get started!

坐稳出发！

### Table of Contents

1.  **Docker 清理：简介（Docker Cleanup: An Introduction）**
2.  **Docker 基础知识（Docker Essentials）**
3.  **Docker 磁盘空间管理（Docker Disk Space Management）**
4.  **Docker 清理命令（Docker Prune Command）**
5.  **删除 Docker 镜像（Removing Docker Images）**
6.  **删除 Docker 容器（Removing Docker Containers）**
7.  **删除 Docker 卷（Removing Docker Volumes）**
8.  **删除 Docker 网络（Removing Docker Network）**
9.  **定期清理 Docker 的重要性（Importance of Regular Docker Cleanup）**
10.  **Docker 清理命令备忘单（Docker Cleanup Command Cheatsheet）**

Docker 清理：简介（Docker Cleanup: An Introduction）
-------------------------------

Docker Cleanup is a process that involves managing resources used by Docker, a popular platform for developing, shipping, and running applications. When you work with Docker, you create containers, which are lightweight, portable environments that package an application and its dependencies.

Docker 是一个用于开发、发布和运行应用程序的流行平台，Docker 清理是一个涉及管理 Docker 使用的资源的过程。使用 Docker 时，我们可以创建容器，它们是打包应用程序及其依赖项的轻量级、可移植环境。

Over time, these [docker containers](https://www.atatus.com/glossary/container/), along with other Docker resources like images, volumes, and networks, can accumulate and consume disk space. Thus, to prevent the accumulation of unused or unnecessary resources, Docker Cleanup helps to remove them. This process frees up disk space and improves system performance.

但是随着时间的推移，这些 [docker containers](https://www.atatus.com/glossary/container/) 以及其他 Docker 资源（例如映像、卷和网络）可能会累积并消耗磁盘空间。因此，为了防止未使用或不必要的资源积累，Docker 清理有助于删除这些不需要的垃圾。此过程可以释放磁盘空间并提高系统性能。

It works by identifying and deleting containers, images, volumes, and networks that are no longer in use or needed. Thus regularly using Docker Cleanup keeps systems organized, efficient, and clutter-free, ensuring applications run smoothly.

它的工作原理是识别和删除不再使用或不需要的容器、镜像、存储卷和网络。此外，定期进行 Docker 清理可以保持系统组织有序、高效且整洁，确保应用程序平稳运行。

Docker 基础知识（Docker Essentials）
-----------------

In Docker, an image is essentially a package containing all the necessary files and settings for an application to run. When you run an image, it creates a container, which is like a virtual environment where the application can operate independently.

在 Docker 中，镜像本质上是一个包，其中包含应用程序运行所需的所有文件和设置。当我们运行一个镜像时，它会创建一个容器，它就像一个虚拟环境，应用程序可以在其中独立运行。

Docker Containers can interact with each other through networks, which enable communication between them. Additionally, Docker volumes provide a way for containers to store and access data, even after the container is shut down.

Docker 容器可以通过网络相互交互，从而实现它们之间的通信。此外，Docker 存储卷为容器提供了一种存储和访问数据的方法，即使在容器关闭后可以继续保存。

Together, these components form the basis of Docker's containerization system, allowing for efficient and reliable application deployment and management.

这些组件共同构成了 Docker 容器化系统的基础，从而实现高效可靠的应用程序部署和管理。

For a deeper understanding of Docker containers, check out the [link](https://www.atatus.com/blog/docker-container-lifecycle-management/).

要更深入地了解 Docker 容器，请查看 [link](https://www.atatus.com/blog/docker-container-lifecycle-management/)。

Docker 磁盘空间管理（Docker Disk Space Management）
----------------------------

It is necessary to regularly check the disk space occupied by Docker to ensure efficient resource management and prevent running out of disk space.

我们有必要定期检查 Docker 占用的磁盘空间，以保证高效的资源管理，以及防止磁盘空间耗尽。

This helps to maintain system performance and avoid potential issues such as failed deployments or slowed container operations.

这有助于维护系统性能并避免潜在问题，例如部署失败或容器操作速度减慢。

To check the disk space usage of Docker, you can use the following command,

要检查 Docker 的磁盘空间使用情况，可以使用以下命令，

```bash
    docker system df
```    

This command provides total disk space occupied by Docker components such as images, containers, volumes, and build cache. Here's a sample output.

此命令提供 Docker 组件（例如镜像、容器、存储卷和构建缓存）占用的总磁盘空间。这是一个示例输出。

```bash
    docker system df
    TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
    Images          4         0         2.863GB   2.863GB (100%)
    Containers      0         0         0B        0B
    Local Volumes   1         0         209.1MB   209.1MB (100%)
    Build Cache     10        0         0B        0B
```

If you run `docker system df -v`, Docker will provide more detailed information about the disk usage, including sizes of individual components, filesystem types, and mount points.

如果运行 `docker system df -v`，Docker 将提供有关磁盘使用情况的更详细信息，包括各个组件的大小、文件系统类型和挂载点。

```bash
    docker system df -v
```    

Using the verbose option can be helpful when you need more detailed information for troubleshooting, analysis, or understanding the behaviour of Docker commands. Here's a sample output.

当我们需要更详细的信息来进行故障排除、分析或了解 Docker 命令的行为时，使用详细选项会很有帮助。这是一个示例输出。

```bash
    docker system df -v
    Images space usage:
    
    REPOSITORY           TAG       IMAGE ID       CREATED       SIZE      SHARED SIZE   UNIQUE SIZE   CONTAINERS
    node                 latest    5199d6829c95   5 days ago    1.11GB    0B            1.108GB       0
    mysql                latest    f3df03e3cfc9   7 days ago    585MB     0B            584.5MB       0
    atatus-infra-agent   1.0.0     68547e56bd6c   2 weeks ago   347MB     0B            347.1MB       0
    
    Containers space usage:
    
    CONTAINER ID   IMAGE     COMMAND   LOCAL VOLUMES   SIZE      CREATED   STATUS    NAMES
    
    Local Volumes space usage:
    
    VOLUME NAME                                                        LINKS     SIZE
    a5eb1d542fea4baf1e230d55eb57c6d1af4f26d2f122e1ce88ffa3315b5b4608   0         209.1MB
    
    Build cache usage: 0B
    
    CACHE ID       CACHE TYPE   SIZE      CREATED       LAST USED     USAGE     SHARED
    7wiqaoxjggbm   regular      105MB     2 weeks ago   2 weeks ago   1         true
    42jd60vtodvv   regular      398B      2 weeks ago   2 weeks ago   1         true
    ihxc4v6iaj3a   regular      0B        2 weeks ago   2 weeks ago   1         true
    cj1nnct3g02c   regular      52.6MB    2 weeks ago   2 weeks ago   1         true
    6jk6z52csgem   regular      7MB       2 weeks ago   2 weeks ago   1         true
    t0kjz0u3ot6b   regular      0B        2 weeks ago   2 weeks ago   1         true
    ryelnhbdosgn   regular      0B        2 weeks ago   2 weeks ago   1         true
    g6965smp8sv1   regular      0B        2 weeks ago   2 weeks ago   1         true
    qjwfflqewqdw   regular      105MB     2 weeks ago   2 weeks ago   1         true
    y3525s5zwwbs   regular      398B      2 weeks ago   2 weeks ago   2         true
```

Docker 清理命令（Docker Prune Command）
--------------------

The Docker prune command is a clean up tool in your Docker environment. You can use Docker prune when your system is running low on disk space, or when you want to ensure that only necessary Docker components are occupying your system resources. The `docker system prune` command removes unused data, including:

Docker prune 命令是 Docker 环境中的清理工具。当系统磁盘空间不足时，或者当我们想确保只有必要的 Docker 组件占用系统资源时，可以使用 Docker prune。 `docker system prune` 命令删除未使用的数据，包括：

*   所有已停止的容器（All stopped Containers）
*   所有没有被至少一个容器未使用的网络（All networks not used by at least one container）
*   所有悬空镜像（All dangling images）
*   所有悬空构建缓存（All dangling build cache）

It is particularly useful in development or testing environments where you are frequently creating and deleting containers or images.

它在经常会创建和删除容器或镜像的开发或测试环境中特别有用。

```bash
    docker system prune
    WARNING! This will remove:
      - all stopped containers
      - all networks not used by at least one container
      - all dangling images
      - all dangling build cache
    
    Are you sure you want to continue? [y/N] y
    Deleted Containers:
    aafb7f5c9e1e00e21e83e0c4d48e9bb02186ea9a3388afb7d607f052af43aa22
    Total reclaimed space: 48B
```

By running Docker system prune, you can reclaim disk space by removing unnecessary resources.

通过运行 Docker 系统清理命令，我们可以通过删除不必要的资源来回收磁盘空间。

If you want to force delete all the unused resources without confirmation, you can run this command,

如果我们想强制删除所有未使用的资源而不确认，可以运行此命令，

```bash
    docker system prune -f
```  

This is useful when you want to automate Docker cleanup tasks or when you are confident about the resources you are deleting and don't need a confirmation step.

当我们想要自动执行 Docker 清理任务或当我们对要删除的资源有信心并且不需要确认步骤时，这非常有用。

Just be cautious when using this option, as it will delete all unused resources without further verification.

使用此选项时请务必小心，因为它将删除所有未使用的资源而不进行进一步验证。

删除 Docker 镜像（Removing Docker Images）
----------------------

### (i). 删除一个或者多个指定镜像（Remove one or more specific image）

```bash
    docker images -a
```

This command provides a list of Docker images, listing both base images and intermediate layers. It displays information such as image IDs, tags, and additional details for each entry.

此命令提供 Docker 镜像列表，其中列出了基础镜像和中间层。它显示每个条目的镜像 ID、标签和其他详细信息等信息。

``` bash
    docker images -a
    REPOSITORY           TAG       IMAGE ID       CREATED       SIZE
    node                 latest    5199d6829c95   5 days ago    1.11GB
    mysql                latest    f3df03e3cfc9   7 days ago    585MB
    atatus-infra-agent   1.0.9     68547e56bd6c   2 weeks ago   347MB
```

Once you have identified the image/ images you want to remove, use the `docker rmi` command followed by the image ID or tag.

当确定要删除的一个或多个镜像后，请使用 `docker rmi` 命令，后跟镜像 ID 或标签。


*   通过 ID 删除 docker 镜像（To remove a docker image by its ID）,

```bash
    docker rmi image_id
	
    docker rmi 5199d6829c95
    Untagged: node:latest
    Untagged: node@sha256:64c46a664eccedec63941dab4027c178a36debe08a232d4f9d7da5aca91cff3d
    Deleted: sha256:5199d6829c9501975002f30375c1b1ff47c5a71b8bfa07d9696c33fa6fb42c7b
    Deleted: sha256:500f6fb1ae68c70173ac5676635fd142add25dcdf53e5325d1210745526aba71
    Deleted: sha256:cb9ae0245c58ae6f85c5fe5886bca018086a447180b8647a29f1ca87554fdc2c
    Deleted: sha256:10e725eccfc92734937b04b3dfd60f6e7d4c5740c24d5d1c4215829ceceefc4d
    Deleted: sha256:d3fb96d9acb6e6d933e3728b4ad5b940bb46bf1d94944ee3424f735c4b3a64c6
    Deleted: sha256:41a13d456d84469e658d82f10bd734f302daab6f65c4cae441299b4a03d3a123
```

**Note:** The command `docker rmi 5199d6829c95` was executed to remove the specified Docker image `node:latest`. Following the command, Docker successfully untagged and deleted the specified image. Additionally, Docker identified and deleted other associated layers that were shared among multiple images, ensuring efficient disk space management. Docker employs similar behaviour for other commands that involve the manipulation of images and containers.

**注意：** 执行命令 `docker rmi 5199d6829c95` 是为了删除指定的 Docker 镜像 `node:latest`。按照该命令，Docker 成功取消标记并删除了指定镜像。此外，Docker 还识别并删除了多个镜像之间共享的其他关联层，从而确保高效的磁盘空间管理。 Docker 对涉及镜像和容器操作的其他命令采用类似的行为。

*   通过标签删除 docker 镜像（To remove a docker image by its tag）,

``` bash
    docker rmi image_tag

    docker rmi golang:latest
    Untagged: golang:latest
    Untagged: golang@sha256:b1e05e2c918f52c59d39ce7d5844f73b2f4511f7734add8bb98c9ecdd4443365
    Deleted: sha256:e0aa2034f411a9f1a2480237a67461716a74dc096a5e74f07e17d30d3021aa8b
    Deleted: sha256:0e966fff3a6ee66b5d6df4e515295b76ecb7a46cb9115d81226c8f4a1211994c
    Deleted: sha256:92de0673715e39e1f2f9e02b74b2ee9d0a20edff0ab1e2edf890765b00b58ee4
    Deleted: sha256:b7bd751ca66c5cfe91cb0325a8186b507188a9b5edb4709947e919c3861ad1b5
    Deleted: sha256:6a2b24ee9cdc8a5fedbd84de9302a4c5357b37f3623ba2d1933582cf7e255dd0
```

*   一次性删除多个 docker 镜像（To remove multiple docker images at once）,

```bash
    docker rmi image1 image2 image3
```

*   一次性删除所有 docker 镜像（To remove all docker images at once）,

```bash
    docker rmi $(docker images -a -q)
```

### (ii). 使用过滤器删除 Docker 镜像（Remove Docker Images with Filters）

To remove Docker images with filters, you can use the `docker image prune` command along with filtering options.

要通过过滤器删除 Docker 镜像，我们可以使用 `docker image prune` 命令以及过滤选项。

```bash
    docker image prune --filter "your_filter"
```    

By using filters with the `docker image prune` command, you can specifically target and remove only the unused (dangling) images.

通过将过滤器与 `docker image prune` 命令结合使用，我们可以专门定位并仅删除未使用的（悬空）镜像。

*   删除在 24 小时前创建的 docker 镜像（To remove docker images that were created more than 24 hours ago）

```bash
    docker image prune --filter "until=24h"
    WARNING! This will remove all dangling images.
    Are you sure you want to continue? [y/N] y
    Deleted Images:
    deleted: sha256:8ff5c7cc34074ab24778653f4f6632b05440b97afe30a7c94f3e744750b4b03c
    Total reclaimed space: 10B
```

*   删除具有特定标签的 docker 镜像（To remove docker images with a specific label）

```bash
    docker image prune --filter "label=unused"
```    

*   删除悬空镜像（To remove dangling docker images）

```bash
    docker image prune --filter "dangling=true"
    untagged:mysql@sha256:091fe36a5591449a69d3011bf05cf083201e4c031101f071447bd985f5
    deleted: sha256:6f2df62f26cc90e1fa08d55f31d4b13f009d3849b1aff23b77797e284336acca
    Total reclaimed space: 743.9MB
```

### (iii). 根据模式删除镜像（Remove Images based on a Pattern）

This is a specific approach to manage Docker images, focusing on filtering and removing images based on a pattern.

这是一种管理 Docker 镜像的特定方法，重点是根据模式过滤和删除镜像。

*   首先使用以下命令列出所有 docker 镜像（First use the following command to list all the docker images）,

```bash
    docker images -a

    REPOSITORY           TAG       IMAGE ID       CREATED        SIZE
    golang               latest    e0aa2034f411   18 hours ago   823MB
    mysql                latest    f3df03e3cfc9   7 days ago     585MB
    atatus-infra-agent   1.0.9     68547e56bd6c   2 weeks ago    347MB
```

*   然后使用 `grep "pattern"` 过滤此列表，仅显示与指定模式匹配的镜像（Then use `grep "pattern"` to filter this list, showing only the images that match the specified pattern）.

```bash
    docker images -a | grep "mysql"
    mysql                latest    f3df03e3cfc9   7 days ago     585MB

	docker images -a | grep "golang" | awk '{print $1":"$2}' | xargs docker rmi
    Untagged: golang:latest
    Untagged: golang@sha256:b1e05e2c918f52c59d39ce7d5844f73b2f4511f7734add8bb98c9ecdd4443365
    Deleted: sha256:e0aa2034f411a9f1a2480237a67461716a74dc096a5e74f07e17d30d3021aa8b
    Deleted: sha256:0e966fff3a6ee66b5d6df4e515295b76ecb7a46cb9115d81226c8f4a1211994c
    Deleted: sha256:92de0673715e39e1f2f9e02b74b2ee9d0a20edff0ab1e2edf890765b00b58ee4
    Deleted: sha256:b7bd751ca66c5cfe91cb0325a8186b507188a9b5edb4709947e919c3861ad1b5
    Deleted: sha256:6a2b24ee9cdc8a5fedbd84de9302a4c5357b37f3623ba2d1933582cf7e255dd0
    Deleted: sha256:b970d87779b54a60898c739c0545a878abca1dc0baabbdc74e5645782b20ef5d
    Deleted: sha256:609a42498e5cd50cecf991708b09a6c29f321d00eccb994167d804b16af8a3dd
    Deleted: sha256:072686bcd3db19834cd1e0b1e18acf50b7876043f9c38d5308e5e579cbefa6be
```

This command removes the specified Docker images.

此命令删除指定的 Docker 镜像。

删除 Docker 容器（Removing Docker Containers）
--------------------------

### (i). 删除一个或多个容器（Remove One or More Containers）

To remove one or more containers using Docker, you can use the `docker rm` command followed by the the container ID or name of the containers you want to remove.

要使用 Docker 删除一个或多个容器，我们可以使用 `docker rm` 命令，后跟要删除的容器的容器 ID 或名称。

```bash
    docker rm ID_or_Name ID_or_Name

    docker rm ac144553cdf7
    ac144553cdf7
```

### (ii). 退出时删除容器（Remove a Container upon Exiting）

To automatically remove a container upon exiting, you can use the `--rm` option.

要在退出时自动删除容器，可以使用 `--rm` 选项。

```bash
    docker run --rm image_name
```

You can replace `image_name` with the desired option you want to remove.

我们可以将 `image_name` 替换为要删除的所需选项。

### (iii). 删除所有退出的容器（Remove all Exited Containers）

If you specifically want to see containers that have stopped running, you can use the `-f` flag with the status `exited`. This helps you identify containers that are no longer active.

如果我们只想查看已停止运行的容器，可以使用状态为 `exited` 的 `-f` 标志。这可以帮助大家识别不再活跃的容器。

```bash
    docker ps -a -f status=exited
    CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS                     PORTS     NAMES
    1cb69341b9ad   mysql     "docker-entrypoint.s…"   2 minutes ago   Exited (1) 2 minutes ago             adoring_austin
```

After identifying you can pass their IDs to the `docker rm` command using the `-q` flag. The `-q` flag simplifies the output of the `docker rm` command by showing only the IDs of the containers being removed, making it easier and quicker to remove them.

识别出要删除的容器后，我们可以使用 `-q` 标志将它们的 ID 传递给 `docker rm` 命令。 `-q` 标志通过仅显示要删除的容器的 ID 来简化 `docker rm` 命令的输出，从而更轻松、更快速地删除它们。

```bash
    docker rm $(docker ps -a -f status=exited -q)
    1cb69341b9ad
```

### (iv). 删除所有 Docker 容器（Remove all Docker Containers）

To remove all Docker containers from your system, you can use the following command. So, when you execute `docker rm $(docker ps -aq)`, it will remove all containers, regardless of whether they are currently running or have already exited.

要从系统中删除所有 Docker 容器，可以使用以下命令。因此，当我们执行 `docker rm $(docker ps -aq)` 时，它将删除所有容器，无论它们当前是正在运行还是已经退出。

```bash
    docker rm $(docker ps -aq)
    8a2a2984c9b9
    3882e4efac11
    cd0f135e9e38
```

Please note that this action cannot be undone. Make sure you want to proceed with this operation before executing the command.

请注意，此操作无法撤消。在执行该命令之前，请确保是否要继续执行此操作。

### (v). 按模式删除 Docker 容器（Remove Docker Containers by Pattern）

```bash
    docker ps -a | grep "pattern"
```

This command helps to find containers whose names or other details match a specific pattern.

此命令有助于查找名称或其他详细信息与特定模式匹配的容器。

```bash
    docker ps -a | grep "node"
    f7ea490859b7   node      "docker-entrypoint.s…"   30 seconds ago   Up 30 seconds             condescending_bardeen
```

After identifying the containers you want to remove, you can use the following command to remove them.

确定要删除的容器后，可以使用以下命令来删除它们。

```bash
    docker ps -a | grep "pattern" | awk '{print $1}' | xargs docker rm
```    

Here `awk '{print $1}'` part extracts the container IDs from the output, and `xargs docker rm` passes the IDs to the `docker rm` command to remove the containers.

这里，`awk '{print $1}'` 部分从输出中提取容器 ID，而 `xargs docker rm` 将 ID 传递给 `docker rm` 命令以删除容器。

```bash
    docker ps -a | grep "node" | awk '{print $1}' | xargs docker rm
    f7ea490859b7
```

### (vi). Docker 容器清理（Docker Container Prune）

The `docker container prune` command is used to remove all stopped containers. Executing this command will permanently remove all stopped containers. Before running it, ensure you no longer need any data from the stopped containers.

`docker container prune` 命令用于删除所有停止的容器。执行此命令将永久删除所有已停止的容器。在运行之前，请确保我们不再需要已停止容器中的任何数据。

```bash
    docker container prune
    WARNING! This will remove all stopped containers.
    Are you sure you want to continue? [y/N] y
    Deleted Containers:
    e5d57327181cf9f07435c8831ae4d8aace0735ae0739a292b8c6fd77fc607492
    aeb630c17970fcadf78d5a40998d01824967ead9bae89cff4c8b90a7f4862e27
    1e0cbfa96ec7e5d378b4ade539610d91e4a5ee9366e2b614bafd35f475a58af4
    e705a877b83da9cc9553e446db042772231bb189dc198149dd0535fc81b5370e
    66a49786540fbbc8d53808d9f44ed6bc678d28e21368a75f4e15a681b37702bd
    67acac9abd34adecbbd691fb456d44bbee3558d288b96b7aee30b4333971b60d
    37c4386bd1bad435624d16ab2a0af0ccf9ab3fa52ee304463fa0f373b86c4410
    a434c900f1e5eb49efdba22bddb3432a287cab04d3f5f4a9c61adaf9be595432
    430aec9dc867068024c4d70d2d369e4987e2a9ab77c5fa23050b9a07b0727c35
    72780d3943a645820ebd0d22773012288b59052506da665c0b6adf30a3028ae0
    2f5b0cb9e382f4d50eb34daf0fa29f566d3f8d2680c17ab005a93555f47d6a0d
    Total reclaimed space: 10B
```

删除 Docker 存储卷（Removing Docker Volumes）
-----------------------

### (i). 删除一个或多个特定存储卷（Remove One or More Specific Volumes）

To list the existing Docker volumes to identify the ones you want to remove, you can use the following command,

要列出现有的 Docker 存储卷以识别要删除的存储卷，可以使用以下命令，

```bash
    docker volume ls 
    DRIVER    VOLUME NAME
    local     0dbd5e14f4424f0b38a208a8c0d2ad2c04c26b4f6f616ce26df833c275d5f3b8
    local     6e157b921a0856acf3e73f26f96facfab9eab8d3cb135bacf641be949ca30014
    local     52d42a7154fdf6d4e912ef960761f1318e5b814d61016954adc96ade223c23ad
    local     86a06bf73fb2cd691c683b87fbb52f2051f22e006d0b23a7524f373966372af3
    local     6680b5bdfe64a4cc9b938c7188016944db7ea6206c26da78832ba71eaf01adf4
    local     a5eb1d542fea4baf1e230d55eb57c6d1af4f26d2f122e1ce88ffa3315b5b4608
    local     aafb7f5c9e1e00e21e83e0c4d48e9bb02186ea9a3388afb7d607f052af43aa22
    local     c45a478cda53af0825fc4d9331a281a225e0df5e8cae3b54ac4787590c522b3e
    local     ff0a25dd0e4820fd748aa71fb8b646b3bb6fd9d5cab25cf5efc9ad69f346c3ca
```

From the list generated, note down the names or ID's you want to remove. Then use the `docker volume rm` command to remove the identified volumes.

从生成的列表中，记下要删除的名称或 ID。然后使用 `docker volume rm` 命令删除已识别的存储卷。

```bash
    docker volume rm volume_name1 volume_name2

    docker volume rm 0dbd5e14f4424f0b38a208a8c0d2ad2c04c26b4f6f616ce26df833c275d5f3b8
    0dbd5e14f4424f0b38a208a8c0d2ad2c04c26b4f6f616ce26df833c275d5f3b8
```

### (ii). 删除悬空存储卷（Remove Dangling Volumes）

```bash
    docker volume ls -f dangling=true
```

`docker volume ls` in the above command lists the Docker volumes. The `-f` flag with `dangling=true` filters out the dangling volumes.

上述命令中的 `docker volume ls` 列出了 Docker 卷。带有 `dangling=true` 的 `-f` 标志会过滤掉悬空卷。

```bash
    docker volume ls -f dangling=true
    DRIVER    VOLUME NAME
    local     6e157b921a0856acf3e73f26f96facfab9eab8d3cb135bacf641be949ca30014
    local     52d42a7154fdf6d4e912ef960761f1318e5b814d61016954adc96ade223c23ad
    local     86a06bf73fb2cd691c683b87fbb52f2051f22e006d0b23a7524f373966372af3
    local     6680b5bdfe64a4cc9b938c7188016944db7ea6206c26da78832ba71eaf01adf4
    local     a5eb1d542fea4baf1e230d55eb57c6d1af4f26d2f122e1ce88ffa3315b5b4608
    local     aafb7f5c9e1e00e21e83e0c4d48e9bb02186ea9a3388afb7d607f052af43aa22
    local     c45a478cda53af0825fc4d9331a281a225e0df5e8cae3b54ac4787590c522b3e
    local     ff0a25dd0e4820fd748aa71fb8b646b3bb6fd9d5cab25cf5efc9ad69f346c3ca
```

Now identify the volumes you want to remove from the list and remove the filtered volumes.

现在选择要从列表中删除的存储卷并删除已过滤的存储卷。

### (iii). Docker 存储卷清理（Docker Volume Prune）

The `docker volume prune` command is an easy way to clean up the unused volumes in one single go. When you run this command, Docker identifies volumes that are not currently in use by any container and deletes them.

`docker volume prune` 命令是一种一次性清理未使用的存储卷的简单方法。当我们运行此命令时，Docker 会识别当前未被任何容器使用的存储卷并删除它们。

```bash
    docker volume prune
    WARNING! This will remove anonymous local volumes not used by at least one container.
    Are you sure you want to continue? [y/N] y
    Deleted Volumes:
    a5eb1d542fea4baf1e230d55eb57c6d1af4f26d2f122e1ce88ffa3315b5b4608
    c45a478cda53af0825fc4d9331a281a225e0df5e8cae3b54ac4787590c522b3e
    6680b5bdfe64a4cc9b938c7188016944db7ea6206c26da78832ba71eaf01adf4
    52d42a7154fdf6d4e912ef960761f1318e5b814d61016954adc96ade223c23ad
    86a06bf73fb2cd691c683b87fbb52f2051f22e006d0b23a7524f373966372af3
    aafb7f5c9e1e00e21e83e0c4d48e9bb02186ea9a3388afb7d607f052af43aa22
    6e157b921a0856acf3e73f26f96facfab9eab8d3cb135bacf641be949ca30014
    ff0a25dd0e4820fd748aa71fb8b646b3bb6fd9d5cab25cf5efc9ad69f346c3ca
    Total reclaimed space: 209.1MB
```

When you run `docker volume prune`, it only deletes volumes that are not being used by any running container. If a volume is currently being used by a container, it won't be removed. This helps prevent accidental deletion of volumes that are still needed by your active services.

当我们运行 `docker volume prune` 时，它仅删除任何正在运行的容器未使用的卷。如果容器当前正在使用某个卷，则不会将其删除。这有助于防止意外删除活动服务仍需要的卷。

删除 Docker 网络（Removing Docker Network）
-----------------------

### (i). 删除网络（Remove a Network）

Use the command given below to remove a network from Docker

使用下面给出的命令从 Docker 中删除网络

```bash
    docker network rm name

    docker network rm my-bridge-network
    my-bridge-network
```

### (ii). 删除多个网络（Remove Multiple Networks）

To remove multiple networks, you can use `docker network rm` command followed by the id/ names of the network you wish to remove.

要删除多个网络，我们可以使用 `docker network rm` 命令，后跟要删除的网络的 ID/名称。

```bash
    docker network rm id name

    docker network rm d82c6deafecf my-bridge-network 
    d82c6deafecf
    my-bridge-network
```

When you provide multiple networks, the command tries to delete each one sequentially. If it fails to delete one network, it moves on to the next. The command then reports whether each deletion was successful or not.

当我们提供多个网络时，该命令会尝试按顺序删除每个网络。如果删除一个网络失败，则会移至下一个网络。然后该命令报告每次删除是否成功。


定期清理 Docker 的重要性（Importance of Regular Docker Cleanup）
------------------------------------

Lets explore the key points illustrating the importance of Docker cleanup.

让我们探讨说明 Docker 清理重要性的要点。

1.  定期清理 docker 可通过删除未使用的文件来帮助您节省宝贵的磁盘空间（Regular docker cleanup helps you save valuable disk space by removing unused files）。
2.  保持 Docker 清洁可以加快创建容器和管理映像等任务的速度（Keeping Docker clean speeds up tasks like creating containers and managing images）。
3.  清理会删除旧文件，包括不必要的 Docker 日志，这些文件可能会被黑客利用，从而使系统更安全（Cleaning up removes old files, including unnecessary Docker logs, that could be exploited by hackers, making your system safer）。
4.  通过 Docker 清理，我们可以防止系统陷入不必要的容器和镜像的困境（By Docker cleanup, you prevent your system from getting bogged down with unnecessary containers and images）。
5.  通过定期进行 Docker 清理，我们可以花更少的时间管理 Docker，而将更多的时间用于开发（With regular Docker cleanup, you spend less time managing Docker and more time developing）。
6.  清理可以减少因资源混乱而导致错误的可能性（Cleaning up reduces the chances of running into errors caused by cluttered resources）。
7.  干净的 Docker 环境使团队更容易协作，因为每个人都使用相同的、有组织的设置（A clean Docker environment makes it easier for teams to collaborate, as everyone works with the same, organized setup）。
8.  通过优化资源使用，我们可以避免与存储和计算资源相关的不必要的成本（By optimizing resource usage, you may avoid unnecessary costs associated with storage and computing resources）。
9.  Docker 中的高效资源管理（包括适当的 [docker logging practices](https://www.atatus.com/blog/docker-logging-best-practices/)）有助于降低能耗（Efficient resource management in Docker, including proper [docker logging practices](https://www.atatus.com/blog/docker-logging-best-practices/), contributes to reducing energy consumption）。
10.  维护良好的 Docker 环境为开发人员和用户提供了更流畅、更愉快的体验（A well-maintained Docker environment provides a smoother and more enjoyable experience for developers and users alike）。

Docker 清理命令备忘单（Docker Cleanup Command Cheatsheet）
---------------------------------

Here is a Cheatsheet for your quick reference,

以下是供大家快速参考的备忘命令清单，

| 命令 | 描述 |
|---|---|
| `docker system df` | 显示 Docker 的磁盘使用情况 |
| `docker system df -v` | 显示详细的磁盘使用详细信息 |
| `docker system prune -f` | 删除所有未使用的容器、网络、镜像（悬空和未使用的）以及可选的存储卷 |
| `docker images -a` | 列出所有 Docker 镜像 |
| `docker rmi image_id` | 通过 ID 删除镜像 |
| `docker rmi image_tag` | 通过标签删除镜像 |
| `docker rmi image1 image2 image3` | 删除多个镜像 |
| `docker rmi $(docker images -a -q)` | 删除所有镜像 |
| `docker image prune --filter "your_filter"` | 使用过滤器清理镜像 |
| `docker image prune --filter "until=24h"` | 清理超过 24 小时的镜像 |
| `docker image prune --filter "label=unused"` | 清理具有未使用标签的镜像 |
| `docker image prune --filter "dangling=true"` | 清理悬挂镜像 |
| `docker images -a` | 列出所有镜像 |
| `docker image -a \| grep "pattern"` | 按模式过滤镜像 |
| `docker images -a \| grep "pattern" \| awk '{print $1":"$2}' \| xargs docker rmi` | 删除与模式匹配的镜像 |
| `docker rm ID_or_Name ID_or_Name` | 按 ID 或名称删除容器 |
| `docker run --rm image_name` | 退出时自动删除容器 |
| `docker ps -a -f status=exited` | 列出已退出的容器 |
| `docker rm $(docker ps -a -f status=exited -q)` | 删除所有退出的容器 |
| `docker rm $(docker ps -aq)` | 删除所有容器 |
| `docker ps -a \| grep "pattern"` | 按模式过滤容器 |
| `docker ps -a \| grep "pattern" \| awk '{print $1}' \| xargs docker rm` | 删除与模式匹配的容器 |
| `docker container prune` | 删除停止的容器 |
| `docker volume ls` | 列出卷 |
| `docker volume rm volume_name1 volume_name2` | 删除多个存储卷 |
| `docker volume ls -f dangling=true` | 列出悬空存储卷 |
| `docker volume prune` | 删除未使用的存储卷 |
| `docker network rm name` | 按名称删除网络 |
| `docker network rm id name` | 通过 ID 和名称删除网络 |


总结（Conclusion）
----------

Docker Cleanup is essential for managing resources effectively in Docker environments. By systematically removing unused containers, images, volumes, and networks, developers can optimize disk space, improve system performance, and mitigate security risks.

Docker 清理对于在 Docker 环境中有效管理资源至关重要。通过系统地删除未使用的容器、映像、卷和网络，开发人员可以优化磁盘空间、提高系统性能并降低安全风险。

Essential commands and techniques discussed in this blog, helps developers to streamline maintenance tasks and ensure consistent adherence to best practices.

本博客中讨论的基本命令和技术可帮助开发人员简化维护任务并确保一致遵守最佳实践。

Regular Docker Cleanup help teams to maximise the benefits of containerization technology and maintain a clean, efficient Docker environment.

定期的 Docker 清理，可以帮助团队最大限度地发挥容器化技术的优势，并维护干净、高效的 Docker 环境。