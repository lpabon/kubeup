# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'socket'

### CONFIGURATION ###
#
# Example: Here we have two k8s clusters, one called 'storage', and one called 'tenant'
#CLUSTERS = [ "storage", "tenant" ]
CLUSTERS = [ "k3s" ]

### Infrastructure ###
NODES = 3
DISKS = 3
MEMORY = 32*1024
CPUS = 16
NESTED = false

NAME_PREFIX = "kubeup"
if ENV["KUBEUP_USER"]
  NAME_PREFIX = ENV["KUBEUP_USER"] + "-"
end

nodes = Array.new
masters = Array.new
groups = Hash.new

# needed for kubeadm to add to cert
HOSTIP = Socket.ip_address_list.reject( &:ipv4_loopback? ).reject( &:ipv6_loopback? ).reject( &:ipv6? ).map{|ip| ip.ip_address}.join(",")

Vagrant.configure("2") do |config|
    config.ssh.insert_key = false
    config.vm.box = "generic/rocky9"

    # Override
    config.vm.provider :libvirt do |v,override|
        override.vm.synced_folder '.', '/home/vagrant/sync', disabled: true
    end


    CLUSTERS.each do |clusterName|
      prefix = NAME_PREFIX + clusterName
      # Make kub master
      config.vm.define "#{prefix}-master" do |master|
          master.vm.host_name = "#{prefix}-master"

          master.vm.provider :libvirt do |lv|
              lv.memory = 16*1024
              lv.cpus = 4
          end
      end

      (0..NODES-1).each do |i|
          config.vm.define "#{prefix}-node#{i}" do |node|
              node.vm.hostname = "#{prefix}-node#{i}"

              node.vm.provider :libvirt do |v,override|
                  override.vm.synced_folder '.', '/home/vagrant/sync', disabled: true
              end

                  (0..DISKS-1).each do |d|
                      node.vm.provider :libvirt do  |lv|
                          driverletters = ('b'..'z').to_a
                          lv.storage :file, :device => "vd#{driverletters[d]}", :path => "#{prefix}-disk-#{i}-#{d}.disk", :size => '1024G'
                          lv.memory = MEMORY
                          lv.cpus = CPUS
                      end
                  end

              if i == (NODES-1)
                  groups["#{clusterName}-master"] = ["#{prefix}-master"]
                  groups["#{clusterName}-nodes"] = (0..NODES-1).map {|j| "#{prefix}-node#{j}"}
                  groups["#{clusterName}-master:vars"] = { "kubeup_host_ip" => HOSTIP , "kubeup_clustername" => clusterName }
                  groups["#{clusterName}-nodes:vars"] =  { "kubeup_host_ip" => HOSTIP , "kubeup_clustername" => clusterName }
              end

              if i == (NODES-1) and clusterName == CLUSTERS[-1]
                  # View the documentation for the provider you're using for more
                  # information on available options.
                  node.vm.provision :ansible do |ansible|
                      ansible.limit = "all"
                      ansible.playbook = "site.yml"
                      ansible.groups = groups
                  end
              end
          end
      end
   end
end
