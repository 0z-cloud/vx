### Own CI Cloud 

## CI Products Application Group_Vars same root for shared environments by Products contract

- ``` ./CI/products/{{ ansible_product }}/{{ ansible_environment }}/group_vars/.. ```

## For setup you local/test/stage enviroment sandbox and able test Infrastructure and Software installations with ansible.

-  ``` !!! ITS REMOVE ALL YOU SANDBOX DATA !!! ```

- For Re-initialization your cloud sandbox try run

*  ``` ./RE_init_cloud.sh ```

## For running some ansible playbooks to your sandbox, you must go

* ``` cd {{ repository_path }}/CI/ansible_cloud/ ```

## Then you can run all like in example below

* ``` ansible -m setup -i inventories/.cloud all ```

* ``` ansible-playbook -i inventories/.cloud playbook-library/{{ some_playbook }} ```