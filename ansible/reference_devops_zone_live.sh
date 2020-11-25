#!/bin/bash
################################################################################
SCRIPT_NAME="reference_devops_zone_live.sh"
PIPELINE_NAME="DevOps SERVICE ZONE LIVE. If you not DevOps and run it you will be killed by DevOps team."
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

# SCRIPT NAME
# echo "SCRIPT_NAME: $SCRIPT_NAME"
# echo "LOG_FILE_NAME: $LOG_FILE_NAME"
# echo "LOCAL_DIRECTORY: $LOCAL_DIRECTORY"
# echo "START_TIME: $START_TIME"
# echo "EXEC_TIMESTAMP: $EXEC_TIMESTAMP"
# echo "uname: $uname"
# echo "runpath: $runpath"
# echo "ansible_dir: $ansible_dir"
# echo "root_path_dir: $root_path_dir"
# sleep 50

export LOCAL_DIRECTORY="$LOCAL_DIRECTORY"
export root_path_dir="$root_path_dir"

# LOAD COLORS
. "$ansible_dir"/scripts/libsh/head/colors.sh

# LOAD MAIN FUNCTIONS
. "$ansible_dir"/scripts/libsh/functions_ng.sh 

# DETERMINATE THE RUNTIME VARIABLES
# . "$ansible_dir"/scripts/libsh/head_ng.sh "$SCRIPT_NAME"

# REUIREMENTS FOR PIP FORCE REINSTALL SECTION

if [ ! -z $force_requirements_reinstall ]; then
    echo -e "          Start force reinstall/check requirements installed"
    uname=`uname -s`
    run_req "$typeofcloud" "$uname" "$ansible_dir"
else
    echo -e "          Not defined to force reinstalling/checking requirements installed"
fi

####################################################################################################################################################################
# RUN REQUIREMENTS HELPER: ПРОВЕРКА ВСЕХ ТРЕБУЕМЫХ ПАРАМЕТРОВ НЕОБХОДИМЫХ ДЛЯ ОСУЩЕСТВЛЕНИЯ СЦЕНАРИЯ НЕПРЕРЫВНОЙ ИНТЕГРАЦИИ И ПРОЦЕССОВ НЕПРЕРЫВНОЙ ДОСТАВКИ
####################################################################################################################################################################

run_req_function "$inventory" "$product" "$username" "$password" "$apps" "$type_of_run" "$typeofcloud" "$vault_pass" "$ansible_global_gitlab_registry_site_name" "$gitlab_project_name" "$gitlab_project_group" "$version_ansible_build_id" "$deploy_environment_security_configuration" "$cluster_type" "$registry_username" "$registry_token" "$ANSIBLE_COMMIT_SHA" "$ANSIBLE_BUILD_ID"
# . "$ansible_dir"/scripts/libsh/deploy/req_help.sh

####################################################################################################################################################################
# DECRYPT VAULT ARCHIVE: ПОЛУЧЕНИЕ И РАСШИФРОВКА ПЕРСОНАЛЬНОГО ХРАНИЛИЩА ДАННЫХ (АУТЕНТИФИКАЦИОННЫЕ, ИНЫЕ ПАРАМЕТРЫ И СЛОВАРИ) ПОЛЬЗОВАТЕЛЯ И АДАПТЕРА
####################################################################################################################################################################

vault_ng "$vault_pass" "$username" "decrypt" "$product" "$typeofcloud" "$inventory" "$root_path_dir" "$ansible_dir" "$LOCAL_DIRECTORY";

####################################################################################################################################################################
# PIPELINE: НАЧАЛО ВЫПОЛНЕНИЯ ЭТАПОВ СЦЕНАРИЯ КОНВЕЙРА
####################################################################################################################################################################

echo "remap_target_to_link_inventory_name: $remap_target_to_link_inventory_name"

