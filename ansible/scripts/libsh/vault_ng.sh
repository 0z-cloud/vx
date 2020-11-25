#!/bin/bash

check_vault_archive_already_encrypted() {

    vault_encrypt_state=$(grep -q -R AES256 ${PROTECTED_ARCHIVE_STORAGE_DIR}/${USERNAME_PRIMARY}-vault.tar.gz && echo ok || echo ko)
    # echo "vault_encrypt_state: $vault_encrypt_state"
    if [[ $vault_encrypt_state == "ok" ]]; then
    
        terminal_custom_logging "
    
                    ${RED}DESTINATION ARCHIVE ALREADY ENCRYPTED${NC}

                    " "info"

        exit 1

    else
        cd ${PROTECTED_ARCHIVE_STORAGE_DIR}/
        tar -czvf ${USERNAME_PRIMARY}-vault.tar.gz -C ${USERNAME_PRIMARY} .
        # tar -czvf ${PROTECTED_ARCHIVE_STORAGE_DIR}/${USERNAME_PRIMARY}-vault.tar.gz -C ${USERNAME_PRIMARY} ${PROTECTED_ARCHIVE_STORAGE_DIR}/${USERNAME_PRIMARY}/
        ls -la ${PROTECTED_ARCHIVE_STORAGE_DIR}/${USERNAME_PRIMARY}-vault.tar.gz
        cd $CURRENT_PATH
        terminal_custom_logging "
    
                    ${RED}DO ENCRYPT VAULT ARCHIVE${NC}
                    
                    " "info"

        echo $ANSIBLE_VAULT_PASSWORD > /tmp/v.pass.txt
        ansible-vault encrypt ${PROTECTED_ARCHIVE_STORAGE_DIR}/${USERNAME_PRIMARY}-vault.tar.gz --vault-password-file /tmp/v.pass.txt
        rm -rf /tmp/v.pass.txt

        terminal_custom_logging "
    
                    ${RED}ERAISING NOT PROTECTED DATA${NC}
                    
                    " "info"

        rm -rf ${PROTECTED_STORAGE_DIR}/*

    fi
}

check_vault_archive_already_decrypted() {

    if [ ! -f ${PROTECTED_ARCHIVE_STORAGE_DIR}/${USERNAME_PRIMARY}-vault.tar.gz ]; then 

        terminal_custom_logging "
    
                    ${RED}ARCHIVE WITH YOUR VAULT ARE NOT PRESENTED${NC}
                    
                    ${YELLOW}PLEASE CHECK YOUR REPOSITORY INTEGRITY${NC}

                    " "red"
        exit 1

    else 

        vault_encrypt_state=`grep -q -R AES256 ${PROTECTED_ARCHIVE_STORAGE_DIR}/${USERNAME_PRIMARY}-vault.tar.gz && echo ko || echo ok`

        terminal_custom_logging "
    
                    ${RED}Vault Encrypt State${NC}: $vault_encrypt_state
                    
                    " "info"

        if [[ $vault_encrypt_state == "ok" ]]; then
        
            terminal_custom_logging "
    
                    ${RED}DESTINATION ARCHIVE ALREADY DECRYPTED${NC}
                    
                    " "info"

            terminal_custom_logging "

        ...........................................................................................................................
                    ${RED}DESTINATION ARCHIVE ALREADY DECRYPTED${NC}
        ...........................................................................................................................
                    
                    " "info"

        else

        echo $ANSIBLE_VAULT_PASSWORD > /tmp/v.pass.txt
        ansible-vault decrypt ${PROTECTED_ARCHIVE_STORAGE_DIR}/${USERNAME_PRIMARY}-vault.tar.gz --vault-password-file /tmp/v.pass.txt
        rm -rf /tmp/v.pass.txt

        fi
    
    fi

}

packing_vault_archive() {

    terminal_custom_logging "
    
                    ${RED}Vault Encrypt State${NC}: $vault_encrypt_state
                    
                    " "info"

    rm -rf ${PROTECTED_STORAGE_DIR}/vault.state

    check_vault_archive_already_encrypted;

    terminal_custom_logging "
    
                    ${RED}SET ENCRYPT LOCK LINK STATE${NC}
                    
                    " "info"

    echo "ok" > ${PROTECTED_STORAGE_DIR}/vault.state
    rm -rf ${PROTECTED_ARCHIVE_STORAGE_DIR}/vault.state

    terminal_custom_logging "
    
                    ${RED}ENCRYPT ARCHIVE COMPLETE${NC}
                    
                    " "info"
    
}

restore_vault_archive_silent() {

    terminal_custom_logging "
    
                    ${RED}START CONVERTING VAULT ARCHIVE TO VAULT DECRYPTED FOR RUN${NC}
                    
                    " "info"

    check_vault_archive_already_decrypted;

    terminal_custom_logging "
    
                    ${RED}DECRYPTION COMPLETED, GO EXTRACT DATA${NC}

                    " "info"

    cd ${PROTECTED_ARCHIVE_STORAGE_DIR}/
    tar -xzvf ${USERNAME_PRIMARY}-vault.tar.gz -C ${USERNAME_PRIMARY} 
    cd $CURRENT_PATH

    check_and_copy_to_local_build;

    folder_protected_listen=`ls -la ${PROTECTED_STORAGE_DIR}/ | awk '{print $9}' | tail -n +3 | xargs -I ID echo '                       ID' | sed 's/\.\.//g'`

    terminal_custom_logging "
    
                    ${RED}LISTEN RESULT${NC}

$folder_protected_listen

                    GO TO NEXT STEP, - REMOVING THE ENCRYPT LOCK LINK STATE AND SET DECRYPTED STATE

                    " "info"

    rm -rf ${PROTECTED_STORAGE_DIR}/vault.state
    echo "ko" > ${PROTECTED_ARCHIVE_STORAGE_DIR}/vault.state

    terminal_custom_logging "
    
                    ${RED}DONE SET STATES${NC}

                    ${GREEN}RESTORING VAULT DONE${NC}

                    " "info"

}

check_and_copy_to_local_build() {

    terminal_custom_logging "
    
                    ${RED}CHECK LOCAL DIRECTORY ARE A PRESENT${NC}

                    " "info"

    if [[ ! -d "${LOCAL_DIRECTORY}" ]]; then

        mkdir -p "${LOCAL_DIRECTORY}"
    
    fi

    terminal_custom_logging "
    
                    ${RED}COPY DECRYPTED ARCHIVE VAULT TO LOCAL DIR${NC}

                    " "info"

    cp -R ${PROTECTED_ARCHIVE_STORAGE_DIR}/${USERNAME_PRIMARY}/* ${LOCAL_DIRECTORY}/

    folder_protected_local_listen=`ls -la ${LOCAL_DIRECTORY}/ | awk '{print $9}' | tail -n +3 | xargs -I ID echo '                        ID' | sed 's/\.\.//g'`

    terminal_custom_logging "
    
                    ${RED}SHOW LOCAL DIRECTORY:${NC}

                        $folder_protected_local_listen

                    " "info"


    copy_adapter_and_shared_configs;

}

copy_adapter_and_shared_configs() {

    shared_files_list=(
        "${PROTECTED_STORAGE_DIR}/shared.yml"
        "${PROTECTED_STORAGE_DIR}/main.yml"
        "${PROTECTED_STORAGE_DIR}/zone.yml"
        "${PROTECTED_STORAGE_DIR}/sg_data.yml"
    );

    inventory_cloud_provider=(
        "${PROTECTED_STORAGE_DIR}/${TYPEOFCLOUD}.yml"
    )

    attached_files_list=(
        "${PROTECTED_STORAGE_DIR}/group_vars/${ANSIBLE_INVENTORY}/attached/attached.yml"
        "${PROTECTED_STORAGE_DIR}/group_vars/${ANSIBLE_INVENTORY}/attached/main.yml"
    );

    terminal_custom_logging "

                    COPY AND DECRYPT SHARED SETTINGS
    
                    ${RED}COPY MAIN CONFIGS TO GROUP_VARS/PRODUCTS/[product]/${NC}

                    " "info"

    for file_path in ${shared_files_list[@]}; do

        file_full_name=$(echo $file_path | rev | cut -d '/' -f 1 | rev)

        terminal_custom_logging "

                    File full name: $file_full_name
                    File path: $file_path
                    Ansible path: $ansible_dir
                    Main group_vars: $main_group_vars_dir
                    Products in group_vars: $main_products_in_group_vars_dir
                    Current product in group_vars directory: $current_product_in_group_vars_dir
                    Current product Inventory in group_vars directory: $current_product_inventory_in_group_vars
                    ${RED}COPY FILE: $file_full_name${NC}

                    " "info"

        cat "$file_path" > "$current_product_in_group_vars_dir/$file_full_name"
        
        terminal_custom_logging "

                    DONE RAW PUT TO EXTERNAL FILE: $file_full_name
                    
                    For check the target file: 

                        ls -la $current_product_in_group_vars_dir/$file_full_name

                        cat current_product_in_group_vars_dir/$file_full_name

                    " "info"

    done

    terminal_custom_logging "

                    DONE DECRYPT AND COPY SHARED SETTINGS
                
                    COPY ADAPTER CONFIG TO GROUP_VARS/PRODUCTS/[product]/

                " "info"

    for inventory_target_cloud_type_config in ${inventory_cloud_provider[@]}; do

        cloud_type_file_full_name=$(echo $inventory_target_cloud_type_config | rev | cut -d '/' -f 1 | rev)

        terminal_custom_logging "

                    Inventory target cloud type configuration : $inventory_target_cloud_type_config
                
                    Current product inventory in group_vars : $current_product_inventory_in_group_vars

                    Cloud Type file full name: $cloud_type_file_full_name
                    
                    Copy the cloud type file: $cloud_type_file_full_name

                " "info"

        cat "$inventory_target_cloud_type_config" > "$current_product_in_group_vars_dir/$cloud_type_file_full_name"
        
        terminal_custom_logging "

                    DONE RAW PUT TO EXTERNAL FILE: $cloud_type_file_full_name

                " "info"

    done

    terminal_custom_logging "
                
                    START COPY GROUP_VARS/PRODUCTS/[product]/[ansible_environment]

                " "info"

    for group_vars_file_path in ${attached_files_list[@]}; do

        group_vars_file_full_name=$(echo $group_vars_file_path | rev | cut -d '/' -f 1 | rev)

        terminal_custom_logging "

                    File full name: $file_full_name
                    Root path: $CURRENT_PATH
                    File path: $file_path
                    Ansible path: $ansible_dir
                    Main group_vars: $main_group_vars_dir
                    Products in group_vars: $main_products_in_group_vars_dir
                    Current product in group_vars directory: $current_product_in_group_vars_dir
                    Current product Inventory in group_vars directory: $current_product_inventory_in_group_vars
                    
                    ${RED}COPY FILE: $file_full_name${NC}

                    " "info"

        cat "$group_vars_file_path" > "$current_product_in_group_vars_dir/${ANSIBLE_INVENTORY}/$group_vars_file_full_name"

        terminal_custom_logging "

                    DONE RAW PUT TO EXTERNAL FILE: $file_full_name
                    
                    For check the target file: 

                        ls -la $current_product_in_group_vars_dir/$file_full_name

                        cat current_product_in_group_vars_dir/$file_full_name

                    " "info"

    done

}

restore_vault_archive() {

    terminal_custom_logging "
                
                    START CONVERTING VAULT ARCHIVE TO VAULT DECRYPTED FOR RUN

                " "info"

    check_vault_archive_already_decrypted;

    terminal_custom_logging "
                
                    DECRYPTION COMPLETED, GO EXTRACT DATA

                " "info"

    #tar -xjvf ${PROTECTED_ARCHIVE_STORAGE_DIR}/${USERNAME_PRIMARY}-vault.tar.gz -C ${PROTECTED_STORAGE_DIR}/ ./
    cd ${PROTECTED_ARCHIVE_STORAGE_DIR}/
    #tar -xjvf ${PROTECTED_ARCHIVE_STORAGE_DIR}/${USERNAME_PRIMARY}-vault.tar.gz -C ${USERNAME_PRIMARY}
    tar -xzvf ${USERNAME_PRIMARY}-vault.tar.gz -C ${USERNAME_PRIMARY} 
    #echo "tar -xzvf ${PROTECTED_ARCHIVE_STORAGE_DIR}/${USERNAME_PRIMARY}-vault.tar.gz -C ${USERNAME_PRIMARY}"
    cd $CURRENT_PATH

    folder_protected_storage_listen=`ls -la ${PROTECTED_STORAGE_DIR}/ | awk '{print $9}' | tail -n +3 | xargs -I ID echo '                        ID' | sed 's/\.\.//g'`

    terminal_custom_logging "
    
                    ${RED}SHOW PROTECTED STORAGE DIRECTORY:${NC}

                        $folder_protected_storage_listen

                    " "info"

    check_and_copy_to_local_build;

    terminal_custom_logging "
                
                    REMOVE VAULT ARCHIVE

                " "info"

    rm -rf ${PROTECTED_ARCHIVE_STORAGE_DIR}/${USERNAME_PRIMARY}-vault.tar.gz

    terminal_custom_logging "
                
                    REMOVE ENCRYPT LOCK LINK STATE AND SET DECRYPTED STATE

                " "info"

    rm -rf ${PROTECTED_STORAGE_DIR}/vault.state
    echo "ko" > ${PROTECTED_ARCHIVE_STORAGE_DIR}/vault.state

    terminal_custom_logging "
                
                    RESTORING VAULT DONE

                " "info"

}

vault_archive_status() {

        if [ -f "$ansible_dir/.files/protected/storage/users/${USERNAME_PRIMARY}/products/${PRODUCT}/${USERNAME_PRIMARY}-vault.tar.gz" ]; then
            return 1
        else
            return 0
        fi

}

function_check_local_placement_directory_in_protected_storage(){

    terminal_custom_logging "
    
                    Checking the current protected storage user directory: 
                    
                        ${CURRENT_PATH}/.files/protected/storage/users/${USERNAME_PRIMARY}/products/${PRODUCT}/${USERNAME_PRIMARY}
                    
                    " "info"


    if [ ! -d "${CURRENT_PATH}/.files/protected/storage/users/${USERNAME_PRIMARY}/products/${PRODUCT}/${USERNAME_PRIMARY}" ]; then

        terminal_custom_logging "
        
                    ------------------------------------------------------

                    ${RED}! DESTINATION DIR NOT EXISTS !${NC}

                    ------------------------------------------------------
                    
                    Checking the current protected storage user directory: 
                        
                        ${CURRENT_PATH}/.files/protected/storage/users/${USERNAME_PRIMARY}/products/${PRODUCT}/${USERNAME_PRIMARY}
                        
                        " "info"

        mkdir "${CURRENT_PATH}/.files/protected/storage/users/${USERNAME_PRIMARY}/products/${PRODUCT}/${USERNAME_PRIMARY}"

    fi 

}

check_vault_init_params(){

    if [ -z $USERNAME_PRIMARY ]; then
        
        terminal_custom_logging "
        
                        ${RED}You must pass USERNAME as First param, try again

                    " "red"
        exit 1
    fi

    if [ -z $PRODUCT ]; then
        
        terminal_custom_logging "
        
                        ${RED}You must pass PRODUCT as Second param, try again

                    " "red"
        exit 1
    fi

    if [ -z $VAULT_WAY ]; then
        
        terminal_custom_logging "
        
                        ${RED}You must pass VAULT_WAY as Third param, try again, possible is - encrypt or decrypt or silent(without delete archive)

                    " "red"
        exit 1
    fi

    if [ -z $ANSIBLE_VAULT_PASSWORD ]; then
        
        terminal_custom_logging "
        
                        ${RED}You must pass ANSIBLE_VAULT_PASSWORD as Fourth param, try again

                    " "red"
        exit 1
    fi

    if [ -z $TYPEOFCLOUD ]; then
        
        terminal_custom_logging "
        
                        ${RED}You must pass TYPEOFCLOUD as Fifth param, try again

                    " "red"
        exit 1
    fi

    if [ -z $ANSIBLE_INVENTORY ]; then
        
        terminal_custom_logging "
        
                        ${RED}You must pass ANSIBLE INVENTORY as Sixth param, try again${NC}
                        
                        " "re"
        exit 1

    fi

}