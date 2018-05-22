# Kubeup
Simple Kubernetes on CentOS 7 based on [kubeadm](http://kubernetes.io/docs/admin/kubeadm/). Default setup is a single master with three nodes

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

