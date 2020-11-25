## HOW TO RUN DEPLOY JAVA MANUALY

`` ansible-playbook -i inventories/{{ TARGET_INVENTORY }} -e "HOSTS={{ HOSTS_TO_DEPLOY_SAME_WITH_APP_NAME }}" playbook-library/deploy-playbooks/java-manual.yml -u {{ YOUR_USER_NAME }} --ask-become-pass --become``

