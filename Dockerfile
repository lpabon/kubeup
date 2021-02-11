FROM vagrantlibvirt/vagrant-libvirt:latest

RUN apt update \
    && apt install -y \
		rsync \
		python3-pip \
    && rm -rf /var/lib/apt/lists \
    ;

RUN pip3 install ansible

ENTRYPOINT ["entrypoint.sh"]
