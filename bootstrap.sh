#!/bin/sh

get_matchbox() {
    git clone https://github.com/coreos/matchbox.git
}

fedora_setup() {
    dnf -y install libvirt \
        dnsmasq \
        qemu \
        git \
        golang \
        docker \
        virt-install \
        virt-manager
}

fedora_setup
get_matchbox
