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
echo "********************************************************"
echo "*                                                      *"
echo "*     install apache (this may actually not be needed) *"  
echo "*                                                      *"  
echo "********************************************************" 
echo

yum install -y httpd
systemctl start httpd
systemctl enable httpd
systemctl status httpd
yum install -y php php-cli mod_fastcgi
cat << EOF > /var/www/cgi-bin/php.fastcgi
#!/bin/bash
PHPRC="/etc/php.ini"
PHP_FCGI_CHILDREN=4
PHP_FCGI_MAX_REQUESTS=1000
export PHPRC
export PHP_FCGI_CHILDREN
export PHP_FCGI_MAX_REQUESTS
exec /usr/bin/php-cgi
EOF
chown apache:apache /var/www/cgi-bin/php.fastcgi
chmod +x /var/www/cgi-bin/php.fastcgi


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
# Note: if this fails, and sometimes it does. Stop here
# re-run the mv command and try the ceph-deploy install again.
# should work now

ceph-deploy mon create-initial
ceph-deploy osd prepare ceph2.slave:/var/local/osd0 ceph3.slave:/var/local/osd1
ceph-deploy osd activate ceph2.slave:/var/local/osd0 ceph3.slave:/var/local/osd1
ceph-deploy admin ceph ceph1 ceph2.slave ceph3.slave
sudo chmod +r /etc/ceph/ceph.client.admin.keyring
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
#sudo scp /etc/ceph/ceph.client.radosgw.keyring xyzuser@ceph1.slave:/home/xyzuser
#sudo scp /etc/ceph/ceph.client.radosgw.keyring xyzuser@ceph2.slave:/home/xyzuser
#sudo scp /etc/ceph/ceph.client.radosgw.keyring xyzuser@ceph3.slave:/home/xyzuser
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