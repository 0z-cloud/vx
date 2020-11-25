# Intro

    Welcome to new era of Microservice Multicloud Adaptive Payment Opensource Platform which compliant PCI DSS as SaaS product.


## How to create a new little cloud from scratch

* Requirements:

    1. New domain or subdomain which ready to be placed a cloud nameservers which we bootstrap.
    2. Alicloud / Vsphere infrastructure.
    3. Complete fill requirement settings in inventories which need for bootstrap.
    4. Install ansible alicloud modules via pip, - ```{{ ansible_root }}/requirements.yml```

* Pre defined information:

    1. We have two types of inventories - 

        I. Dynamic ```bootstrap inventory``` prefilled for create the instances - 

        ```inventories/0z-cloud/products```.

        II. Target Inventory after ```bootstrap inventory``` which contains settings needed after bootstrap the instances - 

        ```inventories/products```.

    2. We have types of clouds backends ```{{ cloud_type }}```, now its:

        * alicloud

        * vsphere

        * do (digitalocean)

        * azure

        * aws

        * bare (baremethal)

        * google

    3. We have a ```products``` which have a environments ```{{ ansible_environment }}```, like ``` develop/stage/production ```.

    4. We have three types and places for ```group_vars```, - spaces which contain main or specific hosts groups settings.

        I. Root variables:

        ```{{ ansible_root }}/group_vars``` and ```{{ ansible_root }}/group_vars/products/{{ product_name }}```

        II. Cloud bootstrap variables, which needed for initial create the cloud instances:

        ```{{ ansible_root }}/inventories/0z-cloud/products/{{ cloud_type }}/{{ product_name }}/{{ ansible_environment }}/bootstrap_vms/group_vars/all.yml```

        III. Variables in ```Target Inventory``` needed for run playbooks after creation the cloud instances:

        ```{{ ansible_root }}/inventories/products/{{ product_name }}/{{ ansible_environment }}/group_vars```

* Fill the access keys from example, for able project ```in run setup``` access to your cloud infrastructure:

    * Becareful - you need prevent sensetive security data from push to repository, you must add them to ```.gitignore```

    * For ``` alicloud ``` move ```{{ ansible_root }}/group_vars/products/{{ product_name }}/alicloud.yml.example``` to ```{{ ansible_root }}/group_vars/products/{{ product_name }}/alicloud.yml```
      and fill settings getted from alicloud console.

    * For ``` vsphere ```  move ```{{ ansible_root }}/group_vars/products/{{ product_name }}/vsphere.yml.example``` to ```{{ ansible_root }}/group_vars/products/{{ product_name }}/vsphere.yml```
      and fill settings getted from vsphere console.

    * For main settings move ```{{ ansible_root }}/group_vars/products/{{ product_name }}/main.yml.example``` to ```{{ ansible_root }}/group_vars/products/{{ product_name }}/main.yml```
      and fill extra settings.

    * You can dynamicly attach some specific dictionaries with settings in !_root_playbooks for some type of cloud:


          - name: Load groupvars/product global shared settings
            include_vars: group_vars/products/{{ ansible_product }}/{{ item }}.yml
            with_items:
                - vsphere
                - main

          - name: Load groupvars/product global shared settings
            include_vars: group_vars/products/{{ ansible_product }}/{{ ansible_environment }}/{{ item }}.yml
            with_items:
                - attached
                - main


* Information about run process:

    1. When all settings filled correctly, you can run the wrapper, for get a list of all commands needed for run step by step:

        ```{{ ansible_root }}/\!_stand-minimal.sh```

    2. For wrapper you need to provide settings:

        ```{{ ansible_root }}/\!_stand-minimal.sh {{ ansible_environment }} {{ product_name }} USERNAME PASS {{ NOWAIT }} {{ TYPE_OF_RUN }} {{ cloud_type }}```

