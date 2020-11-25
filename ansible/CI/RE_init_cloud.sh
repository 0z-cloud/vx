#!/bin/bash

echo "Start REinit Cloud"

echo "Destroy current sandbox"
###
vagrant destroy -f
###
runpath=`pwd`
cloud_db="$runpath/.cloud"
vagrant_db="$runpath/.vagrant"

echo "CURRENT RUN PATH IS: $runpath"
echo "CURRENT CLOUD PATH IS: $cloud_db"

pushd $runpath

echo "Remove a current Vagrantfile"
rm Vagrantfile

echo "Remove a current cloud install"
rm -rf $cloud_db

echo "Remove a current vagrant db install"
rm -rf $vagrant_db

echo "Copy inplace a 0_init Vagrantfile"
cp $runpath/own_cloud/vagrantfile_db/0_init/Vagrantfile $runpath/Vagrantfile

echo "Up the 0_init Vagrantfile"
vagrant up

echo "Make local cloud magic directory"

mkdir $cloud_db

echo "Generate a real inventory"
cat $vagrant_db/provisioners/ansible/inventory/vagrant_ansible_inventory | sed '/private_key/d' >> $cloud_db/inventory

echo "Add the real host headers a real inventory"
vagrant ansible inventory >> $cloud_db/inventory

echo "Copy inplace a 1_init Vagrantfile"
cp $runpath/own_cloud/vagrantfile_db/1_init/Vagrantfile $runpath/Vagrantfile

echo "Provision new reality"
vagrant provision