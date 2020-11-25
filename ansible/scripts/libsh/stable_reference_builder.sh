#!/bin/bash

reference_stable_call_builder_flow_function(){

    echo "!!!!!!!!!!!!!! LF EDGE EVE HYPERCLOUD DEVELOPMENT PLACEMENT. RUN OR CALL 911RS. ONLY ZONE LOCALHOST DEVELOPMENT, NOT FOR PRODUCTION USAGE !!!!!!!!!!!!!!!!!!!!!"

        echo "ANSIBLE_CI_DATACENTER: $ANSIBLE_CI_DATACENTER"
        echo "ANSIBLE_ENVIRONMENT: $ANSIBLE_ENVIRONMENT"
        echo "ANSIBLE_PRODUCT_NAME: $ANSIBLE_PRODUCT_NAME"
        echo "ANSIBLE_DEPLOY_USERNAME: $ANSIBLE_DEPLOY_USERNAME"
        echo "A_DEPLOY_PASSWORD: $A_DEPLOY_PASSWORD"
        echo "ANSIBLE_APPLICATION_TYPE: $ANSIBLE_APPLICATION_TYPE"
        echo "ANSIBLE_RUN_TYPE: $ANSIBLE_RUN_TYPE"
        echo "ANSIBLE_CLOUD_TYPE: $ANSIBLE_CLOUD_TYPE"
        echo "A_VAULT_PASSWORD: $A_VAULT_PASSWORD"
        echo "ANSIBLE_REGISTRY_URL: $ANSIBLE_REGISTRY_URL"
        echo "ANSIBLE_CI_PROJECT_NAME: $ANSIBLE_CI_PROJECT_NAME"
        echo "ANSIBLE_CI_PROJECT_NAMESPACE: $ANSIBLE_CI_PROJECT_NAMESPACE"
        echo "ANSIBLE_CI_VERSION: $ANSIBLE_CI_VERSION" 
        echo "ANSIBLE_SECURITY: $ANSIBLE_SECURITY"
        echo "ANSIBLE_CLUSTER_TYPE: $ANSIBLE_CLUSTER_TYPE"
        echo "ANSIBLE_BUILD_ID: $ANSIBLE_BUILD_ID"
        echo "ANSIBLE_COMMIT_SHA: $ANSIBLE_COMMIT_SHA"
        echo "ANSIBLE_TRIGGER_TOKEN: $ANSIBLE_TRIGGER_TOKEN"
        echo "ANSIBLE_REGISTRY_USERNAME: $ANSIBLE_REGISTRY_USERNAME"

        if [ ! -z $ANSIBLE_TARGET_LINKED_DATACENTER_CHANGE_BETWEEN ]; then
            echo "ANSIBLE_TARGET_LINKED_DATACENTER_CHANGE_BETWEEN: $ANSIBLE_TARGET_LINKED_DATACENTER_CHANGE_BETWEEN"
        fi

    echo "!!!!!!!!!!!!!! LF EDGE EVE HYPERCLOUD DEVELOPMENT PLACEMENT. !!!!!!!!!!!!!!!!!!!!!"


    if [ ! -z $ANSIBLE_TARGET_LINKED_DATACENTER_CHANGE_BETWEEN ]; then
        echo "ANSIBLE_TARGET_LINKED_DATACENTER_CHANGE_BETWEEN: $ANSIBLE_TARGET_LINKED_DATACENTER_CHANGE_BETWEEN"
    fi

    echo "!!!!!!!!!!!!!! 2 APPLICATION SET SOLUTION FROM SERVICES FOLDERBUILD APPS LIVE SH ONLY !!!!!!!!!!!!!!!!!!!!!"

    if [ ! -z $linked_env_in_product ]; then

        echo "!!!!!!!!!!!!!! 2 target $linked_env_in_product ZONE LIVE SH ONLY !!!!!!!!!!!!!!!!!!!!!"

        /bin/bash "$ansible_dir"/reference_builder.sh \
        "$ANSIBLE_ENVIRONMENT" \
        "$ANSIBLE_PRODUCT_NAME" \
        "$ANSIBLE_DEPLOY_USERNAME" \
        "$A_DEPLOY_PASSWORD" \
        "$ANSIBLE_APPLICATION_TYPE" \
        "$ANSIBLE_RUN_TYPE" \
        "$ANSIBLE_CLOUD_TYPE" \
        "$A_VAULT_PASSWORD" \
        "$ANSIBLE_REGISTRY_URL" \
        "$ANSIBLE_CI_PROJECT_NAME" \
        "$ANSIBLE_CI_PROJECT_NAMESPACE" \
        "$ANSIBLE_CI_VERSION" \
        "$ANSIBLE_SECURITY" \
        "$ANSIBLE_CLUSTER_TYPE" \
        "$ANSIBLE_REGISTRY_USERNAME" \
        "$ANSIBLE_TRIGGER_TOKEN" \
        "$ANSIBLE_COMMIT_SHA" \
        "$ANSIBLE_BUILD_ID" \
        "$ANSIBLE_CI_DATACENTER" \
        "EXTRA_MILK_COW" \
        "REINSTALL_PIP_TRUE" \
        "$linked_env_in_product" 

    else
        /bin/bash "$ansible_dir"/reference_builder.sh \
        "$ANSIBLE_ENVIRONMENT" \
        "$ANSIBLE_PRODUCT_NAME" \
        "$ANSIBLE_DEPLOY_USERNAME" \
        "$A_DEPLOY_PASSWORD" \
        "$ANSIBLE_APPLICATION_TYPE" \
        "$ANSIBLE_RUN_TYPE" \
        "$ANSIBLE_CLOUD_TYPE" \
        "$A_VAULT_PASSWORD" \
        "$ANSIBLE_REGISTRY_URL" \
        "$ANSIBLE_CI_PROJECT_NAME" \
        "$ANSIBLE_CI_PROJECT_NAMESPACE" \
        "$ANSIBLE_CI_VERSION" \
        "$ANSIBLE_SECURITY" \
        "$ANSIBLE_CLUSTER_TYPE" \
        "$ANSIBLE_REGISTRY_USERNAME" \
        "$ANSIBLE_TRIGGER_TOKEN" \
        "$ANSIBLE_COMMIT_SHA" \
        "$ANSIBLE_BUILD_ID" \
        "$ANSIBLE_CI_DATACENTER" \
        "EXTRA_MILK_COW"
        #  \
        # "REINSTALL_PIP_TRUE" \
        # "$linked_env_in_product" 

    fi

}

