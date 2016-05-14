# ceph
set up a CEPH cluster

Pre-requisites:
$ vagrant plugin install vagrant-hostmanager 

1. Create 7 VM's with Centos 7
   a Ceph admin node
   3 Ceph monitor nodes
   3 Ceph OSD nodes
   
   $ vagrant up
   $ vagrant reload
   
2. SSH to the Ceph admin node and cd to my-cluster folder.

   $ vagrant ssh cephmaster -c
   $ cd my-cluster

3. Run script to create Ceph Storage Cluster

   $ ./install-ceph.sh
   
4. Check the health of your new Ceph cluster

   $ ceph -w
   

