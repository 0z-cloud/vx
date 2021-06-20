#!/bin/bash
################################################################################
SCRIPT_NAME="stand-minimal.sh"
PIPELINE_NAME="Stand Minimal"
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
# CREATE RC LOCAL TO ALL OTHER HOSTS

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/playbook-library/!_bootstrap/rc_local.yml \
    -e HOSTS="all" -u $username --become-user root --limit "!ids-keepalive-servers" \
    --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

# SETUP DNS SERVICE TO IDS HOSTS

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/playbook-library/\!_bootstrap/dns-initialization.yml \
    -e HOSTS="all" -u $username --become-user root  --become \
    -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

# SETUP SYSTEMD RESOLVED SERVICE TO ALL HOSTS

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/playbook-library/\!_bootstrap/systemd_resolved.yml \
    -u $username --become-user root --become -e "ansible_become_pass='$password'" \
    -e "ansible_ssh_pass='$password'" -e stage="1"

# SSH LOCALHOST DEPENDENCY

function_selector_runner ansible-playbook "$ansible_dir"/playbook-library/system/ssh_deps.yml 

# SSH KEYUPLOAD

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/playbook-library/system/ssh.yml \
    -e HOSTS="all" -u $username --become-user root --become \
    -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" \
    --tags add_user -e stage="1"

## MASKED WIP
# ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ playbook-library/!_bootstrap/ssh.yml \
#     -e HOSTS="ids-keepalive-servers" -u $username --become-user root  --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'"
#####

# CREATE A CONSUL SERVICE DISCOVERY SERVICE

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/playbook-library/cloud/consul/!_consul_cloud_playbook.yml \
    -e HOSTS="all" -u $username --become-user root  --become \
    -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e "consul_upgrade=true" -e stage="1"

# CREATE CLOUD BIND GLUSTERFS STORAGE

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/playbook-library/storage/glusterfs-cluster.yml \
    -e GLUSTERFS_CLUSTER_HOSTS="glusterfs-storage-cloud-main-frontend-dns" \
    -u $username --become-user root --become \
    -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

### GLUSTERFS SECTION >

# CREATE BIND MASTER BACKEND GLUSTERFS STORAGE

# function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
#     playbook-library/storage/glusterfs-cluster.yml \
#     -e GLUSTERFS_CLUSTER_HOSTS="app-glusterfs-cluster" \
#     -u $username --become-user root --become \
#     -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'"

# CREATE DATABASE GLUSTERFS STORAGE

# function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
#     playbook-library/storage/glusterfs-cluster.yml \
#     -e GLUSTERFS_CLUSTER_HOSTS="database-glusterfs-cluster" \
#     -u $username --become-user root --become \
#     -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'"

# CREATE BIND MASTERS GLUSTERFS STORAGE

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/playbook-library/storage/glusterfs-cluster.yml \
    -e GLUSTERFS_CLUSTER_HOSTS="bind-master-glusterfs" \
    -u $username --become-user root --become \
    -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

# CREATE BIND MASTERS GLUSTERFS STORAGE
# sentry-web-glusterfs-cluster

# function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
#     playbook-library/storage/glusterfs-cluster.yml \
#     -e GLUSTERFS_CLUSTER_HOSTS="sentry-web-glusterfs-cluster" \
#     -u $username --become-user root --become \
#     -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" \
#     -e clean_glusterfs_all=true -e clean_glusterfs_reintall=true

# # sentry-cache-glusterfs-cluster

# function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
#     playbook-library/storage/glusterfs-cluster.yml \
#     -e GLUSTERFS_CLUSTER_HOSTS="sentry-cache-glusterfs-cluster" \
#     -u $username --become-user root --become \
#     -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" \
#     -e clean_glusterfs_all=true -e clean_glusterfs_reintall=true

# # sentry-database-glusterfs-cluster

# function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
#     playbook-library/storage/glusterfs-cluster.yml \
#     -e GLUSTERFS_CLUSTER_HOSTS="sentry-database-glusterfs-cluster" \
#     -u $username --become-user root --become \
#     -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" \
#     -e clean_glusterfs_all=true -e clean_glusterfs_reintall=true

