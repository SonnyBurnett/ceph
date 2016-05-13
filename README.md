#!/bin/bash
# ceph
# set up a CEPH cluster
# usage:
# ./README.md :)
#Note: vagrant plugin install vagrant-hostmanager if it’s missing. And vagrant reload makes sure that plugin works properly
vagrant destroy -f && vagrant up && vagrant reload && vagrant ssh cephmaster -c 'cd my-cluster; ./install-ceph.sh && ceph -w'
