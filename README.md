# kubeup
Simple Kubernetes setup for libvirt on Fedora based on Matchbox and bootkube.

* Single one time setup: `./bootstrap.sh`
* Create a multinode cluster running Kubernetes 1.7.1: `./up.sh`
* Type: `./bin/kubectl --kubeconfig=matchbox/assets/auth/kubeconfig get nodes`
* Shutdown cluster: `./down.sh`
