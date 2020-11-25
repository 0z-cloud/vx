# Ansible: .files

    Info:

        * Provides in-repository, per each user, on each environment - [User Vault] secrets managamented storage.
        * Contain same hierarchy model, like in whole project, where as a starts point presented by ```{{ product }}```.
        * Variable ```{{ ANSIBLE_VAULT_PASSWORD }}``` used for encryption and decryption [User Vault].
        * [User Vault] stored in repository will be used for providing secured part as personal storage.
        * Decrypted [User Vault] possible to contain [Children Secrets] or [Shared Secrets].
        * [Children Secrets] used for able to have a private extended secret for another encrypt/decrypt task. 
        * [Shared Secrets] applyed for configurations used by [Multiple Users] which have a rights to environment.

    [Shared Secrets] - Example usage case: 

            ```
                    In big big universe, 
                    in little little galaxy, 
                    in Super [Example Company], 
                    in [Example DevOps Department]...

            ```

        * We have a two Physical DevOps Engineers - ```PDE```
        * Each of ```PDE``` must be can able to run Deploy and pass CI/CD tools for target environments.
        * [Accessing] to environment must be passed by [Example Company] Security Complience Management.
        * [Accessing] with currently applyed security policy requirements and target environment restrictions.
        * Each ```PDE``` must have a Unique and Different password for accessing the to his [User Vault].
        * [Vault:Inventory] encrypted by ansible-vault with [Example DevOps Department] shared vault password.
        
        1. ```PDE``` provides password as ```{{ ANSIBLE_VAULT_PASSWORD }}``` 
        
        2. ```{{ ANSIBLE_VAULT_PASSWORD }}``` used for decrypt his owns in-repository [User Vault] storage.

        2. Ansible, in step when performing loading a private settings and keys, decrypt first [User Vault].
        
        3. Then Ansible perform loading [All Decrypted Variables] dictionaries files to memory.
        
        4. In [All Decrypted Variables] we check ```{{ ANSIBLE_GROUP_VARS_ENVIRONMENT_VAULT_PASSWORD }}```.
        
        5. Featched variable indicate for us, we will need select use new vault password to decrypt or not, for next steps.

        6. If ```{{ ANSIBLE_GROUP_VARS_ENVIRONMENT_VAULT_PASSWORD }}``` is defined - we uses decrypted from vault value.

        7. For case when cannot fetch variable from decrypted vault - we set for that ```{{ ANSIBLE_VAULT_PASSWORD }}```. 

            ```
             _______
            [10---x=] 
            [-  = --] - PDE provide his ``{{ ANSIBLE_VAULT_PASSWORD }}```
            [== -- -] - Ansible get [encrypted].yml and place result to [decrypted].yml
            [=1--xx-] - Loading all vault stored settings and dictionaries from [decrypted].yml
            `-------` 
                       
                In memory placed ```{{ ANSIBLE_GROUP_VARS_ENVIRONMENT_VAULT_PASSWORD }}``` used for decrypt group_vars of target inventory on fly directly when running ansible-playbook command
                
            ```