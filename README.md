# .............................................................................................

![Vortex BIG BANG Workflow](ansible/CI/repo_images/vortex_cutted_full_flow_up.png)

# .............................................................................................

# Welcome, to Vortex Vx˜

**Release State: stable-1.6.2**


* At ``` *.woinc.ru ``` we place a ``` Public Demo Access Platform ``` 
  which represents our ``` Vx Live Run ``` 

* These are real ``` Lifecycle Auto Cloud ``` 

*  The demo has some set of Company Public Internal ``` Products ```,
  and in public part we show,
  as an example our simple sample:
  
  - ``` Vx Zone Environment Infrastructure Subset ``` 

* Vx Repo hold and contain explain to each implemented as
  ``` a self Vx parts in each Vx Repository ``` 


Example run contain:

 - https://woinc.ru
 - https://teamcity.woinc.ru
 - https://gitlab.woinc.ru
 - https://www.woinc.ru
 - https://ogame.woinc.ru

## GitFlow

![GitFlow Working Model Diagram.png](ansible/CI/repo_images/gitflow-complete-eng.png)

## CI/CD/QA Main Dashboard Default Layout

![Teamcity Welcome](ansible/CI/repo_images/TeamCity_Overview.png)

## Services Detector

![Services Detector](ansible/CI/repo_images/services_build_detector.png)

## Service Build Decorator

![Service Build Decorator](ansible/CI/repo_images/service_build_decorator.png)

## Built Container Tag

![Container Tag](ansible/CI/repo_images/service_build_tag_registry_show.png)

## Registry Built Containers List

![Registry Builded Containers List](ansible/CI/repo_images/container_registry_show_builded_list.png)

## SSL Tests Results: 07.01.2021

![ssl labs at 07.01.2021](ansible/CI/repo_images/ssl_labs_test_07_01_2021.png)

## Repository statements:

```
* Terraform-free ansible realization of Dynamic Infrastructure development/management/deployment
* Full IaC support via Ansible Cloud API modules.
* Ready to use, just add your services and declare infrastructure.
* Simple to understand solution template provides complete CI/CD/QA.
* Multimple ways to use many roles, zones, clusters, networks.
* K8 & Docker Swarm support - you can have  multiple clusters in one environment.
* You can have multiple virtual environments on one virtual cloud infrastructure placement.
* Easy template for build, bootstrap, develop, deploy and test your infrastructure.
* Have a TeamCity ready to import configuration with full process with a simple CI/CD/QA pipeline.
* Network balancer included - keepalived, haproxy, nginx, etc
* PCI DSS Compliance initial support modules.
* Firewall zero-in inside based on Shorewall.
* Much other stuff like rabbitmq/tarantool/redis/etc clusters.
* GlusterFS as NFS shared storage.
* Provides single point in the development process.
* All configurations fully generated - for local development and environments.
* You can use different CI/CD tools for use, - TeamCity, Jenkins, Gitlab-CI, etc.
* Storing built docker images possible to different registries - gitlab, registryv2, nexus, etc.
```

### Markdown constants

    - [-] Feature which almost works fine, but need to update/bugfix/extend/refactor now.
    - [+] Feature now in dev's and planned to next major release
    - [p] Feature which is planned for future roadmap release on the second major release
    - [t] Feature in Testing Branch
    - [x] Feature is implemented yet completely, like for CI/CD Pipeline, 
          if Kubernetes as an example have that flag, 
          that describes what we can possibly create cluster and deploy to it.
    - [w] Whitepaper page for feature ready to RFC, or wip state
    - [*] Feature planned to be refactored
    - [?] On RFC stage
    - [.] Pre-research and modeling. Checking able and profit after implementation.
    - [U] An Urgent and most important task for complete

### Ansible Teraforma API Cloud adapters

    - [x] Baremetal (FAKE-API)
    - [*] VMware vCenter/vSphere (API)
    - [-] VMware Cloud Director (API)
    - [x] Alicloud (API)
    - [+] Amazon Web Services (API)
    - [ ] Openstack
    - [ ] Huawei Cloud
    - [+] DigitalOcean
    - [ ] Azure
    - [ ] Apache (Citrix) CloudStack
    - [+] Google Compute Engine / Google Cloud Platform (API)
    - [ ] OpenNebula
    - [U] EVE

