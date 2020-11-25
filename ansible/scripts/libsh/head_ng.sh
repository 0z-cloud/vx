#!/bin/bash

SCRIPT_NAME=$1

# runpath=`pwd`
# ansible_dir="${runpath}/ansible"
# ansible_dir=$(echo "$runpath"/ansible | sed -e "s/ansible\/ansible/ansible/g")

# root_dir="$runpath"
# main_dir="$root_dir"

# export root_dir="$root_dir"
# export runpath="$runpath"
# export ansible_dir="$ansible_dir"
# export main_dir="$main_dir"

echo "FILE: $SCRIPT_NAME"
echo "runpath: $runpath"
echo "ansible_dir: $ansible_dir"

# . "$ansible_dir"/scripts/libsh/vault/main.sh "$runpath" "$ansible_dir"

# . $ansible_dir/scripts/libsh/head/main.sh
# . $ansible_dir/scripts/libsh/deploy/head.sh