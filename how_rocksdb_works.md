# RocksDB 的工作原理入门

* **作者**：`Artem Krylysov`
* **原文**：[How RocksDB Works](https://artem.krylysov.com/blog/2023/04/19/how-rocksdb-works/)

## 简介

在过去的几年中，`RocksDB` 的采用率急剧上升。它已成为可嵌入键值存储的标准。

目前，`RocksDB` 在 **Meta**、[**Microsoft**](https://blogs.bing.com/Engineering-Blog/october-2021/RocksDB-in-Microsoft-Bing)、[**Netflix**](https://netflixtechblog.com/application-data-caching-using-ssds-5bf25df851ef)、[**Uber**](https://eng.uber.com/cherami-message-queue-system/) 的生产环境中运行。在 [Meta](https://engineering.fb.com/2021/07/22/data-infrastructure/mysql/)，`RocksDB` 充当 `MySQL` 部署的存储引擎，为分布式图形数据库提供支持。

大型科技公司并不是 `RocksDB` 的唯一用户。有几家初创公司是围绕 `RocksDB` 建立的 - [**CockroachDB**](https://www.cockroachlabs.com/)、[**Yugabyte**](https://www.yugabyte.com/)、[**PingCAP**](https://www.pingcap.com/)、[**Rockset**](https://rockset.com/)。

过去 `4` 年，我在 `Datadog` 工作期间一直在 `RocksDB` 上构建和运行服务。在这篇文章中，我将概述 `RocksDB` 的工作原理。

## 什么是 RocksDB

`RocksDB` 是一种可嵌入的持久键值存储。它是一种旨在存储与值相关联的大量唯一键的数据库。简单的键值数据模型可用于构建**搜索索引**、**面向文档的数据库**、**SQL 数据库**、**缓存系统**和**消息代理**。

`RocksDB` 于 `2012` 年从 `Google` 的 [**LevelDB**](https://github.com/google/leveldb) 中分叉出来，并针对在具有 `SSD` 驱动器的服务器上运行进行了优化。目前，`RocksDB` 由 `Meta` [开发](https://github.com/facebook/rocksdb) 和维护。

`RocksDB` 是用` C++` 编写的，因此除了 `C` 和 `C++` 之外，`С` 绑定还允许将**库嵌入**到用其他语言编写的应用程序中，例如 [**Rust**](https://github.com/rust-rocksdb/rust-rocksdb)、[**Go**](https://github.com/linxGnu/grocksdb) 或 [**Java**](https://github.com/facebook/rocksdb/tree/main/java)。

如果你曾经使用过 `SQLite`，那么你已经知道什么是可嵌入数据库。在数据库上下文中，特别是在 `RocksDB` 上下文中，“**可嵌入**”意味着：

* **数据库没有独立的进程**；相反，它作为库直接集成到应用程序中，共享其资源和内存，无需昂贵的进程间通信。
* 它没有配备可通过网络访问的**内置服务器**。
* 它**不是分布式的**，这意味着它不提供容错、复制或分片机制。

如果有必要，可以由应用程序来实现这些功能（**译者**：俗话说就是自己造轮子）。

`RocksDB` 将数据存储为键值对的集合。键和值都没有类型，它们只是任意的字节数组。数据库提供了一个低级接口，其中包含一些用于修改集合状态的函数：

* `put(key, value)`: 存储一个新的键值对或者更新现有的键值对
* `merge(key, value)`：将新值与给定键的现有值合并
* `delete(key)`: 从集合中删除一个键值对

可以使用点查找来检索值：

* `get(key)`

迭代器支持“**范围扫描**” - 查找特定键并按顺序访问后续键值对：

* `iterator.seek(key_prefix); iterator.value(); iterator.next()`

## Log-structured merge-tree（日志结构合并树）

`RocksDB` 背后的核心数据结构称为“**日志结构合并树**”（`LSM` 树）。它是一种树状结构，分为多个级别，每个级别的数据按键排序。`LSM` 树主要设计用于**写入密集型工作负载**，并于 `1996` 年在一篇同名论文[**The Log-Structured Merge-Tree (LSM-Tree)**](http://paperhub.s3.amazonaws.com/18e91eb4db2114a06ea614f0384f2784.pdf)中引入。

`LSM-Tree` 的顶层保存在内存中，包含最近插入的数据。较低层存储在磁盘上，编号从 `0` 到 `N`。`0` 级 (`L0`) 存储从内存移动到磁盘的数据，`1` 级及以下存储较旧的数据。当某个层变得太大时，它会与下一个层合并，而下一个层通常比前一个层大一个数量级。

![LSM Tree](https://artem.krylysov.com/images/2023-rocksdb/rocksdb-lsm.png)

为了更好地理解 `LSM` 树的工作原理，让我们仔细看看**写入**和**读取**路径。

## 写入路径

### MemTable

`LSM` 树的顶层称为 _MemTable_。它是一个内存缓冲区，用于在将键和值写入磁盘之前保存它们。所有插入和更新始终通过 `memtable`。删除也是如此 - `RocksDB` 不是就地修改键值对，而是通过插入**墓碑记录**来标记已删除的键。

`memtable` 被配置成具有特定的大小（以**字节**为单位）。当 `memtable` 已满时，它会被新的 `memtable` 替换，旧的 `memtable` 则变为不可变的。

让我们首先向数据库添加一些键：

```c++
db.put("chipmunk", "1")
db.put("cat", "2")
db.put("raccoon", "3")
db.put("dog", "4")
```

![MemTable](https://artem.krylysov.com/images/2023-rocksdb/rocksdb-memtable.png)

如图所示，`memtable` 中的键值对按键排序。尽管 _`chipmunk`_ 是第一个插入的，但由于排序顺序，它在 `memtable` 中位于 _`cat`_ 之后。排序是支持范围扫描的必要条件，它使一些操作（我稍后会介绍）更加高效。

### 预写日志（Write-ahead log, WAL）

如果发生进程崩溃或计划中的应用程序重启，存储在进程内存中的数据将丢失。为了防止数据丢失并确保数据库更新持久，`RocksDB` 除了将所有更新写入内存表之外，还将所有更新写入磁盘上的_预写日志_（`WAL`）。这样，数据库就可以重放日志并在启动时恢复内存表的原始状态。

`WAL` 是一个仅可追加的文件，由一系列记录组成。每条记录包含一个键值对、一个记录类型（`Put`/`Merge`/`Delete`）和一个校验和。校验和用于在重放日志时检测数据损坏或部分写入的记录。与内存表不同，`WAL` 中的记录不是按键排序的。相反，它们按到达的顺序追加。

![WAL](https://artem.krylysov.com/images/2023-rocksdb/rocksdb-wal.png)

### 刷新（Flush）

`RocksDB` 运行一个专用的后台线程，将不可变的内存表持久化到磁盘。刷新完成后，不可变的内存表和相应的 `WAL` 将被丢弃。`RocksDB` 开始写入新的 `WAL` 和新的内存表。每次刷新都会在 `L0` 上生成一个 _`SST`_ 文件。生成的文件是不可变的 - 一旦写入磁盘，它们就永远不会被修改。

`RocksDB` 中默认的内存表实现基于 [**跳链（Skip List）**](https://en.wikipedia.org/wiki/Skip_list)。数据结构是一个链接列表，其中包含额外的链接层，允许按排序顺序快速搜索和插入。排序使刷新变得高效，允许通过迭代键值对将内存表内容按顺序写入磁盘。将随机插入转换为顺序写入是 `LSM` 树设计背后的关键思想之一。

![Flush](https://artem.krylysov.com/images/2023-rocksdb/rocksdb-flush.png)

### SST

`SST` 文件包含已从 `memtable` 刷新到磁盘的键值对，格式针对查询进行了优化。_`SST`_ 代表静态排序表（或某些其他数据库中的排序字符串表）。这是一种基于块的文件格式，将数据组织成块（默认大小目标为 `4KB`）。可以使用 `RocksDB` 支持的各种压缩算法（例如 `Zlib`、`BZ2`、`Snappy`、`LZ4` 或 `ZSTD`）压缩单个块。与 `WAL` 中的记录类似，块包含用于检测数据损坏的校验和。`RocksDB` 每次从磁盘读取时都会验证这些校验和。

`SST` 文件中的块分为多个部分。第一部分，即 _`data`_ 部分，包含有序的键值对序列。此排序允许对键进行增量编码，这意味着我们不必存储完整键，而只需存储相邻键之间的差异。

虽然 `SST` 文件中的键值对是按排序顺序存储的，但二分搜索并不总是适用，尤其是在块被压缩时，这使得搜索文件效率低下。`RocksDB` 通过添加索引来优化查找，该索引存储在数据部分之后的单独部分中。索引将每个数据块中的最后一个键映射到其在磁盘上的相应偏移量。同样，索引中的键是有序的，允许我们通过执行二分搜索快速找到键。例如，如果我们搜索 _`lynx`_，索引会告诉我们键可能在块 `2` 中，因为 _`lynx`_ 在 _`chipmunk`_ 之后，但在 _`raccoon`_ 之前。

![SST](https://artem.krylysov.com/images/2023-rocksdb/rocksdb-sst.png)

实际上，上面的 `SST` 文件中没有 _`lynx`_，但我们必须从磁盘读取块并搜索它。`RocksDB` 支持启用 [**布隆过滤器(bloom)**](https://en.wikipedia.org/wiki/Bloom_filter) - 一种节省空间的概率数据结构，用于测试元素是否属于集合。它存储在可选的 `bloom` 过滤器部分中，可以更快地搜索不存在的键。

此外，还有其他几个不太有趣的部分，例如元数据部分。

### 压缩

到目前为止，我所描述的已经是一个功能齐全的键值存储。但是，有一些挑战会阻碍它在生产系统中的使用：空间和读取放大。**空间放大**衡量的是存储空间与存储的逻辑数据大小的比率。假设一个数据库需要 `2MB` 的磁盘空间来存储占用 `1MB` 的键值对，则空间放大就是 _`2`_。同样，**读取放大**衡量的是执行逻辑读取操作所需的 `IO` 操作数。我将让大家弄清楚什么是**写入放大**，这是一个小练习。

现在，让我们向数据库添加更多键并删除一些键：

```plaintext
db.delete("chipmunk")
db.put("cat", "5")
db.put("raccoon", "6")
db.put("zebra", "7")
// Flush triggers
db.delete("raccoon")
db.put("cat", "8")
db.put("zebra", "9")
db.put("duck", "10")
```

![Compaction1](https://artem.krylysov.com/images/2023-rocksdb/rocksdb-compaction1.png)

随着我们不断写入，内存表被刷新，`L0` 上的 `SST` 文件数量不断增长：

* 已删除或更新的键所占用的空间永远不会被回收。例如，_`cat`_ 键有三个副本，_`chipmunk`_ 和 _`raccoon`_ 仍然占用磁盘空间，即使它们不再需要。
* 随着 `L0` 上的 `SST` 文件数量的增加，读取成本也会随之增加，因此读取速度会变慢。每次查找密钥都需要检查每个 `SST` 文件才能找到所需的密钥。

一种称为“**压缩**”的机制有助于减少空间和读取放大，以换取增加写入放大。压缩选择一层的 `SST` 文件并将其与下一层 SST 文件合并，丢弃已删除和覆盖的键。压缩在专用线程池的后台运行，这允许 `RocksDB` 在压缩过程中继续处理读取和写入请求。

![Compaction2](https://artem.krylysov.com/images/2023-rocksdb/rocksdb-compaction2.png)

**分级压缩** 是 `RocksDB` 中的默认压缩策略。使用分级压缩，`L0` 上的 `SST` 文件的键范围会重叠。第 `1` 级及以下的级别被组织为包含一个已排序的键范围，该范围被划分为多个 `SST` 文件，从而确保同一级别内的键范围没有重叠。压缩会挑选某一级别的文件，并将它们与下一级重叠的文件范围合并。例如，在从` L0 `到 `L1` 的压缩过程中，如果 `L0` 上的输入文件跨越整个键范围，则压缩必须挑选来自 `L0` 的所有文件和来自 `L1` 的所有文件。

![Compaction3](https://artem.krylysov.com/images/2023-rocksdb/rocksdb-compaction3.png)

对于下面的 `L1` 到 `L2` 压缩，`L1` 上的输入文件与 `L2` 上的两个文件重叠，因此压缩仅限于文件子集。

![Compaction4](https://artem.krylysov.com/images/2023-rocksdb/rocksdb-compaction4.png)

当 `L0` 上的 `SST` 文件数量达到某个阈值（默认为 `4`）时，就会触发压缩。对于 `L1` 及以下级别，当整个级别的大小超过配置的**目标大小**时，就会触发压缩。发生这种情况时，可能会触发 `L1` 到 `L2` 的压缩。这样，`L0` 到 `L1` 的压缩可能会一直级联到最底层。压缩结束后，`RocksDB` 会更新其元数据并从磁盘中删除压缩的文件。

还记得 `SST` 文件中的键是有序的吗？排序保证允许在 [**k 路合并算法**](https://en.wikipedia.org/wiki/K-way_merge_algorithm) 的帮助下逐步合并多个 `SST` 文件。**K 路合并**是**双向合并**的通用版本，其工作原理类似于 [**合并排序**](https://en.wikipedia.org/wiki/Merge_sort) 的合并阶段。

## 读取路径

由于不可变的 `SST` 文件持久保存在磁盘上，因此读取路径没有写入路径复杂。密钥查找从顶部到底部遍历 `LSM` 树。它从活动内存表开始，下降到 `L0`，然后继续到更低的级别，直到找到密钥或用尽要检查的 `SST` 文件。

查找步骤如下：

1. 搜索活动的内存表。
2. 搜索不可变的内存表。
3. 从最近刷新的文件开始搜索 `L0` 上的所有 `SST` 文件。
4. 对于 `L1` 及以下级别，找到可能包含密钥的单个 `SST` 文件并搜索该文件。

搜索 `SST` 文件包括：

1. （可选）探测布隆过滤器。
2. 搜索索引来找到该键可能属于的块。
3. 阅读区块并尝试在那里找到钥匙。

就是这样！

考虑这个 `LSM` 树：

![Lookup](https://artem.krylysov.com/images/2023-rocksdb/rocksdb-lookup.png)

根据键，查找可能在任何步骤提前结束。例如，查找 _cat_ 或 _`chipmunk`_ 在搜索活动内存表后结束。搜索仅存在于第 `1` 级的 _`raccoon`_ 或根本不存在于 `LSM` 树中的 _`manul`_ 需要搜索整个树。

## 合并

`RocksDB` 提供了另一个涉及读写路径的功能：_`Merge`_ 操作。假设您在数据库中存储了一个整数列表。有时您需要扩展该列表。要修改列表，您需要从数据库中读取现有值，在内存中更新它，然后写回更新后的值。这称为“**读取-修改-写入**”循环：

```c++
db = open_db(path)

// Read
old_val = db.get(key) // RocksDB stores keys and values as byte arrays. We need to deserialize the value to turn it into a list.
old_list = deserialize_list(old_val) // old_list: [1, 2, 3]

// Modify
new_list = old_list.extend([4, 5, 6]) // new_list: [1, 2, 3, 4, 5, 6]
new_val = serialize_list(new_list)

// Write
db.put(key, new_val)

db.get(key) // deserialized value: [1, 2, 3, 4, 5, 6]
```

该方法有效，但也存在一些缺陷：

* 它不是线程安全的——两个不同的线程可能会尝试更新同一个键并覆盖彼此的更新。
* 写入放大 - 值越大，更新成本越高。例如，将一个整数附加到 `100` 个整数的列表中需要读取 `100` 个整数并写回 `101` 个整数。

除了 _`Put`_ 和 _`Delete`_ 写入操作之外，`RocksDB` 还支持第三种写入操作 _`Merge`_，旨在解决这些问题。`Merge` 操作需要提供一个 _`Merge Operator`_ - 一个用户定义的函数，负责将增量更新组合成一个值：

```c++
func merge_operator(existing_val, updates) {
        combined_list = deserialize_list(existing_val)
        for op in updates {
                combined_list.extend(op)
        }
        return serialize_list(combined_list)
}

db = open_db(path, {merge_operator: merge_operator})
// key's value is [1, 2, 3]

list_update = serialize_list([4, 5, 6])
db.merge(key, list_update)

db.get(key) // deserialized value: [1, 2, 3, 4, 5, 6]
```

上面的合并运算符将传递给 _`Merge`_ 调用的增量更新合并为单个值。调用 _`Merge`_ 时，`RocksDB` 仅将增量更新插入内存表和 `WAL`。稍后，在刷新和压缩期间，`RocksDB` 会调用合并运算符函数，尽可能将更新合并为单个大型更新或单个值。在 _`Get`_ 调用或迭代中，如果有任何未压缩的待处理更新，则会调用同一函数向调用者返回单个组合值。

合并非常适合需要不断对现有值进行小幅更新的写入密集型流式应用程序。那么，问题出在哪里呢？读取变得更加昂贵 - 读取时所做的工作不会被保存。获取相同键的重复查询必须一遍又一遍地执行相同的工作，直到
触发刷新和压缩。与 `RocksDB` 中的几乎所有其他内容一样，可以通过限制内存表中合并操作数的数量或减少 `L0` 中的 `SST` 文件数量来调整行为。

## 挑战

如果性能对于您的应用程序至关重要，那么使用 `RocksDB` 最具挑战性的方面就是针对特定工作负载进行适当的配置。`RocksDB` 提供了许多配置选项，调整它们通常需要了解数据库内部结构并深入研究 `RocksDB` 源代码：

> “不幸的是，最佳配置 `RocksDB` 并非易事。即使我们作为 `RocksDB` 开发人员也不完全了解每次配置更改的影响。如果大家想针工作负载优化 `RocksDB`，我们建议大家进行实验和基准测试，同时关注三个放大因素。”
>
> —[**官方 `RocksDB` 调优指南**](https://github.com/facebook/rocksdb/wiki/RocksDB-Tuning-Guide)

## 总结

从头编写生产级键值存储很困难：

* 硬件和操作系统随时可能出问题，**丢失**或**损坏**数据。
* 性能优化需要大量的时间投入。

`RocksDB` 解决了这个问题，让我们可以专注于业务逻辑。这使得 `RocksDB` 成为数据库的绝佳构建块。