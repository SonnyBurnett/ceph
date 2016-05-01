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
    User cephuser
Host 192.168.33.82
    Hostname ceph2.mon2
    User cephuser
Host 192.168.33.83
    Hostname ceph3.mon3
    User cephuser
Host 192.168.33.84
    Hostname cepha.node1
    User cephuser
Host 192.168.33.85
    Hostname cephb.node2
    User cephuser
Host 192.168.33.86
    Hostname cephc.node3
    User cephuser	
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
#
# Note: do not start to run all commands at once.
# first try them one-by-one
#
# Do not run under root!
# I usually use user vagrant
#
# 
ssh-keygen
ssh-copy-id cephuser@ceph1.mon1
ssh-copy-id cephuser@ceph2.mon2
ssh-copy-id cephuser@ceph3.mon3
ssh-copy-id cephuser@cepha.node1
ssh-copy-id cephuser@cephb.node2
ssh-copy-id cephuser@cephc.node3

# Create the directory for the new cluster
sudo mkdir my-cluster
sudo cd my-cluster
# 
# Create the new cluster by first installing the monitor nodes
ceph-deploy new ceph1 ceph2 ceph3


# set the default number of OSD on 2. Ceph can now run on just 2 OSD's
echo "osd pool default size = 2" >> ceph.conf

# This is a small trick when something goes wrong
sudo mv /etc/yum.repos.d/ceph.repo /etc/yum.repos.d/ceph-deploy.repo

# Install Ceph on all the nodes, Admin node, OSD's and Monitors
ceph-deploy install ceph ceph1.mon1 ceph2.mon2 ceph3.mon3 cepha.node1 cephb.node2 cephc.node3
# Note: if this fails, and sometimes it does. Stop here
# re-run the mv command and try the ceph-deploy install again.
# should work now

# Add the initial monitor(s) and gather the keys
# After this command you will have 4 keyring files in your home directory
ceph-deploy mon create-initial

# Prepare the OSD's
ceph-deploy osd prepare cepha.node1:/var/local/osd cephb.node2:/var/local/osd cephc.node3:/var/local/osd

# activate the OSDs.
ceph-deploy osd activate cepha.node1:/var/local/osd cephb.node2:/var/local/osd cephc.node3:/var/local/osd

# copy the configuration file and admin key to your admin node and your Ceph Nodes
# so that you can use the ceph CLI 
ceph-deploy admin ceph ceph1.mon1 ceph2.mon2 ceph3.mon3 cepha.node1 cephb.node2 cephc.node3

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

cat << EOF > /home/vagrant/create_s3g.sh
#
# Install the Ceph Object Gateway package on all the client nodes
ceph-deploy install --rgw ceph1.slave ceph2.slave ceph3.slave
# create an instance of the Ceph Object Gateway on all the client nodes
ceph-deploy rgw create ceph1.slave ceph2.slave ceph3.slave
# check
curl ceph1.slave:7480
# Generate a Ceph Object Gateway user name and key for each instance
sudo ceph auth get-or-create client.radosgw.gateway osd 'allow rwx' mon 'allow rwx' -o /etc/ceph/ceph.client.radosgw.keyring
# distribute the keyring to the node with the gateway instance (not sure this is needed)
#sudo scp /etc/ceph/ceph.client.radosgw.keyring cephuser@ceph1.slave:/home/cephuser
#sudo scp /etc/ceph/ceph.client.radosgw.keyring cephuser@ceph2.slave:/home/cephuser
#sudo scp /etc/ceph/ceph.client.radosgw.keyring cephuser@ceph3.slave:/home/cephuser
# Now change the CEPH configuration file
sudo vim /etc/ceph/ceph.conf
# Add this:
#client.radosgw.gateway]
#host = {hostname}
#keyring = /etc/ceph/ceph.client.radosgw.keyring
#rgw socket path = /var/run/ceph/ceph.radosgw.gateway.fastcgi.sock
#log file = /var/log/radosgw/client.radosgw.gateway.log
#rgw print continue = false 
#
# 
ceph-deploy --overwrite-conf config pull ceph
ceph-deploy --overwrite-conf config push ceph1.slave ceph2.slave ceph3.slave
# create data directory
sudo mkdir -p /var/lib/ceph/radosgw/ceph-radosgw.gateway
# grant permission to apache
sudo chown apache:apache /var/run/ceph
#
# to be continued. Should change this completely because the instruction from Ceph does not make sense

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