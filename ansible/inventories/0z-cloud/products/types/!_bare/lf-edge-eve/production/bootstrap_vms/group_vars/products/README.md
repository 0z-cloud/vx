# Place where we store the default shared not restricted anycloud connections data end settings, or decrypted on exec
 
 
    *   !!! BE CAREFUL WITH ATTACHED YAML CONFIGURATION, ITS FOR REPLACING ON FLY !!!
 
    *   Contain Basic Project Template directory structure

        ```
        from a personal: project_root/ansible/group_vars/products/{{ ansible_product }}/
        --------------------------------------------------------------------------------------------------------------
            by default contain examples, for main users - shared configuration for product, and specific cloud
            adapter settings and credentials.

            Cloud Adapters settings and vars examples, you must to declare all which you need by types and fill:

                alicloud.yml.example        -->         alicloud.yml
                vcd.yml.example             -->         vcd.yml
                vsphere.yml.example         -->         vsphere.yml

            Shared between types dictionary and settings, can be shared between users, as a part of particular process:

                main.yml.example            -->         main.yml
                shared.yml.example          -->         shared.yml

            Shared ```shared.yml``` configuration file contain only the deteiminators, which select a result variable in some when conditions
            Primary ```main.yml``` configuration file contain only the declared variables, which needed for result variables in some when conditions

        shared attached: project_root/ansible/group_vars/products/{{ ansible_product }}/{{ ansible_environment }}/
        --------------------------------------------------------------------------------------------------------------
            by default contain the overall empty dicts wich works like redirect or change process in particular splitted parts of infrastructure or inventories or environments. After investigate you understand what you can do with this feature.

                attached.yml                 =          shared remapper dictionary and settings, be careful, - use with clear minds
                main.yml                     =          placeholder with test variable, saved for education and future works


        ```