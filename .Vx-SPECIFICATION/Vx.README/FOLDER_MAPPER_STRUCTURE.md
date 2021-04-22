# VORTEX REPOSITORY STRUCTURE CONTRACT MAP

necessary_contract_path_dictionary:
    root:
    # /-/
        |
        # Main Repository folder, which starts your Journey to Ansible Cloud SRE Intelligent System powered by Community Code.
        # Contain primary directories designed and presents for you easy management and bootstrapped and understanding CI/CD/QA/DEV system.
        # Just in case, each time we use way where get a new fork whole of this code repository "Vortex Project Template", simply adding the needed for Project (ps. In BI = Product: Some your designed service/application/platform)...
        # ...services which you developed before or want to develop.
        # ...selects your backends services, such as like Databases, Queries, Storages, Calculation, Transfers -
        # This part represents the back-end hided services layer/level of your designed system coverage and is used to implement BI logic. 
        |
        .local:
        # /-----/
        |       |
        |       # Hidden and (git)ignored local cloud exchange private dir index 0. Contain your personal access variables and encrypted private keys, and also needed stuff.
        |       |
        |       group_vars:
        |       # /---------/
        |       |           |
        |       |           # Specific destination 0z layer checking/replacment/extending/including/rollup'ing other evironments by include patterns of sourced path's 
        |       |           |
        |       |           {{ ansible_environment }}: 
        |       |           # /-------------------------/
        |       |           |                           |
        |       |           |                           attached: 
        |       |           |                           # /-----/
        |       |           |                           |       |
        |       |           |                           |       # Special files with 0z layer checking/replacement/extending/including/rollup'ing other environments,
        |       |           |                           |       # or his parts by including patterns gathered from the sourced path's when flying by dict and values. 
        |       |           |                           |       # Be careful with using it (2 Senior's SRE can manage it on a Production system without race-condition in work times),
        |       |           |                           |       # try 7 times to think 'why it?', 'for what it needs?', 'how it really works?', and 7 times tests before implement it to other then development environment
        |       |           |                           |       |
        |       |           |                           |       # --\
        |       |           |                           |       #   |
        |       |           |                           |       #   |- "attached.yml"
        |       |..         |                           |       #   |- "main.yml"
        |                   |..                         |       #   |- "{{ ansible_cloud_type }}.yml"
        |                                               |..     #   |
        |                                                           |..
        |
        .teamcity:
        # /---------/
        |           |
        |           # CI/CD Implementation Production Ready ToolSet with all сommon. 
        |           # In past years has been multiple times implemented solution for different products same Time-tested,
        |           # implemented repeatedly and used for various products, a huge number of times, the same template of a solution containing
        |           # the necessary and sufficient set for building a modern IT product service chain. 
        |           # Pipelines and And DevOps Practics and Methodologies as well and right included fully completed. 
        |           # Just change settings and go to use.
        |           |
        |           |..
        ansible:
        # /-----/
        |       |
        |       #################################################################################
        |       # CENTRAL POINT OF INFRASTRUCTURES AND ENVIRONMENTS ROOT MANAGEMENT RUN POINT
        |       #################################################################################
        |       |
        |       _selfbox_:
        |       # /---------/
        |       |           |
        |       |           # POINT WHERE WE WORK AT LOCALHOST PLACEMENT FOR DEV,TEST,CONNECT THE SOLUTION COMPONENTS
        |       |           |
        |       |           |..
        |       !_PCI:
        |       # /-----/
        |       |       |
        |       |       # PCI COMPLIANCE TOOLSET AND DOCUMENTATION
        |       |       |
        |       |       |..
        |       |
        |       !_root_playbooks:
        |       # /-----------------/
        |       |                   |
        |       |                   # TERRAFORM ANSIBLE API ADAPTERS FOR CLOUD PROVIDERS TEMPLATE LANDSCAPE WARM-UP BOOTSTRAPING AND APPLY SOLUTION ECOSYSTEM LAYOUT RESOURCES LAYOUT
        |       |                   # DO LIKE TERRAFORM (HASHICORP) STYLE, BUT BETTER 
        |       |                   |
        |       |                   |- {{ ansible_cloud_type }}
        |       |                   |
        |       |                   |..
        |       !_tests:
        |       # /-----/
        |       |       |
        |       |       # INTERNAL VORTEX DEVELOPMENT AND TESTING SUITE FOR LOCAL IMITATION PUSHING THE CI/CD/QA CHAIN PIPELINES BUTTON LIKE IN WEB UI YOUR CI/CD TOOL 
        |       |       |
        |       |       |..
        |       |
        |       .files:
        |       # /-----/
        |       |       |
        |       |       # INTERNAL IN-REPOSITORY CRYPTO VAULT WITH PERSONAL AND GROUP SECURED STORAGE CREDENTIALS AND CRITICAL SETTINGS/OPTIONS/DECLARATIONS
        |       |       |
        |       |       protected:
        |       |       # /---------/
        |       |                   |
        |       |                   # Information will be added in the next release. Try to go to complete and full Vault Readme.
        |       |                   |
        |       |                   |..
        |       .migrations:
        |       # /---------/
        |       |           |
        |       |           # Information will be added in the next release
        |       |           |
        |       |           |..
        |       CI:
        |       # /-/
        |       |   |
        |       |   # Information will be added in the next release
        |       |   |
        |       |   |..
        |       |
        |       group_vars:
        |       # /---------/
        |       |           |
        |       |           # PRIMARY GLOBAL GROUPS ROOT, POINT OF TEMPLATE OVER TEMPLATES. 
        |       |           # Includes - Application Sets, Cluster Group Placements and Shared Settings Templates Dictionary Arrays
        |       |           # (see as example to nginx config generations flow)
        |       |           |
        |       |           |..
        |       |
        |       inventories:
        |       # /---------/
        |       |           |
        |       |           # PRIMARY INVENTORIES-ON-ENVIRONMENTS BY PRODUCT CONTRACT IaC WAY FLOW
        |       |           |
        |       |           0z-cloud:
        |       |           # /-----/
        |       |           |       |
        |       |           |       # IaC Level 0:
        |       |           |       # [CLOUD_PLATFORM_BOOTSTRAPING]
        |       |           |       # RUN TERAFORMATION FROM LANDSCAPE TEMPLATE MAP TO CLOUD PROVIDER, WHICH BOOTSTRAP/CHECK/EXTEND/REMOVE/MANAGE RESOURCES BY CLOUD API ADAPTER. RESULTS IF ALL ARE SUCCESSFUL FILLS TO ORIGINAL BOOTSTRAPING TEMPLATE WHICH LOADED FOR THAT LIKE TEMPLATE.
        |       |           |       |
        |       |           |       products:
        |       |           |       # /-----/
        |       |           |       |       |
        |       |           |       |       #
        |       |           |       |       |
        |       |           |       |       !_{{ ansible_cloud_type }}:
        |       |           |       |       # /-------------------------/
        |       |           |       |       |                           |
        |       |           |       |       |..                         #
        |       |           |       |                                   |
        |       |           |       |                                   |..
        |       |           |       vortex-py:
        |       |           |       # /---------/
        |       |           |       |           |
        |       |           |       |           #
        |       |           |       |           |
        |       |           |       |           templates:
        |       |           |       |           # /---------/
        |       |           |       |           |           |
        |       |           |       |           |           #
        |       |           |       |           |           |
        |       |           |       |           |           |- dynamic.teamcity.yml.j2
        |       |           |       |           |           |- dynamic.web.yml.j2
        |       |           |       |           |           |- dynamic.router.yml.j2
        |       |           |       |           |           |- dynamic.redis.yml.j2
        |       |           |       |           |           |- dynamic.rabbitmq.yml.j2
        |       |           |       |           |           |- dynamic.pci.router.yml.j2
        |       |           |       |           |           |- dynamic.nginx.yml.j2
        |       |           |       |           |           |- dynamic.misc.yml.j2
        |       |           |       |           |           |- dynamic.loadbalancer.yml.j2
        |       |           |       |           |           |- dynamic.k8sm.yml.j2
        |       |           |       |           |           |- dynamic.ids.yml.j2
        |       |           |       |           |           |- dynamic.k8sc.yml.j2
        |       |           |       |           |           |- dynamic.front.yml.j2
        |       |           |       |           |           |- dynamic.etc.yml.j2
        |       |           |       |           |           |- dynamic.database.yml.j2
        |       |           |       |           |           |- dynamic.custom_node.yml.j2
        |       |           |       |           |           |- dynamic.cache.yml.j2
        |       |           |       |           |           |- dynamic.all.yml.j2
        |       |           |       |           |           |- base.dynamic.yml.j2
        |       |           |       |           |
        |       |           |       |           |- inventory
        |       |           |       |           |- v.py
        |       |           |       |..         |
        |       |           |                   |..
        |       |           |
        |       |           global:
        |       |           # /-----/
        |       |           |       |
        |       |           |       #
        |       |           |       |
        |       |           |       _meta_self_search_:
        |       |           |       # /-----------------/
        |       |           |       |                   |
        |       |           |       |                   # AUTOSEARCH/AUTOSTACK ZONES/REGIONS WHEN TO USE DYNAMIC-TO-DYNAMIC WARM-UP GENERATED GEO AND MESH CLOUDS (WIP MODULE)
        |       |           |       |                   |
        |       |           |       |                   |- v.meta.py
        |       |           |       |                   |
        |       |           |       |                   |..
        |       |           |       |
        |       |           |       |       
        |       |           |       oz_router:
        |       |           |       # /---------/
        |       |           |       |           |
        |       |           |       |           # SHARED EDGE DISTRIBUTION EXCHANGE POINT
        |       |           |       |           |
        |       |           |       |           products:
        |       |           |       |           # /-----/
        |       |           |       |           |       |
        |       |           |       |           |       # PRODUCT PLACEMENT FOR MAKE POINT OF MESH DISTRIBUTION
        |       |           |       |           |       |
        |       |           |       |           |       {{ ansible_product }}:
        |       |           |       |           |       # /---------------------/
        |       |           |       |           |       |                       |
        |       |           |       |           |       |..                     # PRODUCT STACKING MESH TRINGLES AND BOARDER BRIDGES CLOUD EDGES (LEFT,RIGHT,WARM,FORWARD - MESH STACK MODEL 3+1 - RAFT n+(-1))
        |       |           |       |           |                               |
        |       |           |       |           |                               {{ ansible_environment }}:
        |       |           |       |           |                               # /-------------------------/
        |       |           |       |           |                               |                           |
        |       |           |       |           |                               |..                         # TARGET TO DEPLOYMENT INVENTORY ROOT DIR.
        |       |           |       |           |..                                                         |
        |       |           |       |..                                                                     group_vars:
        |       |           |                                                                               # /---------/
        |       |           |                                                                               |           |
        |       |           |                                                                               |..         # SYMLINKED PRODUCT TO SAME/DIFFERENT PRODUCTS ROOT FOLDER IN GROUP_VARS
        |       |           |                                                                                           |
        |       |           |                                                                                           products: 
        |       |           |                                                                                           # /-----/
        |       |           |                                                                                           |       |
        |       |           |                                                                                           |       {{ ansible_product }}
        |       |           |                                                                                           |       # /---------------------/
        |       |           |                                                                                           |       |
        |       |           |                                                                                           |       # Links to: 
        |       |           |                                                                                           |       # 
        |       |           |                                                                                           |       # "ansible/inventories/global/oz_router/products/{{ ansible_product }}/{{ ansible_environment }}/ =>
        |       |           |                                                                                           |       # => group_vars/products"
        |       |           |                                                                                           |       #
        |       |           |                                                                                           |       |
        |       |           |                                                                                           |       |- all.yml
        |       |           |                                                                                           |       |
        |       |           |                                                                                           |       |...
        |       |           |                                                                                           |
        |       |           |                                                                                           |- inventory
        |       |           |                                                                                           |
        |       |           |                                                                                           |..
        |       |           products:
        |       |           # /-----/
        |       |           |       |
        |       |           |       # IaC Level 1:
        |       |           |       # [CLOUD_PLATFORM_DEPLOYING]
        |       |           |       # RUN DIRECTLY DEPLOYING SOLUTION AND SERVICE TOOLS, AFTER IaC Level 0 ARE COMPLETES,
        |       |           |       # INVOCATION AND CHECKED SUCCESSFUL CLOUD WANTED ENVIRONMENT LANDSCAPE MAP, FINAL TARGET LAYOUT PLATFORM, APPLYING SOLUTION APPLICATION SET, SERVICE TOOLS, CLUSTERS, STORAGES, BALANCERS AND OTHER STUFF.
        |       |           |       |
        |       |           |       {{ ansible_product }}:
        |       |           |       # /---------------------/
        |       |           |       |                       |
        |       |           |       |..                     # Product for operating in deploying platform section.
        |       |           |                               |
        |       |           |                               {{ ansible_environment }}:
        |       |           |                               # /-------------------------/
        |       |           |                               |                           |
        |       |           |                               |                           # Target inventory on selected environment placed at zone/region/sector
        |       |           |                               |..                         |
        |       |           |                                                           group_vars:
        |       |           |                                                           # /---------/
        |       |           |                                                           |           |
        |       |           |                                                           |           # SYMLINKED TO GLOBAL GROUP_VARS ROOT OR UNIQAL PRESET IN PLACE WITH SPECIFIC INVENTORY IN ENVIRONMENT CONFIGURATION
        |       |           |                                                           |           |
        |       |           |                                                           |           |-/ !_Applications_Core: "[]"
        |       |           |                                                           |           |-/ !_Cache_Services: "[]"
        |       |           |                                                           |           |-/ !_Databases: "[]"
        |       |           |                                                           |           |-/ app-glusterfs-cluster: app-glusterfs-cluster.yml
        |       |           |                                                           |           |-/ dns: "[]"
        |       |           |                                                           |           |-/ elasticsearch-cluster: elasticsearch-cluster.yml
        |       |           |                                                           |           |-/ ids-keepalive-servers: ids-keepalive-servers.yml
        |       |           |                                                           |           |-/ kubernetes-master: kubernetes-master.yml
        |       |           |                                                           |           |-/ nginx-frontend: nginx-frontend.yml
        |       |           |                                                           |           |-/ rabbitmq-cluster: rabbitmq-cluster.yml
        |       |           |                                                           |           |-/ teamcity-server: teamcity-server.yml
        |       |           |                                                           |           |-/ vortex-core-master-backend: vortex-core-master-backend.yml
        |       |           |                                                           |           |- all.yml
        |       |           |                                                           |           |- services.yml
        |       |           |                                                           |           |
        |       |           |                                                           |           |..
        |       |           |                                                           |           
        |       |           |                                                           |- inventory 
        |       |           |..                                                         |
        |       |                                                                       |..
        |       |           
        |       module_utils:
        |       # /---------/
        |       |           |
        |       |           #
        |       |           |
        |       |           |..
        |       |
        |       library:
        |       # /-----/
        |       |       |
        |       |       #
        |       |       |
        |       |       |..
        |       |
        |       modules:
        |       # /-----/
        |       |       |
        |       |       #
        |       |       |
        |       |       |..
        |       |
        |       playbook-library:
        |       # /-------------/
        |       |               |
        |       |               # CONTAIN THE PIPELINES CHAINS WITH STACK OF ROLES RUN
        |       |               |
        |       |               |.. 
        |       |   
        |       plugins:
        |       # /-----/
        |       |
        |       roles:
        |       # /-----/
        |       |       |
        |       |       # CONTAIN TASKS GROUPPED TO ROLES BY TYPE AND DEFENITION
        |       |       |
        |       |       |- \!_0_init:
        |       |       |- \!_0_killer:
        |       |       |- \!__cloud_repo__:
        |       |       |- \!__layouts__:
        |       |       |- \!_acme:
        |       |       |- \!_applications:
        |       |       |- \!_bootstrap:
        |       |       |- \!_cloud:
        |       |       |- \!_cluster_apps:
        |       |       |- \!_configuration:
        |       |       |- \!_databases:
        |       |       |- \!_deploy:
        |       |       |- \!_hooks:
        |       |       |- \!_kubernetes:
        |       |       |- \!_logging:
        |       |       |- \!_monitoring:
        |       |       |- \!_network:
        |       |       |- \!_security:
        |       |       |- \!_storage:
        |       |       |- \!_system_maintanance:
        |       |       |- \!_test_suite:
        |       |       |
        |       |       |..
        |       |       
        |       scripts:
        |       # / ----/
        |       |       |
        |       |       # HELPERS LIBRARY AND SOME USEFUL NECESSARY HOOKS AND SCRIPTS
        |       |       |
        |       |       |..
        |       |
        |       # SAME CONTRACT INTERFACE WHICH RUNS DYNAMIC CHAINS OF PIPELINE FLOWS WHICH PROVIDE WANTED INVOCATION BY ANSIBLE PALYBOOKS CHAINS
        |       |
        |       |- _selfhost_development.sh
        |       |- reference_builder.sh
        |       |- reference_deployer.sh
        |       |- reference_development.sh
        |       |- reference_devops_prod.sh
        |       |- reference_devops_zone_live.sh
        |       |- reference_internal.sh
        |       |- reference_qa.sh
        |       |- reference_services_internal.sh
        |       |- reference_wrapper.sh
        |       |- _selfhost_development.sh
        |       |- ansible.cfg
        |       |- Dockerfile
        |       |- Vagrantfile
        |       |
        |       |..
        |
        # Infrastructure level where we place the really shit magic stuff. provide completed pipelines.
        |
        dockerfiles:
        # /---------/
        |           |
        |           # Stack of services or applications which must be built to docker container images, 
        |           # and represents by self all services like and which you need for product infrastructure layout,
        |           # where we running things such like as Databases, Queues, Storages, Hypervisors, Processing or other,
        |           # used as last backend/transport/queue layer for your front-end/back-end or other BI Pipelines works.
        |           # As example - [redis,mongo,rabbit,kafka,minio,postgres,memcached,nextcloud,etc]
        |           |
        |           |..
        docs:
        # /-/
        |   |
        |   # Stack of services which provides Web Documentation for your products/services/features/etc, like
        |   # Site(sub-domain like sdk.example.com/docs.example.com) with SDK with Repository and API/SDK documentation.
        |   # Designed for able splitting by security zones and published types scope of endless count of needed services.
        |   # Such as best as your can: docs.example.com - primary API/Service preview and documentation. docs-api.example.com - 
        |   # public full API interfaces explain for able better working with you SDK. sdk-developer.example.com - 
        |   # as example docs portal with login redirect to marketing page like "pay or go away" for new devs,
        |   # to able fetching registration and SDK usage fee.
        |   |
        |   |...
        |
        extended:
        # /---------/
        |           |
        |           # Groups with Stacks of services structured by Department/Shared Component as root for Group of a couple in Stacks Services
        |           |
        |           |..
        |
        PythonQA:
        # /-----/
        |       |
        |       |# Placement for QA Section with declared as simple and have powerful flexible types of invocations which you want to add.
        |       |
        |       |..
        |
        services:
        # /-----/
        |       |
        |..     # Stack with Services, which represents your company product/s developed applications and services, 
                # what we need to take as target infinity deployment DEV/CI/CD/QA by Pipelines schedule runs. 
                # Or runs complete update/create/modify/link products services in you want time from Buttons in Your TeamCity instance. 
                # Better and good result two scheduled master self CI Full cycle run each around 12h.
                |
                |..
________________________________________________________________________________________________
Vortex. Contract Version 1.0.1 
________________________________________________________________________________________________
