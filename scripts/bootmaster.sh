#!/usr/bin/env bash
#
# boot CEPH
#


echo
echo "************************************************"
echo "*                                              *"
echo "*             UPDATE THE SYSTEM                *"  
echo "*                                              *"  
echo "************************************************" 
echo

yum -y update

echo   
echo "************************************************"
echo "*                                              *"
echo "*             INSTALL stuff                    *"  
echo "*                                              *"  
echo "************************************************" 
echo

yum install -y vim
yum install -y rpm
yum install -y wget

rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/elrepo.repo
yum install -y yum-utils
yum-config-manager --add-repo https://dl.fedoraproject.org/pub/epel/7/x86_64/ 
yum install --nogpgcheck -y epel-release
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
rm /etc/yum.repos.d/dl.fedoraproject.org*

echo "[ceph-noarch]" > /etc/yum.repos.d/ceph.repo
echo "name=Ceph noarch packages" >> /etc/yum.repos.d/ceph.repo
echo "baseurl=http://download.ceph.com/rpm-infernalis/el7/noarch" >> /etc/yum.repos.d/ceph.repo
echo "enabled=1" >> /etc/yum.repos.d/ceph.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/ceph.repo
echo "type=rpm-md" >> /etc/yum.repos.d/ceph.repo
echo "gpgkey=https://download.ceph.com/keys/release.asc" >> /etc/yum.repos.d/ceph.repo

yum update 
yum install -y ceph-deploy


echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" > /etc/hosts
echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts
echo "192.168.33.80 ceph.master ceph" >> /etc/hosts
echo "192.168.33.81 ceph1.slave ceph1" >> /etc/hosts
echo "192.168.33.82 ceph2.slave ceph2" >> /etc/hosts
echo "192.168.33.83 ceph3.slave ceph3" >> /etc/hosts


echo " Host 192.168.33.81" > /home/vagrant/.ssh/config
echo "    Hostname ceph1.slave" >> /home/vagrant/.ssh/config
echo "    User xyxuser" >> /home/vagrant/.ssh/config
echo " Host 192.168.33.82" >> /home/vagrant/.ssh/config
echo "    Hostname ceph2.slave" >> /home/vagrant/.ssh/config
echo "    User xyzuser" >> /home/vagrant/.ssh/config
echo " Host 192.168.33.83" >> /home/vagrant/.ssh/config
echo "    Hostname ceph3.slave" >> /home/vagrant/.ssh/config
echo "    User xyzuser" >> /home/vagrant/.ssh/config

setenforce 0
systemctl disable firewalld
yum install -y yum-plugin-priorities

cd /home/vagrant
echo "ssh-keygen" > create_csc
echo "ssh-copy-id xyzuser@ceph1.slave" >> create_csc.sh
echo "ssh-copy-id xyzuser@ceph2.slave" >> create_csc.sh
echo "ssh-copy-id xyzuser@ceph3.slave" >> create_csc.sh
echo "mkdir my-cluster" >> create_csc.sh
echo "cd my-cluster" >> create_csc.sh
echo "ceph-deploy new ceph1" >> create_csc.sh
echo 'echo "osd pool default size = 2" >> ceph.conf' >> create_csc.sh
echo "sudo mv /etc/yum.repos.d/ceph.repo /etc/yum.repos.d/ceph-deploy.repo" >> create_csc.sh
echo "ceph-deploy install ceph ceph1.slave ceph2.slave ceph3.slave" >> create_csc.sh 
echo "ceph-deploy mon create-initial" >> create_csc.sh
echo "ceph-deploy osd prepare ceph2.slave:/var/local/osd0 ceph3.slave:/var/local/osd1" >> create_csc.sh
echo "ceph-deploy osd activate ceph2.slave:/var/local/osd0 ceph3.slave:/var/local/osd1" >> create_csc.sh
echo "ceph-deploy admin ceph ceph1 ceph2.slave ceph3.slave" >> create_csc.sh
echo "sudo chmod +r /etc/ceph/ceph.client.admin.keyring" >> create_csc.sh
echo "ceph health" >> create_csc.sh
chmod +x create_csc.sh

echo
echo "************************************************"
echo "*                                              *"
echo "*             SHOW IP                          *"  
echo "*                                              *"  
echo "************************************************"  
echo

ip addr | grep 192