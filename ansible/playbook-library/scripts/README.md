## Script Playbooks

- > Script Playbooks library documentation for able to automation the basic and difficult admin tasks.

## For deploy database Sensetive Data Protection stored passwords on some hosts you must use as template for run:

```bash
 ansible-playbook -i inventories/{{ ENV }}/ playbook-library/scripts/vortex-database-watchdog.yml --ask-become-pass -u {{ username }} --become-user root --ask-pass --become --ask-vault-pass --extra-vars HOSTS="{{ HOSTS_OR_GROUP_TO_PLAY }}"
```

## For deploy database Sensetive Data Protection stored passwords on all hosts you must use as template for run:

```bash
 ansible-playbook -i inventories/{{ ENV }}/ playbook-library/scripts/vortex-database-watchdog.yml --ask-become-pass -u {{ username }} --become-user root --ask-pass --become --ask-vault-pass 
```

## For deploy Pansearcher Watcher on all hosts you must use as template for run:

```bash
 ansible-playbook -i inventories/{{ ENV }}/ playbook-library/scripts/pansearch.yml --ask-become-pass -u {{ username }} --become-user root --ask-pass --become --ask-vault-pass 
```

## For deploy clamav on some hosts you must use as template for run:

```bash
 ansible-playbook -i inventories/{{ ENV }}/ playbook-library/scripts/clamav-all.yml --ask-become-pass -u {{ username }} --become-user root --ask-pass --become --ask-vault-pass --extra-vars HOSTS="all"
```