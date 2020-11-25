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
. ./functions_ng.sh 
# DETERMINATE THE RUNTIME VARIABLES
. ./head_ng.sh "$SCRIPT_NAME"
# RUN REQUIREMENTS HELPER
run_req_function "$inventory" "$product" "$username" "$password" "$apps" "$type_of_run" "$typeofcloud" "$vault_pass" "$ansible_global_gitlab_registry_site_name" "$gitlab_project_name" "$gitlab_project_group" "$version_ansible_build_id" "$deploy_environment_security_configuration" "$cluster_type" "$registry_username" "$registry_token" "$ANSIBLE_COMMIT_SHA" "$ANSIBLE_BUILD_ID"
# . "$ansible_dir"/scripts/libsh/deploy/req_help.sh
# DECRYPT VAULT ARCHIVE
vault_ng "$vault_pass" "$username" "decrypt" "$product" "$typeofcloud" "$inventory";
# GO INFRA PHASE I
run_bootstrap_and_check_infra;
# GO BETWEEN PHASE I/II
. "$ansible_dir"/scripts/libsh/cloud_api_gen.sh $runpath $ansible_dir
# GO PREPARE CI PHASE III
. "$ansible_dir"/scripts/libsh/deploy/prepare_ci.sh "$runpath" "$ansible_dir"
# GO BUILD CI PHASE IV
. "$ansible_dir"/scripts/libsh/deploy/docker_build.sh "$runpath" "$ansible_dir"

