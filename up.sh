#!/bin/sh

#! Generate key

FLUXDIR=$PWD/roles/flux/files

if [ ! -f ${FLUXDIR}/flux ] ; then
	echo ">> Generating flux ssh keys"
	ssh-keygen -t rsa -b 4096 -C "luis@portworx.com" -N "" -f ${FLUXDIR}/flux
fi


vagrant up --provider=libvirt --no-provision $@ \
    && vagrant --provider=libvirt provision
