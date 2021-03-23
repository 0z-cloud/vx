#!/bin/bash

# Script for regeniration the dynamic inventory in production

inventory=$1
product=$2
typeofcloud=$3
connect_type=$4
ansible_path=$5
target_inventory=$6

# LOAD COLORS
. ${ansible_path}/scripts/libsh/head/colors.sh

# LOAD MAIN FUNCTIONS
. ${ansible_path}/scripts/libsh/functions_ng.sh 

# RED='\033[0;31m'
# GREEN='\033[0;32m'
# NC='\033[0m' # No Color


echo -e "         ${GREEN}Start regeneration${NC} cloud inventory: ${RED}${inventory}${NC}";


terminal_line_italy
terminal_line_italy

if [ "$1" = "" ]
then

  echo "Usage: $0 inventory is must to be a specified"
  exit

fi

if [ "$2" = "" ]
then

  echo "Usage: $0 product is must to be a specified"
  exit

fi

get_all_cloud_adapters ${ansible_path}

if [ "$3" = "" ]
then

  echo "Usage: $0 type of install is must to be a specified: "
  echo $API_ADAPTERS_ARRAY_LIST | xargs -I ID echo "Adapter name: ID"
  exit

fi

if [ "$4" = "" ]
then

  echo "Usage: $0 type of connection is must to be a specified: nat / private / public / green / blue / rollback"
  exit

fi
if [ "$5" = "" ]
then
        terminal_line_red_equals
        echo -e "         ${RED}No specified replace ${NC}cloud inventory${RED}${NC}";
        terminal_line_red_equals

else
        
        echo -e "         ${GREEN}Converting to target ${NC}cloud inventory: ${RED}$5 ${NC}";
        
fi

if [ $4 == 'private' ]; then
    connection_type="private"
else 
    if [ $4 == 'public' ]; then
        connection_type="public"
    else 
        if [ $4 == 'nat' ]; then
            connection_type="nat"
        else 
          if [ $4 == 'green' ]; then
              connection_type="green"
          else
            connection_type="none"
            echo -e "         Wrong type of connection, you must to be select one possible from a types - private / public / green / blue / rollback "
          fi
        fi
    fi
fi

function check_target_inventory_dir(){

  if [ ! -d "${ansible_path}/inventories/products/$product/$inventory/" ]; then 
      terminal_line_red_equals
      echo -e "         ${RED}Destination target inventory is not exists, exit 1${NC}";
      echo -e "         ${RED}FATAL: Please check or create destination target environment directory${NC}";
      terminal_line_red_equals
      exit 1
  fi

}

