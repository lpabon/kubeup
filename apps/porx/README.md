# Setup of Portworx

* Create an etcd cluster using the etcd operator from CoreOS

```bash
kubectl -n kube-system create -f < each of the rbac files > 
kubectl -n kube-system create -f etcd-operator.yaml 
kubectl -n kube-system create -f etcd-cluster.yaml 
kubectl -n kube-system create -f etcd-svc.yaml
kubectl -n kube-system get svc portworx-etcd -o json | jq '.spec.ports[0].nodePort'
```

* Deploy Portworx

Notice the node port, and edit `px-spec.yaml` to setup the correct port number on the entry to the etcd cluster. Search for `node1.example.com`.

Submit the cluster:

```bash
kubectl -n kube-system create -f px-spec.yaml
```
