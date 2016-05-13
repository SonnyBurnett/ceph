#!/bin/bash
# ceph
# set up a CEPH cluster
# usage:
#vagrant reload is in order to make sure the hostmanager plugin does its job properly
vagrant destroy -f && vagrant up && vagrant reload && vagrant ssh cephmaster my_cluster/install-ceph.sh && vagrant ssh cephmaster ceph -w
