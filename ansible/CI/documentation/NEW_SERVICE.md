# Добавление нового сайта в nginx с автоматической публикацией в DNS.

1.  Добавляешь то как его будет видно во вне, по факту это для конфигурации nginx
    Объявление имени сайта, в рамках окружения

    ```yaml
    ## Main Sites
    ansible_global_admin_site_name: "admin.{{ public_consul_domain }}"
    ansible_global_api_site_name: "api.{{ public_consul_domain }}"
    ```

2.  Добавлешь сайт -
    Добавление объекта типа сайт в окружение

    ```yaml
    unification_sites:
      - {
          name: "{{ ansible_global_gateway_mcom_site_name }}",
          published: "enabled",
          value: "wildcard",
          prefix: "{{ ansible_global_gateway_mcom_site_name }}",
          type: "{{ ansible_global_gateway_mcom_site_name }}",
          location: "gateway_mcom",
          config: "defaults",
        }
    ```

3.  Добавляешь сервис в unification_services_remapping_external_fqdn или в unification_services

    В эту секцию если имя сервиса содержит дефис или требуется ремапнуть внешнее имя (пример public-api):

    ```yaml
    unification_services_remapping_external_fqdn:
      - {
          "public_api":
            {
              "dns_publish_prefix": "api",
              "upstream_prefix": "public-api",
              "external_ip": "{{ static_dns_mappings.main.external_ip }}",
              "target": "service_discovery",
              "listen_port": "{{ public_api_service_listen_port }}",
              "check_type": "tcp",
              "script_check": "{{ inventory_hostname }}:{{ public_api_service_listen_port }}",
            },
        }
      - {
          "gateway_mcom":
            {
              "dns_publish_prefix": "gateway-mcom",
              "upstream_prefix": "gateway-mcom",
              "external_ip": "{{ static_dns_mappings.main.external_ip }}",
              "target": "service_discovery",
              "listen_port": "{{ public_api_service_listen_port }}",
              "check_type": "tcp",
              "script_check": "{{ inventory_hostname }}:{{ public_api_service_listen_port }}",
            },
        }
    ```

    В эту секцию в общем случае:

    ```yaml
    unification_services:
      - {
          "sentry":
            {
              "external_ip": "{{ static_dns_mappings.main.external_ip }}",
              "target": "sentry-web-swarm-masters",
              "listen_port": "{{ sentry_service_listen_port }}",
              "check_type": "tcp",
              "script_check": "{{ inventory_hostname }}:{{ sentry_service_listen_port }}",
            },
        }
    ```

    Для использования service discovery в nginx необходимо указать:

    ```yaml
    "target": "service_discovery"
    ```

    В ином случае директива указывает на группу хостов которая будет использована для заполнения upstream servers.

4.  Добавляешь порт для сервиса:

    ```yaml
    # Wallets
    wallets_service_listen_port: 8001
    ```

5.  Создаем службу в nginx_locations_mapping_list::

        ```yaml
        nginx_locations_mapping_list:
        - teamcity
        ...
        - sentry

        ```

    <!--


6.  Добавляешь в директиву nginx_same новый конфиг (nginx_config_locations_wallets)

    ````yaml
    nginx_same: "{{ nginx_config_defaults |combine(nginx_config_locations_gateway_mcom,nginx_config_locations_checkout,nginx_config_locations_mobicom,nginx_config_locations_public_api,nginx_config_locations_admin,nginx_config_locations_consul,nginx_config_locations_wallets,nginx_config_locations_sentry) }}"
    ``` -->

    ````

7.  Идешь в корень ansible, в основной group_vars/nginx-frontend/nginx-frontend.yml, находишь переменные и добавляешь по аналогии:

    ```yaml
    nginx_configs_locations_checkout: "{{ ansible_environment }}_locations_checkout"
    nginx_configs_locations_mobicom: "{{ ansible_environment }}_locations_mobicom"
    nginx_configs_locations_gateway_mcom: "{{ ansible_environment }}_locations_gateway_mcom"
    ```

    ```yaml
    nginx_configs_locations_wallets: "{{ ansible_environment }}_locations_wallets"
    nginx_configs_locations_checkout: "{{ ansible_environment }}_locations_checkout"
    nginx_configs_locations_mobicom: "{{ ansible_environment }}_locations_mobicom"
    nginx_configs_locations_gateway_mcom: "{{ ansible_environment }}_locations_gateway_mcom"
    ```

8.  Запускаешь последовательно из корня необходимые плейбуки, с помощью команд:

    ```bash
    ./\!_any_part_runner.sh develop sample_product vortex 1235 dns-backend
    ./\!_any_part_runner.sh develop sample_product vortex 1235 nginx-frontend
    ```

# Добавление нового сервиса для осуществления автоматической сборки

1. Add the environment variables for new service:

   ```yaml
       all_services_settings_map:
           settings: |
           {{ shared_env_variables_service_settings_ }}
           guard:
           - "PORT: 5000"
           new_service:
           - "EXAMPLE_ENV_VAR: value"
   ```

   to

   ```yaml
   ansible/inventories/products/{{ ansible_product }}/{{ ansible_environment }}/group_vars/!_Applications_Core/{{ ANSIBLE_APPLICATION_TYPE }}/{{ ANSIBLE_APPLICATION_TYPE }}_settings_map.yml
   ```

2. Add new service to services list:

   ```yaml
   all_services_remap_docker_compose_generate:
     postgres:
       image: "postgres"
       tag: "{{ default_docker_image_environment_tag }}"
       volumes:
         - "{{ default_docker_database_postgresql_environment_location }}"
       location: "{{ default_docker_image_environment_location }}"
     new_service:
       image: "new_service"
       tag: "{{ default_docker_image_environment_tag }}"
       command: "bash -c 'rake db:create && rake db:migrate && rake db:seed'"
       location: "{{ default_docker_image_environment_location }}"
       depends_on:
         - "postgres"
         - "redis"
       ports: "{{ new_service_service_listen_port }}:4000"
   ```

   to

   ```yaml
   ansible/group_vars/!_ApplicationDocker_Template/docker-compose-template.yml
   ```

3. Add the service port to inventory main settings:

   ```yaml
   { { new_service_service_listen_port } }
   ```

   to

   ```yaml
   ansible/inventories/products/{{ ansible_product }}/{{ ansible_environment }}/group_vars/all.yml
   ```

4. Add the service to docker build directory

   ```yaml
   /root_dir/
   |
   |-/ansible
   |
   |-/services/{{ new_service }}
   |
   |-/docs
   |
   |-/dockerfiles
   ```

   - Notice - services placed to `docs` have a `{{ new_service }}-docs` image name after build and push to registry
