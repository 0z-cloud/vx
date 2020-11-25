### Apache2 playbook ###

## Как использовать:
# Запустив команду ниже, вы увидите все допустимые теги, которые надо использовать для ПРАВИЛЬНОЙ работы этой плайбуки
ansible-playbook playbook-library/configuration/apache2.yml --list-tags

# Приведённая ниже команда выполнит установку Apache2, обновит конфиги по умолчанию, активирует дополнительные модули, активирует
# сайты по умолчанию, сгенерит кофиги для реальных сайтов, акивирует реальные сайты, подгрузит их ssl-сертификаты
# и перезагрузит сервис "systemctl reload apache2"
ansible-playbook -u username -k -b -K playbook-library/configuration/apache2.yml -i inventories/path/to/inventory -e "HOSTS=host_group" --ask-vault-pass --tags="install_apache2,enable_apache2_sites"

## Использование "tags"
# --tags="install_apache2"
# ТОЛЬКО выполнит установку Apache2, обновит конфиги по умолчанию, активирует дополнительные модули, активирует сайты по умолчанию
# и перезагрузит сервис "systemctl reload apache2"
ansible-playbook -u username -k -b -K playbook-library/configuration/apache2.yml -i inventories/path/to/inventory -e "HOSTS=host_group" --ask-vault-pass --tags="install_apache2"

# --tags="enable_apache2_sites"
# ТОЛЬКО сгенерит кофиги, активирует и подгрузит ssl-сертификаты сайтов
# и перезагрузит сервис "systemctl reload apache2"
ansible-playbook -u username -k -b -K playbook-library/configuration/apache2.yml -i inventories/path/to/inventory -e "HOSTS=host_group" --ask-vault-pass --tags="enable_apache2_sites"

# --tags="disable_apache2_sites"
# ТОЛЬКО деакивирует сайты
# и перезагрузит сервис "systemctl reload apache2"
ansible-playbook -u username -k -b -K playbook-library/configuration/apache2.yml -i inventories/path/to/inventory -e "HOSTS=host_group" --ask-vault-pass --tags="disable_apache2_sites"

# --tags="enable_apache2_mods"
# ТОЛЬКО активирует дополнительные модули
# и перезапустит сервис "systemctl restart apache2"
ansible-playbook -u username -k -b -K playbook-library/configuration/apache2.yml -i inventories/path/to/inventory -e "HOSTS=host_group" --ask-vault-pass --tags="enable_apache2_mods"

# --tags="disable_apache2_mods"
# ТОЛЬКО деактивирует дополнительные модули
# и перезапустит сервис "systemctl restart apache2"
ansible-playbook -u username -k -b -K playbook-library/configuration/apache2.yml -i inventories/path/to/inventory -e "HOSTS=host_group" --ask-vault-pass --tags="disable_apache2_mods"

## Для правильной работы плейбуки нужны следующие параметры:
# перечень пакетов, который будут установлены (используется)
apt_install_packages:
  - apache2
  - apache2-bin
  - apache2-data
  - apache2-utils
  - libapache2-mod-security2

# модули, которые будут включены дополнительно к тем, что по умолчанию
enable_apache2_mods:
  - headers
  - rewrite
  - ssl

# модули, которые надо отключить
disable_apache2_mods:
  - security2

# список конфигов, который заменят те, что по умолчанию
update_apache2_default_confs:
  - { src: 'apache2.conf.j2', dest: '/etc/apache2/apache2.conf' }
  - { src: '000-default.conf.j2', dest: '/etc/apache2/sites-available/000-default.conf' }
  - { src: 'default-ssl.conf.j2', dest: '/etc/apache2/sites-available/default-ssl.conf' }

# список сайтов, которые активируются по умолчанию (имена конфигов должны быть именно такими)
enable_apache2_default_sites:
  - 000-default
  - 000-default-ssl

## Если у нас на всех хостах одинаковая конфигурация Apache2, то всё выше описанное добавляем в
## inventory/all.yaml.
##
## Следующие параметры нужно добавить в group_vars или host_vars:

# это ServerName по умолчанию (используется IP)
apache2_default_servername: "{{ ansible_host }}"

# Список сайтов, которые будут сконфигурированы на хосте
# appname - название проекта, которое используется в построении пути DocumentRoot
# name - имя сайта (www)
# domain - имя домена (example.ru)
# ssl-key - имя файла приватного ключа сертификата
# ssl-crt - имя файла сертивиката
# Если ключ/сертификат не указаны, то используются самоподписанные ключ/сертификат на хосте
# Ключ и сертификат нужно разместить в playbook-library/configuration/certs (не забудьте ЗАШИФРОВАТЬ!!!)
# ssl-port - номер порта для https, если он не 443
enable_apache2_sites:
  - { appname: "dashkit", name: "test01", domain: "example.ru", ssl-key: "", ssl-crt: "", ssl-port: "" }
  - { appname: "dashkit", name: "test02", domain: "example.ru", ssl-key: "filename.key", ssl-crt: "filename.pem", ssl-port: "" }

# Список сайтов на отключение
disable_apache2_sites:
  - { name: "test01", domain: "example.ru" }
  - { name: "test05", domain: "example.ru" }