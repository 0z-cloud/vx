#!/bin/bash
################################################################################
SCRIPT_NAME="stand-pci.sh"
PIPELINE_NAME="Stand PCI Recreate"
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

# LOADING SHARED PLAYBOOKS

. "$ansible_dir"/scripts/libsh/head/shared_books.sh "$runpath" "$ansible_dir"

# CREATE RC LOCAL FOR ALL

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
    "$ansible_dir"/playbook-library/!_bootstrap/rc_local.yml \
    -e HOSTS="all" -u $username --become-user root \
    --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

# SETUP DNS INITIALIZATION TO ALL HOSTS

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
    "$ansible_dir"/playbook-library/!_bootstrap/dns-initialization.yml \
    -e HOSTS="all" -u $username --become-user root  --become \
    -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"


# SETUP SYSTEMD RESOLVED SERVICE TO ALL HOSTS

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
    "$ansible_dir"/playbook-library/!_bootstrap/systemd_resolved.yml \
    -u $username --become-user root --become -e "ansible_become_pass='$password'" \
    -e "ansible_ssh_pass='$password'" -e stage="1"

# CREATE CLOUD BIND GLUSTERFS STORAGE

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
    "$ansible_dir"/playbook-library/storage/glusterfs-cluster.yml \
    -e GLUSTERFS_CLUSTER_HOSTS="glusterfs-storage-cloud-bind-frontend-dns" \
    -u $username --become-user root --become \
    -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

# CREATE DATABASES CLUSTER GLUSTERFS STORAGE

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
    "$ansible_dir"/playbook-library/storage/glusterfs-cluster.yml \
    -e GLUSTERFS_CLUSTER_HOSTS="postgres-database-glusterfs" \
    -u $username --become-user root --become \
    -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

# CREATE BIND MASTERS GLUSTERFS STORAGE

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
    "$ansible_dir"/playbook-library/storage/glusterfs-cluster.yml \
    -e GLUSTERFS_CLUSTER_HOSTS="bind-master-glusterfs" \
    -u $username --become-user root --become \
    -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"


# SETUP CoreDNS FRONTEND SERVICE TO IDS HOSTS

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
    "$ansible_dir"/playbook-library/!_bootstrap/core-dns.yml \
    -e HOSTS="cloud-bind-frontend-dns" -u $username --become-user root \
    --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="2"

# SETUP DNS BACKEND SERVICE TO DNS BACKEND HOSTS

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
    "$ansible_dir"/playbook-library/!_bootstrap/dns-backend.yml \
    -e HOSTS="master-bind-master-backend" -u $username --become-user root \
    --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="2" 

### SWARM CLUSTERS >

# CREATE A FRONTEND DOCKER SWARM CLUSTER

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
    "$ansible_dir"/playbook-library/cloud/swarm/swarm-cluster.yml \
    -e SWARM_MASTERS="swarm-cluster" \
    -u $username --become-user root --become -e "ansible_become_pass='$password'" \
    -e "ansible_ssh_pass='$password'" \
    -e leave_cluster="true" -e stage="2"

# CREATE A DATABASE DOCKER SWARM CLUSTER

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
    "$ansible_dir"/playbook-library/cloud/swarm/swarm-cluster.yml \
    -e SWARM_MASTERS="database-swarm-cluster" \
    -u $username --become-user root --become -e "ansible_become_pass='$password'" \
    -e "ansible_ssh_pass='$password'" \
    -e leave_cluster="true" -e stage="2"

# INSTALLING NEW MAIN NETPLAN CONFIGURATION FOR BACKEND HOSTS

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
    "$ansible_dir"/playbook-library/\!_network/netplan.yml \
    -u $username --become-user root \
    --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

# # INSTALLING THE MAIN NETWORK BALANCER FOR BACKEND HOSTS

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
    "$ansible_dir"/playbook-library/\!_network/keepalive_deploy.yml \
    -e HOSTS="network-balancer-stack" -u $username --become-user root \
    --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

# INSTALLING AUDITD & LOGROTATE CONFIGURATIONS

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
    "$ansible_dir"/playbook-library/compliance/audit.yml \
    -u $username --become-user root \
    --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
    "$ansible_dir"/playbook-library/\!_bootstrap/logrotate.yml \
    -u $username --become-user root \
    --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
    "$ansible_dir"/playbook-library/system/pam_d-all.yml \
    -u $username --become-user root \
    --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

# Run the apt_install.yml playbook for all hosts

echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
echo -e "       Run the ${RED}apt_install.yml${NC} playbook for all hosts, for install ${RED}necessary${NC} system packages"
echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        "$ansible_dir"/playbook-library/\!_bootstrap/apt_install.yml \
        -e HOSTS='all' \
        -u $username --become-user root \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
echo -e "       Run the ${RED}postfix.yml${NC} playbook for all hosts, for install ${RED}necessary${NC} system packages"
echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        "$ansible_dir"/playbook-library/\!_bootstrap/postfix.yml \
        -u $username --become-user root \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
echo -e "       Run the ${RED}clamav.yml${NC} playbook for all hosts, for install ${RED}Antivirus${NC} system packages"
echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        "$ansible_dir"/playbook-library/security/clamav.yml \
        -u $username --become-user root \
        -e HOSTS='all' \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
echo -e "       Run the ${RED}apache2 web server${NC} playbook on mirror server host, for serving ${RED}public mirrors in private zone${NC}"
echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        "$ansible_dir"/playbook-library/system/repository_mirror_server_apache.yml \
        -u $username --become-user root \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"


# APT MIRROR

echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
echo -e "       Run the ${RED}apt-mirror.yml${NC} playbook for all hosts, for install ${RED}Antivirus${NC} system packages"
echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
echo -e "       ${RED}IMPORTANT!${NC} Be careful playbook change the sources.list after complete"
echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
echo -e "       ${RED}You must hold and wait full apt-mirror sync before continue run a other playbooks or start deploy pipelines${NC}"
echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        "$ansible_dir"/playbook-library/security/apt-mirror.yml \
        -u $username --become-user root \
        -e HOSTS='all' \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

# LOGGING CLUSTER AND VIEWER

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        "$ansible_dir"/playbook-library/logging/logging-kibana-service.yml \
        -u $username --become-user root \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        "$ansible_dir"/playbook-library/logging/logging-elasticsearch-cluster.yml \
        -u $username --become-user root \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

# FLUENTD PREPARE DIRS AND CONF

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        "$ansible_dir"/playbook-library/logging/fluentd-service.yml \
        -u $username --become-user root \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

# HOOK UPLOAD MISSED LOGS

# function_selector_runner ansible-playbook -i inventories/products/$product/$inventory/ \
#     playbook-library/hooks/fluent_past_logs_upload.yml \
#     -u $username --become-user root \
#     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

### END
last_info_show ${EXEC_TIMESTAMP}
#. "$ansible_dir"/scripts/libsh/end/end.sh ${EXEC_TIMESTAMP}