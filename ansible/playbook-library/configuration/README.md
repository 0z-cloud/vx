## Configuration Playbooks

## laravel-app-install.yaml
# Для подготовки хоста к развертыванию на нём приложения laravel запустите следующую команду
ansible-playbook -u username -k -b -K playbook-library/configuration/laravel-app-install.yaml -i inventories/path/to/inventory -e "HOSTS=host_group" --ask-vault-pass --tags="install_apache2,enable_apache2_sites"