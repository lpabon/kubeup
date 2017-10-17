# kubeup
Simple Kubernetes setup for libvirt on Fedora or CentOS based on [Matchbox](https://github.com/coreos/matchbox) and [bootkube](https://github.com/kubernetes-incubator/bootkube) with storage support based on [Portworx](https://portworx.com/).

# requirements

* For Fedora and CentOS only. (Would love a PR for Ubuntu/Debian support)
* Four nodes with 2G RAM are created so you will need at least of 8G of RAM extra on your system.

# usage

Bring up a kubernetes cluster:
* Single one time setup: `./bootstrap.sh`
* Create a multinode cluster running Kubernetes: `./up.sh`
* Type: `./bin/kubectl --kubeconfig=matchbox/assets/auth/kubeconfig get nodes`

Deploy a StateFul set:

```
$ ./bin/kubectl --kubeconfig=matchbox/assets/auth/kubeconfig create -f apps/db/cockroachdb.yaml
```

When done:

* Shutdown cluster: `./down.sh`

