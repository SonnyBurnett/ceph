# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure(2) do |config|
	  
   config.vm.define :cephnode1 do |cephnode1|
      cephnode1.vm.box = "centos/7"  
	  cephnode1.vm.network "private_network", ip: "192.168.33.81"
	  cephnode1.vm.synced_folder ".","/vagrant", type: "virtualbox", disabled: true
	  cephnode1.vm.synced_folder ".","/home/vagrant/sync", type: "virtualbox", disabled: true
	  cephnode1.vm.provider "virtualbox" do |vb|
	     vb.memory = 1024
	     vb.name = "cephmon1"
      end
	  cephnode1.vm.hostname = "ceph1.mon1"
      cephnode1.vm.provision "shell" do |s|
          s.path = "scripts/bootnode.sh"
      end
   end 
  
  config.vm.define :cephnode2 do |cephnode2|
      cephnode2.vm.box = "centos/7"  
	  cephnode2.vm.network "private_network", ip: "192.168.33.82"
	  cephnode2.vm.synced_folder ".","/vagrant", type: "virtualbox", disabled: true
	  cephnode2.vm.synced_folder ".","/home/vagrant/sync", type: "virtualbox", disabled: true
	  cephnode2.vm.provider "virtualbox" do |vb|
	     vb.memory = 1024
	     vb.name = "cephmon2"
      end
	  cephnode2.vm.hostname = "ceph2.mon2"
      cephnode2.vm.provision "shell" do |s|
          s.path = "scripts/bootnode.sh"
      end
   end 
     
   config.vm.define :cephnode3 do |cephnode3|
      cephnode3.vm.box = "centos/7"  
	  cephnode3.vm.network "private_network", ip: "192.168.33.83"
	  cephnode3.vm.synced_folder ".","/vagrant", type: "virtualbox", disabled: true
	  cephnode3.vm.synced_folder ".","/home/vagrant/sync", type: "virtualbox", disabled: true
	  cephnode3.vm.provider "virtualbox" do |vb|
	     vb.memory = 1024
	     vb.name = "cephnode3"
      end
	  cephnode3.vm.hostname = "ceph3.mon3"
      cephnode3.vm.provision "shell" do |s|
          s.path = "scripts/bootnode.sh"
      end
   end
   
   config.vm.define :cephnode4 do |cephnode4|
      cephnode4.vm.box = "centos/7"  
	  cephnode4.vm.network "private_network", ip: "192.168.33.84"
	  cephnode4.vm.synced_folder ".","/vagrant", type: "virtualbox", disabled: true
	  cephnode4.vm.synced_folder ".","/home/vagrant/sync", type: "virtualbox", disabled: true
	  cephnode4.vm.provider "virtualbox" do |vb|
	     vb.memory = 1024
	     vb.name = "cephnode4"
      end
	  cephnode4.vm.hostname = "cepha.node1"
      cephnode4.vm.provision "shell" do |s|
          s.path = "scripts/bootnode.sh"
      end
   end
   
   config.vm.define :cephnode5 do |cephnode5|
      cephnode5.vm.box = "centos/7"  
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
      end
   end
   
   config.vm.define :cephnode6 do |cephnode6|
      cephnode6.vm.box = "centos/7"  
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
      end
   end
   
   config.vm.define :cephmaster do |cephmaster|
      cephmaster.vm.box = "centos/7"  
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
      end
   end
    
end