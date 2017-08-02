#!/bin/sh

setup_rkt() {
    if ! command -v rkt > /dev/null ; then
        echo "--> Installing rkt"
        dnf -y install https://github.com/rkt/rkt/releases/download/v1.28.0/rkt-1.28.0-1.x86_64.rpm

        mkdir -p /etc/rkt/net.d
		cat > /etc/rkt/net.d/20-metal.conf << EOF
{
  "name": "metal0",
  "type": "bridge",
  "bridge": "metal0",
  "isGateway": true,
  "ipMasq": true,
  "ipam": {
    "type": "host-local",
    "subnet": "172.18.0.0/24",
    "routes" : [ { "dst" : "0.0.0.0/0" } ]
   }
}
EOF

    fi
}

add_hosts() {
    if ! grep "$1" /etc/hosts > /dev/null ; then
        echo "--> Adding $1 to /etc/hosts"
        echo "$1" >> /etc/hosts
    fi
}

setup_hosts() {
    add_hosts "172.18.0.21 node1.example.com"
    add_hosts "172.18.0.22 node2.example.com"
    add_hosts "172.18.0.23 node3.example.com"
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
}

setup_sshkeys() {
    if [ ! -d ssh ] ; then
        echo "--> Setting up ssh keys"
        mkdir ssh
        ssh-keygen -f ssh/id_rsa
    fi
}

setup_coreos_cl() {
    echo "--> Get Container Linux"
    ( cd matchbox && ./scripts/get-coreos stable 1409.7.0 ./examples/assets )
}

setup_firewall_fedora() {
    echo "--> Setup firewall for matchbox"
    firewall-cmd --add-interface=metal0 --zone=trusted && \
        firewall-cmd --add-interface=metal0 --zone=trusted --permanent
}

fedora_setup && \
get_matchbox && \
get_bootkube && \
setup_hosts && \
setup_rkt && \
setup_firewall_fedora && \
setup_sshkeys && \
setup_coreos_cl
