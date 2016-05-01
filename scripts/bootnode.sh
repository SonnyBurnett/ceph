#!/usr/bin/env bash
#
# boot CEPH node
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
yum install -y openssh-server

useradd -d /home/cephuser -m cephuser
echo -e "87654321\n87654321" | passwd cephuser
echo "cephuser ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephuser
echo "vagrant ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/cephuser

setenforce 0
systemctl disable firewalld
yum install -y yum-plugin-priorities

cat << EOF /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.33.80 ceph.master ceph
192.168.33.81 ceph1.mon1 ceph1
192.168.33.82 ceph2.mon2 ceph2
192.168.33.83 ceph3.mon3 ceph3
192.168.33.84 cepha.node1 cepha
192.168.33.85 cephb.node2 cephb
192.168.33.86 cephc.node3 cephc
EOF

mkdir /var/local/osd
chmod 777 /var/local/osd

echo
echo "************************************************"
echo "*                                              *"
echo "*             SHOW IP                          *"  
echo "*                                              *"  
echo "************************************************"  
echo

ip addr | grep 192