#!/usr/bin/env bash
#
# Create a CEPH node
# 
# This can be a Monitor or and OSD
#
# Based on: http://docs.ceph.com/docs/master/start/quick-start-preflight/
# and based on: http://www.virtualtothecore.com/en/adventures-ceph-storage-part-1-introduction/
#
# This script is part of a code package that creates a Ceph Storage cluster
# with 1 admin node, 3 monitors and 3 OSD's
#
# The script is intended for a Centos 7 VM
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
echo "*             INSTALL some basic stuff         *"  
echo "*                                              *"  
echo "************************************************" 
echo

yum install -y vim
yum install -y rpm
yum install -y wget

# Make sure all the clocks on the nodes are synchronised
yum install -y ntp ntpdate ntp-doc
ntpdate 0.us.pool.ntp.org
hwclock --systohc
systemctl enable ntpd.service
systemctl start ntpd.service

# Install an SSH server (if necessary)
yum install -y openssh-server

# For now I use the vagrant user. But this can be changed to cephuser.
# Make sure the user has passwordless sudo privileges
useradd -d /home/cephuser -m cephuser
echo -e "87654321\n87654321" | passwd cephuser
echo "cephuser ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephuser
echo "vagrant ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/cephuser

# SELinux must be Permissive or disabled
setenforce 0

# Turn off the firewall (or open the appropriate ports (6789, 6800:7300)
systemctl disable firewalld

# Ensure that your package manager has priority/preferences packages installed and enabled
yum install -y yum-plugin-priorities

# Make sure the admin node can find the other nodes by name
cat << EOF > /etc/hosts
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

# Create an OSD directory that will be used for the Storage cluster
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