#!/bin/sh

setup_rkt() {
    if ! command -v rkt > /dev/null ; then
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
