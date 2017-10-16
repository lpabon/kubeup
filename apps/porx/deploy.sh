#!/bin/bash

source ../../scripts/lib.sh

# Deploy etcd-operator
echo "----> Deploying etcd-operator"
kubectl -n kube-system create -f etcd-operator.yaml || fail "Unable to deploy etc-operator"
wait_for_pod_ready kube-system etcd-operator 1

# Deploy etcd-cluster
echo "----> Deploying etcd-cluster"
kubectl -n kube-system create -f etcd-cluster.yaml || fail "Unable to deploy etcd-cluster"
wait_for_pod_ready kube-system px-etcd-cluster 3

# Get node port
echo "----> Deploying Portworx storage system"
nodeport=`get_node_port_from_service kube-system px-etcd`
sed -e "s#@@NODEPORT@@#${nodeport}#" \
	px-spec.yaml.sed | kubectl create -f -
wait_for_pod_ready kube-system portworx 2