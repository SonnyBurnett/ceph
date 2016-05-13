# -*- mode: ruby -*-
# vi: set ft=ruby :

file_to_disk = './tmp/large_disk.vdi'

Vagrant.configure(2) do |config|

  # Every Vagrant virtual environment requires a box to build off of.
    config.vm.box = "centos-7.0_1.0"
  
   # The url from where the 'config.vm.box' box will be fetched if it
   # doesn't already exist on the user's system.
   config.vm.box_url = "http://build-utils.nl.europe.intranet/vagrantbox/centos-7.0-x86_64_1.0.box"
   config.vm.boot_timeout = 900
	  
   config.vm.define :cephmon1 do |cephmon1|
	  cephmon1.vm.network "private_network", ip: "192.168.33.81"
	  cephmon1.vm.synced_folder ".","/vagrant", type: "virtualbox", disabled: true
	  cephmon1.vm.synced_folder ".","/home/vagrant/sync", type: "virtualbox", disabled: true
	  cephmon1.vm.provider "virtualbox" do |vb|
	     vb.memory = 1024
	     vb.name = "cephmon1"
      end
	  cephmon1.vm.hostname = "ceph1.mon1"
      cephmon1.vm.provision "shell" do |s|
          s.path = "scripts/bootnode.sh"
          s.path = "scripts/sshkeys.sh"
      end
   end 
  
  config.vm.define :cephmon2 do |cephmon2|
	  cephmon2.vm.network "private_network", ip: "192.168.33.82"
	  cephmon2.vm.synced_folder ".","/vagrant", type: "virtualbox", disabled: true
	  cephmon2.vm.synced_folder ".","/home/vagrant/sync", type: "virtualbox", disabled: true
	  cephmon2.vm.provider "virtualbox" do |vb|
	     vb.memory = 1024
	     vb.name = "cephmon2"
      end
	  cephmon2.vm.hostname = "ceph2.mon2"
      cephmon2.vm.provision "shell" do |s|
          s.path = "scripts/bootnode.sh"
          s.path = "scripts/sshkeys.sh"
      end
   end 
     
   config.vm.define :cephmon3 do |cephmon3|
	  cephmon3.vm.network "private_network", ip: "192.168.33.83"
	  cephmon3.vm.synced_folder ".","/vagrant", type: "virtualbox", disabled: true
	  cephmon3.vm.synced_folder ".","/home/vagrant/sync", type: "virtualbox", disabled: true
	  cephmon3.vm.provider "virtualbox" do |vb|
	     vb.memory = 1024
	     vb.name = "cephmon3"
      end
	  cephmon3.vm.hostname = "ceph3.mon3"
      cephmon3.vm.provision "shell" do |s|
          s.path = "scripts/bootnode.sh"
          s.path = "scripts/sshkeys.sh"
      end
   end
   
 
   
   config.vm.define :cephnode4 do |cephnode4|
	  cephnode4.vm.network "private_network", ip: "192.168.33.84"
	  cephnode4.vm.synced_folder ".","/vagrant", type: "virtualbox", disabled: true
	  cephnode4.vm.synced_folder ".","/home/vagrant/sync", type: "virtualbox", disabled: true
	  cephnode4.vm.provider "virtualbox" do |vb|
	     vb.memory = 1024
	     vb.name = "cephnode4"
		 unless File.exist?(file_to_disk)
            vb.customize ['createhd', '--filename', file_to_disk, '--variant', 'Fixed', '--size', 1 * 1024]
         end
         vb.customize ['storageattach', :id,  '--storagectl', 'IDE Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
		 
	  end
	  cephnode4.vm.hostname = "cepha.node1"
	  
      cephnode4.vm.provision "shell" do |s|
          s.path = "scripts/bootnode.sh"
          s.path = "scripts/sshkeys.sh"
      end
   end
   
   config.vm.define :cephnode5 do |cephnode5|
	  cephnode5.vm.network "private_network", ip: "192.168.33.85"
	  cephnode5.vm.synced_folder ".","/vagrant", type: "virtualbox", disabled: true
	  cephnode5.vm.synced_folder ".","/home/vagrant/sync", type: "virtualbox", disabled: true
	  cephnode5.vm.provider "virtualbox" do |vb|
	     vb.memory = 1024
	     vb.name = "cephnode5"
		 
      end
	  cephnode5.vm.hostname = "cephb.node2"
	  
      cephnode5.vm.provision "shell" do |s|
          s.path = "scripts/bootnode.sh"
          s.path = "scripts/sshkeys.sh"
      end
   end
   
   config.vm.define :cephnode6 do |cephnode6|
	  cephnode6.vm.network "private_network", ip: "192.168.33.86"
	  cephnode6.vm.synced_folder ".","/vagrant", type: "virtualbox", disabled: true
	  cephnode6.vm.synced_folder ".","/home/vagrant/sync", type: "virtualbox", disabled: true
	  cephnode6.vm.provider "virtualbox" do |vb|
	     vb.memory = 1024
	     vb.name = "cephnode6"
		 
      end
	  cephnode6.vm.hostname = "cephc.node3"
	  
      cephnode6.vm.provision "shell" do |s|
          s.path = "scripts/bootnode.sh"
          s.path = "scripts/sshkeys.sh"
      end
   end
   
   config.vm.define :cephmaster do |cephmaster|
	  cephmaster.vm.network "private_network", ip: "192.168.33.80"
	  cephmaster.vm.synced_folder ".","/vagrant", type: "virtualbox", disabled: true
	  cephmaster.vm.synced_folder ".","/home/vagrant/sync", type: "virtualbox", disabled: true
	  cephmaster.vm.provider "virtualbox" do |vb|
	     vb.memory = 2048
	     vb.name = "cephmaster"
      end
      cephmaster.vm.hostname = "ceph.master"	  
      cephmaster.vm.provision "shell" do |s|
          s.path = "scripts/bootmaster.sh"
          s.path = "scripts/sshkeys.sh"
      end
   end
    
end
