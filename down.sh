#!/bin/sh
cd matchbox
sudo ./scripts/libvirt destroy
sudo ./scripts/devnet destroy
sudo rkt gc --grace-period=0
