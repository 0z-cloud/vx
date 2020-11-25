#!/bin/bash

runpath=$1
ansible_dir=$2
remap_target_to_link_inventory_name=$4
before_inventory=$3
##############################
# SHELL WRAPPER FUNCTIONS LOAD
##############################
# LOAD COLORS
. ${ansible_dir}/scripts/libsh/head/colors.sh

# LOAD MAIN FUNCTIONS
. ${ansible_dir}/scripts/libsh/functions_ng.sh 
##############################

terminal_line_red_equals
echo -e "          ${GREEN}Currnet Filename: libsh/development_cloud_api_gen.sh${NC}"
echo -e "          ${GREEN}Running root Path: $runpath${NC}"
echo -e "          ${GREEN}Ansible Directory: $ansible_dir${NC}"
echo -e "          ${GREEN}Ansible Linked inventory: $remap_target_to_link_inventory_name${NC}"
echo -e "          ${GREEN}Ansible Source inventory: $before_inventory${NC}"
terminal_line_red_equals


cd ${ansible_dir}

terminal_line_red_equals
echo -e "          Used type of inventory: ${RED}${typeofcloud}${NC}"
terminal_line_red_equals

if [ "$type_of_run" != "run_from_wrapper" ]; then

    terminal_line_green_equals
    echo -e "          ${GREEN}Start regen the dynamic inventory${NC} for run: $type_of_run"
    terminal_line_green_equals


fi

### CREATING DEPLOY VIA DOCKER ANSIBLE CONTAINER (FOR PCI WIP)
####

DOCKER_VERSION="latest"

cd ${ansible_dir}

#
if [ ! -z $remap_target_to_link_inventory_name ]; then

    . "$ansible_dir"/scripts/libsh/development_cloud.regen.run.sh "$runpath" "$ansible_dir" "$before_inventory" "$remap_target_to_link_inventory_name"

else

    . "$ansible_dir"/scripts/libsh/development_cloud.regen.run.sh "$runpath" "$ansible_dir" "$before_inventory"

fi