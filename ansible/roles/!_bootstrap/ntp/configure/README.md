## NTP Configure for inventory

- > Your IDS must have ``` ids_server="true" ``` in server object vars
- > You can run role on IDS or All other hosts, not both in same time.
- > You mast provide the extra-vars with HOSTS variable which contents destination of deploy, by default group is 
- > Inline of run ansible-playbook you must write your login username by replacing field of example - ``` %write_this_your_login_username% ```
- > For running playbook use as examples:

```
Running on only one host vortex-ids-01 as example:

ansible-playbook -i inventories/production-vortex/ playbook-library/services/ntp-service.yml --ask-become-pass -u %write_this_your_login_username% --become-user root --ask-pass --become --ask-vault-pass --extra-vars HOSTS="vortex-ids-01"
```


```
Running on group tomcat-servers as example:

ansible-playbook -i inventories/production-vortex/ playbook-library/services/ntp-service.yml --ask-become-pass -u %write_this_your_login_username% --become-user root --ask-pass --become --ask-vault-pass --extra-vars HOSTS="tomcat-servers"

```
