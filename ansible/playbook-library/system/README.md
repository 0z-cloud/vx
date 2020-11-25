## System Playbooks

- > System Playbooks library documentation for able to automation the basic and difficult admin tasks.

## For change passwords on some hosts you must use as template for run:

```bash
 ansible-playbook -i inventories/{{ ENV }}/ playbook-library/system/ssh-change-pass.yml --ask-become-pass -u {{ username }} --become-user root --ask-pass --become --ask-vault-pass --extra-vars HOSTS="{{ HOSTS_OR_GROUP_TO_PLAY }}"
```

## For change passwords on some hosts you must use as example for run:

```bash
 ansible-playbook -i inventories/{{ ENV }}/ playbook-library/system/ssh-change-pass.yml --ask-become-pass -u vortex --become-user root --ask-pass --become --ask-vault-pass --extra-vars HOSTS="vortex-after-bastion"
```