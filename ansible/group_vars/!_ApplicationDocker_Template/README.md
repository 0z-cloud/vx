# ReadME.md: Please add required variables for each inventory

    - Must have remap variable - ``` build_image_id or latest```:

        * Place this variable to all.yml of the your inventory_path/group_vars

        ```
            default_docker_image_environment_tag: latest
        ```
        ```
            default_docker_image_environment_tag: latest
        ```

    - Must have remap variable - image_location value is ```registry or local```:

        * Place this variable to all.yml of the your inventory_path/group_vars

        ```
            default_docker_image_environment_location: registry
        ```
        ```
            default_docker_image_environment_location: local
        ```

    - Must have remap variable - database_postgresql_environment_location:

        * Place this variable to all.yml of the your inventory_path/group_vars

        * Its a docker volume mount string, for can be have a persistent cloud storage:

        ```
        example production -

            default_docker_database_postgresql_environment_location: "../../PROD_DB:/var/lib/postgresql/data"
        ```
        ```
        example stage -

            default_docker_database_postgresql_environment_location: "../../STAGE_DB:/var/lib/postgresql/data"
        ```
        ```
        example local -

            default_docker_database_postgresql_environment_location: "postgres-data:/var/lib/postgresql/data"
        ```
        ```
        example etc -

            default_docker_database_postgresql_environment_location: "../../ETC_DB:/var/lib/postgresql/data"
        ```