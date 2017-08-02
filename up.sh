#!/bin/sh

cd matchbox

SETUPALL=true
SSHOPTIONS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i tests/smoke/fake_rsa"
export CONTAINER_RUNTIME=docker

sudo setenforce Permissive
sleep 2
sudo CONTAINER_RUNTIME=docker ./scripts/devnet create bootkube-install
sleep 10
sudo ./scripts/libvirt create-docker
sleep 120

for node in 'node1' 'node2' 'node3'; do
    scp $SSHOPTIONS assets/auth/kubeconfig core@$node.example.com:/home/core/kubeconfig
    ssh $SSHOPTIONS core@$node.example.com 'sudo mv kubeconfig /etc/kubernetes/kubeconfig'
    ssh $SSHOPTIONS core@$node.example.com 'sudo modprobe dm_thin_pool'
done
scp $SSHOPTIONS -r assets core@node1.example.com:/home/core
ssh $SSHOPTIONS core@node1.example.com 'sudo mv assets /opt/bootkube/assets && sudo systemctl start bootkube'
ssh $SSHOPTIONS core@node1.example.com 'journalctl -f -u bootkube'