### Ansible Teraplatforma API Hardware adapters



### Clusters management platform flags are supported by Cluster backend type

    - [x] Docker Swarm
    - [x] Kubernetes
    - [p] Nomad
    - [.] Mesos

### Localhost providers Hyper-Visors for VMs

    - [ ] VMware Workstation/Fusion
    - [ ] Hyper-V
    - [ ] VirtualBox
    - [U] QEMU
    - [ ] Parallels
    - [ ] XEN
    - [U] EVE

### Vortex runs at OS Platforms

    - [x] Linux
    - [x] Mac OS X
    - [-] Windows
    - [-] Android

### Localhost cluster types arch in place

    - [x] Docker by docker-compose
    - [x] Vagrant
    - [p] miniKube

### Vault Storages

    - [x] Internal Contract Model Vault storage based on Ansible-Vault and simple interface,
          uses for manage the zero levels necessary shared logins and passwords constraints,
          and also product specific settings, which possible to be shared by groups, 
          by inventories, regions, sectors, zones, environments, and placements like ACL, -
          represents are same shared pieces of security cake, - 
          For example, one command implements a feature for dev[1-3] environments, 
          and have only access by security violation policy interface,
          only to part of vault where stored his credentials,
          which able perform operations only on dev environments, after the task completes, 
          team lead as an example, who has more access level, 
          and can from same commit run chain pipeline to stage environment,
          with separated per each user credentials container level.
            
            Please README in Vx component documentation.

    - [.] Vault (HashiCorp)

### Service Discovery

    - [x] Consul. Multi-DC & Multi-Zone Cloud Consul Cluster,
           with separated/mixed Service Discovery each Zone, Service, Network,
           where ACL is infinitly run with checks to reborn itself cloud warmup bootstrap,
           by platform levels chaining bootstrapping. Mesh accounting, validation and relocation.
           Nginx service discovery full cover by use as upstreams service discovery endpoints,
           which extends with prefix `*.cloud.` each frontend service mesh endpoint.
    - [.] EtcD

### Mesh Mesh Providers

    - [-] Istio
    - [x] Consul
    - [.] LinkerD
    - [.] Envoy

