#!/bin/sh

## CONFIGURATION
BOOTKUBE_VERSION=v0.6.0
CL_VERSION=1409.7.0


add_hosts() {
    if ! grep "$1" /etc/hosts > /dev/null ; then
        echo "--> Adding $1 to /etc/hosts"
        sudo -E bash -c "echo $1 >> /etc/hosts"
    fi
}

setup_hosts() {
    add_hosts "172.17.0.21 node1.example.com"
    add_hosts "172.17.0.22 node2.example.com"
    add_hosts "172.17.0.23 node3.example.com"
    add_hosts "172.17.0.24 node3.example.com"
}

get_bootkube() {
    if [ ! -d ./bin ] ; then
        mkdir bin
    fi
    if [ ! -x ./bin/linux/bootkube ] ; then
        echo "--> Get bootkube"
        wget https://github.com/kubernetes-incubator/bootkube/releases/download/${BOOTKUBE_VERSION}/bootkube.tar.gz
        tar xf bootkube.tar.gz
        rm -f bootkube.tar.gz
    fi
}

get_matchbox() {
    if [ ! -d matchbox/.git ] ; then
        echo "--> Get matchbox"
        git clone https://github.com/coreos/matchbox.git
        chmod 600 matchbox/tests/smoke/fake_rsa
    fi
}

start_services() {
    if ! systemctl is-active docker > /dev/null ; then
        echo "--> Starting docker service"
        sudo systemctl start docker
    fi

    if ! systemctl is-active libvirtd > /dev/null ; then
        echo "--> Starting libvirtd service"
        sudo systemctl start libvirtd
    fi
}

fedora_setup() {
    echo "--> Installing applications (Fedora)"
    sudo dnf -y install libvirt \
        dnsmasq \
        qemu \
        qemu-kvm \
        git \
        golang \
        docker \
        wget \
        virt-install \
        virt-manager
    if [ $? -ne 0 ] ; then
        echo "Unable to install packages"
        exit 1
    fi

    start_services
}

centos_setup() {
    echo "--> Installing applications (CentOS)"
    sudo yum -y install libvirt \
        dnsmasq \
        qemu \
        qemu-kvm \
        git \
        golang \
        docker \
        wget \
        virt-install \
        virt-manager
    if [ $? -ne 0 ] ; then
        echo "Unable to install packages"
        exit 1
    fi

    start_services
}

host_setup() {
    if grep "CentOS" /etc/redhat-release > /dev/null 2>&1 ; then
        centos_setup
    elif grep "Fedora" /etc/redhat-release > /dev/null 2>&1 ; then
        fedora_setup
    fi
}

setup_coreos_cl() {
    if [ ! -x matchbox/examples/assets/coreos/${CL_VERSION} ] ; then
        echo "--> Get Container Linux"
        ( cd matchbox && ./scripts/get-coreos stable ${CL_VERSION} ./examples/assets )
    fi
}

generate_assets() {
    if [ ! -d matchbox/assets ] ; then
        ./bin/linux/bootkube render --asset-dir=matchbox/assets \
            --api-servers=https://node1.example.com:443 \
            --api-server-alt-names=DNS=node1.example.com \
            --etcd-servers=https://node1.example.com:2379
    fi
}

get_kubectl() {
    if [ ! -x bin/kubectl ] ; then
        echo "--> Get latest kubectl"
        ./matchbox/scripts/dev/get-kubectl
    fi
}

host_setup && \
get_matchbox && \
get_bootkube && \
get_kubectl && \
setup_hosts && \
generate_assets && \
setup_coreos_cl && \
echo "--> Done"
