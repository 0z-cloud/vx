#!/usr/bin/env bash

sudopassword=$1
runtype=$2
typeofcloud=$3
product=$4
inventory=$5

function_valid_types(){

    echo -e "

        ##########################################################################
            
            You must pass way describes pipeline what to do with your environment:
            
        #### ACCEPTED 3 TYPES OF RUN: 
        
                default / recreate / cleanfirst

        ##########################################################################

    "

}


function_error(){


    echo -e "

        ##########################################################################
    
    [E] CATCHED ERROR!
    
            YOU ARE RUN WITH INVALID OR WRONG TYPE OF RUN PARAM! 

            RUN TYPE IS: ${runtype}

        ##########################################################################
        "
    function_valid_types

    exit 1

}

if [ -z "${sudopassword}" ] ; then

    echo -e "
    
    [E] CATCHED ERROR!
            
            YOU ARE RUN WITH MISSED SUDO PASS PARAM! 
            
            You must pass as first param your sudo Password of YOUR LOCALHOST MAC/PC MACHINE

            Use EMPTY for empty password
            
        "
    exit 1

fi

if [ "${sudopassword}" == "EMPTY" ] ; then
    sudopassword=""
fi


if [ -z "${runtype}" ]; then 

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

case $runtype in
    recreate|default)
        echo "RUNTYPE: ${runtype}";;
    cleanfirst)
            ;;
    *) function_error;;
esac


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


if [ "${runtype}" == "cleanfirst" ]; then

    echo -e "
            ##########################################################################

                Removing Vagrant environment
                
            ##########################################################################
            "

# ! See to Global inventories, for understud the merging and stacking the environments zone placements

    # ansible-playbook -i ansible/inventories/global/oz_router/products/"$product"/"$inventory" \
    #     -i ansible/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ \
    #     ansible/_selfbox_/_selfbox_vagrant_.yml -e ansible_product="$product" -e ansible_environment="$inventory" \ 
    #     -e stage="0" -e ansible_become_pass="${sudopassword}" -e RUNTYPE="${runtype}" \
    #     -e destroy="true"

    ansible-playbook -i ansible/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ \
        ansible/_selfbox_/_selfbox_vagrant_.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e ansible_cloud_type="$typeofcloud" \ 
        -e stage="0" -e ansible_become_pass="${sudopassword}" -e RUNTYPE="${runtype}" \
        -e destroy="true"

fi

# ansible-playbook -i ansible/inventories/global/oz_router/products/"$product"/"$inventory" \
#         -i ansible/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ \
#         ansible/_selfbox_/_selfbox_vagrant_.yml -e ansible_product="$product" -e ansible_environment="$inventory" \
#         -e stage="0" -e ansible_become_pass="${sudopassword}" -e RUNTYPE="${runtype}" 

ansible-playbook -i ansible/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ \
        ansible/_selfbox_/_selfbox_vagrant_.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e ansible_cloud_type="$typeofcloud" \
        -e stage="0" -e ansible_become_pass="${sudopassword}" -e RUNTYPE="${runtype}" 
