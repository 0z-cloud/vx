# TERAFORMA STYLE TRANSFTER ANSIBLE INTERNAL WAY BETWEEN TWO TYPES OF INVOCATIONS 

## AGNOSTIC OBJECTS FOR ANYTHING, 

### 'CLASSIC BOOTSTRAP'

  * Use for able to transfer more then only v.py works results/state and original filled dataset

  * MIXED REPLACE TYPE {VARS/TEMPLATE}.FILE

    1. First 'ZERO' step get the yaml as a VARS.FILE with some list, dicts, values and other data 

        ```all.yml```

    2. Second step, after 'ZERO' parse results from API his creates use as source ```all.yml``` and fill it

        ```all.yml -> {{ root_adapter_playbook_exec }} -> .dynamic.all.yml```

    3. ```v.py``` translate resulting state to default Ansilbe ini format in target inventory.

        ```.dynamic.all.yml -> v.py -> invenotries/products/{{ ansible_product}}/{{ ansible_environment }}/inventory```

### 'TERAFORMA-STYLE'

  * For implement all our wants and requirements, we want transfer all state of working cloud to local ignored special declared directory:

        ```{{ repository_root }}/.cloud```

    1. After 'CLASSIC FLOW' is finished, if you definde 'TERAFORMA-STYLE' as primary option():
        
        Pipeline can go run to saving all dicts/facts/states use original dicts as templates to -
        
        - template each file to ```.cloud``` by 'SHORT-CONTRACT' Way - Its defaults.

        - template each file to ```.cloud``` by 'FULL-CONTRACT' Way - option must be enabled.


    2. After saving dicts to cloud, provides special flag which determines to Reference Pipeline Call (run) who running in next stage and type of CI/CD/QA IaC process fact, about availiable option to load all special prepared and saved extended data states of wanted cloud by 'TERAFORMA-STYLE' Ansible internal data connector.

        ``` {{ ansible_zero_cloud_extra_data }}```

          - ansible_zero_cloud_extra_data: teraforma

         or

          - ansible_zero_cloud_extra_data: classic