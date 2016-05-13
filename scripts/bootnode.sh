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
ntpdate nldcr-ntp11.nwd.itc.intranet
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

ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}'
