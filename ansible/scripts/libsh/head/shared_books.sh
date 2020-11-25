#!/bin/bash
runpath=$1
ansible_dir=$2

echo -e "     ${GREEN}Currnet Filename: head/shared_books.sh${NC}"
echo -e "     ${GREEN}Running root Path: $runpath${NC}"
echo -e "     ${GREEN}Ansible Directory: $ansible_dir${NC}"

# Run the init playbooks clean cloud init 

#. "$ansible_dir"/scripts/libsh/deploy/head.sh

echo -e "     |>...........................................................................................................................................................................................................<|"

echo -e "     ${On_IBlue}|>=======================================================================================================================================================<|${NC}"
echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
echo -e "       Run the ${RED}afterinstall.yml${NC} playbook for all hosts, for install ${RED}necessary${NC} system packages"
echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
echo -e "     ${On_IBlue}|>=======================================================================================================================================================<|${NC}"

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/playbook-library/\!_0_init/afterinstall.yml \
        -u $username --become-user root \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

echo -e "     |>...........................................................................................................................................................................................................<|"

echo -e "     ${On_IBlue}|>=======================================================================================================================================================<|${NC}"
echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
echo -e "       Run the ${RED}sudoers.yml${NC} playbook for all hosts, for change ${RED}sudoers${NC} system configuration"
echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
echo -e "     ${On_IBlue}|>=======================================================================================================================================================<|${NC}"

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/playbook-library/\!_0_init/sudoers.yml \
        -u $username --become-user root \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"
