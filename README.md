#!/bin/bash
# ceph
# set up a CEPH cluster
# usage:
# ./README.md :)
vagrant destroy -f && vagrant up && vagrant reload && vagrant ssh cephmaster my_cluster/install-ceph.sh && vagrant ssh cephmaster ceph -w
