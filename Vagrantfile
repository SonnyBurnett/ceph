# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure(2) do |config|

  # Every Vagrant virtual environment requires a box to build off of.
  #config.vm.box = "centos/7"
  #config.vm.box = "tsbakker/cephbox"
  config.vm.box = "ceph/centos7"

  config.hostmanager.enabled = true

  (1..3).each do |i|
    config.vm.define "cephmon#{i}" do |cephmon|
      cephmon.vm.network "private_network", ip: "192.168.33.8#{i+1}"
      cephmon.vm.synced_folder ".","/vagrant", type: "virtualbox", disabled: true
      cephmon.vm.synced_folder ".","/home/vagrant/sync", type: "virtualbox", disabled: true
      cephmon.vm.provider "virtualbox" do |vb|
        vb.memory = 1024
      end
      cephmon.vm.hostname = "cephmon#{i}"
      cephmon.vm.provision "shell", path: "scripts/bootnode.sh"
      # cephmon.vm.provision "shell", path: "scripts/sshkeys.sh"
    end 
  end 

  (4..6).each do |i|
    file_to_disk = "./tmp/large_disk#{i}.vdi"
    config.vm.define "cephnode#{i}" do |cephnode|
      cephnode.vm.network "private_network", ip: "192.168.33.8#{i+1}"
      cephnode.vm.synced_folder ".","/vagrant", type: "virtualbox", disabled: true
      cephnode.vm.synced_folder ".","/home/vagrant/sync", type: "virtualbox", disabled: true
      cephnode.vm.provider "virtualbox" do |vb|
        vb.memory = 1024
       #unless File.exist?(file_to_disk)
         #vb.customize ['createhd', '--filename', file_to_disk, '--variant', 'Fixed', '--size', 1 * 1024]
       #end
       #Hanging vagrant? try swapping SATA with IDe or vice versa
       #vb.customize ['storageattach', :id,  '--storagectl', 'IDE Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]

      end
      cephnode.vm.hostname = "cephnode#{i}"

      cephnode.vm.provision "shell", path: "scripts/bootnode.sh"
      # cephnode.vm.provision "shell", path: "scripts/sshkeys.sh"
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
    cephmaster.vm.hostname = "cephmaster"	  

    cephmaster.vm.provision "shell", path: "scripts/bootmaster.sh"
    # cephmaster.vm.provision "shell", path: "scripts/sshkeys.sh"
  end

end