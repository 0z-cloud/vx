#!/bin/bash

inventory="$1"
product="$2"
username="$3"
password="$4"
apps="$5"
type_of_run="$6"
typeofcloud="$7"
vault_pass="$8"
ansible_global_gitlab_registry_site_name="$9"
gitlab_project_name="${10}"
gitlab_project_group="${11}"
version_ansible_build_id="${12}"
deploy_environment_security_configuration="${13}"
cluster_type="${14}"
extra_args_type_of_run="${15}"

# SCRIPT NAME
SCRIPT_NAME="reference_wrapper.sh"

# LOAD MAIN FUNCTIONS
. ./scripts/libsh/scripts/libsh/functions_ng.sh 
# DETERMINATE THE RUNTIME VARIABLES
. ./scripts/libsh/scripts/libsh/head_ng.sh "$SCRIPT_NAME"
# RUN REQUIREMENTS HELPER
. "$ansible_dir"/scripts/libsh/deploy/req_help.sh
# DECRYPT VAULT ARCHIVE
vault_ng "$vault_pass" "$username" "decrypt" "$product" "$typeofcloud" "$inventory";
# GO INFRA PHASE I
. "$ansible_dir"/scripts/libsh/cloud_api_gen.sh $runpath $ansible_dir






#. "$ansible_dir"/scripts/libsh/head/clouds.sh "$SCRIPT_NAME" $runpath $ansible_dir

# inventory=$1
# product=$2
# username=$3
# password=$4
# automatic=$5
# type_of_run=$6
# typeofcloud=$7
# certificate_prefix=$8
# extra_args_type_of_run=$9

# if [ "$1" = "" ]
# then

#   echo -e "     |>...........................................................................................................................................................................................................<|"
#   echo -e "          Usage for: $0 ${RED}inventory${NC} is must to be a specified!"
#   echo -e "     |>...........................................................................................................................................................................................................<|"

#   print_run_info 0z-quality_assurance
#   exit

# fi

# if [ "$2" = "" ]
# then

#   echo -e "     |>...........................................................................................................................................................................................................<|"
#   echo -e "           Usage for: $0 ${RED}product${NC} is must to be a specified!"
#   echo -e "     |>...........................................................................................................................................................................................................<|"

#   print_run_info 0z-quality_assurance
#   exit

# fi

# if [ "$3" = "" ]
# then

#   echo -e "     |>...........................................................................................................................................................................................................<|"
#   echo -e "          Usage for: $0 ${RED}username${NC} is must to be a specified!"
#   echo -e "     |>...........................................................................................................................................................................................................<|"

#   print_run_info 0z-quality_assurance
#   exit

# fi

# if [ "$4" = "" ]
# then

#   echo -e "     |>...........................................................................................................................................................................................................<|"
#   echo -e "          Usage for: $0 ${RED}password${NC} is must to be a specified!"
#   echo -e "     |>...........................................................................................................................................................................................................<|"

#   print_run_info 0z-quality_assurance
#   exit

# fi

# if [ "$5" = "" ]
# then

#   echo -e "     |>...........................................................................................................................................................................................................<|"
#   echo -e "         Usage for: $0 ${RED}automatic${NC} is must to be a specified, and can be:"
#   echo -e "                   "
#   echo -e "         ${BLUE_BACK}true${NC} / ${BLACK_TO_WHITE}false${NC}"
#   echo -e "\n"
#   echo -e "         automatic Param: can be true of false - if true, wrapper try to get certificate name from inventory"
#   echo -e "     |>...........................................................................................................................................................................................................<|"

#   print_run_info 0z-quality_assurance
#   exit

# fi

# if [ "$6" = "" ]
# then

#   echo -e "     |>...........................................................................................................................................................................................................<|"
#   echo -e "${YELLOW}Usage${NC}: $0 ${BLUE}type_of_run${NC} ${RED}is must to be a specified${NC}, and can be:"
#   echo -e "                   "
#   echo -e "         ${BLUE_BACK}create${NC} / ${BLACK_TO_WHITE}destroy${NC} / ${GREEN}true${NC} / ${RED}false${NC} / ${BLUE}print_only${NC} / ${CYAN}debug${NC} / ${LM}cloud_regen${NC} / ${RED}remove_unwanted${NC} / ${GREEN}add_wanted${NC}"
#   echo -e "                   
#                         ${BLUE}run_from_wrapper${NC}
#         "
#   echo -e "     |>...........................................................................................................................................................................................................<|"
#   echo -e "     |>...........................................................................................................................................................................................................<|"
#   echo -e "         ${RED}False to validate the type of run!${NC}"

#   print_run_info 0z-quality_assurance
#   exit

# else

#     if [ "$type_of_run" = "false" ] || [ "$type_of_run" = "true" ] || [ "$type_of_run" = "partial" ] || [ "$type_of_run" = "print_only" ] || [ "$type_of_run" = "run_from_wrapper" ] || [ "$type_of_run" = "debug" ] || [ "$type_of_run" = "cloud_regen" ] || [ "$type_of_run" = "destroy" ] || [ "$type_of_run" = "create" ]; then

#         if [ "$type_of_run" != "run_from_wrapper" ]; then

#             echo -e "     |>...........................................................................................................................................................................................................<|"
#             echo -e "         Passed value: ${RED}$type_of_run${NC} to run"
#             echo -e "     |>...........................................................................................................................................................................................................<|"

#         fi

#   else

#     echo -e "     |>...........................................................................................................................................................................................................<|"
#     echo -e "          False to validate the type of run!"
#     echo -e "          Usage for: $0 type_of_run is must to be a specified, and can be a true or false!"
#     echo -e "     |>...........................................................................................................................................................................................................<|"
#     exit

#   fi

# fi

# echo -e "         ${RED}Inventory is:${NC} $inventory  ${RED}Product is:${NC} $product ${RED}Username is:${NC} $username ${RED}Password:${NC} $password ${RED}Wait After bootstrap is:${NC} $automatic ${RED}Type of run:${NC} $type_of_run"
# echo -e "     |>...........................................................................................................................................................................................................<|"

# # PY REQ

# if [ "$type_of_run" != "run_from_wrapper" ]; then

#     echo -e "         Start regen the dynamic inventory for run"
#     echo -e "     |>...........................................................................................................................................................................................................<|"

# fi

# . ./scripts/libsh/cloud.regen.run.sh

# # RUN QA TESTS SETTINGS GENERATION

# function_selector_runner ansible-playbook -i inventories/products/$product/$inventory/ \
#     playbook-library/!_test_suite/python_qa.yml \
#     -e HOSTS="nginx-frontend" -u $username --become-user root --become -e "ansible_become_pass=$password" -e "ansible_ssh_pass=$password" -e stage="2"

# ### END

# . ./scripts/libsh/end/end.sh ${EXEC_TIMESTAMP}