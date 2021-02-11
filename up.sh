#!/bin/sh

if [ ! global_vars.yml ] ; then
	cp global_vars.yml.tmpl global_vars.yml
fi

./kubeup vagrant up --provider=libvirt --no-provision $@ \
    && ./kubeup vagrant --provider=libvirt provision