### GLUSTERFS SECTION<

# DOCKER INSTALL FOR ALL HOSTS

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/playbook-library/cloud/docker/docker-install-auto-cloud.yml \
    -e HOSTS="all" -u $username --become-user root --become \
    -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="2"

# SETUP CoreDNS FRONTEND SERVICE TO IDS HOSTS

if [[ "$inventory" != "production" ]]; then

    echo -e "     |>..........................................................................................................................................................................................<|"
    echo -e "          Inventory not a production, current environment is: $inventory"
    echo -e "          We not recommends to deploy core-dns main service other then production inventory"
    echo -e "     |>..........................................................................................................................................................................................<|"


    if [ "$type_of_run" == "print_only" ]; then

        echo -e "     |>..........................................................................................................................................................................................<|"
        echo -e "         Show core-dns runline"
        echo -e "     |>..........................................................................................................................................................................................<|"

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/playbook-library/\!_bootstrap/core-dns.yml \
            -e HOSTS="cloud-bind-frontend-dns" -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="2"
    echo -e "     |>..........................................................................................................................................................................................<|"

    fi 

else

    echo -e "     |>..........................................................................................................................................................................................<|"
    echo -e "         Show core-dns runline"
    echo -e "     |>..........................................................................................................................................................................................<|"

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/playbook-library/\!_bootstrap/core-dns.yml \
        -e HOSTS="cloud-bind-frontend-dns" -u $username --become-user root \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="2"

    echo -e "     |>..........................................................................................................................................................................................<|"

fi


# SETUP DNS FRONTEND SERVICE TO IDS HOSTS

# function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
#     playbook-library/!_bootstrap/dns-frontend.yml \
#     -e HOSTS="cloud-bind-frontend-dns" -u $username --become-user root \
#     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'"

# SETUP DNS BACKEND SERVICE TO IDS HOSTS

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/\!_bootstrap/dns-backend.yml \
    -e HOSTS="master-bind-master-backend" -u $username --become-user root \
    --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="2" 

# Obtaining Certificates

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/\!_bootstrap/letsencrypt-pacemaker.yml \
    -e HOSTS="master-bind-master-backend" -u $username --become-user root \
    --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="3" \
    -e acme_domain_for_obtain="vortex.com"

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/\!_bootstrap/letsencrypt-pacemaker.yml \
    -e HOSTS="master-bind-master-backend" -u $username --become-user root \
    --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="4" \
    -e acme_domain_for_obtain="*.vortex.com" -e acme_domain_prefix_txt=""

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/\!_bootstrap/letsencrypt-pacemaker.yml \
    -e HOSTS="master-bind-master-backend" -u $username --become-user root \
    --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="5" \
    -e acme_domain_for_obtain="*.business.vortex.com" -e acme_domain_prefix_txt=""

# # SETUP IMMORTAL CHECKS BACKEND SERVICE TO ALL DNS HOSTS

# function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
#     playbook-library/cloud/immortal/immortal.yml \
#     -e DELEGATE_HOSTS="master-bind-master-backend" -u $username --become-user root \
#     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'"


### SWARM CLUSTERS >

# CREATE A DOCKER SWARM CLUSTER

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/cloud/swarm/swarm-cluster.yml \
    -e SWARM_MASTERS="swarm-cluster" \
    -u $username --become-user root --become -e "ansible_become_pass='$password'" \
    -e "ansible_ssh_pass='$password'" \
    -e leave_cluster="true" -e stage="2"

# CREATE A DOCKER DATABASE SWARM CLUSTER

# function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
#     playbook-library/cloud/swarm/swarm-cluster.yml \
#     -e SWARM_MASTERS="database-swarm-masters" -u $username --become-user root \
#     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" \
#     -e leave_cluster="true"

# # CREATE A DOCKER DATABASE SWARM CLUSTER

