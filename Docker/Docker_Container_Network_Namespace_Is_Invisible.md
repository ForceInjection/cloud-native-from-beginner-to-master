消失的 Docker 网络命名空间
=====================================================================

Network Namespaces
----------------------------

At the very foundational layer of the Docker container are the Linux cgroup and namespace mechanism. Both of the mechanisms work together to provide the process and resources isolation in Docker container that we leverage. For example, cgroups limit the resources a process can use. On the other hand, namespace controls the visibility of resources between processes. One of the examples of namespace is the network namespace, more commonly known as the net.

The network namespace essentially virtualizes and isolates the network stack of a process. In other words, different processes can have their own unique firewall configuration, private IP address, and routing rules. It is through this network namespace we can give each Docker container an isolated network stack from the host network.

In Linux, one of the primary tools for managing the network namespace is `ip netns`. This command-line tool is an extension of the ip tool. It allows us to execute ip compatible commands on different network namespaces.

Invisible Docker Network Namespace
----------------------------

Whenever we create a Docker container, the daemon will create the namespaces pseudo files for the container process. It’ll then place these files under the directory `/proc/{pid}/ns`, where pid is the process ID of the container. Let’s look at an example:

```bash
$ sudo docker run --rm -d ubuntu:latest sleep infinity
2545fdac9b41e463a29b4a61c201b789d567f88d54b6973bdcca9e69ba35ba92
$ sudo docker inspect -f '{{.State.Pid}}' 2545fdac9b41e463a29b4a61c201b789d567f88d54b6973bdcca9e69ba35ba92 
3357
```

In the command above, we first create a Docker container running the ubuntu:latest image. Then we keep the container running by running sleep infinity. Finally, we run the docker inspect command to obtain the process id of the container.

Now, looking into the `/proc/3357/ns` directory, we can see that all the different kinds of namespaces are created:

```bash
$ sudo ls -la /proc/3357/ns
total 0
dr-x--x--x 2 root root 0 Feb  5 04:24 .
dr-xr-xr-x 9 root root 0 Feb  5 04:24 ..
lrwxrwxrwx 1 root root 0 Feb  5 04:25 cgroup -> 'cgroup:[4026531835]'
lrwxrwxrwx 1 root root 0 Feb  5 04:25 ipc -> 'ipc:[4026532720]'
lrwxrwxrwx 1 root root 0 Feb  5 04:25 mnt -> 'mnt:[4026532718]'
lrwxrwxrwx 1 root root 0 Feb  5 04:24 net -> 'net:[4026532723]'
lrwxrwxrwx 1 root root 0 Feb  5 04:25 pid -> 'pid:[4026532721]'
lrwxrwxrwx 1 root root 0 Feb  5 04:25 pid_for_children -> 'pid:[4026532721]'
lrwxrwxrwx 1 root root 0 Feb  5 04:25 time -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 Feb  5 04:25 time_for_children -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 Feb  5 04:25 user -> 'user:[4026531837]'
lrwxrwxrwx 1 root root 0 Feb  5 04:25 uts -> 'uts:[4026532719]'
```

Since the Docker daemon is running as a root, all the filesystems are owned by the root. Hence, we’ll need sudo to view those files.

From the list of namespace pseudo files, we can see the presence of the net file for this process. Since the net file corresponds to a Linux network namespace, we can expect it to shows up when we list all the network namespaces. However, we can see that it is not the case. For example, running ip netns ls now will show 0 results:

```bash
$ ip netns ls
$
```

As a sanity check, let’s create a network namespace manually. Then, verify that it shows up when we run ip netns:

```bash
$ sudo ip netns add netA
$ ip netns ls
netA
$ 
```

As we can see, it is displaying the netA as expected. So why doesn’t it display the net created by docker run?

The Missing File Reference
----------------------------

To understand the problem, we’ll need to recognize that the ip netns ls command looks up network namespaces file in the `/var/run/netns` directory. However, the Docker daemon doesn’t create a reference of the network namespace file in the `/var/run/netns` directory after the creation. Therefore, ip netns ls cannot resolve the network namespace file.

One way to fix this inconsistency is to create a file reference for the net file in the `/var/run/netns` directory. Specifically, we can bind mount the net namespace file onto an empty file we create in the `/var/run/netns` directory.

Firstly, we create an empty file in the directory and name it with the container id the namespace file is associated to:

```bash
$ mkdir -p /var/run/netns
$ touch /var/run/netns/$container_id
```

Where `$container_id` is an environment variable that evaluates the ID of the Docker container we’ve created.

Subsequently, we can run the `mount -o bind` command to bind mount the net file:

```bash
$ mount -o bind /proc/3357/ns/net /var/run/netns/$container_id
```

Now, running the same ip netns ls command again would display the network namespace, as expected:

```bash
$ ip netns ls
ip netns ls
2545fdac9b41e463a29b4a61c201b789d567f88d54b6973bdcca9e69ba35ba92
netA
```

Once we’ve established the file reference to the network namespace file, we can run any ip commands using ip netns exec. For instance, we can look at the interfaces on the network namespace using the `ip addr list` command:

```bash
$ ip netns exec $container_id ip addr list
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
4: eth0@if5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever
```

One thing to keep in mind is we should always use a bind-mount to create the file reference. Using a symbolic link could be dangerous as the PID values are reusable. This would introduce the possibility of ip netns erroneously resolving to the wrong network namespace the file reference is created for.

Summary
----------------------------

In this tutorial, we’ve started with a brief introduction to the Linux namespaces and cgroup. Then, we’ve demonstrated the problem whereby the network namespace file created by docker run is not showing up when we run ip netns ls. Subsequently, we’ve learned that it is due to the fact that the file reference is not created at `/var/run/netns`, which is where the `ip netns ls` command looks up for any network namespaces.

Finally, we ended the article with a simple fix, which is to bind mount the file onto the `/var/run/netns` so that it can be located by `ip netns ls`.