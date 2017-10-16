#!/bin/sh

## CONFIGURATION

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
    add_hosts "172.17.0.24 node4.example.com"
    add_hosts "172.17.0.25 node5.example.com"
}

get_bootkube() {
    if [ ! -d ./bin ] ; then
        mkdir bin
    fi
    if [ ! -x ./bin/bootkube ] ; then
        echo "--> Get bootkube"
	./matchbox/scripts/dev/get-bootkube bin
    fi
}

get_matchbox() {
    if [ ! -d matchbox/.git ] ; then
        echo "--> Get matchbox"
        git clone https://github.com/coreos/matchbox.git
        chmod 600 matchbox/tests/smoke/fake_rsa
    fi
    cp -r resources/bootkube matchbox/examples/groups
    ( cd matchbox ; patch -p1 < ../resources/docker0.conf.patch )
}

start_services() {
    if ! systemctl is-active docker > /dev/null ; then
        echo "--> Starting docker service"
        sudo systemctl start docker
        sudo systemctl enable docker
    fi

    if ! systemctl is-active libvirtd > /dev/null ; then
        echo "--> Starting libvirtd service"
        sudo systemctl start libvirtd
        sudo systemctl enable libvirtd
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
        jq \
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
        jq \
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
    else
        echo "Only CentOS or Fedora are supported"
        exit 1
    fi
}

setup_coreos_cl() {
    if [ ! -d matchbox/examples/assets/coreos ] ; then
        echo "--> Get Container Linux"
        ( cd matchbox && ./scripts/get-coreos )
    fi
}

generate_assets() {
    if [ ! -d matchbox/assets ] ; then
        ./bin/bootkube render --asset-dir=matchbox/assets \
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
