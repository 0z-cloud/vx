#!/bin/bash

runpath=$1
ansible_dir=$2

echo -e "     ${GREEN}Currnet Filename: libsh/cloud.regen.run.sh${NC}"
echo -e "     ${GREEN}Running root Path: $runpath${NC}"
echo -e "     ${GREEN}Ansible Directory: $ansible_dir${NC}"

# DEFAULT CONNECTION TO NODES
# Connection is must to be a specified: nat / public
nodes_connection_network_type=public
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
            echo -e "     ${GREEN}{****************************************************************************************************************************************************************************************************}${NC}"
            echo -e "         "
            echo -e "         $command_echo_run"
            echo -e "         "
            echo -e "     ${GREEN}{****************************************************************************************************************************************************************************************************}${NC}"

        fi

    else

        if [ "$type_of_run" = "debug" ]; then

            echo -e "     ${GREEN}{****************************************************************************************************************************************************************************************************}${NC}"
            echo -e "          Start running command: $command_echo_run"
            echo -e "     ${GREEN}{****************************************************************************************************************************************************************************************************}${NC}"
            eval "${command_echo_run}"
            echo -e "     ${GREEN}{****************************************************************************************************************************************************************************************************}${NC}"
            echo -e "          Finish running command: $command_echo_run"
            echo -e "     ${GREEN}{****************************************************************************************************************************************************************************************************}${NC}"

        else

            echo -e "     ${GREEN}{****************************************************************************************************************************************************************************************************}${NC}"
            echo "$command_echo_run"
            eval "${command_echo_run}"
            echo -e "     ${GREEN}{****************************************************************************************************************************************************************************************************}${NC}"
        fi

    fi

}


if [ "$type_of_run" = "cloud_regen" ]; then

    echo -e "     ${GREEN}{****************************************************************************************************************************************************************************************************}${NC}"
    echo -e "     ${RED}|> inventory / product / type of cloud / infrastracture connection type - private or public                                                                  <|${NC}"
    echo -e "     ${GREEN}{****************************************************************************************************************************************************************************************************}${NC}"

    function_selector_runner_test "$ansible_dir"/!_root_playbooks/cloud_regen.sh $inventory $product $typeofcloud $nodes_connection_network_type $ansible_dir

    echo -e "     ${GREEN}{****************************************************************************************************************************************************************************************************}${NC}"

    if [ "$type_of_run" != "run_from_wrapper" ]; then

        echo -e "     ${GREEN}{****************************************************************************************************************************************************************************************************}${NC}"
        echo -e "         Exit because whats only cloud_regen. See you later! =)"
        echo -e "     ${GREEN}{****************************************************************************************************************************************************************************************************}${NC}"

    fi

    exit 1

else

    echo -e "     ${GREEN}{****************************************************************************************************************************************************************************************************}${NC}"
    echo -e "     ${RED}|> inventory / product / type of cloud / infrastracture connection type - private or public                                                                  <|${NC}"
    echo -e "     ${GREEN}{****************************************************************************************************************************************************************************************************}${NC}"

    function_selector_runner "$ansible_dir"/!_root_playbooks/cloud_regen.sh $inventory $product $typeofcloud $nodes_connection_network_type $ansible_dir

    echo -e "     ${GREEN}{****************************************************************************************************************************************************************************************************}${NC}"

fi