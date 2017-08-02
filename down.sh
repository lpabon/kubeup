#!/bin/sh
cd matchbox
sudo ./scripts/libvirt destroy
sudo CONTAINER_RUNTIME=docker ./scripts/devnet destroy