function check_target_group_vars_ansible_root(){

  if [ ! -d "${ansible_path}/group_vars/products/$product/$inventory/" ]; then 
      terminal_line_red_equals
      echo -e "         ${RED}Destination root ansible group_vars products placement necessary default values is not exists, exit 1${NC}";
      echo -e "         ${RED}FATAL: Please check or create group_vars/products/{{ ansible_products }}/{{ ansible_environment }} target environment directory${NC}";
      terminal_line_red_equals
      exit 1
  fi

}
########## WORKS WITH LINKS IN SAME PRODUCTS
if [ ! -z $target_inventory ]; then
    #####
    before_inventory_parent=$inventory

    terminal_line_red_equals
    terminal_line_red_equals
    terminal_line_red_equals
    terminal_line_yellow_equals
    echo -e "         ${GREEN}Before ${NC}cloud inventory: ${RED}${before_inventory_parent}${NC}";
    echo -e "         ${GREEN}Target ${NC}cloud inventory: ${RED}${target_inventory}${NC}";
    echo -e "         ${GREEN}Source ${NC}cloud inventory: ${RED}${inventory}${NC}";
    terminal_line_yellow_equals

    # LINKED INVENTORY CORES IN FIRST IF ALL NOT A PRODUCTION! IN BASICLY YOU MUST HAVE A ONE ROOT IN ONE PRODUCT, OR IF YOU KNOW WHAT YOU DO - DO IT.

    if [ "$inventory" != "baremetal" ] && [  "$inventory" != "production" ] && [  "$inventory" != "alpha" ] && [  "$inventory" != "beta" ] && [  "$inventory" != "devops" ] && [  "$inventory" != "service" ] && [  "$inventory" != "service_devops_zone" ] && [  "$inventory" != "poc" ]; then

        
        echo -e "         ${GREEN}Detected ${NC}cloud inventory: ${RED}NON PRODUCTION INVENTORY ${NC}";

        if [[ ! -z "$before_inventory_parent" ]]; then

            if [ -L ${ansible_path}/inventories/0z-cloud/products/types/!_${typeofcloud}/$product/$before_inventory_parent/v.py ]; then
              
              echo -e "         ${GREEN}Current vortex script is a symlink ${NC}";
              before_inventory_parent=$(readlink ${ansible_path}/inventories/0z-cloud/products/types/!_${typeofcloud}/${product}/${inventory}/v.py | sed 's/\/v.py//' | sed 's/..\///')
              echo -e "         ${GREEN}Before ${NC}cloud inventory: ${RED}${before_inventory_parent}${NC}";
              echo -e "         ${GREEN}Target ${NC}cloud inventory: ${RED}${target_inventory}${NC}";

            else
              
              echo -e "         ${RED}Current vortex script is not a symlink ${NC}";
              before_inventory_parent=""

            fi

        else
            if [ -L ${ansible_path}/inventories/0z-cloud/products/types/!_${typeofcloud}/$product/$inventory/v.py ]; then
              
              echo -e "         ${GREEN}Current vortex script is a symlink ${NC}";
              before_inventory_parent=$(readlink ${ansible_path}/inventories/0z-cloud/products/types/!_${typeofcloud}/${product}/${inventory}/v.py | sed 's/\/v.py//' | sed 's/..\///')
              echo -e "         ${GREEN}Before ${NC}cloud inventory: ${RED}${before_inventory_parent}${NC}";

            else
              
              echo -e "         ${RED}Current vortex script is not a symlink ${NC}";
              before_inventory_parent=""

            fi
        fi
        check_target_inventory_dir;
        check_target_group_vars_ansible_root;

        echo -e "         ${GREEN}RUNNUNG V.PY TO GENERATE ${NC}cloud inventory: ${RED}${inventory}${NC}"
        echo -e "         ${GREEN}Current ${NC}cloud inventory: ${RED}${inventory}${NC}"
        rm -rf ${ansible_path}/inventories/products/$product/$inventory/inventory
        ${ansible_path}/inventories/0z-cloud/products/types/!_${typeofcloud}/$product/$inventory/v.py --file ".dynamic.all.yml" --connection_type ${connection_type} --product ${product} --cloudtype ${typeofcloud} --environment ${inventory} >> ${ansible_path}/inventories/products/$product/$inventory/inventory

        if [[ ! -z "$before_inventory_parent" ]]; then
        
          sed "s/$before_inventory_parent/$inventory/g" ${ansible_path}/inventories/products/${product}/${inventory}/inventory >> ${ansible_path}/inventories/products/${product}/${inventory}/inventory.new
          mv ${ansible_path}/inventories/products/${product}/${inventory}/inventory.new ${ansible_path}/inventories/products/${product}/${inventory}/inventory
        
        fi

        echo -e "         ${GREEN}Converting ${NC}cloud inventory: ${RED}DONE ${NC}";
        

    else

        
        echo -e "         ${GREEN}Matched except and catch else section for 'change boots on fly' ${NC} will replace original target inventory, but take from original sourcecloud inventory: ${RED}LINKED IN PRODUCT ${NC}";
        
        echo -e "         ${GREEN}Detected ${NC}cloud inventory: ${RED}PRODUCTION INVENTORY ${NC}";
        echo -e "         ${GREEN}Current ${NC}cloud inventory: ${RED}${inventory}${NC}";
        echo -e "         ${GREEN}Provided ${NC}cloud link bootstrap from verfied already parent inventory: ${RED}${target_inventory}${NC}";
        
        source_original_inventoryname="$inventory"
        inventory="$target_inventory"
        check_target_inventory_dir;

        rm -rf ${ansible_path}/inventories/products/$product/$inventory/inventory
        ${ansible_path}/inventories/0z-cloud/products/types/!_${typeofcloud}/$product/$source_original_inventoryname/v.py --file ".dynamic.all.yml" --connection_type ${connection_type} --product ${product} --cloudtype ${typeofcloud} --environment ${source_original_inventoryname} >> ${ansible_path}/inventories/products/$product/$inventory/inventory
        
        # echo "./inventories/0z-cloud/products/types/\!_${typeofcloud}/$product/$inventory/${connection_type} --connection_type >> ./inventories/products/$product/$inventory/inventory"

        

    fi

