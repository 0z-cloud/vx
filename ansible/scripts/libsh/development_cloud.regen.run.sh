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

terminal_line_yellow_equals
echo -e "          ${GREEN}Currnet Filename: libsh/development_cloud.regen.run.sh${NC}"
echo -e "          ${GREEN}Running root Path: $runpath${NC}"
echo -e "          ${GREEN}Ansible Directory: $ansible_dir${NC}"
terminal_line_yellow_equals

if [ ! -z $remap_target_to_link_inventory_name ]; then

    terminal_line_yellow_equals
    echo -e "          ${GREEN}Ansible Linked Inventory: $remap_target_to_link_inventory_name${NC}"
    echo -e "          ${GREEN}Ansible Before Inventory: $before_inventory${NC}"
    terminal_line_yellow_equals

else

    terminal_line_yellow_equals
    echo -e "          ${GREEN}Ansible Target Inventory: $remap_target_to_link_inventory_name${NC}"
    terminal_line_yellow_equals

fi

# DEFAULT CONNECTION TO NODES
# Connection is must to be a specified: nat / public
nodes_connection_network_type="public"
# 

function_selector_runner_test(){

    escaped_list=`echo $@ |sed 's/[!]/\\\!/g'`

    test=`echo "${@}" | grep -E "\\!\_"  && echo 1 || echo 0`

    if [[ "$test" == 1 ]]; then
        #echo "test = 1"
        IFS='"\!_' in=($escaped_list)
        ommand_echo_run=`echo ${in[@]}|sed 's/[!]/\\\!/g'`
    else
        #echo "else test != 1"
        IFS='"\' in=($@)

        command_echo_run=`echo ${in[@]}|sed 's/[!]/\\\!/g'`
    fi

    if [ "$type_of_run" = "print_only" ] || [ "$type_of_run" = "run_from_wrapper" ]; then

        if [ "$type_of_run" = "run_from_wrapper" ]; then
            
            echo "$command_echo_run"

        else

            string_column_one=`echo $command_echo_run | awk '{print $4}'` 

            echo -e "         ${YELLOW}Print type_of_run is${NC} print_only for manual run ${GREEN}${string_column_one}${NC}"

            terminal_line_green_stars
            echo -e "         "
            echo -e "         $command_echo_run"
            echo -e "         "
            terminal_line_green_stars

        fi

    else

        if [ "$type_of_run" = "debug" ]; then

            terminal_line_green_stars
            echo -e "          Start running command: $command_echo_run"
            terminal_line_green_stars

            eval "${command_echo_run}"

            terminal_line_green_stars
            echo -e "          Finish running command: $command_echo_run"
            terminal_line_green_stars

        else

            terminal_line_green_stars
            echo "$command_echo_run"

            eval "${command_echo_run}"

            terminal_line_green_stars
        fi

    fi

}


if [ "$type_of_run" = "cloud_regen" ]; then

    terminal_line_green_stars
    echo -e "     ${RED}|> inventory / product / type of cloud / infrastracture connection type - private or public                                                                  <|${NC}"
    terminal_line_green_stars

    if [ ! -z $remap_target_to_link_inventory_name ]; then

        terminal_line_white_equals
        echo -e "          ${GREEN}Ansible Linked Inventory: $remap_target_to_link_inventory_name${NC}"
        echo -e "          ${RED}Ansible Source Inventory: $before_inventory${NC}"
        terminal_line_white_equals

        function_selector_runner_test "$ansible_dir"/!_root_playbooks/cloud_regen.sh $before_inventory $product $typeofcloud $nodes_connection_network_type $ansible_dir $remap_target_to_link_inventory_name

    else

        function_selector_runner_test "$ansible_dir"/!_root_playbooks/cloud_regen.sh $before_inventory $product $typeofcloud $nodes_connection_network_type $ansible_dir

    fi

    terminal_line_green_stars

    if [ "$type_of_run" != "run_from_wrapper" ]; then

        terminal_line_green_stars
        echo -e "         Exit because whats only cloud_regen. See you later! =)"
        terminal_line_green_stars

    fi

    exit 1

else

    terminal_line_green_stars
    echo -e "          Cloud Regen Runner Info: ${RED}|> inventory / product / type of cloud / infrastracture connection type - private or public                                                                  <|${NC}"
    terminal_line_green_stars
     
    if [ ! -z $remap_target_to_link_inventory_name ]; then

        terminal_line_yellow_equals

        terminal_line_white_equals
        echo -e "          ${GREEN}Ansible Linked Inventory: $remap_target_to_link_inventory_name${NC}"
        echo -e "          ${GREEN}Ansible Before Inventory: $before_inventory${NC}"

        function_selector_runner "$ansible_dir"/!_root_playbooks/cloud_regen.sh $before_inventory $product $typeofcloud $nodes_connection_network_type $ansible_dir $remap_target_to_link_inventory_name

        terminal_line_yellow_equals
        terminal_line_white_equals

    else

        terminal_line_green_stars
        echo -e "          ${GREEN}Ansible Current Inventory: $before_inventory${NC}"

        function_selector_runner "$ansible_dir"/!_root_playbooks/cloud_regen.sh $before_inventory $product $typeofcloud $nodes_connection_network_type $ansible_dir

        terminal_line_green_stars

    fi

        terminal_line_green_stars

fi