if [ ! -z $remap_target_to_link_inventory_name ]; then

    ####################################################################################################################################################################
    # GO INFRA PHASE I: УРОВЕНЬ РАЗВЕРТЫВАНИЯ И ВАЛИДАЦИИ ВИРТУАЛЬНЫХ МАШИН 
    ####################################################################################################################################################################
    
    # development_run_bootstrap_and_check_infra "$typeofcloud" "$ansible_dir" "$product" "$inventory" "$ansible_datacenter";

    ####################################################################################################################################################################
    # GO BETWEEN PHASE I/II: СОЗДАНИЕ КОНЕЧНОГО ИНВЕНТАРЯ
    ####################################################################################################################################################################

    echo -e "       INVENTORY TO REMAP: $remap_target_to_link_inventory_name"
    echo -e "       PARENT INVENTORY SOURCE: $inventory"

    # REPLACE MAIN ANSIBLE_ENVIRONMENT VARIABLE BY TARGET LINKED EXTEND ENVIRONMENT ON SAME ZONE (vAPP)
    # В СЛУЧАЕ ПОЛУЧЕНИЯ ИНВЕНТАРЯ НАЗНАЧЕНИЯ ОТЛИЧНОГО ОТ ИНВЕНТАРЯ ИСТОЧНИКА, ПРОИЗВОДИТСЯ ЗАМЕНА ИМЕНИ КОНЕЧНОГО ИНВЕНТАРЯ С ПЕРВОНАЧАЛЬНОГО НА КОНЕЧНЫЙ 
    #
    #
    . "$ansible_dir"/scripts/libsh/development_cloud_api_gen.sh "$runpath" "$ansible_dir" "$inventory" "$remap_target_to_link_inventory_name" 

    ####################################################################################################################################################################
    # CUSTOM TARGET LINKED INVENTORY PIPE SHORT TASKS: ВЫПОЛНЕНИЕ ДОПОЛНИТЕЛЬНОГО СЦЕНАРИЯ ДЛЯ ПОТОМКА ОСНОВНОГО ИНВЕНТАРЯ ВНУТРИ ПРОДУКТА
    ####################################################################################################################################################################
    inventory="$remap_target_to_link_inventory_name"

    ####################################################################################################################################################################
    # TO_WIP: CURRENTLY ONLY DNS UPDATE ON THIS FLOW, NEED TALKS ABOUT WHAT WE REALLY NEED WHEN THIS CASE RUN
    ####################################################################################################################################################################

    target_inventory_link_devops_service_zone_live "$typeofcloud" "$ansible_dir" "$product" "$remap_target_to_link_inventory_name" "$ansible_datacenter";

else

    ####################################################################################################################################################################
    # GO INFRA PHASE I: УРОВЕНЬ РАЗВЕРТЫВАНИЯ И ВАЛИДАЦИИ ВИРТУАЛЬНЫХ МАШИН 
    ####################################################################################################################################################################

    # development_run_bootstrap_and_check_infra "$typeofcloud" "$ansible_dir" "$product" "$inventory" "$ansible_datacenter";

    ####################################################################################################################################################################
    # GO BETWEEN PHASE I/II: СОЗДАНИЕ КОНЕЧНОГО ИНВЕНТАРЯ
    ####################################################################################################################################################################

    . "$ansible_dir"/scripts/libsh/development_cloud_api_gen.sh "$runpath" "$ansible_dir" "$inventory" 

    ####################################################################################################################################################################
    # PRIMARY TARGET LINKED INVENTORY PIPE FULL CHAIN PLAYBOOKS WITH MULTIPLE ROLES AND TASKS: ВЫПОЛНЕНИЕ ДОПОЛНИТЕЛЬНОГО СЦЕНАРИЯ ДЛЯ ПОТОМКА ОСНОВНОГО ИНВЕНТАРЯ ВНУТРИ ПРОДУКТА
    ####################################################################################################################################################################

    devops_service_zone_live "$typeofcloud" "$ansible_dir" "$product" "$inventory" "$ansible_datacenter";

fi
# SHOW RUN INFO
last_info_show ${EXEC_TIMESTAMP}