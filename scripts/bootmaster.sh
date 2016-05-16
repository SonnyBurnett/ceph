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

#install some basics
yum install -y vim
#yum install -y rpm
yum install -y wget

# install elrepo
#rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
#rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
#sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/elrepo.repo
#yum install -y yum-utils
#yum-config-manager --add-repo https://dl.fedoraproject.org/pub/epel/7/x86_64/ 
#yum install --nogpgcheck -y epel-release
#rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
#rm /etc/yum.repos.d/dl.fedoraproject.org*

echo   
echo "********************************************************"
echo "*                                                      *"
echo "*     create a Yellowdog Updater, Modified (YUM) entry *"  
echo "*                                                      *"  
echo "********************************************************" 
echo



#cat << EOF > /etc/yum.repos.d/ceph.repo

[ceph]
name=Ceph packages for $basearch
baseurl=http://eu.ceph.com/rpm-hammer/el7/$basearch
enabled=1
priority=2
gpgcheck=1
type=rpm-md
gpgkey=https://eu.ceph.com/keys/release.asc

[ceph-noarch]
name=Ceph noarch packages
baseurl=http://eu.ceph.com/rpm-hammer/el7/noarch
enabled=1
priority=2
gpgcheck=1
type=rpm-md
gpgkey=https://eu.ceph.com/keys/release.asc

[ceph-source]
name=Ceph source packages
baseurl=http://eu.ceph.com/rpm-hammer/el7/SRPMS
enabled=0
priority=2
gpgcheck=1
type=rpm-md
gpgkey=https://eu.ceph.com/keys/release.asc
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
echo "*     set some pre-requisites                          *"  
echo "*                                                      *"  
echo "********************************************************" 
echo

# Make sure all the clocks on the nodes are synchronised
#yum install -y ntp ntpdate ntp-doc
#ntpdate 0.us.pool.ntp.org
#hwclock --systohc
systemctl enable ntpd.service
systemctl start ntpd.service

# SELinux must be Permissive or disabled
setenforce 0

# Turn off the firewall (or open the appropriate ports (6789, 6800:7300)
systemctl disable firewalld

# Ensure that your package manager has priority/preferences packages installed and enabled
#yum install -y yum-plugin-priorities


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

cat << EOF > install-ceph.sh
#!/bin/bash
# 
# Script to create a RADOS Ceph Storage Cluster
# 
# 
set -e
sudo rpm --import 'https://download.ceph.com/keys/release.asc'
sudo rpm --import 'https://download.ceph.com/keys/autobuild.asc'


# Create the new cluster by first installing the monitor nodes
ceph-deploy new cephmon1 cephmon2 cephmon3

# set the default number of OSD on 2. Ceph can now run on just 2 OSD's
echo "osd pool default size = 2" >> ceph.conf
echo "osd pool default min size = 1" >> ceph.conf
echo "osd pool default pg num = 256" >> ceph.conf
echo "osd pool default pgp num = 256" >> ceph.conf
echo "osd crush chooseleaf type = 1" >> ceph.conf

# Install Ceph on all the nodes, Admin node, OSD's and Monitors
ceph-deploy install --release hammer cephmon1 cephmon2 cephmon3 cephnode4 cephnode5 cephnode6 cephmaster

# This is a small trick when something goes wrong
# sudo mv /etc/yum.repos.d/ceph.repo /etc/yum.repos.d/ceph-deploy.repo

# Add the initial monitor(s) and gather the keys
# After this command you will have 4 keyring files in your home directory
ceph-deploy mon create-initial
ls -al /home/vagrant/my-cluster/*keyring
 
# Prepare the OSD's
ceph-deploy osd prepare cephnode4:/var/local/osd cephnode5:/var/local/osd cephnode6:/var/local/osd

# activate the OSDs.
ceph-deploy osd activate cephnode4:/var/local/osd cephnode5:/var/local/osd cephnode6:/var/local/osd

# copy the configuration file and admin key to your admin node and your Ceph Nodes
# so that you can use the ceph CLI 
ceph-deploy admin cephmon1 cephmon2 cephmon3 cephnode4 cephnode5 cephnode6 cephmaster

# Ensure that you have the correct permissions for the ceph.client.admin.keyring.
sudo chmod +r /etc/ceph/ceph.client.admin.keyring

# Check your cluster’s health.
ceph health
ceph -s

# Hope you get an healty state. If so: phase one is done!
EOF

cat << EOF > repair.sh
#!/bin/bash
# 
# Script to create a RADOS Ceph Storage Cluster
# After an Error occurred
# 
# 
set -e
sudo mv /etc/yum.repos.d/ceph.repo /etc/yum.repos.d/ceph-deploy.repo
# Install Ceph on the Admin node
ceph-deploy install --release hammer cephmaster

# Add the initial monitor(s) and gather the keys
# After this command you will have 4 keyring files in your home directory
ceph-deploy mon create-initial
ls -al /home/vagrant/my-cluster/*keyring
 
# Prepare the OSD's
ceph-deploy osd prepare cephnode4:/var/local/osd cephnode5:/var/local/osd cephnode6:/var/local/osd

# activate the OSDs.
ceph-deploy osd activate cephnode4:/var/local/osd cephnode5:/var/local/osd cephnode6:/var/local/osd

# copy the configuration file and admin key to your admin node and your Ceph Nodes
# so that you can use the ceph CLI 
ceph-deploy admin cephmon1 cephmon2 cephmon3 cephnode4 cephnode5 cephnode6 cephmaster

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
ceph-deploy install --rgw cephmon1

# make your Ceph Object Gateway node an administrator node
ceph-deploy admin cephmon1

# From the working directory of your administration server, 
# create an instance of the Ceph Object Gateway on the Ceph Object Gateway.
sudo cd ~/mycluster
ceph-deploy rgw create cephmon1

# test the gateway
curl http://cephnode4:7480

# 


EOF

cat << EOF > ssh-keys.sh
#!/bin/bash
# 
# Script to create a RADOS Ceph Storage Cluster
# 
# Create a key on the admin node and copy it to all the other nodes
# so the admin node can communicate without a password to the nodes
ssh-keygen
ssh-copy-id vagrant@cephmon1
ssh-copy-id vagrant@cephmon2
ssh-copy-id vagrant@cephmon3
ssh-copy-id vagrant@cephnode4
ssh-copy-id vagrant@cephnode5
ssh-copy-id vagrant@cephnode6
ssh-copy-id vagrant@cephmaster

EOF

chmod +x *.sh
chown vagrant:vagrant *.sh

echo
echo "************************************************"
echo "*                                              *"
echo "*             SHOW IP                          *"  
echo "*                                              *"  
echo "************************************************"  
echo
ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}'