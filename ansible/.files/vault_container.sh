#!/bin/bash

CURRENT_PATH=`pwd`

USERNAME_PRIMARY=$1
PRODUCT=$2
VAULT_WAY=$3
ANSIBLE_VAULT_PASSWORD=$4
TYPEOFCLOUD=$5
ANSIBLE_INVENTORY=$6
TARGET_USERNAME=$7
SOURCE_USERNAME=$8

# LOAD COLORS
. "$CURRENT_PATH"/scripts/libsh/head/colors.sh

# LOAD MAIN FUNCTIONS
. "$CURRENT_PATH"/scripts/libsh/functions_ng.sh 

# LOAD VAULT FUNCTIONS
. "$CURRENT_PATH"/scripts/libsh/vault_ng.sh 

exec_root_dir=`dirname $(pwd)`

LOCAL_DIRECTORY="${exec_root_dir}/.local"

ansible_dir_check="${CURRENT_PATH}/ansible"
ansible_dir=`echo "$ansible_dir_check" | sed -e "s/ansible\/ansible/ansible/g"`
main_group_vars_dir="$ansible_dir/group_vars"
main_products_in_group_vars_dir="$main_group_vars_dir/products"
current_product_in_group_vars_dir="$main_group_vars_dir/products/$PRODUCT"
current_product_inventory_in_group_vars="$current_product_in_group_vars_dir/$ANSIBLE_INVENTORY"

check_vault_init_params;

if [ -z $TARGET_USERNAME ]; then
    TARGET_USERNAME=${USERNAME_PRIMARY}
fi

if [ -z $SOURCE_USERNAME ]; then
    SOURCE_USERNAME=${TARGET_USERNAME}
fi

PROTECTED_STORAGE_DIR="$ansible_dir/.files/protected/storage/users/${USERNAME_PRIMARY}/products/${PRODUCT}/${SOURCE_USERNAME}"

PROTECTED_ARCHIVE_STORAGE_DIR="$ansible_dir/.files/protected/storage/users/${USERNAME_PRIMARY}/products/${PRODUCT}"

PROTECTED_MAPPING_DIR="$ansible_dir/.files/protected/products/${PRODUCT}/${TARGET_USERNAME}"

function_check_local_placement_directory_in_protected_storage;

user_files_count=$(ls -la ${ansible_dir}/.files/protected/storage/users/${USERNAME_PRIMARY}/products/${PRODUCT}/${USERNAME_PRIMARY}/ | sed -e '1,3d' | wc -l | sed "s/ //g") 

vault_archive_status_get=`vault_archive_status`;

LISTEN_RESULT_PROTECTED_STORAGE_DIR=`ls -la $PROTECTED_STORAGE_DIR/ | awk '{print $9}' | tail -n +3 | xargs -I ID echo '                      ID' | sed 's/\.\.//g'`
LISTEN_RESULT_PROTECTED_MAPPING_DIR=`ls -la $PROTECTED_MAPPING_DIR/ | awk '{print $9}' | tail -n +3 | xargs -I ID echo '                      ID' | sed 's/\.\.//g'`

terminal_custom_logging "

                    -----------------------------------------------------------------------------

                    Vault Archive ${GREEN}Status${NC}: $vault_archive_status
                    Vault Archive Status Getted: $vault_archive_status_get
                    User Files Counter: $user_files_count

                    Products in group_vars: $main_products_in_group_vars_dir
                    Current product in group_vars directory: $current_product_in_group_vars_dir
                    Current product Inventory in group_vars directory: $current_product_inventory_in_group_vars

                    Primary user name: $USERNAME_PRIMARY
                    Target user name: $TARGET_USERNAME
                    Source user name: $SOURCE_USERNAME

                    ${GREEN}Protected${NC} Storage Directory: $PROTECTED_STORAGE_DIR
                    ${RED}Protected${NC} Mapping Directory: $PROTECTED_MAPPING_DIR
                    Root current directory: $exec_root_dir
                    Ansible current directory: $ansible_dir
                    Local cloud configuration directory: $LOCAL_DIRECTORY

                    -----------------------------------------------------------------------------

                    Show ${GREEN}protected${NC} storage directory 

                    [$PROTECTED_STORAGE_DIR] 
                    
                    ${RED}contents${NC}: ${YELLOW}
                    $LISTEN_RESULT_PROTECTED_STORAGE_DIR
                    ${NC}
                    -----------------------------------------------------------------------------
                    =============================================================================
                    -----------------------------------------------------------------------------

                    Show ${GREEN}protected${NC} mapping directory 
                    
                    [$PROTECTED_MAPPING_DIR] 
                    
                    ${RED}contents${NC}: ${YELLOW}
                    $LISTEN_RESULT_PROTECTED_MAPPING_DIR
                    ${NC}
                    -----------------------------------------------------------------------------
                    =============================================================================
                    
                    " "info"

if [ ! -L ${PROTECTED_MAPPING_DIR} ]; then

    terminal_custom_logging "
    
                    CRITICAL! Your VAULT destination placement not fully prepared for ${PRODUCT} and ${SOURCE_USERNAME} of not exists
                    
                    You user profile storage target must be a link to users storage

                    " "red"

    exit 1
fi

if [ $VAULT_WAY == 'encrypt' ]; then

    packing_vault_archive

else 

    if [ $VAULT_WAY == 'decrypt' ]; then

        restore_vault_archive

    else

        if [ $VAULT_WAY == 'silent' ]; then

            restore_vault_archive_silent

        fi
        
    fi

fi