#!/bin/sh
cd matchbox
echo "--> Shutdown and destroy nodes"
sudo ./scripts/libvirt destroy
echo "--> Shutdown and destroy pxe"
sudo CONTAINER_RUNTIME=docker ./scripts/devnet destroy
