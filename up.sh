#!/bin/sh

cd matchbox

SSHOPTIONS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i tests/smoke/fake_rsa"

sudo setenforce Permissive
sleep 2
echo "--> Start internal pxe boot service"
sudo CONTAINER_RUNTIME=docker ./scripts/devnet create bootkube-install
sleep 10
echo "--> Booting nodes"
sudo VM_MEMORY=2048 ./scripts/libvirt create-docker
echo "--> Systems are updating and rebooting. This may take a while"
echo "--> Waiting for 10 minutes for systems to come up"
sleep 600

echo "--> Copy etcd TLS assets to controllers"
for node in 'node1' ; do
    scp -r $SSHOPTIONS assets/tls/etcd-* assets/tls/etcd core@$node.example.com:/home/core
    ssh $SSHOPTIONS core@$node.example.com 'sudo mkdir -p /etc/ssl/etcd && sudo mv etcd-* etcd /etc/ssl/etcd/ && sudo chown -R etcd:etcd /etc/ssl/etcd && sudo chmod -R 500 /etc/ssl/etcd/'
done

echo "--> Copying assets to nodes"
for node in 'node1' 'node2' 'node3'; do
    scp $SSHOPTIONS assets/auth/kubeconfig core@$node.example.com:/home/core/kubeconfig
    ssh $SSHOPTIONS core@$node.example.com 'sudo mv kubeconfig /etc/kubernetes/kubeconfig'
done

echo "--> Installing Kubernetes"
scp $SSHOPTIONS -r assets core@node1.example.com:/home/core
ssh $SSHOPTIONS core@node1.example.com 'sudo mv assets /opt/bootkube/assets && sudo systemctl start bootkube'
ssh $SSHOPTIONS core@node1.example.com 'journalctl -f -u bootkube'
