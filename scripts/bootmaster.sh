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
echo "*             INSTALL some basics              *"  
echo "*                                              *"  
echo "************************************************" 
echo

yum install -y vim
yum install -y rpm
yum install -y wget

echo   
echo "************************************************"
echo "*                                              *"
echo "*             INSTALL elrepo                   *"  
echo "*                                              *"  
echo "************************************************" 
echo

rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/elrepo.repo
yum install -y yum-utils
yum-config-manager --add-repo https://dl.fedoraproject.org/pub/epel/7/x86_64/ 
yum install --nogpgcheck -y epel-release
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
rm /etc/yum.repos.d/dl.fedoraproject.org*

echo   
echo "********************************************************"
echo "*                                                      *"
echo "*     create a Yellowdog Updater, Modified (YUM) entry *"  
echo "*                                                      *"  
echo "********************************************************" 
echo

cat << EOF > /etc/yum.repos.d/ceph.repo
[ceph-noarch]
name=Ceph noarch packages
baseurl=http://download.ceph.com/rpm-infernalis/el7/noarch
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc
EOF

echo   
echo "********************************************************"
echo "*                                                      *"
echo "*     install ceph-deploy                              *"  
echo "*                                                      *"  
echo "********************************************************" 
echo

yum update 
yum install -y ceph-deploy

echo   
echo "********************************************************"
echo "*                                                      *"
echo "*     Make sure the Master can find the nodes          *"  
echo "*                                                      *"  
echo "********************************************************" 
echo

cat << EOF /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.33.80 ceph.master ceph
192.168.33.81 ceph1.slave ceph1
192.168.33.82 ceph2.slave ceph2
192.168.33.83 ceph3.slave ceph3
EOF

cat << EOF > /home/vagrant/.ssh/config
Host 192.168.33.81
    Hostname ceph1.slave
    User xyxuser
Host 192.168.33.82
    Hostname ceph2.slave
    User xyzuser
Host 192.168.33.83
    Hostname ceph3.slave
    User xyzuser
EOF

echo   
echo "********************************************************"
echo "*                                                      *"
echo "*     set some pre-requisites                          *"  
echo "*                                                      *"  
echo "********************************************************" 
echo

setenforce 0
systemctl disable firewalld
yum install -y yum-plugin-priorities

echo   
echo "**************************************************************"
echo "*                                                            *"
echo "*     create a very basic script to create a storage cluster *"  
echo "*                                                            *"  
echo "**************************************************************" 
echo

cat << EOF > /home/vagrant/create_csc.sh
ssh-keygen
ssh-copy-id xyzuser@ceph1.slave
ssh-copy-id xyzuser@ceph2.slave
ssh-copy-id xyzuser@ceph3.slave
sudo mkdir my-cluster
sudo cd my-cluster
ceph-deploy new ceph1
echo "osd pool default size = 2" >> ceph.conf
sudo mv /etc/yum.repos.d/ceph.repo /etc/yum.repos.d/ceph-deploy.repo
ceph-deploy install ceph ceph1.slave ceph2.slave ceph3.slave
ceph-deploy mon create-initial
ceph-deploy osd prepare ceph2.slave:/var/local/osd0 ceph3.slave:/var/local/osd1
ceph-deploy osd activate ceph2.slave:/var/local/osd0 ceph3.slave:/var/local/osd1
ceph-deploy admin ceph ceph1 ceph2.slave ceph3.slave
sudo chmod +r /etc/ceph/ceph.client.admin.keyring
ceph health
EOF

chmod +x create_csc.sh

echo
echo "************************************************"
echo "*                                              *"
echo "*             SHOW IP                          *"  
echo "*                                              *"  
echo "************************************************"  
echo

ip addr | grep 192