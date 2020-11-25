# Encrypt / Decrypt vaults with settings in inventory

    * encrypt :
    
    ```
    ansible-vault encrypt inventories/products/vortex/production/group_vars/\!_Applications_Core/rails/*/*.yml
    ```
    
    * decrypt :
    
    ```
    ansible-vault decrypt inventories/products/vortex/production/group_vars/\!_Applications_Core/rails/*/*.yml
    ```
    