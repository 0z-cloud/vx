## Deploy Playbooks

- Deploy playbooks library documentation

## JAVA MANUAL BASIC (FULL DEPLOY)

- For most cases run use as example a string:

```
ansible-playbook -i inventories/vortex/production/ playbook-library/deploy/java-manual.yml -e HOSTS="TARGET_GROUP_HOSTS" --ask-become-pass -u MY_SUPER_USERNAME --become-user root --ask-pass --become --ask-vault-pass -e P_GITLAB_TOKEN="SUperPrivateTokkenfromGITLabCIserver" -e P_GITLAB_JOB="77777"
```

## JAVA MANUAL CONFIGURATION UPDATE ONLY (WITHOUT DEPLOY)

- For configuration-update cases use this example string:
- To get application CURRENT_RELEASE folder, please use the following example: ls -la /var/lib/tomcat11/webapps/ | grep "APPLICATION"

```
ansible-playbook -i inventories/vortex/production/ playbook-library/deploy/java-manual.yml --ask-become-pass -u MY_SUPER_USERNAME --become-user root --ask-pass --become --ask-vault-pass --extra-vars HOSTS="TARGET_GROUP_HOSTS" -e P_GITLAB_JOB="77777" -e P_GITLAB_TOKEN="SUperPrivateTokkenfromGITLabCIserver" -e configuration_update_only="1" -e RELEASE_DIRECTORY="/java_core/webapps/APPLICATION/releases/CURRENT_RELEASE"
```

## JAVA DEPLOY - PREVENT TOMACT STARTUP

- WARNING!!! Please use with ``` --limit 'vortex-tomcat-{id},java-keepalived-drain-target-java' ``` to run on only one host not in group!

- For serial deploy step by step use as example:

```
first for vortex-tomcat-01:

ansible-playbook -i inventories/vortex/production/ playbook-library/deploy/java-manual.yml -e HOSTS="TARGET_GROUP_HOSTS" --ask-become-pass -u MY_SUPER_USERNAME --become-user root --ask-pass --become --ask-vault-pass -e P_GITLAB_TOKEN="SUperPrivateTokkenfromGITLabCIserver" -e P_GITLAB_JOB="77777" --limit 'vortex-vortex-tomcat-01,java-keepalived-drain-target-java'

second for vortex-tomcat-02:

ansible-playbook -i inventories/vortex/production/ playbook-library/deploy/java-manual.yml -e HOSTS="TARGET_GROUP_HOSTS" --ask-become-pass -u MY_SUPER_USERNAME --become-user root --ask-pass --become --ask-vault-pass -e P_GITLAB_TOKEN="SUperPrivateTokkenfromGITLabCIserver" -e P_GITLAB_JOB="77777" --limit 'vortex-vortex-tomcat-02,java-keepalived-drain-target-java'

```

- To prevent TOMCAT startup add NOT_STARTUP="true" to ansible-playbook command

```
ansible-playbook -i inventories/vortex/production/ playbook-library/deploy/java-manual.yml -e HOSTS="TARGET_GROUP_HOSTS" --ask-become-pass -u MY_SUPER_USERNAME --become-user root --ask-pass --become --ask-vault-pass -e P_GITLAB_TOKEN="SUperPrivateTokkenfromGITLabCIserver" -e P_GITLAB_JOB="77777" -e NOT_STARTUP="true" 
```

```
Examine presented in example used variables:

MY_SUPER_USERNAME is yours login username for connection to hosts for deploy

P_GITLAB_JOB (as example used 77777) is a GITLAB JOB ID FROM YOUR BUILD PIPELINE

P_GITLAB_TOKEN is a your private access token for fetch release contents

TARGET_GROUP_HOSTS (as example processing-bin-bank) is an a example target group hosts for deploy the application. See you inventory file and group_vars/java/{{ hosts_group }} contents.

configuration_update_only when this variable is present, will change only configs and certs in release
```

##Examples

```bash
ansible-playbook playbook-library/deploy/laravel.yml -i inventories/vortex/production -e "HOSTS=vortex-financial-reports" --ask-vault-pass -u {{ USERNAME }} --ask-sudo-pass --ask-pass --become-user root --become --ask-become-pass
```

```bash
ansible-playbook playbook-library/deploy/laravel.yml -i inventories/vortex/production -e "HOSTS=vortex-botman-service" --ask-vault-pass -u vortex --ask-sudo-pass --ask-pass --become-user root --become --ask-become-pass
```