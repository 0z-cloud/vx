OpenLDAP Example Playbook
=========================

```bash
ansible-playbook -i Inventory --ask-vault-pass
```

Passwords in this example are stored in an encrypted [Ansible Vault](http://docs.ansible.com/ansible/playbooks_vault.html). The password used in this example is: `ansible-vault-secret`

```bash
ansible-vault edit config-vault.yml
```

### Storing the Vault password
In case you don't want to enter the vault password every time you the playbook, consider storing it in clear-text among your playbook.

```bash
echo "config-vault-password.txt" >> .gitignore
echo -n "ansible-vault-secret" > config-vault-password.txt

# edit the vault with a password file
ansible-vault edit config-vault.yml --vault-password-file=config-vault-password.txt

# run the playbook with a password file
ansible-playbook -i Inventory --vault-password-file=config-vault-password.txt playbook.yml
```

Please make sure you never store a password in an Ansible Playbook :)

Seeding Data
------------

After executing the the role the example Playbook will seed some sample data and configure access control. The LDIF files used for that are stored in `./seed`.

It is important to skip existing entries when adding the seed data to keep the playbook idempotent
