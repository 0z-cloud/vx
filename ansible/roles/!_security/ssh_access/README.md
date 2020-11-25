Role Name
=========

Configure ssh access to servers / change passwords

# Need to know

- > if you use not defaults RSA keys, when you perform copy the ssh-keys to remote server for future simple login, sometimes you need to forcibly use:

```bash
ssh-copy-id -f -i .ssh/id_ed25519.pub 10.91.90.95
```

- > Where .ssh/id_ed25519.pub its a your public key

# Change password role

## Important for change password

- > if you sse on run the playbook - ERROR! passlib must be installed to encrypt vars_prompt values - you must to install passlib:

``pip3 install passlib``

## How to run change password

- > Select hosts when you want to update your password and provide group_name or host_name to ``` HOSTS ``` extra variable, as example 

``` for one host_name only: vortex-admin-01 ```

``` foe group_name write: web-servers/vortex-after-bastion/etc ```

- > Provide your connection username in ``` YOUR_USERNAME ``` position

- > Provide the inventory name when you want to execute the playbook in position ``` {{ RUNNING_INVENTORY }} ```

``` ansible-playbook -i inventories/{{ RUNNING_INVENOTORY }}/ ./playbook-library/configuration/ssh-change-pass.yml --extra-vars HOSTS="{{ hosts_when_you_want_to_change_password }}" --ask-become-pass -u {{ YOUR_USERNAME }} --become-user root --ask-pass --become --ask-vault-pass ```

- > Run the result ansible-playbook command, provide your current ssh password, vault pass if needed, and new password for update your account.