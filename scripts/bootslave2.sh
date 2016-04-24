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

yum install -y ntp ntpdate ntp-doc
useradd -d /home/xyzuser -m xyzuser
echo -e "87654321\n87654321" | passwd xyzuser
echo "xyzuser ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/xyzuser
chmod 0440 /etc/sudoers.d/xyzuser

setenforce 0
systemctl disable firewalld
yum install -y yum-plugin-priorities

echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" > /etc/hosts
echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts
echo "192.168.33.81 ceph1.slave ceph1" >> /etc/hosts
echo "192.168.33.82 ceph2.slave ceph2" >> /etc/hosts
echo "192.168.33.83 ceph3.slave ceph3" >> /etc/hosts
echo "192.168.33.80 ceph.master ceph" >> /etc/hosts

mkdir /var/local/osd0
chmod 777 /var/local/osd0

echo
echo "************************************************"
echo "*                                              *"
echo "*             SHOW IP                          *"  
echo "*                                              *"  
echo "************************************************"  
echo

ip addr | grep 192