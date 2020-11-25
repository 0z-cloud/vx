#!/bin/bash

ansible all -i inventories/{{ ansible_environment }}/ -m shell -a "apt-get purge glusterfs-server glusterfs-common glusterfs-client -y" --ask-vault-pass --become
ansible all -i inventories/{{ ansible_environment }}/ -m shell -a "umount /mnt/glusterfs" --ask-vault-pass --become
ansible all -i inventories/{{ ansible_environment }}/ -m shell -a "rm -rf /mnt/glusterfs && rm -rf /var/lib/glusterd && rm -rf /bricks && rm -rf /opt/bricks && killall glusterd && service rpcbind restart " --ask-vault-pass --become