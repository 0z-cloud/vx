# README

### ==========          keepalive_deploy.yml            ========== ###
Описание работы и команд для использования keepalive_deploy.yml

По умолчанию, плайбука производит следующие действия:
1.  устанавливает пакет iptables-persistent, который нужен для сохранения правил iptables
2.  отключаем возможность запуска скрипта /usr/share/netfilter-persistent/plugins.d/25-ip6tables, который уставливается с пакетом
    iptables-persistent и его задача сохраниять правила iptables для ipv6, который у нас отключен в /etc/default/grub
3.  устанавливает пакет keepalived
4.  создаёт пустой конфигурационный файл /etc/keepalived/keepalived.conf, если его нет
5.  создаёт дирректорию /wrk/keepalived для хранения резервных копий /etc/keepalived/keepalived.conf при их обновлении
6.  делает резервную копию файла /etc/keepalived/keepalived.conf в дирректорию /wrk/keepalived
7.  генерит конфиграционный файл на основе шаблона
8.  добавляет в iptables правила, разрешающее VRRP
9.  добавляет правила NAT для сервисов, которые обслуживает keepalive
10. сохраняет правила iptable, для применения их после перезагрузки системы
11. добавляет в /etc/sysctl.conf параметр net.ipv4.ip_nonlocal_bind=1, необходимый для работы keepalived и применяет его
12. перезапускает службу keepalived для применения нового конфигурационного файла и выводит статус службы

Команда запуска по умолчанию:
ansible-playbook playbook-library/network/keepalive_deploy.yml -u USER_NAME -k -b -K -i inventories/vortex/develop/inventory

В плайбуке используются "Теги", т.ч. можно запускать конкретные части её.

Только инсталляция пакета iptables-persistent:
ansible-playbook playbook-library/network/keepalive_deploy.yml -u USER_NAME -k -b -K -i inventories/vortex/develop/inventory --tags "install_iptables_persistent"

Только инсталляция пакета keepalived:
ansible-playbook playbook-library/network/keepalive_deploy.yml -u USER_NAME -k -b -K -i inventories/vortex/develop/inventory --tags "install_keepalived"

Только генерация и обновление конфигурационного файла /etc/keepalived/keepalived.conf:
ansible-playbook playbook-library/network/keepalive_deploy.yml -u USER_NAME -k -b -K -i inventories/vortex/develop/inventory --tags "gen_keepalived_conf"

Только добавление iptables правил, разрешающих VRRP и сохранение правил для применения после перезагрузки системы:
ansible-playbook playbook-library/network/keepalive_deploy.yml -u USER_NAME -k -b -K -i inventories/vortex/develop/inventory --tags "add_vrrp_iptables_rules"

Только добавление iptables правил включения NAT для сервисов, которые обслуживает keepalive:
ansible-playbook playbook-library/network/keepalive_deploy.yml -u USER_NAME -k -b -K -i inventories/vortex/develop/inventory --tags "add_nat_for_backend_servers"

Только сохранение iptables правил для применения их после перезагрузки системы:
ansible-playbook playbook-library/network/keepalive_deploy.yml -u USER_NAME -k -b -K -i inventories/vortex/develop/inventory --tags "iptable_rules_save"

Только добавление в /etc/sysctl.conf параметров net.ipv4.ip_nonlocal_bind=1, net.ipv4.ip_forward=1 и их применение:
ansible-playbook playbook-library/network/keepalive_deploy.yml -u USER_NAME -k -b -K -i inventories/vortex/develop/inventory --tags "add_sysctl_options"

Только перезагрузка сервиса keepalived:
ansible-playbook playbook-library/network/keepalive_deploy.yml -u USER_NAME -k -b -K -i inventories/vortex/develop/inventory --tags "reload_keelapived"

Только просмотр статуса службы keepalived:
ansible-playbook playbook-library/network/keepalive_deploy.yml -u USER_NAME -k -b -K -i inventories/vortex/develop/inventory --tags "status_keepalived"
### ==========          keepalive_deploy.yml            ========== ###