# Generate and compare response from Cloud API after validation templated infrastructure layout

  * We have 0z-template without IP/etc values

  * We use for deployment/bootstrap/validate configuration that 0z template as real and filled dict, and in process we use elements of that dict, such as like cloud_bootstrap.servers dictionary, contain the servers objects.

  * When we get results from Cloud Provider Api Service, we doing the two big things - Firts, - converting Cloud API responses result to applicable for compare type of Python object, Second - use 0z infrastructure template not as dict, use now as real template. Compare, and fill the target infrastructure layer file for next steps of bootstrap. This folder in your 0z template product environment layout - 

    ```
      ./0z-cloud/products/\!_{{ cloud_type }}/{{ ansible_product }}/{{ ansible_environment }}/bootstrap_vms/group_vars/.dynamic.all.yml
    ```

  * Cloud regen automaticly detects if dynamic file are a presents in source folder of infrastructure layout level