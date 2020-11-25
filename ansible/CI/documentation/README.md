### Running the playbooks on PCI Inventories

* You must to run playbook with sudo login and password, for able to deploy/check/configuring something like in example below:

```bash
  ansible-playbook -i inventories/develop-vortex/ playbook-library/compliance/tomcat-compliance.yml --ask-sudo-pass -u  YOUR_USER_NAME --become-user YOUR_USER_NAME --ask-pass 
```

* For running something playbooks or roles you must have a root access to exec a commands, as example use become-user root:

```bash
  --ask-become-pass -u YOUR_USER_NAME --become-user root --ask-pass --become 
```

```bash
 ansible-playbook playbook-library/template/test.yml -i inventories/develop-vortex/ --ask-become-pass -u YOUR_USER_NAME --become-user root --ask-pass --become 
```

* for deploy alienvaut-watchdog.yml

```bash
  ansible-playbook -i inventories/vortex/production/ playbook-library/scripts/alienvaut-watchdog.yml --ask-become-pass -u YOUR_USER_NAME --become-user root --ask-pass --become --ask-vault-pass
```

* for deploy vortex-database-watchdog.yml

```bash
  ansible-playbook -i inventories/vortex/production/ playbook-library/scripts/vortex-database-watchdog.yml --ask-become-pass -u YOUR_USER_NAME --become-user root --ask-pass --become --ask-vault-pass
```

* for deploy pansearch script

```bash
  ansible-playbook -i inventories/vortex/production/ playbook-library/configuration/pansearch.yml --ask-become-pass -u YOUR_USER_NAME --become-user root --ask-pass --become --ask-vault-pass
```

## Deploying the selfhosted applications

* As example deploy mobicom application to HOSTS='vortex-mobicom-01':

```bash
  ansible-playbook -i inventories/vortex/production/ playbook-library/deploy/laravel.yml --ask-become-pass -u YOUR_USER_NAME --become-user root --ask-pass --become --ask-vault-pass --extra-vars HOSTS="vortex-mobicom-01"
```


## Running playbooks on non PCI Inventories in most cases:

```bash
git clone git@172.16.31.110:foundation/ansible.git
ansible-galaxy install -r requirements.yml
```

## Deploying some package from GitLab example, see whole a playbook code for understanding what and on a which you run a tasks:

```bash
ansible-playbook deploy.yml -i inventories/*** -u *** --ask-vault-pass
```

## For deploy the ossec-agent role use as example:

```bash
 ansible-playbook -i inventories/vortex/production/ playbook-library/configuration/ossec-agent.yml --ask-become-pass -u YOUR_USER_NAME --become-user root --ask-pass --become --ask-vault-pass
```

* You can run playbook with limit hosts - when limit setted playbook deploy only to limit host not for all hosts, just add to ansible-playbook command line:

```bash
--limit vortex-proxy-payments-gateway-01 
```

## Port forwards

* You can connect to internal services in inventory via port forward via ssh needed PCI web service, such as like OSSIM, SWITCH, NAGIOS, etc - see a document:

- > [port_forward ](port_forward/README.md)

## Specific runs for admins and security officer:

- > Security Officer or CIO ansible exclude param ``--limit '!linux-hosts:vortex-dns-01:vortex-rsyslog-01:vortex-ossim-01'``

- > DevOps/Admin/SRE ansible exclude param ``--limit 'linux-hosts:!vortex-dns-01:!vortex-rsyslog-01:!vortex-ossim-01'``

## For deploy mysql-proxy-run for some server or server group as example run:


* Your host/hostgroup object must have a mysql_proxy_backend_address in your inventory:

```
mysql_proxy_backend_address="10.2.0.210"
```

* Playbook run string:

```bash
 ansible-playbook -i inventories/vortex/production/ playbook-library/configuration/mysql-proxy.yml --ask-become-pass -u YOUR_USER_NAME --become-user root --ask-pass --become --ask-vault-pass -e HOSTS="SOME_HOST_OR_GROUP_FOR_DEPLOY"
```

- > DevOps/Admin/SRE ansible exclude param ``--limit 'linux-hosts:!vortex-dns-01:!vortex-rsyslog-01:!vortex-ossim-01'``