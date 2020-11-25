#!/bin/bash

linked_env_in_product="baremetal"

runpath=`pwd`

ansible_dir="$runpath/ansible"
ansible_dir=$(echo "$runpath"/ansible | sed -e "s/ansible\/ansible/ansible/g")

. $ansible_dir/\!_tests/SERVICE_DEVOPS_ZONE.sh $linked_env_in_product;