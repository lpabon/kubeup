#!/bin/sh

vagrant up --provider=libvirt --no-provision $@ \
    && vagrant --provider=libvirt provision
