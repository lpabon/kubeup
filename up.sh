#!/bin/sh

if [ ! global_vars.yml ] ; then
	cp global_vars.yml.tmpl global_vars.yml
fi

vagrant up --provider=libvirt --no-provision $@ \
    && vagrant --provider=libvirt provision
