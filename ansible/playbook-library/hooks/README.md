## Hooks Playbooks

- > Hooks Playbooks library documentation for able to automation the basic and difficult admin tasks.

## For fetch IDS rules to local temp folder you must use as template for run:


```bash
ansible-playbook -i inventories/{{ ENV }} playbook-library/hooks/fetch-ids-rules.yml --ask-become-pass -u {{ username }} --become-user root --ask-pass --become --ask-vault-pass
```

##  For fetch SQL Reports from SQL Slave to local temp folder you must use as template for run:

```bash
 ansible-playbook -i inventories/{{ ENV }} playbook-library/hooks/fetch-sql-reports.yml --ask-become-pass -u {{ username }} --become-user root --ask-pass --become --ask-vault-pass
```