* A little example of commands which runned step by step for setup a simple cloud, getted by wrapper.

    1. Creating VMs:

        ```ansible-playbook -i inventories/0z-cloud/products/types/\!_alicloud/vortex/production/bootstrap_vms/ ./\!_root_playbooks/alicloud/bootstrap-ng.yml -e ansible_product=vortex --ask-vault-pass```

    2. Run convertation from ```0z-cloud inventory``` to ```Target inventory```:

        ```{{ ansible_root }}/!_root_playbooks/cloud_regen.sh production vortex alicloud cloud_connection_type```

    3. Run initial DNS configuration playbook:

        ```ansible-playbook -i inventories/products/vortex/production/ playbook-library/!_bootstrap/dns.yml -e HOSTS=ids-keepalive-servers -u vortex --become-user root --become -e ansible_become_pass='1235' -e ansible_ssh_pass='1235'```

        ```ansible-playbook -i inventories/products/vortex/production/ playbook-library/!_bootstrap/systemd_resolved.yml -u vortex --become-user root --become -e ansible_become_pass='1235' -e ansible_ssh_pass='1235'```

    4. Adding the inventory users and public keys for access to instances (developers/admins/etc):

        ```ansible-playbook -i inventories/products/vortex/production/ playbook-library/system/ssh.yml -e HOSTS=all -u vortex --become-user root --become -e ansible_become_pass='1235' -e ansible_ssh_pass='1235' --tags add_user```

    5. Running the Consul cluster installation playbook:

        ```ansible-playbook -i inventories/products/vortex/production/ playbook-library/cloud/consul/!_consul_cloud_playbook.yml -e HOSTS=all -u vortex --become-user root --become -e ansible_become_pass='1235' -e ansible_ssh_pass='1235' -e consul_upgrade=true```

    6. Creating the cloud persisetnt storages for each needed that hosts groups:

        ```ansible-playbook -i inventories/products/vortex/production/ playbook-library/storage/glusterfs-cluster.yml -e GLUSTERFS_CLUSTER_HOSTS=cloud-bind-frontend-dns-glusterfs-storage -u vortex --become-user root --become -e ansible_become_pass='1235' -e ansible_ssh_pass='1235'```

        ```ansible-playbook -i inventories/products/vortex/production/ playbook-library/storage/glusterfs-cluster.yml -e GLUSTERFS_CLUSTER_HOSTS=bind-master-glusterfs -u vortex --become-user root --become -e ansible_become_pass='1235' -e ansible_ssh_pass='1235'```

    7. Installing docker subsystem:

        ```ansible-playbook -i inventories/products/vortex/production/ playbook-library/cloud/docker/docker-install-auto-cloud.yml -e HOSTS=all -u vortex --become-user root --become -e ansible_become_pass='1235' -e ansible_ssh_pass='1235'```

    8. Installing CoreDNS cloud forwarder:

        ```ansible-playbook -i inventories/products/vortex/production/ playbook-library/!_bootstrap/core-dns.yml -e HOSTS=cloud-bind-frontend-dns -u vortex --become-user root --become -e ansible_become_pass='1235' -e ansible_ssh_pass='1235'```

    9. Installing DNS Backend service for publish services DNS records to Internet:

        ```ansible-playbook -i inventories/products/vortex/production/ playbook-library/!_bootstrap/dns-backend.yml -e HOSTS=master-bind-master-backend -u vortex --become-user root --become -e ansible_become_pass='1235' -e ansible_ssh_pass='1235'```


    10. Obtaining wildcard certificate for cloud domain:

        ```ansible-playbook -i inventories/products/vortex/production/ playbook-library/!_bootstrap/letsencrypt-pacemaker.yml -e HOSTS=master-bind-master-backend -u vortex --become-user root --become -e ansible_become_pass='1235' -e ansible_ssh_pass='1235'```

    11. Creation the Docker Swarm Cluster where to after to be deploy stack of applications:

        ```ansible-playbook -i inventories/products/vortex/production/ playbook-library/cloud/swarm/swarm-cluster.yml -e SWARM_MASTERS=swarm-cluster -u vortex --become-user root --become -e ansible_become_pass='1235' -e ansible_ssh_pass='1235' -e leave_cluster=true```

    12. Deploy nginx frontend role, which provide proxy to backends:

        ```ansible-playbook -i inventories/vortex/production/ playbook-library/cloud/nginx/nginx-frontend-ng.yml -e HOSTS=nginx-frontend -u vortex --become-user root --become -e ansible_become_pass=1235 -e ansible_ssh_pass=1235```

    13. Profit: Cloud initialization done, now we can to deploy the applications.
    
## Cloud Deploy and Service Management

1. Basic Directory Structure:

    ```         
       /root_dir/
                |
                |-/ansible
                |
                |-/services
                |
                |-/docs
                |
                |-/dockerfiles
                |
                /.gitlab-ci.yml

    ```

2. Build process basic:

    1. We have a three basic environments, its -

        ``` 
            development
            stage
            production
        ```

    2. Deploy to each environment start automaticly via Gitlab CI by .gitlab-ci.yml file:

        * when we push ```any``` branch deploy starts to ```development environment```.

        * when we update and push commits to branch with name ```develop``` deploy starts to ```stage environment```.

        * when we update and push commits to ```master``` branch deploy starts to ```production environment```.

    3. Deploy and build process controlled by script:

        ```/root_dir/ansible/!_all_service_deployer.sh```

        * Build script basic work:

            * Script takes a applications and services from each dirs, as example

                ``` 
                    /root_dir/services/{{ service_name }}
                    /root_dir/docs/{{ service_name }}
                    /root_dir/services/{{ service_name }}
                ```

            * Script build services and push to Gitlab Docker Registry

            * Script generate the docker-stack file for deploy docker swarm stack

            * Script deploy updated applications and services from builded images getted from docker registry.

3. For each public service you must have a nginx configuration and public certificates, this process controlled by wrapper:

    ```/root_dir/ansible/!_0z-nginx_acme_helper.sh```

    * Wrapper checks the DNS configuration

    * Wrapper run the ```playbook-library/!_bootstrap/letsencrypt-pacemaker.yml``` for each public domain and service which declared in:

        ```/root_dir/ansible/inventories/products/$product/$inventory/group_vars/all.yml``` as ```public_consul_domain```

        ```/root_dir/ansible/!_0z-nginx_acme_helper.sh``` as ```declare prefixes_list=( )```

    * Wrapper sync obtained certificates from DNS backend service to Nginx frontend service.

    * In last step wrapper update nginx configuration via run a playbook

        ```/root_dir/ansible/playbook-library/cloud/nginx/nginx-frontend-ng.yml```