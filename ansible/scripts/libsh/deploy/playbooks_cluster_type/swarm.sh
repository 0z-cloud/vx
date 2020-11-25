#!/bin/bash
runpath=$1
ansible_dir=$2

echo -e "     ${GREEN}Currnet Filename: deploy/swarm.sh${NC}"
echo -e "     ${GREEN}Running root Path: $runpath${NC}"
echo -e "     ${GREEN}Ansible Directory: $ansible_dir${NC}"

cd ${ansible_dir}

# source ../.tmp_bus.yml
# source ../tmp_bus.yml

# --vault-password-file /volume/pass.yml

# # CHECK HOSTS FOR PLACE GITLAB AND DOCKER REGISTRY TO ITSELF

# function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/production/ \
#     "$ansible_dir"/playbook-library/hooks/hosts_feel_gitlab.yml \
#     -e HOSTS="nginx-frontend" -u $username --become-user root \
#     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"
 
# echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

# ELASTICSEARCH PREPARE DIRS AND CONF

# function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
#     "$ansible_dir"/playbook-library/database/elasticsearch-stack.yml \
#     -e HOSTS="gitlab-server" -u $username --become-user root \
#     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"
 
# echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

#
echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

echo -e "       CURRENT ENVIRONMENT TYPE OF SECURITY IS: $deploy_environment_security_configuration"
echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

#sleep 10

# Run the apt_install.yml playbook for all hosts

echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
echo -e "       Run the ${RED}apt_install.yml${NC} playbook for all hosts, for install ${RED}necessary${NC} system packages"
echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        "$ansible_dir"/playbook-library/\\!_bootstrap/apt_install.yml \
        -u $username --become-user root \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

if [ $deploy_environment_security_configuration == 'pci' ]; then

    echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
    echo "          Perform PCI DSS pipeline"
    echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

    # Deploy the docker-stack.yml from template on target database cluster

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        "$ansible_dir"/playbook-library/\\!_A_Deploy_pipeline/docker-stack-deploy-playbook_pci_database.yml \
        -u $username --become-user root --become -e HOSTS="postgres-database" \
        -e "ansible_become_pass=$password" -e "ansible_ssh_pass=$password" -e stage="docker-stack-deploy" -e version_ansible_build_id="${version_ansible_build_id}" -e "@../.local/current_tags.yml"

    echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

    # INIT ALL DATABASES 

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/hooks/init_dbs_pci.yml \
            -e HOSTS="postgres-database[0]" -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

    echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

    # Deploy the docker-stack.yml from template on target application cluster

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        "$ansible_dir"/playbook-library/\\!_A_Deploy_pipeline/docker-stack-deploy-playbook_pci_front.yml \
        -u $username --become-user root --become -e HOSTS="cloud-bind-frontend-dns" \
        -e "ansible_become_pass=$password" -e "ansible_ssh_pass=$password" -e stage="docker-stack-deploy" -e version_ansible_build_id="${version_ansible_build_id}" -e "@../.local/current_tags.yml"

    echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

    # @ PERFORM MIGRATIONS

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/hooks/init_mig_pci.yml \
            -e HOSTS="nginx-frontend[0]" -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

    echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

    # Deploy the docker-vpn-stack.yml from template on target application cluster

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        "$ansible_dir"/playbook-library/\\!_A_Deploy_pipeline/docker-stack-deploy-playbook_pci_vpn.yml \
        -u $username --become-user root --become -e HOSTS="pritunl-stack" \
        -e "ansible_become_pass=$password" -e "ansible_ssh_pass=$password" -e stage="docker-stack-deploy" -e version_ansible_build_id="${version_ansible_build_id}" -e "@../.local/current_tags.yml"

    echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

    # INSTALLING PCI FEATURES AND CONFIGURATIONS

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        "$ansible_dir"/playbook-library/compliance/audit.yml \
        -u $username --become-user root \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        "$ansible_dir"/playbook-library/\\!_bootstrap/logrotate.yml \
        -u $username --become-user root \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        "$ansible_dir"/playbook-library/system/pam_d-all.yml \
        -u $username --become-user root \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

    # FLUENTD PREPARE DIRS AND CONF

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        "$ansible_dir"/playbook-library/logging/fluentd-service.yml \
        -e HOSTS="nginx-frontend" -u $username --become-user root \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

    echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

else 

    if [ $deploy_environment_security_configuration == 'minimal' ]; then

        echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
        echo "              Perform Minimal Security Configuration Environment Deploy Pipeline"
        echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

        # Deploy the docker-stack.yml from template on target application cluster

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/\\!_A_Deploy_pipeline/docker-stack-deploy-playbook.yml \
            -u $username --become-user root --become -e HOSTS="cloud-bind-frontend-dns" \
            -e "ansible_become_pass=$password" -e "ansible_ssh_pass=$password" -e stage="docker-stack-deploy" -e version_ansible_build_id="${version_ansible_build_id}" -e "@../.local/current_tags.yml"

        echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

        # # INIT ALL DATABASES AND PERFORM MIGRATIONS

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/hooks/init_dbs_all.yml \
            -e HOSTS="nginx-frontend[0]" -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

        # echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

        # INIT MONGO DB

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/hooks/init_db_mongo.yml \
            -e HOSTS="nginx-frontend[0]" -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

        echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

        # INIT FLEXY GUARD DBs

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/hooks/init_db_flexy_guard.yml \
            -e HOSTS="nginx-frontend[0]" -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"
        
        echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

        # FLUENTD PREPARE DIRS AND CONF

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/logging/fluentd-service.yml \
            -e HOSTS="nginx-frontend" -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

        echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
    
    fi

fi