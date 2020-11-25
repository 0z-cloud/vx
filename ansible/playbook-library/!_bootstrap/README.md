## Bootstrap Readme


* For deploy ssh configuration and create users, run:

```bash
  ansible-playbook -i inventories/YOUR_ENVIRONMENT playbook-library/playbook-library/\!_bootstrap/ --ask-become-pass -u YOUR_USER_NAME --become-user root --ask-pass --become --ask-vault-pass
```
