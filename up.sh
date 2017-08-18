#!/bin/sh

(
cd matchbox

SSHOPTIONS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i tests/smoke/fake_rsa"

sudo setenforce Permissive
sleep 2
echo "--> Start internal pxe boot service"
sudo CONTAINER_RUNTIME=docker ./scripts/devnet create bootkube
sleep 10
echo "--> Booting nodes"
sudo VM_MEMORY=2048 ../scripts/libvirt create-docker
echo "--> Waiting for 2 minutes for systems to come up"
sleep 120

echo "--> Copy etcd TLS assets to controllers"
for node in 'node1' ; do
    scp -r $SSHOPTIONS assets/tls/etcd-* assets/tls/etcd core@$node.example.com:/home/core
    ssh $SSHOPTIONS core@$node.example.com 'sudo mkdir -p /etc/ssl/etcd && sudo mv etcd-* etcd /etc/ssl/etcd/ && sudo chown -R etcd:etcd /etc/ssl/etcd && sudo chmod -R 500 /etc/ssl/etcd/'
done

echo "--> Copying assets to nodes"
for node in 'node1' 'node2' 'node3'; do
    scp $SSHOPTIONS assets/auth/kubeconfig core@$node.example.com:/home/core/kubeconfig
    ssh $SSHOPTIONS core@$node.example.com 'sudo mv kubeconfig /etc/kubernetes/kubeconfig'
    ssh $SSHOPTIONS core@$node.example.com 'sudo modprobe dm_thin_pool'
done

echo "--> Installing Kubernetes"
scp $SSHOPTIONS -r assets core@node1.example.com:/home/core
ssh $SSHOPTIONS core@node1.example.com 'sudo mv assets /opt/bootkube/assets && sudo systemctl start bootkube'
)

echo "--> Wait until the system is ready"
n=0
while [ `./bin/kubectl --kubeconfig=matchbox/assets/auth/kubeconfig get nodes 2>/dev/null | grep -w Ready | wc -l` -ne 3 ] ; do
    n=$[$n+1]
    if [ $n -gt 180 ] ; then
        echo "--> Timed out waiting for system to be ready"
        exit 1
    fi
    sleep 10
done
echo "--> Kubernetes is now ready"
echo "--> Try: ./bin/kubectl --kubeconfig=matchbox/assets/auth/kubeconfig get nodes"

