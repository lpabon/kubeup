# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'socket'

### CONFIGURATION ###

CLUSTER = "1" # Cluster value must be from 1-9 only because it is used in IP_PREFIX
NAME_PREFIX = "lpabon-k8s-"

# Prefix for IP address: In essense: IP_PREFIX+id => "192.168.10.19
IP_PREFIX = "192.168.10." + CLUSTER

### Infrastructure ###
NODES = 3
DISKS = 3
MEMORY = 8196
CPUS = 2
NESTED = true

PREFIX = NAME_PREFIX + CLUSTER

# needed for kubeadm to add to cert
HOSTIP = Socket.ip_address_list.reject( &:ipv4_loopback? ).reject( &:ipv6_loopback? ).reject( &:ipv4_private? ).reject( &:ipv6? )[0].ip_address

Vagrant.configure("2") do |config|
    config.ssh.insert_key = false
    config.vm.box = "centos/7"

    # Override
    config.vm.provider :libvirt do |v,override|
        override.vm.synced_folder '.', '/home/vagrant/sync', disabled: true
    end

    # Make kub master
    config.vm.define "#{PREFIX}-master" do |master|
        master.vm.network :private_network, ip: "#{IP_PREFIX}9"
        master.vm.host_name = "#{PREFIX}-master"

        master.vm.provider :libvirt do |lv|
            lv.memory = MEMORY
            lv.cpus = CPUS
            lv.nested = NESTED
        end

    end

    # Make the glusterfs cluster, each with DISKS number of drives
    (0..NODES-1).each do |i|
        config.vm.define "#{PREFIX}-node#{i}" do |node|
            node.vm.hostname = "#{PREFIX}-node#{i}"
            node.vm.network :private_network, ip: "#{IP_PREFIX}#{i}"

			node.vm.provider :libvirt do |v,override|
				override.vm.synced_folder '.', '/home/vagrant/sync', disabled: true
			end

            (0..DISKS-1).each do |d|
                node.vm.provider :libvirt do  |lv|
                    driverletters = ('b'..'z').to_a
                    lv.storage :file, :device => "vd#{driverletters[d]}", :path => "#{PREFIX}-disk-#{i}-#{d}.disk", :size => '1024G'
                    lv.memory = MEMORY
                    lv.cpus = CPUS
                    lv.nested = NESTED
                end
            end

            if i == (NODES-1)
                # View the documentation for the provider you're using for more
                # information on available options.
                node.vm.provision :ansible do |ansible|
                    ansible.limit = "all"
                    ansible.playbook = "site.yml"
                    ansible.groups = {
                        "master" => ["#{PREFIX}-master"],
                        "nodes" => (0..NODES-1).map {|j| "#{PREFIX}-node#{j}"},
                        "master:vars" => { "kubeup_host_ip" => HOSTIP },
                        "nodes:vars" => { "kubeup_host_ip" => HOSTIP },
                    }
                end
            end
        end
    end
end
