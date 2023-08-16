# Kubeup
Simple Kubernetes cluster creator based on
[kubeadm](http://kubernetes.io/docs/admin/kubeadm/) for libvirt (Linux).
Default setup is a single master with three nodes

## Kubernetes Versions Supported

`master` branch contains support for the last three verions of Kubernetes.

### Git Tags

* Tag `v2.0.0+` supports Kubernetes 1.24+
* Tag `v1.0.0` supports up to Kubernetes 1.23

## Requirements

Install qemu-kvm, libvirt

### Ubuntu

```
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
```

### Fedora

```
sudo dnf -y install qemu-kvm libvirt
```

### CentOS 7

* Run the following:

```
sudo yum install epel-release
sudo yum install qemu libvirt qemu-kvm
```

# Usage

## Add your user to libvirt group
```
sudo usermod -a -G libvirt $(whoami)
```

This will allow the *up.sh* script to run without *sudo* later on.

You may also need to restart libvirtd to pick up the change.

```
sudo systemctl restart libvirtd.service
```

## Create global_vars.yml

If you have not already done so, create `global_vars.yml`:

```
$ cp global_vars.yml.tmpl global_vars.yml
```

Edit `global_vars.yml` accordingly, then to create the cluster, type:

```
$ ./up.sh
```

The Kubernetes configuration is then copied from the master node to the host and can be used as follows:

```
$ kubectl --kubeconfig=kubeconfig-k8s1.conf get nodes
NAME                  STATUS   ROLES    AGE     VERSION
lpabon-k8s-1-master   Ready    master   8m12s   v1.19.5
lpabon-k8s-1-node0    Ready    <none>   7m44s   v1.19.5
lpabon-k8s-1-node1    Ready    <none>   7m44s   v1.19.5
lpabon-k8s-1-node2    Ready    <none>   7m45s   v1.19.5
```

### kubeup script

Kubeup uses a container to run `vagrant` and `vagrant-libvirt`. For convenience
a script called `kubeup` has been provided.

Use this script to prefix all your vagrant commands. For example:

```
$ ./kubeup vagrant ssh lpabon-k8s-1-node0
```

# Changelog

## v2.1.0

* Moved to Rocky Linux 8 instead of CentOS 7. (Rocky Linux 9 can also be used)
* Use containerd instead of docker or cri-o
* Flannel uses vxlan instead of udp

## v2.0.0

* Updated to use cri-o from Docker
* Removed all docker files
* Cleaned up the K8S versions to support only the last three
* Creating certificates and exporting was removed because it wasn't working with
  cri-o. We will investigate to determine if we can add it back.