# function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
#     playbook-library/cloud/swarm/swarm-cluster.yml \
#     -e SWARM_MASTERS="database-swarm-masters" -u $username --become-user root \
#     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" \
#     -e leave_cluster="true"

# CREATE SENTRY SWARM CLUSTERS

# sentry-database-swarm-cluster

# function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
#     playbook-library/cloud/swarm/swarm-cluster.yml \
#     -e SWARM_MASTERS="sentry-database-swarm-cluster" -u $username --become-user root \
#     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" \
#     -e leave_cluster="true"

# sentry-cache-swarm-cluster

# function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
#     playbook-library/cloud/swarm/swarm-cluster.yml \
#     -e SWARM_MASTERS="sentry-cache-swarm-cluster" -u $username --become-user root \
#     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" \
#     -e leave_cluster="true"

# sentry-web-swarm-cluster

# function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
#     playbook-library/cloud/swarm/swarm-cluster.yml \
#     -e SWARM_MASTERS="sentry-web-swarm-cluster" -u $username --become-user root \
#     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" \
#     -e leave_cluster="true"

### SWARM CLUSTERS <

# BOOTSTRAP OR UPDATE PERCONA CLUSTER

# function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
#     playbook-library/database/percona-cluster.yml \
#     -e HOSTS="percona-cluster" \
#     -e bootstrap_cluster="true" \
#     -e clear_cluster="true" \
#     -u $username --become-user root  --become -e "ansible_become_pass='$password'" \
#     -e "ansible_ssh_pass='$password'"

# BOOTSTRAP OR UPDATE POSTGRES Sentry CLUSTER

# function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
#     playbook-library/database/postgres-cluster.yml \
#     -e HOSTS="sentry-postgres-cluster" \
#     -e bootstrap_cluster="true" \
#     -e clear_cluster="true" \
#     -u $username --become-user root  --become -e "ansible_become_pass='$password'" \
#     -e "ansible_ssh_pass='$password'"

# BOOTSTRAP RABBITMQ CLUSTER SERVICE

# function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
#     playbook-library/core_services/rabbitmq-docker-cluster.yml \
#     -e HOSTS="rabbitmq-cluster" -u $username --become-user root \
#     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'"

# ELASTIC SEARCH CLUSTER

# function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
#     playbook-library/database/elasticsearch-cluster.yml \
#     -e HOSTS="elasticsearch-cluster" -u $username --become-user root \
#     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'"

# REDIS DOCKER CLUSTER FOR SENTRY

# function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
#     playbook-library/database/redis-io-cluster.yml \
#     -e HOSTS="sentry-redis-io-cluster" -u $username --become-user root \
#     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'"

# NGINX FRONTEND ROLE

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/cloud/nginx/nginx-frontend-ng.yml \
    -e HOSTS="nginx-frontend" -u $username --become-user root  --become \
    -e "ansible_become_pass=$password" -e "ansible_ssh_pass=$password" -e stage="2"

#

# INSTALLING AUDITD & LOGROTATE CONFIGURATIONS

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/compliance/audit.yml \
    -u $username --become-user root \
    --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/\!_bootstrap/logrotate.yml \
    -u $username --become-user root \
    --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/system/pam_d-all.yml \
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

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/security/apt-mirror.yml \
        -u $username --become-user root -e HOSTS='all' \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"


# LOGGING CLUSTER AND VIEWER

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/logging/logging-kibana-service.yml \
        -u $username --become-user root \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/logging/logging-elasticsearch-cluster.yml \
        -u $username --become-user root \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

# FLUENTD PREPARE DIRS AND CONF

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/logging/fluentd-service.yml \
        -u $username --become-user root \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

# # ELASTICSEARCH PREPARE DIRS AND CONF

# function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
#     playbook-library/database/elasticsearch-stack.yml \
#     -e HOSTS="gitlab-server" -u $username --become-user root \
#     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

# WIP....

### END
last_info_show ${EXEC_TIMESTAMP}
#. ./scripts/libsh/end/end.sh ${EXEC_TIMESTAMP}