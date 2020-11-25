# You must write readme here

## Important info about process of update -

- > when you want to replace your wildcard certificate for multiple services which use that, you must to provide old certificate name and new certificate name.

```
old_ssl_certificate: "/etc/{{ webserver }}/ssl/vortex.io_2017.01.16-2018.03.18"
new_ssl_certificate: "/etc/{{ webserver }}/ssl/vortex.io_2018.03.12-2019.03.13"

```

- > Values must be updated in inventory group_vars
- > You must place new cert and key with support currently directory structure to success pass playbook run:

```

roles 
    /-|
    |-/ certificate_update 
          /-|
          |-/ files 
                /-|
                |-/ {{ ansible_product }} 
                        /-|
                        |-/ {{ certificate_year }} 
                                /-|
                                |-/ {{ certificate_name }}.pem
                                |
                                |-/ {{ certificate_name }}.key
                                                

```

- > You must to encrypt new certificates and private keys before push to master!!!

## As example runline for run ansible playbook -

```

 ansible-playbook -i inventories/vortex/asgard/ playbook-library/security/certificate_upload.yml --ask-pass \
    --ask-sudo-pass --limit '!p2p-webservers' --ask-vault-pass

```