function_stable_reference_builder(){ 

    ################################################################################
    SCRIPT_NAME="reference_builder.sh"
    PIPELINE_NAME="BuildAndPush"
    ################################################################################
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
    registry_username="${15}"
    registry_token="${16}"
    ANSIBLE_COMMIT_SHA="${17}"
    ANSIBLE_BUILD_ID="${18}"
    extended_datacenter_zone="${19}"
    extra_args_type_of_run="${20}"
    force_requirements_reinstall="${21}"
    remap_target_to_link_inventory_name="${22}"
    ################################################################################
    export apps="$apps"
    export gitlab_project_name="$gitlab_project_name"
    export gitlab_project_group="$gitlab_project_group"
    export typeofcloud="$typeofcloud"
    export username="$username"
    export inventory="$inventory"
    export product="$product"
    export ansible_global_gitlab_registry_site_name="$ansible_global_gitlab_registry_site_name"
    export type_of_run="$type_of_run"
    export registry_username="$registry_username"
    export registry_token="$registry_token"
    export version_ansible_build_id="$version_ansible_build_id"
    export deploy_environment_security_configuration="$deploy_environment_security_configuration"
    export password="$password"
    export vault_pass="$vault_pass"
    export cluster_type="$cluster_type"
    export ANSIBLE_COMMIT_SHA="$ANSIBLE_COMMIT_SHA"
    export ANSIBLE_BUILD_ID="$ANSIBLE_BUILD_ID"
    export force_requirements_reinstall="$force_requirements_reinstall"
    export remap_target_to_link_inventory_name="$remap_target_to_link_inventory_name"
    ################################################################################
    clear

    EXEC_TIMESTAMP=`date +%s`
    START_TIME=`date +%Y-%m-%d`

    LOG_LEVEL_WRAPPER="short" # debug / trace / info / short
    export LOG_LEVEL_WRAPPER $LOG_LEVEL_WRAPPER

    # Have fun when you use that! =)
    # Becareful, you need known what you doing =)
    # . "$ansible_dir"/scripts/libsh/head/colors.sh

    pipelinename=$PIPELINE_NAME
    LOG_FILE_NAME="./CI/logs/${pipelinename}-${USER}-${START_TIME}-${EXEC_TIMESTAMP}.log"
    uname=$(uname)
    runpath=`pwd`
    ansible_dir="${runpath}/ansible"
    ansible_dir=$(echo "$runpath" | sed -e "s/ansible\/ansible/ansible/g")
    root_path_dir=`echo $runpath | sed -e 's/\/ansible//g'`
    LOCAL_DIRECTORY="$root_path_dir/.local"

    export LOCAL_DIRECTORY="$LOCAL_DIRECTORY"
    export root_path_dir="$root_path_dir"

    # LOAD COLORS
    . "$ansible_dir"/scripts/libsh/head/colors.sh

    # LOAD MAIN FUNCTIONS
    . "$ansible_dir"/scripts/libsh/functions_ng.sh 

    # DETERMINATE THE RUNTIME VARIABLES
    # . "$ansible_dir"/scripts/libsh/head_ng.sh "$SCRIPT_NAME"

    ####################################################################################################################################################################
    # REUIREMENTS FOR PIP FORCE REINSTALL SECTION
    ####################################################################################################################################################################
    terminal_custom_logging " 

                            Application Set $apps 
                            VCS Project Name: $gitlab_project_name 
                            VCS Project Group: $gitlab_project_group 
                            Type of cloud: $typeofcloud 
                            Username: $username 
                            Inventory: $inventory 
                            Product: $product 
                            Registry site URL: $ansible_global_gitlab_registry_site_name 
                            Type of run: $type_of_run 
                            Registry Username: $registry_username 
                            Registry Token: $registry_token 
                            Ansible Build ID $version_ansible_build_id 
                            Environment Security Configuration: $deploy_environment_security_configuration 
                            Password: $password 
                            Vault password: $vault_pass 
                            Cluster Type: $cluster_type 
                            CI Commit SHA: $ANSIBLE_COMMIT_SHA 
                            CI Build ID: $ANSIBLE_BUILD_ID 
                            Reinstall requirements flag: $force_requirements_reinstall 
                            Remapping target inventory from same zero template source to: $remap_target_to_link_inventory_name 
                            
                            SCRIPT_NAME: $SCRIPT_NAME
                            LOG_FILE_NAME: $LOG_FILE_NAME
                            LOCAL_DIRECTORY: $LOCAL_DIRECTORY
                            START_TIME: $START_TIME
                            EXEC_TIMESTAMP: $EXEC_TIMESTAMP
                                
                            " "info"
    ####################################################################################################################################################################

    if [ ! -z $force_requirements_reinstall ]; then

        terminal_custom_logging "

                                Start force reinstall/check requirements installed
                                
                                " "info"
        uname=`uname -s`
        run_req "$typeofcloud" "$uname" "$ansible_dir"

    else

        terminal_custom_logging "
        
                                Not defined to force reinstalling/checking requirements installed
                                
                                " "info"
    fi

    ####################################################################################################################################################################
    terminal_custom_logging " RUN REQUIREMENTS HELPER: ПРОВЕРКА ВСЕХ ТРЕБУЕМЫХ ПАРАМЕТРОВ НЕОБХОДИМЫХ ДЛЯ ОСУЩЕСТВЛЕНИЯ СЦЕНАРИЯ НЕПРЕРЫВНОЙ ИНТЕГРАЦИИ И ПРОЦЕССОВ НЕПРЕРЫВНОЙ ДОСТАВКИ" "trace"
    ####################################################################################################################################################################

    run_req_function "$inventory" "$product" "$username" "$password" "$apps" "$type_of_run" "$typeofcloud" "$vault_pass" "$ansible_global_gitlab_registry_site_name" "$gitlab_project_name" "$gitlab_project_group" "$version_ansible_build_id" "$deploy_environment_security_configuration" "$cluster_type" "$registry_username" "$registry_token" "$ANSIBLE_COMMIT_SHA" "$ANSIBLE_BUILD_ID"
    # . "$ansible_dir"/scripts/libsh/deploy/req_help.sh

    ####################################################################################################################################################################
    terminal_custom_logging " DECRYPT VAULT ARCHIVE: ПОЛУЧЕНИЕ И РАСШИФРОВКА ПЕРСОНАЛЬНОГО ХРАНИЛИЩА ДАННЫХ (АУТЕНТИФИКАЦИОННЫЕ, ИНЫЕ ПАРАМЕТРЫ И СЛОВАРИ) ПОЛЬЗОВАТЕЛЯ И АДАПТЕРА" "trace"
    ####################################################################################################################################################################

    vault_ng "$vault_pass" "$username" "decrypt" "$product" "$typeofcloud" "$inventory" "$root_path_dir" "$ansible_dir" "$LOCAL_DIRECTORY";

    ####################################################################################################################################################################
    terminal_custom_logging " PIPELINE: НАЧАЛО ВЫПОЛНЕНИЯ ЭТАПОВ СЦЕНАРИЯ КОНВЕЙРА" "trace"
    ####################################################################################################################################################################

    terminal_custom_logging "PARENT INVENTORY SOURCE: $inventory" "trace"

    #echo "remap_target_to_link_inventory_name: $remap_target_to_link_inventory_name"
    ANSIBLE_COMMIT_SHA_SHORT=`echo $ANSIBLE_COMMIT_SHA | head -c 8`
    DATE_YEAR=`date '+%Y'`
    DATE_MOUTH=`date '+%m'`
    ANSIBLE_CI_VERSION="${DATE_YEAR}.${DATE_MOUTH}.$ANSIBLE_BUILD_ID-${ANSIBLE_COMMIT_SHA_SHORT}"

    terminal_custom_logging "

                        ANSIBLE CI VERSION: $ANSIBLE_CI_VERSION
                        
                        " "info"

    if [ ! -z $remap_target_to_link_inventory_name ]; then

        terminal_custom_logging "REMAPPED RESULT TRARGET IS(remap_target_to_link_inventory_name) $remap_target_to_link_inventory_name" "trace"

        ####################################################################################################################################################################
        terminal_custom_logging " # GO INFRA PHASE I: УРОВЕНЬ РАЗВЕРТЫВАНИЯ И ВАЛИДАЦИИ ВИРТУАЛЬНЫХ МАШИН" "trace"
        ####################################################################################################################################################################
        
        # development_run_bootstrap_and_check_infra "$typeofcloud" "$ansible_dir" "$product" "$inventory" "$ansible_datacenter";

        ####################################################################################################################################################################
        terminal_custom_logging " # GO BETWEEN PHASE I/II: СОЗДАНИЕ КОНЕЧНОГО ИНВЕНТАРЯ" "trace"
        ####################################################################################################################################################################

        terminal_custom_logging "INVENTORY TO REMAP: $remap_target_to_link_inventory_name" "trace"
        terminal_custom_logging "PARENT INVENTORY SOURCE: $inventory" "trace"

        # echo -e "       INVENTORY TO REMAP: $remap_target_to_link_inventory_name"
        # echo -e "       PARENT INVENTORY SOURCE: $inventory"

        ####################################################################################################################################################################
        terminal_custom_logging " # CUSTOM TARGET LINKED INVENTORY PIPE SHORT TASKS: ВЫПОЛНЕНИЕ ДОПОЛНИТЕЛЬНОГО СЦЕНАРИЯ ДЛЯ ПОТОМКА ОСНОВНОГО ИНВЕНТАРЯ ВНУТРИ ПРОДУКТА" "trace"
        ####################################################################################################################################################################
        inventory="$remap_target_to_link_inventory_name"

        ####################################################################################################################################################################
        terminal_custom_logging " # TO_WIP: CURRENTLY ONLY DNS UPDATE ON THIS FLOW, NEED TALKS ABOUT WHAT WE REALLY NEED WHEN THIS CASE RUN" "trace"
        ####################################################################################################################################################################
        terminal_custom_logging " # DOCKER BUILD ALL" "trace"

        prepare_ci "$username" "$product" "$typeofcloud" "$inventory" "$root_path_dir" "$ansible_dir" "$runpath" "$LOCAL_DIRECTORY" "$ANSIBLE_CI_VERSION" "$ANSIBLE_BUILD_ID";

        docker_build_function "$username" "$product" "$typeofcloud" "$inventory" "$root_path_dir" "$ansible_dir" "$runpath" "$LOCAL_DIRECTORY" "$registry_username" "$registry_token";
        # target_inventory_link_devops_service_zone_live "$typeofcloud" "$ansible_dir" "$product" "$remap_target_to_link_inventory_name" "$ansible_datacenter";

    else

        ####################################################################################################################################################################
        terminal_custom_logging " # GO INFRA PHASE I: УРОВЕНЬ РАЗВЕРТЫВАНИЯ И ВАЛИДАЦИИ ВИРТУАЛЬНЫХ МАШИН" "trace"
        ####################################################################################################################################################################

        # development_run_bootstrap_and_check_infra "$typeofcloud" "$ansible_dir" "$product" "$inventory" "$ansible_datacenter";

        ####################################################################################################################################################################
        terminal_custom_logging " # GO BETWEEN PHASE I/II: СОЗДАНИЕ КОНЕЧНОГО ИНВЕНТАРЯ" "trace"
        ####################################################################################################################################################################

        . "$ansible_dir"/scripts/libsh/development_cloud_api_gen.sh "$runpath" "$ansible_dir" "$inventory" 

        ####################################################################################################################################################################
        terminal_custom_logging " # PRIMARY TARGET LINKED INVENTORY PIPE FULL CHAIN PLAYBOOKS WITH MULTIPLE ROLES AND TASKS: ВЫПОЛНЕНИЕ ДОПОЛНИТЕЛЬНОГО СЦЕНАРИЯ ДЛЯ ПОТОМКА ОСНОВНОГО ИНВЕНТАРЯ ВНУТРИ ПРОДУКТА" "trace"
        ####################################################################################################################################################################
        terminal_custom_logging " # DOCKER BUILD ALL" "trace"

        prepare_ci "$username" "$product" "$typeofcloud" "$inventory" "$root_path_dir" "$ansible_dir" "$runpath" "$LOCAL_DIRECTORY" "$ANSIBLE_CI_VERSION" "$ANSIBLE_BUILD_ID";

        docker_build_function "$username" "$product" "$typeofcloud" "$inventory" "$root_path_dir" "$ansible_dir" "$runpath" "$LOCAL_DIRECTORY" "$registry_username" "$registry_token" "$ansible_global_gitlab_registry_site_name" "$gitlab_project_group" "$gitlab_project_name";
        # devops_service_zone_live "$typeofcloud" "$ansible_dir" "$product" "$inventory" "$ansible_datacenter";

    fi
    # SHOW RUN INFO
    last_info_show ${EXEC_TIMESTAMP}

}