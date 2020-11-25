## Compliance Playbooks


### Deploy Apache2 ModSecurity
 
- > For deploy the apache2 mod_security you must to run:

```
 ansible-playbook -i inventories/vortex/production/ playbook-library/compliance/apache_modsecurity.yml --ask-become-pass -u vortex --become-user root --ask-pass --become --ask-vault-pass --extra-vars HOSTS="TARGET_HOSTNAME"
```