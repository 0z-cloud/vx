#!/bin/bash
################################################################################
SCRIPT_NAME="internal-network-stack.sh"
PIPELINE_NAME="Internal Network Stack"
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
extra_args_type_of_run="${19}"
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
export registry_username="$registry_username"
export registry_token="$registry_token"
export ANSIBLE_COMMIT_SHA="$ANSIBLE_COMMIT_SHA"
export ANSIBLE_BUILD_ID="$ANSIBLE_BUILD_ID"
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
echo "SCRIPT_NAME: $SCRIPT_NAME"
echo "LOG_FILE_NAME: $LOG_FILE_NAME"
echo "LOCAL_DIRECTORY: $LOCAL_DIRECTORY"
echo "START_TIME: $START_TIME"
echo "EXEC_TIMESTAMP: $EXEC_TIMESTAMP"
echo "uname: $uname"
echo "runpath: $runpath"
echo "ansible_dir: $ansible_dir"
echo "root_path_dir: $root_path_dir"
# sleep 50

export LOCAL_DIRECTORY="$LOCAL_DIRECTORY"
export root_path_dir="$root_path_dir"

. "$ansible_dir"/scripts/libsh/head/colors.sh
# LOAD MAIN FUNCTIONS
. "$ansible_dir"/scripts/libsh/functions_ng.sh 
# DETERMINATE THE RUNTIME VARIABLES
# . "$ansible_dir"/scripts/libsh/head_ng.sh "$SCRIPT_NAME"
# RUN REQUIREMENTS HELPER
run_req_function "$inventory" "$product" "$username" "$password" "$apps" "$type_of_run" "$typeofcloud" "$vault_pass" "$ansible_global_gitlab_registry_site_name" "$gitlab_project_name" "$gitlab_project_group" "$version_ansible_build_id" "$deploy_environment_security_configuration" "$cluster_type" "$registry_username" "$registry_token" "$ANSIBLE_COMMIT_SHA" "$ANSIBLE_BUILD_ID"
# . "$ansible_dir"/scripts/libsh/deploy/req_help.sh
# DECRYPT VAULT ARCHIVE
vault_ng "$vault_pass" "$username" "decrypt" "$product" "$typeofcloud" "$inventory" "$root_path_dir" "$ansible_dir" "$LOCAL_DIRECTORY";
# GO INFRA PHASE I
run_bootstrap_and_check_infra "$typeofcloud" "$ansible_dir" "$product" "$inventory";

# GO BETWEEN PHASE I/II
. "$ansible_dir"/scripts/libsh/cloud_api_gen.sh "$runpath" "$ansible_dir"

all_hosts_echo;

# INSTALLING THE MAIN NETWORK BALANCER FOR BACKEND HOSTS

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
    "$ansible_dir"/playbook-library/\!_network/keepalive_deploy.yml \
    -e HOSTS="network-balancer-stack" -u $username --become-user root \
    --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

### END

last_info_show ${EXEC_TIMESTAMP}