### Domain Name Services

    - [x] CoreDNS.

          * Primary DNS Protocol engager which placed like frontend endpoint, -
          is are a cloud placement ` layout ` use this as shared on each ```` platform ` at ` zone `
          for rewriting, filtering, forwarding, redirection for all DNS queries.

          * Only contain rules for recursion pathing processing on each DNS query,
          knowns only about DNS zones and backend services which answer to them,
          such as like K8S Cluster DNS Public VIP Edpoint and Consul Service Discovery DNS Interface,
          who able possible to use mesh service discovery zones as parts of the parent zone.


    - [x] Bind9 DNS Services Backend.

          * Is are a Stub Placement with SOA and records for primary root Domain, -
          ` consul_public_domain ` for each ` sector/zone ` where parent are ` environment ` father.
          Like redirects to (*.cloud|*.k8|*.swarm), declare itself's and static records,
          VIP and service management tools endpoints, which are uses as pointer where Service Discovery,
          are is enabled for service, and static mapping was generated by Ansible Groups.

          * Provides dynamic zone extending and stacking, 
            in geo-mesh networks detects and declare nearest endpoints of truth.

    - [-] Kubernetes DNS Vip Endpoint.

          * Used as the same case like in Consul, extends domain with prefix k8 by CoreDNS DMZ Service Discovery Sector,
          and able forward DNS queries to Internal Kubernetes Cluster DNS Service Discovery,
          and represented by ` *.k8.{{ consul_public_domain }} `

    - [.] Docker Swarm DNS VIP Endpoint.

          * Internal Swarm Service Discovery DNS which are represented by ` *.swarm.{{ consul_public_domain }} `

## SERVICE NOTE BY ONE PAPER STYLE:

- [PIPELINE EXPLAIN](SERVICE_NOTE.md)
- [CONTRACT EXPLAIN](MAPPER_STRUCTURE.md)

## IaC Flow Design Compare Diagram

![Vortex vs Terraform](ansible/CI/repo_images/Vortex-vs-Terrraform_Table_comparison.png)

## Declared example standard environments/solutions architecture zone sizes for region placements

- [Vortex Minimal Layout](ansible/CI/repo_images/VortexMinimalTypeNG.png)
- [Vortex Minimal With Service Node](ansible/CI/repo_images/VortexMinimalWithServiceNodeNG.png)
- [Vortex Standard PCI DSS](ansible/CI/repo_images/VortexStandardPCING.png)

  - As default/standard ecosystem layout, in most cases for simple IT Software Solution, we use,

  ![Vortex Standard PCI DSS](ansible/CI/repo_images/VortexStandardPCING.png)

## Geo-replicated mesh cloud model map

![Vortex EVE Hyperscale Mesh Cloud](ansible/CI/repo_images/cloud_mesh_hyperledger_eve.png)

## Mesh QA Stress Test Flow

- [Default QA Running Flow](ansible/CI/repo_images/QA_Short_flow.png)
- [Mesh QA Geo Stress Flow](ansible/CI/repo_images/QA_mesh_stress_run.png)

  - For mesh ecosystems with multiple geo-placements we able to initiate Stress Test Suite
    to something environment from each able to accessed inventory.

![Mesh QA Geo Stress Flow](ansible/CI/repo_images/QA_mesh_stress_run.png)

## Readme's links:

- [Ansible](ansible/)
- [Roles](ansible/roles/)
- [Inventories](ansible/inventories/)
- [Group Vars](ansible/group_vars/)
- [CI/CD PCI DSS Usage](ansible/CI/documentation/)
- [How to add a New Service](ansible/CI/documentation/NEW_SERVICE.md)
- [Network Maps](ansible/CI/documentation/PCI/network_maps/)
- [CI/CD Agents Debugger](ansible/!_tests/)
- [API Inventory Ansible Adapters](ansible/!_root_playbooks/)
- [In-Repository Vault Storage](ansible/.files/)

## QA Suites for templating own QA solution

- [QA Example 1 - Payment](PythonQA/history_facts/v.test.selenium.example.payment/)
- [QA Example 2 - Voting](PythonQA/history_facts/v.test.selenium.example.voting/)
- [(WIP) Warrior Way - Guidline](PythonQA/)

## Folders info must to read

- [Dockerfiles](dockerfiles/README.md)
- [Services](services/README.md)

## Two basic types of inventories

Dynamic Inventory (API INVENTORY), called 0z-cloud:

     - Zero Inventory start point of your cloud - very simple way to work.
     - Zero Inventory - cloud bootstrap and check or validate your cloud infrastructure.
     - Contain prefilled/prepared template for creating the instances.
     - Availiable in two types of run - api or baremetal.
     - Contains dict and variables which you want about infrastructure.
     - In API type used as a template.

Target Inventory (GET INVENTORY), resulting inventory:

     - Result of generation the API INVENTORY, contains all needed for ansible works.
     - Placed in inventories/products/{{ ansible_product }}/{{ ansible_environment }}
     - No stored in repository.

## Principal workflow

### The directory structure for dynamic inventories describes basic call flow

![Directory_structure](ansible/CI/repo_images/vortex_work_map.png)

### ZeroCloud configuration flow inside and only on ansible calls

![Api_flow_dynamic_inventories](ansible/CI/repo_images/vortex_api_generate_flow.png)

### Working with virtual and cloud environments, bootstrapping and managing

- Basically, we have refactored and simplified reference runners, represented as `references_*.sh`
  which in one year past Beta Vortex Prototype Production Testing not looks are great, like now.
  For understanding how it changes solution by timeline, how works before,
  you can see past versions of Vortex beta-version wrappers here -
  https://github.com/itmo-eve/adam-vortex/tree/master/ansible/scripts/wrappers/init

- Generally, by layout, we have three types of environments, except localhost development type -
  `standalone`, `minimal` and `PCI`.
  You can create your special one and select your options for your time.

- First of all, we create and bootstrap environment, now its are included in any `reference_*.sh`, in previous versions
  wrappers for that has been in separated executable wrapper files,
  you can find those old wrappers in https://github.com/itmo-eve/adam-vortex/tree/master/ansible/scripts/wrappers/init
  If you are a needed, can do like are wants be you require by Platform Product and Cloud layout,
  with flexible ways to contract your pipeline chain CI/CD flow suite.

- Go to ansible folder in the cloned repository, -

     ```
        cd ./ansible
     ```

  - Try run the wrapper as an example, -

    ```
      ./reference_iac_stand.sh
    ```

    ![reference_iac_stand.sh](ansible/CI/repo_images/reference_iac_stand.sh.png)

  - TeamCity or other CI/CD/QA running tool just run wrappers to execute some step of pipeline with
    `type_of_run` equals `true`, for local running/debugging/understanding you can run each wrapper
    with value `print_only` in `type_of_run` parameter.
    Please read the configuration in folder `.teamcity` for more understanding.

  - We split processes for managing your business product lifecycle into two steps -

  - Build and validate infrastructure - only if you use an API Cloud Adapter 
    to support a full dynamic environment way.
    
    If you are using the bare-metal adapter, you must create the infrastructure itself and after then -
    declare necessary nodes information to the static template.

  - Deploy pipeline:

  - Prepare CI

  - Build and Push Docker images -
    Completely Build your software and necessary backend/database/services images for able to work your own software.

    ```
      ./reference_builder.sh

    ```

    ![reference_builder.png](ansible/CI/repo_images/reference_builder.sh.png)

  - Validate Deployment and Deploy - Deploy to Docker Swarm / K8 / Standalone updated manifests, perform DB migrations.

     ```
       ./reference_deployment.sh

     ```

    ![reference_deployment.png](ansible/CI/repo_images/reference_deployment.sh.png)

  - Update the Backend DNS & Web-Server (Nginx) configurations - update DNS & webserver configurations
    and check some list of backend services like monitoring, NTP, etc.

     ```
       ./reference_internal.sh

     ```

    ![reference_internal.png](ansible/CI/repo_images/reference_internal.sh.png)

  - Run the QA part of the pipeline - running your custom QA test suites.
    You must enable that part of the pipeline by itself because the default state of the feature is disabled.

     ```
       ./reference_qa.sh

     ```

    ![reference_qa.png](ansible/CI/repo_images/reference_qa.sh.png)

  - You can customize each part of the pipeline, playbooks, and roles.

    ### INTERNAL TEST SUITE DESCRIBE. HOW TO EASY TO START =)

    - By contract in a Vortex flow, root exec point for infrastructure (aka HOME_DIR) -
      placed not in the root of the whole repository, -
      
      Enter and operate your cloud ecosystems available from `ansible` folder.

    - All chain flow work with detailed annotations you can see in Vortex Cloud interface 
      when trying to run any `./reference_*.sh` wrapper,
      which calls functions chains for able to instantly start and do develop anything are you want, 
      open easy interface with the way to create, develop, manage, migrate, 
      update or extend your Clouds with runned Services at Scale.
      
      If you are run any reference without input the necessary parameters, -
      Vortex Vx exit immanently  with detailed info about this error,
      and also say what to need to do with that.

    - `CI/CD Vortex Chained Pipeline Flows of Suites with Playbooks` designed with `anycloud` model, 
      when not code pass the flow, where `Cloud Vortex Toolset` says - 
      which he need necessary and by contract are wanted,
      from any input source who want to use any `reference_*.sh`.
      That statement says we can use for run the `Vortex Vx Flow` by any ` CI/CD Tools Solution Product`,
      such as `Jenkins`, `Gitlab-CI`, `TeamCity`, and other capabilities for that software. 
      
      Maybe like `cron`.

    - So, because the interface for talking to platform box are knowns and we can use any way to run pipe, 
      by same way, like it will same way to hapen in next time on build by any tool, 
      then say me - I can imitate the `Pushing CI Button or CI Triggers`.
      Also, its are great way to test all features completely, 
      from the same code for preparing an awesome featured release.

    - For running any Shell CI Button, go to `ansible` HOME_DIR =)

    - Try to run something from `./\!_test/[A-Z]*.sh` - all DevOps Shell Imitation CI Buttons
      wrote with the same Pipeline, which itself represents any `CI/CD Tools Product` at any Run. 
      
      Only for development and testing, no play with fire.

    ### PROTOTYPE MODEL BLANK PIPE WITH BUILD RUN AT ANSIBLE TESTS

    - LF EDGE EVE CI dev/test Imitation Button Run in Continuous Development is - 
      
        `./\!_tests/LF_EDGE_EVE_DEVELOPMENT.sh`

   ```

      PS.  
          ALL TESTS SHELL CI BUTTONS HAVE UPPERCASE CHARACTERS.
          AND MAY BE RIGHT WAY WILL BE LOOKING TO INSIDE BEFORE =)

   ```

    - To contribute and correct usage complete solution, -
      you must create `Internal Vault` for your profile ` Internal Vault Contract`.

## Examples of usage the inventories children -

### One to multiple, where one as a parent:

We have one primary inventory, on some product, some cloud type provider as total, -

            one compute environment, - {{ ansible_environment }} == 'production'

But wants to placement multiple virtual environments on the same Datacenter to same VMs environment

All linked environments, which we want to add as children like virtual, looks and works by the symlinks way.

Let's do like for example, two Childs of Primary - development and stage environments,

- Create the new folders in API Cloud Inventory -

    ```
         ./0z-cloud/products/\!_{{ cloud_type }}/{{ ansible_product }}/developemnt/
         ./0z-cloud/products/\!_{{ cloud_type }}/{{ ansible_product }}/stage/
    ```

- Create symlinks from Parent Primary Cloud dynamic Environment to his new children -

    ```
         mkdir ./0z-cloud/products/\!_{{ cloud_type }}/{{ ansible_product }}/stage/
         cd ./0z-cloud/products/\!_{{ cloud_type }}/{{ ansible_product }}/stage/
         ln -s ../production/v.py
         ln -s ../production/bootstrap_vms
    ```

- Copy the Target inventory from Parent to New, first of all, create a target inventories locations -

    ```
         src_environment="production"
         new_environment="stage"
         
         mkdir ./products/{{ ansible_product }}/{{ new_environment }}
         
         old_from_env="./products/{{ ansible_product }}/{{ src_environment }}/*"
         new_env_path="./products/{{ ansible_product }}/{{ new_environment }}/"
         
         cp -R $old_from_env $new_env_path
    ```
    
- Done, now change the domain names and ports settings on your new cloud target children from production environments, and deploy!

### Create a new environment (API and target) by cloning some as parent:

- Makes new inventories from scratch, with examples and descriptions about why we need those and for what

       ./\!_mk_new_env.sh production vortex bare symlink bare setta vortex

- Necessary input values to select your way to create a new environment, product, scale,
  or during some migrate or update to your infrastructure.

      1. inventory:    
          
          Parent inventory is must be specified, which be a donor for new inventory

      2. product:      
          
          Parent product is must be specified, which be a donor for new cloud-config

      3. type cloud:   
          
          Parent cloud type is must be specified, like { vsphere / alicloud / bare / etc }

      4. run type:     
      
          Type of spawning the scratcher, from other repo, ways for choice {clone/symlink}

      5. type cloud:   
      
          Target cloud type is must be specified, such as like -
          
          { aws / azure / do / vcd / vsphere / yandex / gcp / alicloud / bare / etc }

      6. inventory:    
          
          Target inventory is must be specified, -
          which be a result of new inventory for cloud location

      7. product:      
          
          Target product is must be specified, which be a result for new cloud location

### Code Cloud Liquid Coin Database 

* Localhost simple web integrated API Client overview:


![UI.png](ansible/CI/repo_images/CodeCloudCoinClientUIatLocalHost.png)
