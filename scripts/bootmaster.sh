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
echo "*             INSTALL Internal repos           *"  
echo "*                                              *"  
echo "************************************************" 
echo
rm /etc/yum.repos.d/*
cat << EOF > /etc/yum.repos.d/INGmirror.repo
[base]
name=CentOS-\$releasever - Base
baseurl=https://artifactory-a.ing.net/artifactory/rpm_centos_proxy/\$releasever/os/\$basearch/
gpgcheck=0
gpgkey=file:/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-\$releasever
protect=1
priority=1
enabled=1
sslverify=false
proxy=_none_
[updates]
name=CentOS-\$releasever - Updates
baseurl=https://artifactory-a.ing.net/artifactory/rpm_centos_proxy/\$releasever/updates/\$basearch/
gpgcheck=0
gpgkey=file:/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-\$releasever
protect=1
priority=1
enabled=1
sslverify=false
proxy=_none_
[extras]
name=CentOS-\$releasever - Extras
baseurl=https://artifactory-a.ing.net/artifactory/rpm_centos_proxy/\$releasever/extras/\$basearch/
gpgcheck=0
gpgkey=file:/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-\$releasever
protect=1
priority=1
enabled=1
sslverify=false
proxy=_none_
[centosplus]
name=CentOS-\$releasever - Plus
baseurl=https://artifactory-a.ing.net/artifactory/rpm_centos_proxy/\$releasever/centosplus/\$basearch/
exclude=kernel*
gpgcheck=0
enabled=1
sslverify=false
gpgkey=file:/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-\$releasever
protect=0
priority=1
proxy=_none_
[contrib]
name=CentOS-\$releasever - Contrib
baseurl=https://artifactory-a.ing.net/artifactory/rpm_centos_proxy/\$releasever/contrib/\$basearch/
gpgcheck=0
enabled=0
sslverify=false
gpgkey=file:/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-\$releasever
protect=0
priority=3
proxy=_none_
[epel-rhel]
name=RHEL epel repo
baseurl=http://registry.ic.ing.net/repository/epel
enabled=1
gpgcheck=0
sslverify=0
proxy=_none_
EOF

echo   
echo "********************************************************"
echo "*                                                      *"
echo "*     install ceph-deploy                              *"  
echo "*                                                      *"  
echo "********************************************************" 
echo

yum install -y ceph-deploy

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

cat << EOF > step2.sh
#!/bin/bash
# 
# Script to create a RADOS Ceph Storage Cluster
# 
# 
# Create the new cluster by first installing the monitor nodes
ceph-deploy new cephmon1 cephmon2 cephmon3


# set the default number of OSD on 2. Ceph can now run on just 2 OSD's
echo "osd pool default size = 2" >> ceph.conf
echo "osd pool default min size = 1" >> ceph.conf
echo "osd pool default pg num = 256" >> ceph.conf
echo "osd pool default pgp num = 256" >> ceph.conf
echo "osd crush chooseleaf type = 1" >> ceph.conf
# check
ceph-deploy disk list cephnode4
EOF

cat << EOF > step3.sh
#!/bin/bash
# 
# Script to create a RADOS Ceph Storage Cluster
# 
# Install Ceph on all the nodes, Admin node, OSD's and Monitors
ceph-deploy install cephmon1 
ceph-deploy install cephmon2 
ceph-deploy install cephmon3 
ceph-deploy install cephnode4 
ceph-deploy install cephnode5 
ceph-deploy install cephnode6
ceph-deploy install cephmaster
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
ceph-deploy osd prepare cephnode4:/var/local/osd cephnode5:/var/local/osd cephnode6:/var/local/osd

# activate the OSDs.
ceph-deploy osd activate cephnode4:/var/local/osd cephnode5:/var/local/osd cephnode6:/var/local/osd

EOF

cat << EOF > step6.sh
#!/bin/bash
# 
# Script to create a RADOS Ceph Storage Cluster
# 
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

chmod +x step[1-6].sh create_s3g.sh
chown vagrant:vagrant step[1-6].sh create_s3g.sh

echo
echo "************************************************"
echo "*                                              *"
echo "*             SHOW IP                          *"  
echo "*                                              *"  
echo "************************************************"  
echo
ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}'