else
   
    # FAKE INVENTORY CORES IN FIRST IF ALL NOT A PRODUCTION! IN BASICLY YOU MUST HAVE A ONE ROOT IN ONE PRODUCT, OR IF YOU KNOW WHAT YOU DO - DO IT.

    if [ "$inventory" != "access-f1-run" ] && [ "$inventory" != "baremetal" ] && [  "$inventory" != "production" ] && [  "$inventory" != "pre-prod" ] && [  "$inventory" != "production-eden-eve" ] && [  "$inventory" != "alpha" ] && [  "$inventory" != "beta" ] && [  "$inventory" != "devops" ] && [  "$inventory" != "service" ] && [  "$inventory" != "service_devops_zone" ] && [  "$inventory" != "poc" ]; then

        
        echo -e "         ${GREEN}Detected ${NC}cloud inventory: ${RED}NON PRODUCTION INVENTORY ${NC}";

        if [ -L ${ansible_path}/inventories/0z-cloud/products/types/!_${typeofcloud}/$product/$inventory/v.py ]; then
          
          echo -e "         ${GREEN}Current vortex script is a symlink ${NC}";
          before_inventory_parent=$(readlink ${ansible_path}/inventories/0z-cloud/products/types/!_${typeofcloud}/${product}/${inventory}/v.py | sed 's/\/v.py//' | sed 's/..\///')
          echo -e "         ${GREEN}Before ${NC}cloud inventory: ${RED}${before_inventory_parent}${NC}";

        else
          
          echo -e "         ${RED}Current vortex script is not a symlink ${NC}";
          before_inventory_parent=""

        fi

        check_target_inventory_dir;
        check_target_group_vars_ansible_root;
        echo -e "         ${GREEN}Current ${NC}cloud inventory: ${RED}${inventory}${NC}"
        rm -rf ${ansible_path}/inventories/products/$product/$inventory/inventory
        ${ansible_path}/inventories/0z-cloud/products/types/!_${typeofcloud}/$product/$inventory/v.py  --file ".dynamic.all.yml" --connection_type ${connection_type} --product ${product} --cloudtype ${typeofcloud} --environment ${inventory} >> ${ansible_path}/inventories/products/$product/$inventory/inventory

        if [[ ! -z "$before_inventory_parent" ]]; then
        
          sed "s/$before_inventory_parent/$inventory/g" ${ansible_path}/inventories/products/${product}/${inventory}/inventory >> ${ansible_path}/inventories/products/${product}/${inventory}/inventory.new
          mv ${ansible_path}/inventories/products/${product}/${inventory}/inventory.new ${ansible_path}/inventories/products/${product}/${inventory}/inventory
        
        fi

        
        echo -e "         ${GREEN}Converting ${NC}cloud inventory: ${RED}DONE ${NC}";
        

    else

        
        echo -e "         ${GREEN}Detected ${NC}cloud inventory: ${RED}PRODUCTION INVENTORY ${NC}";
        echo -e "         ${GREEN}Current ${NC}cloud inventory: ${RED}${inventory}${NC}";

        check_target_inventory_dir;

        rm -rf ${ansible_path}/inventories/products/$product/$inventory/inventory
        ${ansible_path}/inventories/0z-cloud/products/types/!_${typeofcloud}/$product/$inventory/v.py  --file ".dynamic.all.yml" --connection_type ${connection_type} --product ${product} --cloudtype ${typeofcloud} --environment ${inventory} >> ${ansible_path}/inventories/products/$product/$inventory/inventory
        
        # echo "./inventories/0z-cloud/products/types/\!_${typeofcloud}/$product/$inventory/${connection_type} --connection_type >> ./inventories/products/$product/$inventory/inventory"

        

    fi

fi
