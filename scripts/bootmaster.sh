#!/usr/bin/env bash
#
# Create a CEPH admin node with ceph-deploy installed
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
baseurl=http://download.ceph.com/rpm-giant/el7/noarch
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

cat << EOF > /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.33.80 cephm.master cephm
192.168.33.81 ceph1.mon1 ceph1
192.168.33.82 ceph2.mon2 ceph2
192.168.33.83 ceph3.mon3 ceph3
192.168.33.84 cepha.node1 cepha
192.168.33.85 cephb.node2 cephb
192.168.33.86 cephc.node3 cephc
EOF

cat << EOF > /home/vagrant/.ssh/config
Host 192.168.33.81
    Hostname ceph1.mon1
    User vagrant
Host 192.168.33.82
    Hostname ceph2.mon2
    User vagrant
Host 192.168.33.83
    Hostname ceph3.mon3
    User vagrant
Host 192.168.33.84
    Hostname cepha.node1
    User vagrant
Host 192.168.33.85
    Hostname cephb.node2
    User vagrant
Host 192.168.33.86
    Hostname cephc.node3
    User vagrant	
EOF

echo   
echo "********************************************************"
echo "*                                                      *"
echo "*     set some pre-requisites                          *"  
echo "*                                                      *"  
echo "********************************************************" 
echo

# Make sure all the clocks on the nodes are synchronised
yum install -y ntp ntpdate ntp-doc
ntpdate nldcr-ntp11.nwd.itc.intranet
hwclock --systohc
systemctl enable ntpd.service
systemctl start ntpd.service

# SELinux must be Permissive or disabled
setenforce 0

# Turn off the firewall (or open the appropriate ports (6789, 6800:7300)
systemctl disable firewalld

# Ensure that your package manager has priority/preferences packages installed and enabled
yum install -y yum-plugin-priorities


echo   
echo "**************************************************************"
echo "*                                                            *"
echo "*     create a very basic script to create a storage cluster *"  
echo "*                                                            *"  
echo "**************************************************************" 
echo

mkdir my-cluster
chown vagrant:vagrant my-cluster
cd my-cluster

cat << EOF > step1.sh
#!/bin/bash
# 
# Script to create a RADOS Ceph Storage Cluster
# 
# Create a key on the admin node and copy it to all the other nodes
# so the admin node can communicate without a password to the nodes
ssh-keygen
ssh-copy-id vagrant@ceph1.mon1
ssh-copy-id vagrant@ceph2.mon2
ssh-copy-id vagrant@ceph3.mon3
ssh-copy-id vagrant@cepha.node1
ssh-copy-id vagrant@cephb.node2
ssh-copy-id vagrant@cephc.node3
ssh-copy-id vagrant@cephm.master

EOF

cat << EOF > step2.sh
#!/bin/bash
# 
# Script to create a RADOS Ceph Storage Cluster
# 
# 
# Create the new cluster by first installing the monitor nodes
ceph-deploy new ceph1.mon1 ceph2.mon2 ceph3.mon3


# set the default number of OSD on 2. Ceph can now run on just 2 OSD's
echo "osd pool default size = 2" >> ceph.conf
echo "osd pool default min size = 1" >> ceph.conf
echo "osd pool default pg num = 256" >> ceph.conf
echo "osd pool default pgp num = 256" >> ceph.conf
echo "osd crush chooseleaf type = 1" >> ceph.conf
# check
ceph-deploy disk list cepha.node1
EOF

cat << EOF > step3.sh
#!/bin/bash
# 
# Script to create a RADOS Ceph Storage Cluster
# 
# Install Ceph on all the nodes, Admin node, OSD's and Monitors
ceph-deploy install ceph1.mon1 
ceph-deploy install ceph2.mon2 
ceph-deploy install ceph3.mon3 
ceph-deploy install cepha.node1 
ceph-deploy install cephb.node2 
ceph-deploy install cephc.node3
ceph-deploy install cephm.master
# This is a small trick when something goes wrong
# sudo mv /etc/yum.repos.d/ceph.repo /etc/yum.repos.d/ceph-deploy.repo
EOF

cat << EOF > step4.sh
#!/bin/bash
# 
# Script to create a RADOS Ceph Storage Cluster
# 
# Add the initial monitor(s) and gather the keys
# After this command you will have 4 keyring files in your home directory
ceph-deploy mon create-initial
ls -al /home/vagrant/my-cluster/*keyring

EOF

cat << EOF > step5.sh
#!/bin/bash
# 
# Script to create a RADOS Ceph Storage Cluster
# 
# Prepare the OSD's
ceph-deploy osd prepare cepha.node1:/var/local/osd cephb.node2:/var/local/osd cephc.node3:/var/local/osd

# activate the OSDs.
ceph-deploy osd activate cepha.node1:/var/local/osd cephb.node2:/var/local/osd cephc.node3:/var/local/osd

EOF

cat << EOF > step6.sh
#!/bin/bash
# 
# Script to create a RADOS Ceph Storage Cluster
# 
# copy the configuration file and admin key to your admin node and your Ceph Nodes
# so that you can use the ceph CLI 
ceph-deploy admin ceph1.mon1 ceph2.mon2 ceph3.mon3 cepha.node1 cephb.node2 cephc.node3 cephm.master

# Ensure that you have the correct permissions for the ceph.client.admin.keyring.
sudo chmod +r /etc/ceph/ceph.client.admin.keyring

# Check your cluster’s health.
ceph health
ceph -s

# Hope you get an healty state. If so: phase one is done!
EOF

echo   
echo "**************************************************************"
echo "*                                                            *"
echo "*     create a very basic script to create an S3 Gateway     *"  
echo "*                                                            *"  
echo "**************************************************************" 
echo

cat << EOF > /home/vagrant/my-cluster/create_s3g.sh
#!/bin/bash
# 
# Script to create an S3 Gateway
# from: http://docs.ceph.com/docs/master/install/install-ceph-gateway/
#
# Install the Ceph Object Gateway package on all the client nodes
ceph-deploy install --rgw ceph1.mon1

# make your Ceph Object Gateway node an administrator node
ceph-deploy admin ceph1.mon1

# From the working directory of your administration server, 
# create an instance of the Ceph Object Gateway on the Ceph Object Gateway.
sudo cd ~/mycluster
ceph-deploy rgw create ceph1.mon1

# test the gateway
curl http://cepha.node1:7480

# 


EOF

chmod +x step[1-6].sh create_s3g.sh
chown vagrant:vagrant step[1-6].sh create_s3g.sh

echo
echo "************************************************"
echo "*                                              *"
echo "*             SHOW IP                          *"  
echo "*                                              *"  
echo "************************************************"  
echo

ip addr | grep 192
