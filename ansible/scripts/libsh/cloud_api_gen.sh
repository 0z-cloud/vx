#!/bin/bash

runpath=$1
ansible_dir=$2

echo -e "     ${GREEN}Currnet Filename: libsh/cloud_api_gen.sh${NC}"
echo -e "     ${GREEN}Running root Path: $runpath${NC}"
echo -e "     ${GREEN}Ansible Directory: $ansible_dir${NC}"

cd ${ansible_dir}

echo -e "     {****************************************************************************************************************************************************************************************************}"
echo -e "          Used type of inventory: ${RED}${typeofcloud}${NC}"
echo -e "     {****************************************************************************************************************************************************************************************************}"

if [ "$type_of_run" != "run_from_wrapper" ]; then

    echo -e "     ${GREEN}{****************************************************************************************************************************************************************************************************}${NC}"
    echo -e "            ${GREEN}Start regen the dynamic inventory${NC} for run: $type_of_run"
    echo -e "     ${GREEN}{****************************************************************************************************************************************************************************************************}${NC}"

fi

### CREATING DEPLOY VIA DOCKER ANSIBLE CONTAINER (FOR PCI WIP)
####

DOCKER_VERSION="latest"

cd ${ansible_dir}

#

. "$ansible_dir"/scripts/libsh/cloud.regen.run.sh "$runpath" "$ansible_dir"