#!/bin/bash

echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

anycloud_ci_cd_vcs_project_checkout_service_auth_identity_pass_or_token="${anycloud_ci_cd_vcs_project_checkout_service_auth_identity_pass_or_token}"

echo $anycloud_ci_cd_vcs_project_checkout_service_auth_identity_pass_or_token

echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
echo -e "         ${RED}CI Job ID${NC}: ${CI_JOB_ID}"
echo -e "         ${RED}CI Pipeline ID${NC}: ${CI_PIPELINE_ID}"
CI_ANSIBLE_ENVIRONMENT=$inventory
echo -e "         ${RED}CI Ansible Environment${NC}: ${CI_ANSIBLE_ENVIRONMENT}"
echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

echo -e "     ${RED}|>..........................................................................................................................................................................................<|${NC}"
echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
echo -e "     ${GREEN}|>.... WARM UP! =)...<|${NC}"
echo -e "     ${GREEN}|>.... HELLO.!! =)..........................................................................................................................................<|${NC}"
echo -e "     ${RED}|>....................................................................................................................................................<|${NC}"
echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
echo -e "     ${RED}|>... UPDATE NGINX & DNS BACKEND .................................................................................................................................................<|${NC}"
echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"


# NTP ROLE

function_selector_runner ansible-playbook -i inventories/products/$product/$inventory/ \
    playbook-library/services/ntp-service.yml \
    -e HOSTS="all" -u $username --become-user root  --become \
    -e "ansible_become_pass=$password" -e "ansible_ssh_pass=$password" -e stage="2"

# INSTALL GRAFANA ALERTMANAGER PROMETHEUS

function_selector_runner ansible-playbook -i inventories/products/$product/$inventory/ \
    playbook-library/services/monitoring.yml \
    -e HOSTS="all" -u $username --become-user root \
    --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="2"

# NGINX FRONTEND ROLE

function_selector_runner ansible-playbook -i inventories/products/$product/$inventory/ \
    playbook-library/cloud/nginx/nginx-frontend-ng.yml \
    -e HOSTS="nginx-frontend" -u $username --become-user root  --become \
    -e "ansible_become_pass=$password" -e "ansible_ssh_pass=$password" -e stage="2"

echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

# UPDATE DNS BACKEND SERVICE TO IDS HOSTS

function_selector_runner ansible-playbook -i inventories/products/$product/$inventory/ \
    playbook-library/!_bootstrap/dns-backend.yml \
    -e HOSTS="master-bind-master-backend" -u $username --become-user root \
    --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="2"

echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

# WAZUH STACK INSTALL

# function_selector_runner ansible-playbook -i inventories/products/$product/$inventory/ \
#     playbook-library/services/wazuh.yml \
#     -e HOSTS="all:wazuh-manager:wazuh-agent:wazuh-elasticsearch:wazuh-kibana" -u $username --become-user root \
#     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="2" \
#     -e acme_domain_for_obtain="vortex.com" -e acme_domain_prefix_txt=""

echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

# SECURITY APPS INSTALL

# function_selector_runner ansible-playbook -i inventories/products/$product/$inventory/ \
#     docker-stack-deploy-playbook_pci_security-apps.yml \
#     -u $username --become-user root --become -e HOSTS="security-apps" \
#     -e "ansible_become_pass=$password" -e "ansible_ssh_pass=$password" -e stage="docker-stack-deploy" -e version_ansible_build_id="${version_ansible_build_id}" -e "@../.local/current_tags.yml"

echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"


echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
echo -e "     ${RED}|>... UPDATE NGINX & DNS BACKEND .................................................................................................................................................<|${NC}"
echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
