# Kubeup
Simple Kubernetes on CentOS 7 based on [kubeadm](http://kubernetes.io/docs/admin/kubeadm/). Default setup is a single master with three nodes

> NOTE: Currently libvirt only. Support for VirtualBox will be available soon

## Requirements

Install qemu-kvm, libvirt, vagrant-libvirt, and ansible

* Fedora

```
sudo dnf -y install qemu-kvm libvirt vagrant-libvirt ansible
```

## Usage

To setup type:

```
$ sudo ./up.sh
$ sudo vagrant ssh master
[vagrant@master]$ kubectl get nodes
```

The Kubernetes configuration is then copied from the master node to the host and can be used as follows:

```
$ kubectl --kubeconfig=kubeconfig.conf get nodes
NAME      STATUS    ROLES     AGE       VERSION
master    Ready     master    7m        v1.10.3
node0     Ready     <none>    7m        v1.10.3
node1     Ready     <none>    7m        v1.10.3
node2     Ready     <none>    7m        v1.10.3
```

