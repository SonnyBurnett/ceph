# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure(2) do |config|
	  
   config.vm.define :cephslave1 do |cephslave1|
      cephslave1.vm.box = "centos/7"  
	  cephslave1.vm.network "private_network", ip: "192.168.33.81"
	  cephslave1.vm.synced_folder ".","/vagrant", type: "virtualbox", disabled: true
	  cephslave1.vm.synced_folder ".","/home/vagrant/sync", type: "virtualbox", disabled: true
	  cephslave1.vm.provider "virtualbox" do |vb|
	     vb.memory = 2048
	     vb.name = "cephslave1"
      end
	  cephslave1.vm.hostname = "ceph1.slave"
      cephslave1.vm.provision "shell" do |s|
          s.path = "scripts/bootslave1.sh"
      end
   end 
  
  config.vm.define :cephslave2 do |cephslave2|
      cephslave2.vm.box = "centos/7"  
	  cephslave2.vm.network "private_network", ip: "192.168.33.82"
	  cephslave2.vm.synced_folder ".","/vagrant", type: "virtualbox", disabled: true
	  cephslave2.vm.synced_folder ".","/home/vagrant/sync", type: "virtualbox", disabled: true
	  cephslave2.vm.provider "virtualbox" do |vb|
	     vb.memory = 2048
	     vb.name = "cephslave2"
      end
	  cephslave2.vm.hostname = "ceph2.slave"
      cephslave2.vm.provision "shell" do |s|
          s.path = "scripts/bootslave2.sh"
      end
   end 
     
   config.vm.define :cephslave3 do |cephslave3|
      cephslave3.vm.box = "centos/7"  
	  cephslave3.vm.network "private_network", ip: "192.168.33.83"
	  cephslave3.vm.synced_folder ".","/vagrant", type: "virtualbox", disabled: true
	  cephslave3.vm.synced_folder ".","/home/vagrant/sync", type: "virtualbox", disabled: true
	  cephslave3.vm.provider "virtualbox" do |vb|
	     vb.memory = 2048
	     vb.name = "cephslave3"
      end
	  cephslave3.vm.hostname = "ceph3.slave"
      cephslave3.vm.provision "shell" do |s|
          s.path = "scripts/bootslave3.sh"
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