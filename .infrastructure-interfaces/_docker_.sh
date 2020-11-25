#!/usr/bin/env bash

sudopassword=$1
runtype=$2
typeofcloud=$3
product=$4
inventory=$5
application_set_mame=$6
ansible_inventory_vault_storage_user=$7

# LOAD COLORS
. ./scripts/libsh/head/colors.sh

# LOAD MAIN FUNCTIONS
. ./scripts/libsh/functions_ng.sh 

terminal_line_red

function_valid_types(){

    terminal_line_green;       
    echo -e "            You must pass way describes pipeline what to do with your environment:
            
        #### ACCEPTED 3 TYPES OF RUN: 
        
                default / recreate / cleanfirst

    "
    terminal_line_green; 

}

if [ "${sudopassword}" == "" ]; then

    echo -e "
    
    [E] CATCHED ERROR!
            
            YOU ARE RUN WITH MISSED SUDO PASS PARAM! 
            
            You must pass as first param your sudo Password of YOUR LOCALHOST MAC/PC MACHINE
            
        "
    exit 1

fi

if [ "${runtype}" == "" ]; then

    echo -e "
    
    [E] CATCHED ERROR!
            
            YOU ARE RUN WITHOUT TYPE OF RUN PARAM! 
            
            You must pass as first param your sudo Password of YOUR LOCALHOST MAC/PC MACHINE
            
        "
    
    function_valid_types

    exit 1

fi

if [[ -z "${runtype}" ]]; then 

    echo -e "

        ##########################################################################
    
    [E] CATCHED ERROR!
    
            YOU ARE RUN WITHOUT TYPE OF RUN PARAM! 
            
        ##########################################################################
    "

    function_valid_types

    echo -e "
    
        ##########################################################################

        #### BY DEFAULT WHEN IS NOT SPECIFIED, CONTAINS A DEFAULT VALUE: default

        ##########################################################################
    "

    runtype="default"

fi

if [ "${runtype}" != "default" ] && [ "${runtype}" != "recreate" ] && [ "${runtype}" != "cleanfirst" ] ; then

        echo -e "

            ##########################################################################
        
        [E] CATCHED ERROR!
        
                YOU ARE RUN WITH INVALID OR WRONG TYPE OF RUN PARAM! 

                RUN TYPE IS: ${runtype}

            ##########################################################################
            "
        function_valid_types
        exit 1

else

    echo -e "   
            
            ##########################################################################
            
            RUN TYPE IS: ${runtype}
            
            ##########################################################################
        "

fi

if [ "${typeofcloud}" == "" ]; then

    echo -e "
    
    [E] CATCHED ERROR!
    
            YOU ARE RUN WITH MISSED CLOUD TYPE PARAM! 
            
            You must pass as third param your Cloud Type
            
        "
    exit 1

fi

if [ "${product}" == "" ]; then

    echo -e "
    
    [E] CATCHED ERROR!
    
            YOU ARE RUN WITH MISSED PRODUCT PARAM! 
            
            You must pass as third param your Product name
            
        "
    exit 1

fi

if [ "${inventory}" == "" ]; then

    echo -e "
    
    [E] CATCHED ERROR!
            
            YOU ARE RUN WITH MISSED INVENTORY PARAM! 
            
            You must pass param contain your environment name
            
        "
    exit 1

fi

if [ "${ansible_inventory_vault_storage_user}" == "" ]; then

    echo -e "
    
    [E] CATCHED ERROR!
            
            YOU ARE RUN WITH MISSED USERNAME WHO OWN THE CURRENT INTERNAL VAULT, 
            PLEASE PASS YOUR NAME PARAM! 
            
            You must pass param contain your username who owns current vault
            
        "
    exit 1

fi

if [ "${application_set_mame}" == "" ]; then

    echo -e "
    
    [E] CATCHED ERROR!
            
            YOU ARE RUN WITH MISSED APPLICATION SET NAME PARAM! 
            
            You must pass param contain your applications asset name
            
        "
    exit 1

fi

if [ "${runtype}" == "cleanfirst" ]; then

    echo -e "
            ##########################################################################

                Removing Docker environment
                
            ##########################################################################
            "

    ansible-playbook -i ansible/inventories/global/oz_router/products/"$product"/"$inventory" \
        -i ansible/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ \
        ansible/_selfbox_/_selfbox_docker_.yml -e ansible_product="$product" -e ansible_environment="$inventory" \ 
        -e stage="0" -e ansible_become_pass="${sudopassword}" -e RUNTYPE="${runtype}" \
        -e destroy="true" \
        -e ANSIBLE_APPLICATION_TYPE="${application_set_mame}" \
        -e ansible_environment="${inventory}" \
        -e ansible_product="${product}" -e ansible_inventory_vault_storage_user="${ansible_inventory_vault_storage_user}"
fi

docker ps -a | grep Exited | awk '{print $1}' | tail -n +2 | xargs -I ID docker rm -f ID
docker ps -a | awk '{print $1}' | tail -n +2 | xargs -I ID docker rm -f ID

rm -rf ./../.cloud/cloud_dir/production/production_mariadb
rm -rf ./../.cloud/cloud_dir/production/production_mariadb_logs

ansible-playbook -i ansible/inventories/global/oz_router/products/"$product"/"$inventory" \
        -i ansible/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ \
        ansible/_selfbox_/_selfbox_docker_.yml -e ansible_product="$product" -e ansible_environment="$inventory" \
        -e stage="0" -e ansible_become_pass="${sudopassword}" -e RUNTYPE="${runtype}" \
        -e ANSIBLE_APPLICATION_TYPE="${application_set_mame}" \
        -e ansible_environment="${inventory}" \
        -e ansible_product="${product}" -e ansible_inventory_vault_storage_user="${ansible_inventory_vault_storage_user}" -e ansible_vx_selfbox_flag="true" -e ansible_vx_build_localhost="true"

        