# -*- mode: ruby -*-
# vi: set ft=ruby :

### CONFIGURATION ###

CLUSTER = "1" # Cluster value must be from 1-9 only because it is used in IP_PREFIX
NAME_PREFIX = "lpabon-"

# Prefix for IP address: In essense: IP_PREFIX+id => "192.168.10.19
IP_PREFIX = "192.168.10." + CLUSTER

CLUSTERS = [ "dev", "test", "prod-east-a", "prod-east-b", "prod-west-a", "prod-west-b" ]

### Infrastructure ###
NODES = 1
DISKS = 3
MEMORY = 6*1024
CPUS = 2
NESTED = true

# Startig IP
ip=4

nodes = Array.new
masters = Array.new
groups = Hash.new

Vagrant.configure("2") do |config|
    config.ssh.insert_key = false
    config.vm.box = "centos/7"

    # Override
    config.vm.provider :libvirt do |v,override|
        override.vm.synced_folder '.', '/home/vagrant/sync', disabled: true
    end


    CLUSTERS.each { |clusterName|
      prefix = NAME_PREFIX + clusterName
      # Make kub master
      config.vm.define "#{prefix}-master" do |master|
          ip += 1
          master.vm.network :private_network, ip: "#{IP_PREFIX}#{ip}"
          master.vm.host_name = "#{prefix}-master"

          master.vm.provider :libvirt do |lv|
              lv.memory = MEMORY
              lv.cpus = CPUS
              lv.nested = NESTED
          end

          #masters.push(master.vm.host_name)
      end

      (0..NODES-1).each do |i|
          config.vm.define "#{prefix}-node#{i}" do |node|
              node.vm.hostname = "#{prefix}-node#{i}"
              #nodes.push(node.vm.hostname)

              ip += 1
              node.vm.network :private_network, ip: "#{IP_PREFIX}#{ip}"

              node.vm.provider :libvirt do |v,override|
                  override.vm.synced_folder '.', '/home/vagrant/sync', disabled: true
              end

              (0..DISKS-1).each do |d|
                  node.vm.provider :libvirt do  |lv|
                      driverletters = ('b'..'z').to_a
                      lv.storage :file, :device => "vd#{driverletters[d]}", :path => "#{prefix}-disk-#{i}-#{d}.disk", :size => '1024G'
                      lv.memory = MEMORY
                      lv.cpus = CPUS
                      lv.nested = NESTED
                  end
              end

              if i == (NODES-1)
                  groups["#{clusterName}-master"] = ["#{prefix}-master"]
                  groups["#{clusterName}-nodes"] = (0..NODES-1).map {|j| "#{prefix}-node#{j}"}
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
    }

end
