#!/bin/sh

add_hosts() {
    if ! grep "$1" /etc/hosts > /dev/null ; then
        echo "--> Adding $1 to /etc/hosts"
        echo "$1" >> /etc/hosts
    fi
}

setup_hosts() {
    add_hosts "172.17.0.21 node1.example.com"
    add_hosts "172.17.0.22 node2.example.com"
    add_hosts "172.17.0.23 node3.example.com"
    add_hosts "172.17.0.24 node3.example.com"
}

get_bootkube() {
    if [ ! -x ./bootkube ] ; then
        echo "--> Get bootkube"
        wget https://github.com/kubernetes-incubator/bootkube/releases/download/v0.6.0/bootkube.tar.gz
        tar xf bootkube.tar.gz
        cp bin/linux/bootkube .
    fi
}

get_matchbox() {
    if [ ! -d matchbox/.git ] ; then
        echo "--> Get matchbox"
        git clone https://github.com/coreos/matchbox.git
        chmod 600 matchbox/tests/smoke/fake_rsa
    fi
}

fedora_setup() {
    echo "--> Installing applications"
    dnf -y install libvirt \
        dnsmasq \
        qemu \
        git \
        golang \
        docker \
        wget \
        virt-install \
        virt-manager

    if ! systemctl is-active docker > /dev/null ; then
        echo "--> Starting docker service"
        systemctl start docker
    fi

    if ! systemctl is-active libvirtd > /dev/null ; then
        echo "--> Starting libvirtd service"
        systemctl start libvirtd
    fi
}

setup_sshkeys() {
    if [ ! -d ssh ] ; then
        echo "--> Setting up ssh keys"
        mkdir ssh
        ssh-keygen -f ssh/id_rsa
    fi
}

setup_coreos_cl() {
    if [ ! -d matchbox/examples/assets ] ; then
        echo "--> Get Container Linux"
        ( cd matchbox && ./scripts/get-coreos stable 1409.7.0 ./examples/assets )
    fi
}

setup_firewall_fedora() {
    if command -v firewall-cmd > /dev/null ; then
        echo "--> Setup firewall for matchbox"
        firewall-cmd --add-interface=metal0 --zone=trusted && \
            firewall-cmd --add-interface=metal0 --zone=trusted --permanent
    fi
}

generate_assets() {
    if [ ! -d matchbox/assets ] ; then
    ./bootkube render --asset-dir=matchbox/assets \
        --api-servers=https://node1.example.com:443 \
        --api-server-alt-names=DNS=node1.example.com \
        --etcd-servers=https://node1.example.com:2379
    fi
}

fedora_setup && \
get_matchbox && \
get_bootkube && \
setup_hosts && \
generate_assets && \
setup_coreos_cl && \
echo "--> Done"
