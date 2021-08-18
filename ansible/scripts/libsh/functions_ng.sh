#!/bin/bash
export ANSIBLE_KEEP_REMOTE_FILES=0
#export ANSIBLE_DEBUG=True
export ANSIBLE_PIPELINING=True
export ANSIBLE_SSH_PIPELINING=True
export ACTION_WARNINGS=False
export ANSIBLE_ENABLE_TASK_DEBUGGER=True
export ANSIBLE_STDOUT_CALLBACK=super_debug
#export ANSIBLE_STDOUT_CALLBACK=anstomlog
#export ANSIBLE_STDOUT_CALLBACK=anstomlog
teamcity_run_check_for_set_output_callback_ansible_type(){

    if [[ ! -z "$ansible_ci_cd_runned_marker" ]]; then
        export ANSIBLE_STDOUT_CALLBACK=teamcity
    elif [[ -z "$ansible_output_stdout_plugin" ]]; then
        export ANSIBLE_STDOUT_CALLBACK=default
    fi
    if [[ "$ansible_output_stdout_plugin" == "anstomlog" ]]; then
        export ANSIBLE_STDOUT_CALLBACK=anstomlog
    fi
    if [[ "$ansible_output_stdout_plugin" == "json" ]]; then
        export ANSIBLE_STDOUT_CALLBACK=json
    fi
    if [[ "$ansible_output_stdout_plugin" == "minimal" ]]; then
        export ANSIBLE_STDOUT_CALLBACK=minimal
    fi
    if [[ "$ansible_output_stdout_plugin" == "yaml" ]]; then
        export ANSIBLE_STDOUT_CALLBACK=yaml
    fi
    if [[ "$ansible_output_stdout_plugin" == "debug" ]]; then
        export ANSIBLE_STDOUT_CALLBACK=debug
    fi
    if [[ "$ansible_output_stdout_plugin" == "actionable" ]]; then
        export ANSIBLE_STDOUT_CALLBACK=actionable
    fi

}

teamcity_run_check_for_set_output_callback_ansible_type;

get_all_cloud_adapters(){

    API_ADAPTER_DIR=$1

    API_ADAPTERS_ROOT="$API_ADAPTER_DIR/\!_root_playbooks/"

    API_ADAPTERS_ARRAY_LIST=`ls -la $API_ADAPTERS_ROOT | awk '{print $9}' | tail -n +4 | egrep -v '(md|sh|yml)'`

}

clear_vcd_adapter_logs(){
    
    primary_root_for_clean=$1

    find ${primary_root_for_clean}/ | grep vcd | grep log | grep -v 'py' | xargs -I ID rm -f ID

}

all_hosts_echo(){

    if [ "$type_of_run" != "run_from_wrapper" ]; then

        terminal_custom_logging "
        
            |>..........................................................................................................................................................................................<|
                Start checking echo from all hosts
            |>..........................................................................................................................................................................................<|
                " "info"

    fi 

    if [ "$nowait" = "true" ] && [ "$type_of_run" != "run_from_wrapper" ]; then
        
        terminal_custom_logging "
        
                Run from wrapper - no awaiting
                
                " "info"

    else

    function_selector_runner ansible -m shell -a \"'echo 1; hostname"' -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        all -u $username --become-user root --become \
        -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'"

    fi

}

default_type(){

    echo "ok"

    # need to be separetad injoinable by request by periods of time

    # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
    # "$ansible_dir"/playbook-library/!_bootstrap/letsencrypt-pacemaker.yml \
    # -u $username --become-user root \
    # --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="3" \
    # -e "acme_domain_for_obtain='$certificate_prefix'" -e acme_domain_prefix_txt="_acme-challenge.$certificate_prefix"
 
}

update_core_dns_service_frontend(){

    terminal_custom_logging "

                    Starting: ${RED}UPDATE CORE DNS SERVICE${NC}
            
                    " "trace"

    if [ "$inventory" != "production" ]; then

        terminal_custom_logging "
        
                    ${YELLOW}Inventory${NC} not a ${RED}production${NC}, current environment is: $inventory
                    ${GREEN}Updating the frontend dns configuration${NC}
                
                    " "info"

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/production/ \
            "$ansible_dir"/playbook-library/!_bootstrap/core-dns.yml \
            -e HOSTS="cloud-bind-frontend-dns" -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="2"

    else

        terminal_custom_logging "
        
                    ${YELLOW}Inventory${NC} is a ${GREEN}production${NC}
                    ${GREEN}Updating the frontend dns configuration${NC}
                
                    " "info"

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/!_bootstrap/core-dns.yml \
            -e HOSTS="cloud-bind-frontend-dns" -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="2"

    fi

    terminal_custom_logging "

                    Completed: ${RED}UPDATE CORE DNS SERVICE${NC}
            
                    " "trace"

}

run_req_function(){

    inventory="$1"
    product="$2"
    username="$3"
    password="$4"
    apps="$5"
    type_of_run="$6"
    typeofcloud="$7"
    vault_pass="$8"
    ansible_global_gitlab_registry_site_name="$9"
    gitlab_project_name="${10}"
    gitlab_project_group="${11}"
    version_ansible_build_id="${12}"
    deploy_environment_security_configuration="${13}"
    cluster_type="${14}"
    registry_username="${15}"
    registry_token="${16}"
    ANSIBLE_COMMIT_SHA="${17}"
    ANSIBLE_BUILD_ID="${18}"
    extra_args_type_of_run="${19}"

    terminal_custom_logging "

                    Inventory: $inventory
                    Product: $product
                    Username: $username
                    Password: $password
                    Application Groups: $apps
                    Type of Run: $type_of_run
                    Type of Cloud: $typeofcloud
                    Personal Vault Password: $vault_pass
                    Docker registry URL: $ansible_global_gitlab_registry_site_name
                    VCS Project Name: $gitlab_project_name
                    VCS Project Group: $gitlab_project_group
                    VCS VERSION Build ID: $version_ansible_build_id
                    Environment Security: $deploy_environment_security_configuration
                    Cluster map and types of configuration layout: $cluster_type
                    Registry Username: $registry_username
                    Registry Token: $registry_token
                    
                    " "info"

    check_input_inventory $inventory

    check_input_product $product

    check_input_username $username

    check_input_password $password

    check_input_apps $apps

    check_type_of_run_input $type_of_run

    check_type_of_cloud_input $typeofcloud

    check_input_vault_password $vault_pass

    check_input_registry_url $ansible_global_gitlab_registry_site_name

    check_input_vcs_project_name $gitlab_project_name

    check_input_vcs_project_group $gitlab_project_group

    check_input_version $version_ansible_build_id

    terminal_custom_logging "             

                    ${RED}Inventory${NC}: $inventory
                    ${RED}Product${NC}: $product
                    ${RED}Username${NC}: $username
                    ${RED}Password${NC}: $password
                    ${GREEN}Ansible Vault Password:${NC} ********* 
                    ${RED}Application Groups${NC}: $apps
                    ${RED}Type of Run${NC}: $type_of_run
                    ${RED}Type of Cloud${NC}: $typeofcloud
                    ${RED}Personal Vault Password${NC}: $vault_pass
                    ${RED}Docker registry URL${NC}: $ansible_global_gitlab_registry_site_name
                    ${RED}VCS Project Name${NC}: $gitlab_project_name
                    ${RED}VCS Project Group${NC}: $gitlab_project_group
                    ${RED}VCS VERSION Build ID${NC}: $version_ansible_build_id
                    ${RED}Environment Security${NC}: $deploy_environment_security_configuration
                    ${RED}Cluster map and types of configuration layout${NC}: $cluster_type
                
                " "trace"

    check_security_type_function $deploy_environment_security_configuration
    check_cluster_type_function $cluster_type
    check_registry_username $registry_username
    check_registry_token $registry_token
    check_ansible_commit_sha $ANSIBLE_COMMIT_SHA
    check_ansible_build_id $ANSIBLE_BUILD_ID

}

check_ansible_build_id(){

    ANSIBLE_BUILD_ID=$1

    if [[ "$ANSIBLE_BUILD_ID" == "" ]]; then

        terminal_custom_logging "

                    Usage: $0 ${RED}ANSIBLE_BUILD_ID${NC} is must to be a specified! 
            
                    " "red"

        print_run_info
        exit 1

    else

        terminal_custom_logging "

                    no Rewrite: ${RED}ANSIBLE_BUILD_ID is${NC} is $ANSIBLE_BUILD_ID a specified! 
                    
                    " "info"

    fi

}

check_ansible_commit_sha(){

    ANSIBLE_COMMIT_SHA=$1

    if [[ "$ANSIBLE_COMMIT_SHA" == "" ]]; then

        terminal_custom_logging "

                    Usage: $0 ${RED}ANSIBLE_COMMIT_SHA${NC} is must to be a specified! So, go rewrite...
            
                    " "info"
        

        builded_commit=`git log --pretty=format:'%h' | tail -n -1`

        ANSIBLE_COMMIT_SHA=${builded_commit}
        export ANSIBLE_COMMIT_SHA=$ANSIBLE_COMMIT_SHA
        
        terminal_custom_logging "

                    Rewrite: ${RED}ANSIBLE_COMMIT_SHA${NC} is $ANSIBLE_COMMIT_SHA a specified! 
            
                    " "red"

    fi

}

check_registry_token(){

    registry_token=$1

    if [[ "$registry_token" == "" ]]; then
        
        terminal_custom_logging "
            
                    Usage: $0 ${RED}registry_token${NC} is must to be a specified! 
            
                    " "red"
        
        print_run_info
        exit

    fi

}

check_registry_username(){

    registry_username=$1

    if [[ "$registry_username" == "" ]]; then

        terminal_custom_logging "

                    Usage: $0 ${RED}registry_username${NC} is must to be a specified! 
            
                    " "red"
        
        print_run_info
        exit

    fi

}

check_type_of_run_input(){

    type_of_run=$1

    if [[ "$type_of_run" == "" ]]; then

        terminal_custom_logging "
        
                    ${YELLOW}Usage${NC}: $0 ${BLUE}type_of_run${NC} ${RED}is must to be a specified${NC}, and can be:

                        ${BLUE_BACK}create${NC} / ${BLACK_TO_WHITE}destroy${NC} / ${GREEN}update${NC} / ${RED}rollback${NC} / 
                    
                        ${BLUE}print_only${NC} / ${CYAN}debug${NC} / ${LM}cloud_regen${NC} / ${RED}true${NC} / ${GREEN}false${NC}
                
                          
                    ${RED}IMPORTANT NOTIFY${NC} : ${BLUE}run_from_wrapper${NC}

                    For partial run you must write which playbooks sections to be running:

                        ./\!_all_service_deployer.sh ${GREEN}develop${NC} ${RED}vortex${NC} vortex ${RED}1235${NC} ${BLUE}type_of_run${NC}

                        ${BLACK_TO_WHITE}Like${NC} example some role: ${BLACK_TO_WHITE}docker${NC} / ${BLACK_TO_WHITE}consul${NC} / ${BLACK_TO_WHITE}dns${NC} 

                        ${BLACK_TO_WHITE}percona${NC} / ${BLACK_TO_WHITE}glusterfs${NC} / ${BLACK_TO_WHITE}etc${NC}
                
                    " "red"


        terminal_custom_logging "

                    ${RED}False to validate the type of run!${NC}
        
                    " "red"

        print_run_info
        exit

    else

        if [[ "$type_of_run" == "destroy" ]] || [[ "$type_of_run" == "update" ]] || [[ "$type_of_run" == "rollback" ]] || [[ "$type_of_run" == "print_only" ]] || [[ "$type_of_run" == "scale" ]] || [[ "$type_of_run" == "debug" ]] || [[ "$type_of_run" == "true" ]] || [[ "$type_of_run" == "cloud_regen" ]] || [[ "$type_of_run" == "false" ]]; then

            if [[ "$type_of_run" != "run_from_wrapper" ]]; then

                terminal_custom_logging "

                    Passed value: ${RED}$type_of_run${NC} to run
                
                    " "info"

            fi

        else

            terminal_custom_logging "
            
                    ${RED}False to validate the type of run!${NC}
                    Usage: $0 type_of_run is must to be a specified, and can be a true or false!
            
                    " "red"
            exit

        fi

    fi

}

check_type_of_cloud_input(){

    typeofcloud=$1

    if [[ "$typeofcloud" == "" ]] && [[ $typeofcloud != "vcd" ]] && [[ $typeofcloud != "vsphere" ]] && [[ $typeofcloud != "alicloud" ]] && [[ $typeofcloud != "bare" ]]; then

        terminal_custom_logging "
                
                    ${YELLOW}Usage${NC}: $0 ${BLUE}type of cloud${NC} ${RED}is must to be a specified${NC}, and can be:

                        ${BLUE_BACK}vcd${NC} / ${BLACK_TO_WHITE}alicloud${NC} / ${GREEN}bare${NC} / ${RED}vsphere${NC} / 
                    
                        ${BLUE}aws${NC} / ${CYAN}google${NC} / ${LM}azure${NC} / ${RED}digitalocean${NC} / ${GREEN}etc${NC}
                
                    " "red"
    

        terminal_custom_logging "

                    ${RED}False to validate the type of cloud!${NC}
            
                    " "red"

        print_run_info
        exit

    else

        terminal_custom_logging "

                    ${RED}Type of cloud $typeofcloud validated the type of cloud!${NC}
            
                    " "green"

    fi

}

check_input_apps(){

    apps=$1

    if [[ "$apps" == "" ]]; then

        terminal_custom_logging "

                    Usage: $0 ${RED}apps${NC} is must to be a specified! 
                    Apps Param: must be once from true / false 
            
                    " "red"

        print_run_info
        exit

    fi

}

check_input_vault_password(){

    vault_passowrd=$1

    if [[ "$vault_passowrd" == "" ]]; then

        terminal_custom_logging "

                    Usage: $0 ${RED}vault_password ${NC} is must to be a specified!
            
                    " "red"

        print_run_info
        exit

    fi

}

check_input_password(){

    password=$1

    if [[ "$password" == "" ]]; then

        terminal_custom_logging "
        
                    Usage: $0 ${RED}password${NC} is must to be a specified!
                
                    " "red"

        print_run_info
        exit

    fi

}

check_input_registry_url(){

    registry_url=$1

    if [[ "$registry_url" == "" ]]; then

        terminal_custom_logging "
        
                    Usage: when run $0 the Docker Registry URL as ${RED}registry_url${NC} is must to be a specified!
                    
                    " "red"

        print_run_info
        exit

    fi

}

check_input_username(){

    username=$1

    if [[ "$username" == "" ]]; then

        terminal_custom_logging "
                    
                    Usage: $0 ${RED}username${NC} is must to be a specified!
                    
                    " "red"

        print_run_info
        exit

    fi

}

check_input_product(){

    product=$1

    if [[ "$product" == "" ]]; then

        terminal_custom_logging "

                    Usage: $0 ${RED}product${NC} is must to be a specified!
                    
                    " "red"

        print_run_info
        exit

    fi

}

check_input_inventory(){

    inventory=$1

    if [[ "$1" == "" ]]; then

        terminal_custom_logging "
                    
                    Usage: $0 ${RED}inventory${NC} is must to be a specified!
                    
                    " "red"

        print_run_info
        exit

    fi

}

check_security_type_function(){

    deploy_environment_security_configuration=$1

    if [[ "$deploy_environment_security_configuration" == "" ]]; then

        terminal_custom_logging "

                    Usage: $0 ${RED}Security Type${NC} is must to be a specified!
                    
                        Valid Types for: $0 ${GREEN}pci${NC} | ${RED}minimal${NC} | ${BLUE}standalone${NC}

                    " "red"

        print_run_info
        exit

    else

        if [[ "$deploy_environment_security_configuration" != "pci" ]] && [[ "$deploy_environment_security_configuration" != "minimal" ]] && [[ "$deploy_environment_security_configuration" != "standalone" ]]; then

            terminal_custom_logging "

                    ${RED}WARNING!${NC} Incorrect ${RED}Security Type${NC} is must have to be one of this values:
                    
                        Valid Types for: $0 ${GREEN}pci${NC} | ${RED}minimal${NC} | ${BLUE}standalone${NC}

                    " "red"

            print_run_info
            exit

        fi

    fi

}
check_cluster_type_function(){

    cluster_type=$1

    if [[ "$cluster_type" == "" ]]; then

        terminal_custom_logging "
        
                    Usage: $0 ${RED}Cluster Type${NC} is must to be a specified!
        
                        Valid Types for: $0 ${GREEN}k8s${NC} | ${RED}swarm${NC} | ${BLUE}none${NC}
                        
                    " "red"

        print_run_info

        exit

    else

        if [[ "$cluster_type" != "k8s" ]] && [[ "$cluster_type" != "swarm" ]] && [[ "$cluster_type" != "none" ]]; then

            terminal_custom_logging "
                    ${RED}WARNING!${NC} Incorrect cluster type, pipeline must have one of this values: 
                    
                        ${GREEN}k8s${NC} | ${RED}swarm${NC} | ${BLUE}none${NC}
                    
                    " "red"

            print_run_info
            exit
        
        else

            if [[ "$cluster_type" == "k8s" ]] && [[ "$deploy_environment_security_configuration" == "standalone" ]]; then 

                terminal_custom_logging "
                
                    ${RED}WARNING!${NC} Deployment strategy cannot be ${RED}k8s${NC} and ${RED}standalone${NC} in same time: 
                
                        Please change the ${RED}Cluster Type${NC} or Security configuration!
                
                " "red"

                print_run_info
                exit

            fi

            if [[ "$cluster_type" == "swarm" ]] && [[ "$deploy_environment_security_configuration" == "standalone" ]]; then 

                terminal_custom_logging "
                
                    ${RED}WARNING!${NC} Deployment strategy cannot be ${RED}swarm${NC} and ${RED}standalone${NC} in same time: 
                
                        Please change the ${RED}Cluster Type${NC} or Security configuration!
                    
                " "red"

                print_run_info
                exit

            fi

            if [[ "$cluster_type" == "none" ]] && [[ "$deploy_environment_security_configuration" != "standalone" ]]; then

                terminal_custom_logging "
                
                    ${RED}WARNING!${NC} Deployment strategy cannot be ${RED}none${NC} and ${RED}not a standalone${NC} in same time: 
                
                        Please change the ${RED}Cluster Type${NC} or Security configuration!
                
                " "red"

                print_run_info
                exit

            fi


        fi

    fi


}

os_echo(){

    root_dir_path=$1

    terminal_custom_logging "

                    Start install requirements to localhost which OS TYPE: $uname
                    
                    " "info"

    $root_dir_path/scripts/requirements/requirements.sh $uname

    terminal_custom_logging "
    
                    Done install requirements to localhost
                    
                    " "info"

}

run_req(){

    typeofcloud=$1
    uname=$2
    root_dir_path=$3
    
    #clear_vcd_adapter_logs;

    terminal_custom_logging "CLOUD TYPE REQ: $typeofcloud" "info"

    terminal_custom_logging "RUNNED REQ: $uname" "info"

    if [ "$uname" == "Darwin" ]; then

        os_echo $root_dir_path;

    elif [ "$uname" == "Linux" ]; then

        os_echo $root_dir_path;

    elif [ "$uname" == "MINGW32_NT" ]; then
        
        os_echo $root_dir_path;

    elif [ "$uname" == "MINGW64_NT" ]; then

        #terminal_line
        terminal_custom_logging "Current run OS cannot pass checks ${GREEN}${uname}${NC} not validated" "info"
        #terminal_line
        exit 1
    fi

}

logit(){
    echo -e "[${USER}][`date`] - ${*}" >> ${LOG_FILE_NAME}
}

usage_cloud(){

    set=$1
    info_name=$2

    #terminal_line
    terminal_custom_logging "
    
                Usage: $0 ${RED}Select Cloud Provider${NC} is must to be a specified!

                Avaliable options: $0 ${T1_T1}vsphere${NC} / ${T1_T1}alicloud${NC} / ${T1_T1}bare${NC} / ${T1_T1}vcd${NC}
        
                " "red"

    #terminal_line
    eval $info_name
    #"print_run_info"

    if [ "$set" = 'ERROR' ]; then 

        exit

    fi

}

vault_ng(){

    decrypt_vault_pass=$1
    username=$2
    vault_job_type=$3
    product=$4
    typeofcloud=$5
    inventory=$6
    root_path_dir=$7
    ansible_dir=$8
    LOCAL_DIRECTORY=$9

    #terminal_line;
    terminal_custom_logging "
            
            VAULT NG
            
            " "info"
    #terminal_line;
    terminal_custom_logging "
            
            Inventory: $inventory
            Type of Cloud: $typeofcloud
            Product: $product
            Vault Job Type: $vault_job_type
            Local Directory: $LOCAL_DIRECTORY
            Root Path: $root_path_dir
            Username: $username
            Ansible Directory Path: $ansible_dir
            
            " "info"

    #terminal_line

    if [[ ! -d "$LOCAL_DIRECTORY" ]]; then

        mkdir -p $LOCAL_DIRECTORY

    fi

   "$ansible_dir"/.files/vault_container.sh "$username" "$product" "$vault_job_type" "$decrypt_vault_pass" "$typeofcloud" "$inventory"

}

check_for_changes(){

    terminal_custom_logging "
            
                    START CHECK FOR CHANGES

                    logic_folders: $logic_folders
            
                    " "info"

    set -e

    logic_folders=$@

    commit=`diff --old-line-format='' --new-line-format='' <(git rev-list --first-parent develop) <(git rev-list --first-parent HEAD) | head -1`
    branch=`git rev-parse --abbrev-ref HEAD`

    if [ $branch = "qa" ]; then
        echo 1
    elif [ $branch = "master" ]; then
        echo 1
    else
        for folder in ${logic_folders[@]}; do

            changes=$(git diff --relative=$folder $commit --quiet --; echo $?)

            terminal_custom_logging "
            
                    SHOW CHECKED CHANGES
                    
                    folder: $folder
                    changes: $changes
            
                    " "info"

            if [ $changes = 1 ]; then

                echo 1

            else

                echo 0

            fi

        done
    fi
    
}

run_req_vault_pass(){

    vault_pass_in=$1

    if [ -z "$vault_pass_in" ];then


        terminal_custom_logging "
        
                Usage: $0 ${RED}vault_pass${NC} is must to be a specified!
                
                " "red"


        print_run_info   

        exit 1

    fi

    terminal_custom_logging "      
    
                Vault password: ***********

                " "red"

}

run_req_registry_sitename(){

    ansible_global_gitlab_registry_site=$1

    if [ -z "$ansible_global_gitlab_registry_site" ];then

        terminal_custom_logging "
        
                Usage: $0 ${RED}ansible_global_gitlab_registry_site${NC} is must to be a specified!
                
                " "red"

        print_run_info   

        exit 1

    fi

    terminal_custom_logging "Docker registry uri: $ansible_global_gitlab_registry_site" "info"

}

run_req_gitlab_project_group(){

    ansible_global_gitlab_project_group=$1

    if [ -z "$ansible_global_gitlab_project_group" ];then

        #terminal_line
        terminal_custom_logging "
        
                Usage: $0 ${RED}ansible_global_gitlab_project_group${NC} is must to be a specified!
                
                " "red"

        #terminal_line
        print_run_info   
        exit 1

    fi


    terminal_custom_logging "
    
                Project group: $ansible_global_gitlab_project_group
            
                " "info"

}

run_req_gitlab_project_name(){

    ansible_global_gitlab_project_name=$1

    if [ -z "$ansible_global_gitlab_project_name" ];then

        terminal_custom_logging "
        
                Usage: $0 ${RED}ansible_global_gitlab_project_name${NC} is must to be a specified!
                
                " "red"

        print_run_info   

        exit 1

    fi

    terminal_custom_logging "
    
                Project name: $ansible_global_gitlab_project_name
                
                " "info"

}

usage_cloud(){

    set=$1

    terminal_custom_logging "
    
                            Usage: $0 ${RED}Select Cloud Provider${NC} is must to be a specified!
    
                                Avaliable options: $0 ${T1_T1}vsphere${NC} / ${T1_T1}alicloud${NC} /  ${T1_T1}bare${NC} / ${T1_T1}vcd${NC}
                
                            " "red"
    
    print_run_info

    if [ "$set" = 'ERROR' ]; then

        exit

    fi

}

install_requirements(){

    typeofcloud=$1

    terminal_custom_logging "
    
                            ${GREEN}Type of Cloud${NC} in install_requirements $typeofcloud
                
                            " "info"

    if [ -z "$typeofcloud" ]; then

        terminal_custom_logging "
        
                            ${RED}Type is null, possible die:${NC} ${type_of_run}
                
                            " "debug"

        set=ERROR

        usage_cloud $set;

    else

        terminal_custom_logging "     
        
                ${GREEN}|>.........................................................................................................................................................................................<|${NC}
                            Start the Services Wrapper to perform on type of cloud ${typeofcloud}
                ${GREEN}|>.........................................................................................................................................................................................<|${NC}
                
                            " "info"

        if [ "$typeofcloud" == "vsphere" ] || [ "$typeofcloud" == "alicloud" ] || [ "$typeofcloud" == "bare" ]; then

            CLOUD_PROVIDER="${typeofcloud}"
            terminal_custom_logging "
                    
                            RUN WITH CLOUD_PROVIDER: $CLOUD_PROVIDER
                    
                            " "debug"
            
            #run_req $typeofcloud $uname;

        else

            usage_cloud $set;

        fi
    fi

}

# ${RED} {****************************************************************************************************************************************************************************************************}${NC}
# ${BLACK_TO_WHITE}{****************************************************************************************************************************************************************************************************}${NC}
#           ${GREEN}|>--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------<|${NC}
#

# ${BLUE}NO_WAIT VM BOOTUP:${NC}

#     - true / false

#WIP

print_run_info(){ 

    pipelinename=$SCRIPT_NAME

    echo -e "      ${YELLOW}INFO${NC}: WRAPPER NAME IS ${RED}./${pipelinename}${NC}
      ${YELLOW}{****************************************************************************************************************************************************************************************************}
      ${NC}${BLACK_TO_WHITE}{*}${NC} NECESSARY PARAMETERS:
      ${YELLOW}{****************************************************************************************************************************************************************************************************}
      | ENV | PRODUCT | USERNAME | PASSWORD | APPS | TYPE OF RUN | CLOUD_TYPE | VAULT PASS | REGISTRY URL | A PROJECT NAME | GIT GROUP | VERSION | SECURITY | CLUSTER | HUB USER | TOKEN | SHA | BUILD ID |
      |     |         |          |          |      |             |            |            |              |                |           |         |          |         |          |       |     |          |
      | ${NC}${GREEN}dev${NC}${YELLOW} | ${NC}${RED}vortex ${NC} ${YELLOW}|${NC} vortex${YELLOW}   | ${NC}password${YELLOW} | ${NC}core${YELLOW} | ${NC}${YELLOW}print_only${NC}${YELLOW}  | ${NC}${BLACK_TO_WHITE}cloud_type${NC}${YELLOW} | ${NC}${RED}vault_pass${NC}${YELLOW} | ${NC}${RED}hub.abc.su${NC} ${YELLOW}  | ${NC}vortex_engine ${YELLOW} | ${NC}vortex    ${YELLOW}| ${NC}777-sha ${YELLOW}| ${NC}${GREEN}pci${NC}      ${YELLOW}|${NC} k8s     ${YELLOW}|${NC} docker   ${YELLOW}|${NC} token ${YELLOW}|${NC} sha ${YELLOW}|${NC} 27761247 ${YELLOW}|
      |     |         |          |          |      |             |            |            |              |                |           |         |          |         |          |       |     |          |
      {****************************************************************************************************************************************************************************************************}${NC} 
      ${BLACK_TO_WHITE}{*}${NC} ${YELLOW}Example Run${NC}: 
      
      ./\!_${pipelinename} ${GREEN}development${NC} ${RED}vortex${NC} vortex password rails ${BLUE}true${NC} ${YELLOW}true${NC} ${BLACK_TO_WHITE}cloud_type${NC} ${RED}vault_pass${NC} ${RED}hub.abc.su${NC} vortex_engine vortex 1234-sha ${GREEN}pci${NC} k8s registry_user registry_token sha build_id
      
      ${YELLOW}{****************************************************************************************************************************************************************************************************}${NC}"
   echo -e "        
      ${BLACK_TO_WHITE}{*}${NC} POSSIBLE VALUES:

               ${GREEN}ENVIRONMENT:${NC} 

                - development / stand / stage / sandbox / testing / production / etc

            ${RED}PRODUCT:${NC}

                - vortex / your_product_name / matreshka / office / moscow / london / etc

            ${YELLOW}TYPE_OF_RUN:${NC}

                - true (AUTORUN THE WRAPPER)
                - false (DIFFERENT RUN THE WRAPPER)
                - ${RED}print_only${NC} (PRINT COMMANDS TO RUN, SHOW ONLY WHAT HAPPENED IF BE TRUE)

            ${BLACK_TO_WHITE}TYPE_OF_CLOUD:${NC} 

                - alicloud / digitalocean / azure / aws / vsphere / vcd / google / etc
                - ${RED}bare${NC} (baremetal - can be used for any as default and simplest)
                "

}

docker_build_function(){

    username=$1
    product=$2
    typeofcloud=$3
    inventory=$4
    root_path_dir=$5
    ansible_dir=$6
    runpath=$7
    LOCAL_DIRECTORY=$8
    registry_username=$9
    registry_token=${10}
    ansible_global_gitlab_registry_site_name=${11}
    gitlab_project_group=${12}
    gitlab_project_name=${13}
    build_runpath="$root_path_dir"

    extended_applications=`ls -la "$root_path_dir"/extended/ | grep -v 'README.md' | awk '{print $9}' |sed 1,3d` 
    array_of_applications=`ls -la "$root_path_dir"/services/ | grep -v 'README.md' | awk '{print $9}' |sed 1,3d` 
    array_of_services=`ls -la "$root_path_dir"/dockerfiles/ | grep -v 'README.md' | awk '{print $9}' |sed 1,3d`
    array_of_docs=`ls -la "$root_path_dir"/docs/ | grep -v 'README.md' | awk '{print $9}' |sed 1,3d`

    IFS=$'\n' read -rd '' -a array_of_docs <<<"$array_of_docs"
    IFS=$'\n' read -rd '' -a array_of_services <<<"$array_of_services"
    IFS=$'\n' read -rd '' -a array_of_applications <<<"$array_of_applications"
    IFS=$'\n' read -rd '' -a extended_applications <<<"$extended_applications"

    terminal_custom_logging " 
                
                            ${RED}Docker login to registry${NC}
                
                            " "info"
    docker_login_result=`docker login "$ansible_global_gitlab_registry_site_name" -u "$registry_username" -p "$registry_token"`
    terminal_custom_logging "
    
                            Login result: $docker_login_result
         
                            " "info"

    function_applications_sorted_list_in_object
    function_ext_applications_sorted_list_in_object
    function_services_sorted_list_in_object
    function_docs_sorted_list_in_object

    terminal_custom_logging "
    
                            ${RED}Deploy applications${NC}: $applications_sorted_list_in_object

                            ${RED}Deploy services${NC}: $services_applications_sorted_list_in_object

                            ${RED}Deploy extended services${NC}: $extended_applications_sorted_list_in_object

                            ${RED}Deploy documents services${NC}: $docs_applications_sorted_list_in_object

                            " "info"

    for group_name in ${extended_applications[@]}; do

        group_root_path="${build_runpath}"/extended/"${group_name}"

        internal_services_list=$(ls -la "$group_root_path" | grep -v "README.md" | awk '{print $9}' | sed 1,3d)
        extended_services_list=`ls -la "$group_root_path" | grep -v 'README.md' | awk '{print $9}' |sed 1,3d` 
        IFS=$'\n' read -rd '' -a extended_services_list <<<"$extended_services_list"

        #declare -a extended_applications_list_in_groups_list=()
        #IFS=', ' read -r -a extended_applications_list_in_groups_list <<< ${internal_services_list[@]}
        #extended_applications_list=$(ls -la "$build_runpath"/extended/"$group_name"/ | grep -v "README.md" | awk '{print $9}' |sed 1,3d)

        for item_list_entity in ${extended_services_list[@]}; do

            terminal_custom_logging "
            
                            Container Group Name: $group_name
                            Project Root Path: ${build_runpath}
                            Group Root Path: $group_root_path
                            Container Image Name in Group Name: $item_list_entity
                            Dockerfile Build Path: $build_runpath/extended/${group_name}/${item_list_entity}
                    
                            " "info"
            build_and_validate "$item_list_entity" "extended" "by_group_name" "$group_name" "$root_path_dir" "$ansible_global_gitlab_registry_site_name" "$gitlab_project_group" "$gitlab_project_name" 

        done
    done

    declare -a array_of_applications_list=()
    IFS=', ' read -r -a array_of_applications_list <<< $array_of_applications

    declare -a array_of_services_list=()
    IFS=', ' read -r -a array_of_services_list <<< $array_of_services

    declare -a array_of_docs_list=()
    IFS=', ' read -r -a array_of_docs_list <<< $array_of_docs

    for item in ${array_of_applications[@]}; do

        build_and_validate "$item" "services" "" "" "$root_path_dir" "$ansible_global_gitlab_registry_site_name" "$gitlab_project_group" "$gitlab_project_name" 

    done

    for item in ${array_of_services[@]}; do

        build_and_validate "$item" "dockerfiles" "" "" "$root_path_dir" "$ansible_global_gitlab_registry_site_name" "$gitlab_project_group" "$gitlab_project_name" 

    done

    for item in ${array_of_docs[@]}; do

        build_and_validate "$item" "docs" "-docs" "" "$root_path_dir" "$ansible_global_gitlab_registry_site_name" "$gitlab_project_group" "$gitlab_project_name" 

    done

    echo "cat ${LOCAL_DIRECTORY}/current_tags.yml"

    cat "$LOCAL_DIRECTORY/current_tags.yml"

}

build_and_validate(){

    service_name_from=$1
    containers_root=$2
    containers_prefix=$3
    extended_type=$4
    root_dir=$5
    ansible_global_gitlab_registry_site_name=$6
    gitlab_project_group=$7
    gitlab_project_name=$8
    extra_full_path=$9

    if [[ "$containers_prefix" == "by_group_name" ]]; then

        terminal_custom_logging "
        
                            Extra Containers Group: $extended_type
                            Must to build: $MUST_BUILD
                            Start build special service: $service_name_from
                            Set build ID to latest
                            Full path to service: $extra_full_path

                            " "info"
    
        version_ansible_build_id="latest"

        cd ${root_dir}/${containers_root}/${extended_type}/${service_name_from}
        
        docker build -q -f Dockerfile -t ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from} ./ 
        docker build -q -f Dockerfile -t ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from}:$version_ansible_build_id ./ 
    
        docker build -q -f Dockerfile -t ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from}:$version_ansible_build_id ./ 
        
        docker build --pull -t ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from} . 
        docker tag ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from}:$version_ansible_build_id ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${version_ansible_build_id} 
        docker push ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from}:$version_ansible_build_id 

        cd ${root_dir}

        terminal_custom_logging "
        
                            Done build special service: $service_name_from
                
                            " "info"    
    else

        tags_get "$service_name_from" "$containers_root" "$containers_prefix" "${root_dir}";


        if [[ "$MUST_BUILD" -eq "1" ]]; then

            terminal_custom_logging "         
        
                            MUST_BUILD: $MUST_BUILD
                
                            " "info"


            build_image_and_push "$service_name_from" "$containers_root" "$containers_prefix" "${root_dir}" "$ansible_global_gitlab_registry_site_name" "$gitlab_project_group" "$gitlab_project_name" "$check_service_result"

        else 

        if [[ "$MUST_BUILD" -eq "2" ]]; then 

                terminal_custom_logging "
                
                            MUST_BUILD: $MUST_BUILD
                            Start build special service: $service_name_from
                            Set build ID to latest
                            
                            " "info"

                version_ansible_build_id="latest"

                cd ${root_dir}/${containers_root}/${service_name_from}
                
                docker build -q -f Dockerfile -t ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from} ./ 
                docker build -q -f Dockerfile -t ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from}:$version_ansible_build_id ./ 
            
                docker build -q -f Dockerfile -t ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from}:$version_ansible_build_id ./ 
                
                docker build --pull -t ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from} . 
                docker tag ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from}:$version_ansible_build_id ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${version_ansible_build_id} 
                docker push ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from}:$version_ansible_build_id 
                
                cd ${root_dir}

                terminal_custom_logging "
                
                            Done build special service: $service_name_from
                            
                            " "info"
            fi
        fi
    fi
}

tags_get(){

    service_name_from=$1
    containers_root=$2
    containers_prefix=$3
    root_dir=$4

    item="${service_name_from}${containers_prefix}"    
    service_path="${containers_root}/${item}"
    check_service_result=`check_for_changes $service_path`
    service_to_check_now=`echo $item | tr '-' '_'`

    terminal_custom_logging "        
        
                        Running for service with name: $item
                        Service to checking now: $service_to_check_now
                        Service path: $service_path
                        Service name from: $service_name_from
                        ${GREEN}Path to${NC} app: ${RED}${service_path}${NC}
                        ${GREEN}Start get changes in ${NC}app: ${RED}${item}${NC}

                        " "info"

    service_possible_childrens="${service_to_check_now}_"
    
    terminal_custom_logging "         
    
                        Service possible childrens: $service_possible_childrens
                        
                        " "info" 
    
    array_with_childrens=`cat "${root_dir}"/ansible/group_vars/\!_Applications_Core/"$apps"/"$apps"_settings_map.yml |  grep -e "$service_possible_childrens+*" | grep -o '[a-z].*: '  | grep "$service_possible_childrens" | cut -d : -f 1 | grep -v docs | grep -v mongo`    
    check_docker_stack_exists_run_commands=$(ansible -m shell -a "test -e /mnt/cloud-bind-glusterfs-storage/$inventory/stack/docker-stack.yml && echo 0 || echo 1 " -i "$root_dir"/ansible/inventories/products/$product/$inventory/ cloud-bind-frontend-dns[0] -u $username --become-user root --become -e "ansible_become_pass=$password" -e "ansible_ssh_pass=$password" )
    check_docker_stack_exists_run_commands_result=`echo $check_docker_stack_exists_run_commands | awk '{print $7}'`
    
    terminal_custom_logging "
                        
                        Result of checking the remote docker stack: $check_docker_stack_exists_run_commands_result 

                        ${GREEN}Changes in${NC} app: $item
                        
                        Check result ${RED}${check_service_result}${NC}
    
                        Service name: $service_to_check_now
                        Service possible sub apps: $service_possible_childrens
                        Possible apps list: $array_with_childrens
                    
                        " "info"

    terminal_custom_logging "
    
                        SECURITY CONFIGURATION IS: $deploy_environment_security_configuration
                    
                        " "info"

    case ${deploy_environment_security_configuration} in
        minimal) echo "sec_minimal_validate" ;;
        pci) echo "sec_pci_validate" ;;
        standalone) echo "sec_standalone_validate" ;;

        *) terminal_custom_logging "

                        ${RED}YOU MUST HAVE A SECURITY CONFIGURATION ARE CORRECT${NC}:
            
                        " "red";;
    esac

    if [[ "$deploy_environment_security_configuration" == "pci" ]]; then

        terminal_custom_logging "
        
                    START CHECKING TAGS FOR PCI CONFIGURATION
                    
                    CHECKING THE DB CONTAINERS ARRAY FOR PRESENTED CONTAINER TAG
                    
                    " "info"

        array_service_tag_from_files=$(eval 'cat "$root_dir"/ansible/group_vars/\!_ApplicationDocker_Template/docker-compose-template-pci-databases.yml | grep -A 3 "    $service_to_check_now:" | grep tag | cut -d \" -f 2')        
        check_int=`echo $array_service_tag_from_files | grep -q "{{ version_ansible_build_id }}" && echo 1 || echo 0`
        terminal_custom_logging "array_service_tag_from_files: ${array_service_tag_from_files}" "info"

        part_1=`ansible -m shell -a "cat /mnt/cloud-bind-glusterfs-storage/${inventory}/stack/docker-stack.yml | grep -A 1 \"    ${service_to_check_now}:\" | grep image | cut -d : -f 3 " -i "${root_dir}"/ansible/inventories/products/$product/$inventory/ cloud-bind-frontend-dns[0] -u $username --become-user root --become -e "ansible_become_pass=$password" -e "ansible_ssh_pass=$password"`
        echo "part_1: $part_1"
        return_code=`echo $part_1 | awk '{print $5}' | cut -d = -f 2`
        return_tag=`echo $part_1 | awk '{print $7}'`
        
        check_return_tag_int=`echo $return_tag | grep -q -E "[0-9]{4}.[0-9]{2}.[0-9]{2}-[0-9a-z]{8}$" && echo 1 || echo 0`

        terminal_custom_logging "

                        Show return tag $return_tag
                        Show return code $return_code
                        Show returned from remote docker-stack boolean status: $check_return_tag_int
                        Show check int value: $check_int
                        Show part 1 value: $part_1
                        
                        " "info"




        terminal_custom_logging "
        
                        array_service_tag_from_files: $array_service_tag_from_files
                        
                        " "info"

        if [ -z "$array_service_tag_from_files" ]; then

            terminal_custom_logging "
            
                        CHECKING THE SERVICES CONTAINERS ARRAY FOR PRESENTED CONTAINER TAG
                        
                        " "info"

            array_service_tag_from_files=$(eval cat "$root_dir"/ansible/group_vars/\!_ApplicationDocker_Template/docker-compose-template-pci-services.yml | grep -A 3 "    ${service_to_check_now}:" | grep tag | cut -d \" -f 2)        
            check_int=`echo $array_service_tag_from_files | grep -q "{{ version_ansible_build_id }}" && echo 1 || echo 0`
            terminal_custom_logging "array_service_tag_from_files: $array_service_tag_from_files" "info"

            part_1=`ansible -m shell -a "cat /mnt/cloud-bind-glusterfs-storage/${inventory}/stack/docker-stack.yml | grep -A 1 \"    $service_to_check_now:\" | grep image | cut -d : -f 3 " -i "$root_dir"/ansible/inventories/products/$product/$inventory/ cloud-bind-frontend-dns[0] -u $username --become-user root --become -e "ansible_become_pass=$password" -e "ansible_ssh_pass=$password"`
            echo "part_1: $part_1"
            return_code=`echo $part_1 | awk '{print $5}' | cut -d = -f 2`
            return_tag=`echo $part_1 | awk '{print $7}'`
            
            check_return_tag_int=`echo $return_tag | grep -q -E "[0-9]{4}.[0-9]{2}.[0-9]{2}-[0-9a-z]{8}$" && echo 1 || echo 0`

   
            terminal_custom_logging "Show return tag $return_tag
            Show return code $return_code" "info"
   
            terminal_custom_logging "array_service_tag_from_files: $array_service_tag_from_files" "info"

        fi

        if [ -z "$array_service_tag_from_files" ]; then

            terminal_custom_logging "CHECKING THE VPN CONTAINERS ARRAY FOR PRESENTED CONTAINER TAG" "info"

            array_service_tag_from_files=$(eval 'cat ansible/group_vars/\!_ApplicationDocker_Template/docker-compose-template-pci-vpn.yml | grep -A 3 "    $service_to_check_now:" | grep tag | cut -d \" -f 2')        
            check_int=`echo $array_service_tag_from_files | grep -q "{{ version_ansible_build_id }}" && echo 1 || echo 0`
            terminal_custom_logging "array_service_tag_from_files: $array_service_tag_from_files" "info"

            part_1=`ansible -m shell -a "cat /mnt/cloud-bind-glusterfs-storage/${inventory}/stack/docker-vpn-stack.yml | grep -A 1 \"    $service_to_check_now:\" | grep image | cut -d : -f 3 " -i "$root_dir"/ansible/inventories/products/$product/$inventory/ cloud-bind-frontend-dns[0] -u $username --become-user root --become -e "ansible_become_pass=$password" -e "ansible_ssh_pass=$password"`
            echo "part_1: $part_1"
            return_code=`echo $part_1 | awk '{print $5}' | cut -d = -f 2`
            return_tag=`echo $part_1 | awk '{print $7}'`
            
            check_return_tag_int=`echo $return_tag | grep -q -E "[0-9]{4}.[0-9]{2}.[0-9]{2}-[0-9a-z]{8}$" && echo 1 || echo 0`

            terminal_custom_logging "Show return tag $return_tag
            Show return code $return_code" "info"
   
            terminal_custom_logging "array_service_tag_from_files: $array_service_tag_from_files" "info"

        fi

        if [ -z "$array_service_tag_from_files" ]; then

            terminal_custom_logging "CHECKING THE SECURITY SERVICES CONTAINERS ARRAY FOR PRESENTED CONTAINER TAG" "info"

            array_service_tag_from_files=$(eval 'cat "$root_dir"/ansible/group_vars/\!_ApplicationDocker_Template/docker-compose-template-pci-security-apps.yml | grep -A 3 "    $service_to_check_now:" | grep tag | cut -d \" -f 2')        
            check_int=`echo $array_service_tag_from_files | grep -q "{{ version_ansible_build_id }}" && echo 1 || echo 0`
            terminal_custom_logging "array_service_tag_from_files: $array_service_tag_from_files" "info"

            part_1=`ansible -m shell -a "cat /mnt/cloud-bind-glusterfs-storage/${inventory}/stack/docker-security-stack.yml | grep -A 1 \"    $service_to_check_now:\" | grep image | cut -d : -f 3 " -i ansible/inventories/products/$product/$inventory/ cloud-bind-frontend-dns[0] -u $username --become-user root --become -e "ansible_become_pass=$password" -e "ansible_ssh_pass=$password"`
            echo "part_1: $part_1"
            return_code=`echo $part_1 | awk '{print $5}' | cut -d = -f 2`
            return_tag=`echo $part_1 | awk '{print $7}'`
            
            check_return_tag_int=`echo $return_tag | grep -q -E "[0-9]{4}.[0-9]{2}.[0-9]{2}-[0-9a-z]{8}$" && echo 1 || echo 0`

            terminal_custom_logging "
            
                    Show return tag $return_tag
                    Show return code $return_code
                    
                    " "info"

            terminal_custom_logging "
            
                array_service_tag_from_files: $array_service_tag_from_files
                
                " "info"
        fi

        if [ -z "$array_service_tag_from_files" ]; then

            terminal_custom_logging "
            
                    ERROR!: array_service_tag_from_files is null!
                    
                    " "red"

        fi

        if [[ $check_int -eq 1 ]]; then

            terminal_custom_logging "
            
                    Set new stable tag as version_ansible_build_id
                    
                    " "info"

            version_ansible_build_id="$version_ansible_build_id"
            new_tag=$version_ansible_build_id
            return_tag=$return_tag
            published_commit=`echo $return_tag | cut -d - -f 2`
            builded_commit=`git log --pretty=format:'%h' | tail -n -1`
            terminal_custom_logging "
            
                    Build version is: ${version_ansible_build_id}
                    Past version is: ${return_tag}
                    New version is ${new_tag}
                    CI Published commit: $published_commit
                    CI Builded commit: $builded_commit
                    
                    " "info"
   
            MUST_BUILD="1"

        else

            if [[ "$array_service_tag_from_files" == "latest" ]]; then

       
                terminal_custom_logging "
                
                        Because we want have latest, try validate latest
                        
                        " "info"
                version_ansible_build_id="latest"
                return_tag=$version_ansible_build_id
                new_tag=$version_ansible_build_id
                terminal_custom_logging "
                
                        Build version is: ${return_tag}
                        Past version is: ${return_tag}
                        New version is ${new_tag}
                        
                        " "info"
       
                MUST_BUILD="1"
            else
       
                terminal_custom_logging "
                
                        Because we no have tag, ignore service to build
                        Service name is: ${service_to_check_now}
                        
                        " "info"
       
                
                if [[ $service_to_check_now == "fluentd" ]]; then
                    MUST_BUILD="2"
                else
                    MUST_BUILD="0"
                fi

            fi

        fi

    else 

        if [[ "$deploy_environment_security_configuration" == "minimal" ]]; then

            array_service_tag_from_files=$(eval 'cat "$root_dir"/ansible/group_vars/\!_ApplicationDocker_Template/docker-compose-template.yml | grep -A 3 "    $service_to_check_now:" | grep tag | cut -d \" -f 2')

            # array_service_tag_from_files=`eval $eval_command`

            check_int=`echo $array_service_tag_from_files | grep -q "{{ version_ansible_build_id }}" && echo 1 || echo 0`

            terminal_custom_logging "
            
                        array_service_tag_from_files: $array_service_tag_from_files
                    
                        " "info"

            part_1=`ansible -m shell -a "cat /mnt/cloud-bind-glusterfs-storage/${inventory}/stack/docker-stack.yml | grep -A 1 \"    $service_to_check_now:\" | grep image | cut -d : -f 3 " -i "$root_dir"/ansible/inventories/products/$product/$inventory/ cloud-bind-frontend-dns[0] -u $username --become-user root --become -e "ansible_become_pass=$password" -e "ansible_ssh_pass=$password"`

            terminal_custom_logging "
            
                        part_1: $part_1
                    
                        " "debug"

            return_code=`echo $part_1 | awk '{print $5}' | cut -d = -f 2`
            return_tag=`echo $part_1 | awk '{print $7}'`
            
            check_return_tag_int=`echo $return_tag | grep -q -E "[0-9]{4}.[0-9]{2}.[0-9]{2}-[0-9a-z]{8}$" && echo 1 || echo 0`

            terminal_custom_logging "
            
                        Show return tag $return_tag
                        Show return code $return_code
                    
                        " "info"
    
            terminal_custom_logging "
            
                        array_service_tag_from_files: $array_service_tag_from_files
                    
                        " "info"

            if [[ $check_int -eq 1 ]]; then
        
                terminal_custom_logging "

                        Set new stable tag as version_ansible_build_id
                    
                        " "info"
                version_ansible_build_id="$version_ansible_build_id"
                new_tag=$version_ansible_build_id
                return_tag=$return_tag
                published_commit=`echo $return_tag | cut -d - -f 2`
                builded_commit=`git log --pretty=format:'%h' | tail -n -1`
                terminal_custom_logging "

                        Build version is: ${version_ansible_build_id}
                        Past version is: ${return_tag}
                        New version is ${new_tag}
                        CI Published commit: $published_commit
                        CI Builded commit: $builded_commit
                
                        " "info"
                
                MUST_BUILD="1"
            else

                if [[ "$array_service_tag_from_files" == "latest" ]]; then

                    terminal_custom_logging "
                        
                    Because we want have latest, try validate latest
                    
                    " "info"

                    version_ansible_build_id="latest"
                    return_tag=$version_ansible_build_id
                    new_tag=$version_ansible_build_id
                    terminal_custom_logging "

                    Build version is: ${return_tag}
                    Past version is: ${return_tag}
                    New version is ${new_tag}
                    
                    " "info"
            
                    MUST_BUILD="1"
                else

                    terminal_custom_logging "
                    
                        Because we no have tag, ignore service to build
                    Service name is: ${service_to_check_now}
                    
                    " "info"
            
                    if [[ $service_to_check_now == "fluentd" ]]; then
                        MUST_BUILD="2"
                    else
                        MUST_BUILD="0"
                    fi

                fi

            fi

        fi

    fi

}

build_image_and_push(){

    service_name_from=$1
    containers_root=$2
    containers_prefix=$3
    root_dir=$4
    ansible_global_gitlab_registry_site_name=$5
    gitlab_project_group=$6
    gitlab_project_name=$7
    check_service_result=$8

    terminal_custom_logging "    
    
                        ${GREEN}Build Image and Push${NC} app: ${RED}${service_name_from}${NC}

                        Check service result: $check_service_result

                        Service Name From: $service_name_from
                        Containers root: $containers_root
                        Containers prefix: $containers_prefix
                        Root directory: $root_dir
                        Docker Registry URI: $ansible_global_gitlab_registry_site_name
                        Registry project group: ${gitlab_project_group}
                        Registry project name: ${gitlab_project_name}
                    
                        " "info"

    if [[ $check_service_result -eq 1 ]]; then
    
        terminal_custom_logging "    
        
                        ${GREEN}Because have changes, start rebuild${NC} app: ${RED}${item}${NC}

                        MAIN IF CHECKS check_service_result & check_service_result
                        
                        CI Version Build ID: $version_ansible_build_id
                        CI Published commit: $published_commit
                        CI Builded commit: $builded_commit
                        Return code: $return_code
                        Check service need to be deployed: $check_service_need_to_be_deployed
                        New version is ${new_tag}
                        Past version is: ${return_tag}
                        
                        " "info"
        
        cd ${root_dir}/${containers_root}/${service_name_from}
        
        docker build -q -f Dockerfile -t ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from} ./ 
        docker build -q -f Dockerfile -t ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from}:$new_tag ./ 
       
        # docker build -q -f Dockerfile -t ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${item}:$version_ansible_build_id ./ 
        
        docker build --pull -t ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from} . 
        docker tag ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from}:$new_tag ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from} 
        docker push ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from}:$new_tag 
        
        #docker push ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${item} 

        echo "passed_ci_docker_tag_${service_to_check_now}: ${new_tag}" >> $LOCAL_DIRECTORY/current_tags.yml

        if [[ ! -z ${array_with_childrens[@]} ]]; then
            terminal_custom_logging "        
            
                        Services/Applications/Etc to build are presenter in array given
                        
                        "
            for children in ${array_with_childrens[@]}; do
                echo $children
                echo "passed_ci_docker_tag_${children}: ${new_tag}" >> $LOCAL_DIRECTORY/current_tags.yml
            done
        else
            terminal_custom_logging "
            
                    Service are no have a any childs
                    
                    " "info"
        fi
        
        cd $root_dir
    
    else

        check_rt_int=`echo $return_tag | grep -q -E "[0-9]{4}.[0-9]{2}.[0-9]{2}-[0-9a-z]{8}$" && echo 1 || echo 0`
        check_rtl_int=`echo $return_tag | grep -q -E "latest" && echo 1 || echo 0`

        if [[ $check_rt_int -eq 1 ]] || [[ $check_rtl_int -eq 1 ]]; then

            version_ansible_build_id="$version_ansible_build_id"
            new_tag=$return_tag
            return_tag=$return_tag
            #published_commit=`echo $return_tag | cut -d - -f 2`
            builded_commit=`git log --pretty=format:'%h' | tail -n -1`
            MUST_BUILD="1"

        else 

            version_ansible_build_id="$version_ansible_build_id"
            new_tag=$ANSIBLE_CI_VERSION
            return_tag=$return_tag
            builded_commit=`git log --pretty=format:'%h' | tail -n -1`
            MUST_BUILD="1"

        fi

        terminal_custom_logging "
                        
                        ${GREEN}Because no have changes ${NC} we validate the app: ${RED}${service_name_from}${NC}

                        Set new stable tag as replaced getted tag
                        Build version is: ${return_tag}
                        Past version is: ${return_tag}
                        New version is ${new_tag}
                        CI Published commit: $published_commit
                        CI Builded commit: $builded_commit
                        CI Version Build ID: $version_ansible_build_id
                        Return code: $return_code
                        Check service need to be deployed: $check_service_need_to_be_deployed
                        New version is ${new_tag}
                        Past version is: ${return_tag}
                        ansible_global_gitlab_registry_site_name: ${ansible_global_gitlab_registry_site_name}
                        gitlab_project_group: ${gitlab_project_group}
                        gitlab_project_name: ${gitlab_project_name}
                        service_name_from: ${service_name_from}

                        " "info"

        cd ${root_dir}/${containers_root}/${service_name_from}
        


        docker build -q -f Dockerfile -t ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from} ./ 
        docker build -q -f Dockerfile -t ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from}:$new_tag ./ 
    
        docker build -q -f Dockerfile -t ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from}:$version_ansible_build_id ./ 
        
        docker build --pull -t ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from} . 
        docker tag ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from}:$new_tag ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from} 
        docker push ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from}:$new_tag 
        
        docker push ${ansible_global_gitlab_registry_site_name}/${gitlab_project_group}/${gitlab_project_name}/${service_name_from} 
        

        echo "passed_ci_docker_tag_${service_to_check_now}: ${new_tag}" >> $LOCAL_DIRECTORY/current_tags.yml


        if [[ ! -z ${array_with_childrens[@]} ]]; then
            terminal_custom_logging "
                    
                    Services/Applications/Etc to build are presenter in array given
                    
                    " "info"
            for children in ${array_with_childrens[@]}; do
                echo $children
                echo "passed_ci_docker_tag_${children}: ${new_tag}" >> $LOCAL_DIRECTORY/current_tags.yml
            done
        else
            terminal_custom_logging "
            
                    Service are no have a any childs
                    
                    " "info"
        fi
        
        cd $root_dir

    fi
}

run_bootstrap_and_check_infra(){

    typeofcloud=$1
    ansible_dir=$2
    product=$3
    inventory=$4

    # Prevents cause when children dynamic inventory cannot access to main temporarity inventory for recreate local

    terminal_custom_logging "
                    
                      ${GREEN}Inventory not${NC} a ${RED}production, current environment is${NC}: $inventory
                      
                    " "info"

    if [ "$typeofcloud" == "bare" ]; then

        terminal_custom_logging "
                    
                    Bootstap the ${GREEN}infrastructure${NC} is ${RED}not possible${NC}, go next step
                    
                    " "info"

        # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/0z-cloud/products/types/\\!_$typeofcloud/$product/$inventory/bootstrap_vms/ \
        #     ./\\!_root_playbooks/$typeofcloud/bootstrap-ng-bare.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e destroy_instances="true"

    else

        terminal_custom_logging "
        
                    Bootstaping the ${GREEN}infrastructure${NC} is ${RED}possible${NC}, go to ${GREEN}check and validate${NC} cloud configuration
                    
                    " "info"

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ "$ansible_dir"/\!_root_playbooks/"$typeofcloud"/bootstrap-ng.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e ansible_cloud_type="$typeofcloud" -e stage="0"

    fi
}

terminal_custom_logging(){

    LOG_MESSAGE=$1
    LOG_LEVEL=$2
    case $LOG_LEVEL in
        DEBUG|debug)   
            COLOR="${BIRed}"
            LINE_COLOR="${UPurple}"
            OUT_LINE="${UPurple}"
            if [[ "TRACE" = $LOG_LEVEL_WRAPPER ]] || [[ "trace" = $LOG_LEVEL_WRAPPER ]] || [[ "debug" = $LOG_LEVEL_WRAPPER ]] || [[ "DEBUG" = $LOG_LEVEL_WRAPPER ]]; then
                si=$(seq -s'_'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${OUT_LINE}""${si}""${NC}" 
                si=$(seq -s'*'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${LINE_COLOR}""${si}""${NC}" 
                printf "\n" ; echo -e "    <${LINE_COLOR}DEBUG${NC}> : ${COLOR}${LOG_MESSAGE}${NC}" ; printf "\n" 
                si=$(seq -s'_'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${LINE_COLOR}""${si}""${NC}" 
                si=$(seq -s'*'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${OUT_LINE}""${si}""${NC}" 
            fi
            ;;
        INFO|info)      
            COLOR="${BWhite}"
            LINE_COLOR="${GREEN}"
            OUT_LINE="${GREEN}"
            if [[ "short" != $LOG_LEVEL_WRAPPER ]] || [[ "SHORT" != $LOG_LEVEL_WRAPPER ]]; then
                si=$(seq -s'_'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${OUT_LINE}""${si}""${NC}" 
                si=$(seq -s'*'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${LINE_COLOR}""${si}""${NC}" 
                printf "\n" ; echo -e "     <${LINE_COLOR}INFO${NC}> : ${COLOR}${LOG_MESSAGE}${NC}" ; printf "\n" 
                si=$(seq -s'*'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${LINE_COLOR}""${si}""${NC}" 
                si=$(seq -s'_'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${OUT_LINE}""${si}""${NC}" 
            fi
            ;;
        TRACE|trace)
            COLOR="${CYAN}"
            LINE_COLOR="${BLACK_TO_WHITE}"
            OUT_LINE="${On_IBlack}"
            if [[ "TRACE" = $LOG_LEVEL_WRAPPER ]] || [[ "trace" = $LOG_LEVEL_WRAPPER ]]; then
                si=$(seq -s'_'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${OUT_LINE}""${si}""${NC}" 
                si=$(seq -s'*'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${LINE_COLOR}""${si}""${NC}" 
                printf "\n" ; echo -e "    <${COLOR}TRACE${NC}> : ${OUT_LINE}${LOG_MESSAGE}${NC}" ; printf "\n" 
                si=$(seq -s'*'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${LINE_COLOR}""${si}""${NC}" 
                si=$(seq -s'_'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${OUT_LINE}""${si}""${NC}" 
            fi
            ;; 
        GREEN|green|ok)
            COLOR="${BGreen}"
            LINE_COLOR="${RED}"
            OUT_LINE="${On_IGreen}"
            if [[ "short" != $LOG_LEVEL_WRAPPER ]] || [[ "SHORT" != $LOG_LEVEL_WRAPPER ]]; then
                si=$(seq -s'_'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${OUT_LINE}""${si}""${NC}" 
                si=$(seq -s'*'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${LINE_COLOR}""${si}""${NC}" 
                printf "\n" ; echo -e "       <${COLOR}OK${NC}> : ${COLOR}${LOG_MESSAGE}${NC}" ; printf "\n" 
                si=$(seq -s'*'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${LINE_COLOR}""${si}""${NC}" 
                si=$(seq -s'_'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${OUT_LINE}""${si}""${NC}" 
            else
                si=$(seq -s'*'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${LINE_COLOR}""${si}""${NC}" 
                printf "\n" ; echo -e "       <${COLOR}OK${NC}> : ${COLOR}${LOG_MESSAGE}${NC}" ; printf "\n" 
            fi
            ;; 
        RED|red|ko)
            COLOR="${BIWhite}"
            LINE_COLOR="${RED}"
            OUT_LINE="${On_IYellow}"
            if [[ "short" != $LOG_LEVEL_WRAPPER ]] || [[ "SHORT" != $LOG_LEVEL_WRAPPER ]]; then
                si=$(seq -s'!'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${OUT_LINE}""${si}""${NC}" 
                si=$(seq -s'*'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${LINE_COLOR}""${si}""${NC}" 
                printf "\n" ; echo -e "     <${LINE_COLOR}FAIL${NC}> : ${COLOR}${LOG_MESSAGE}${NC}" ; printf "\n" 
                si=$(seq -s'*'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${LINE_COLOR}""${si}""${NC}" 
                si=$(seq -s'!'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${OUT_LINE}""${si}""${NC}" 
            else
                si=$(seq -s'*'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${LINE_COLOR}""${si}""${NC}" 
                printf "\n" ; echo -e "     <${LINE_COLOR}FAIL${NC}> : ${COLOR}${LOG_MESSAGE}${NC}" ; printf "\n" 
            fi
            ;; 
        *)
            COLOR="${GREEN}"
            LINE_COLOR="${RED}"
            OUT_LINE="${On_IBlue}"
            si=$(seq -s'_'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${OUT_LINE}""${si}""${NC}" 
            si=$(seq -s'*'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${LINE_COLOR}""${si}""${NC}" 
            printf "\n" ; echo -e "   <${OUT_LINE}NOTIFY${NC}> : ${COLOR}${LOG_MESSAGE}${NC}" ; printf "\n" 
            si=$(seq -s'*'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${LINE_COLOR}""${si}""${NC}" 
            si=$(seq -s'_'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${OUT_LINE}""${si}""${NC}" 

            ;;
    esac
    
    printf "\n" 
    
}

terminal_line_italy(){
     si=$(seq -s'*'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${GREEN}""${si}""${NC}" 
}


terminal_line_yellow(){
     si=$(seq -s'#'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${YELLOW}""${si}""${NC}" 
}

terminal_line_red(){
     si=$(seq -s'#'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${RED}""${si}""${NC}" 
     
}

terminal_line_green_stars(){
     si=$(seq -s'*'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${GREEN}""${si}""${NC}" 
     
}
terminal_line_red_stars(){
     si=$(seq -s'*'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${RED}""${si}""${NC}" 
     
}

terminal_line_green_equals(){
     si=$(seq -s'='0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${GREEN}""${si}""${NC}" 
     
}

terminal_line_white_equals(){
     si=$(seq -s'='0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${WHITE}""${si}""${NC}" 
     
}

terminal_line_red_equals(){
     si=$(seq -s'='0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${RED}""${si}""${NC}" 
     
}

terminal_line_yellow_equals(){
     si=$(seq -s'='0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${YELLOW}""${si}""${NC}" 
     
}

terminal_line_meta_color(){
     color=$1
     line_char=$2
    echo "---------------------------------------------------------------------------"
     line_to_exec="si=$(seq -s'$line_char'0 $(tput cols) | tr -d '[:digit:]')"

     echo "line_to_exec_part1: $line_to_exec"
    echo "---------------------------------------------------------------------------"

     # si=$(seq -s'${line_char}'0 $(tput cols) | tr -d '[:digit:]')

    echo -e "${GREEN}""${si}""${NC}" 
     
}

terminal_line_green(){
     si=$(seq -s'#'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${GREEN}""${si}""${NC}" 
     
}

terminal_line(){
     si=$(seq -s'#'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${YELLOW}""${si}""${NC}" 
     
}

terminal_line_white_stars(){
     si=$(seq -s'*'0 $(tput cols) | tr -d '[:digit:]') ; echo -e "${YELLOW}""${si}""${NC}" 
     
}

devops_prod_run_bootstrap_and_check_infra(){

    typeofcloud=$1
    ansible_dir=$2
    product=$3
    inventory=$4


    #for i in {1..$(stty size | cut -d" " -f2)};do echo -n -e "${RED}=${NC}";done

    terminal_custom_logging "
    
                ${GREEN}{******* DEVELOPMENT  *********************************************************************************************************************************************************************************}${NC}
                
                " "info"


    #for i in {1..$(stty size | cut -d" " -f2)};do echo -n -e "${RED}=${NC}";done
    


    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        "$ansible_dir"/playbook-library/!_bootstrap/dns-backend.yml \
        -e HOSTS="master-bind-master-backend" -u $username --become-user root \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="2"

    #function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/global/oz_router/products/"$product"/"$inventory" -i "$ansible_dir"/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ "$ansible_dir"/playbook-library/_oZ_router/ozrouter.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e stage="0"

    # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ "$ansible_dir"/\!_root_playbooks/"$typeofcloud"/bootstrap-ng.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e stage="0"



    terminal_custom_logging "
                
                ${GREEN}{******* DEVELOPMENT SLEEP PLACE **********************************************************************************************************************************************************************}${NC}
                
                " "info"




    # # Prevents cause when children dynamic inventory cannot access to main temporarity inventory for recreate local
    # echo -e "     ${GREEN}{**************************************************************************************************************************************************************************************************}${NC}"
    # echo -e "            ${GREEN}Inventory not${NC} a ${RED}production, current environment is${NC}: $inventory"
    # echo -e "     ${GREEN}{**************************************************************************************************************************************************************************************************}${NC}"


    # if [ "$typeofcloud" == "bare" ]; then

    #     echo -e "     ****************************************************************************************************************************************************************************************************"
    #     echo -e "         Bootstap the ${GREEN}infrastructure${NC} is ${RED}not possible${NC}, go next step"
    #     echo -e "     ****************************************************************************************************************************************************************************************************"


    #     # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/0z-cloud/products/types/\\!_$typeofcloud/$product/$inventory/bootstrap_vms/ \
    #     #     ./\\!_root_playbooks/$typeofcloud/bootstrap-ng-bare.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e destroy_instances="true"

    # else

    #     echo -e "     ****************************************************************************************************************************************************************************************************"
    #     echo -e "         Bootstaping the ${GREEN}infrastructure${NC} is ${RED}possible${NC}, go to ${GREEN}check and validate${NC} cloud configuration"
    #     echo -e "     ****************************************************************************************************************************************************************************************************"

    #     function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ "$ansible_dir"/\!_root_playbooks/"$typeofcloud"/bootstrap-ng.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e stage="0"

    # fi
}

rnd_development_run_bootstrap_and_check_infra(){

    typeofcloud=$1
    ansible_dir=$2
    product=$3
    inventory=$4
    ansible_datacenter=$5


    #for i in {1..$(stty size | cut -d" " -f2)};do echo -n -e "${RED}=${NC}";done

    terminal_custom_logging "
    
        ${GREEN}{******* DEVELOPMENT  *********************************************************************************************************************************************************************************}${NC}
        
        " "info"


    #for i in {1..$(stty size | cut -d" " -f2)};do echo -n -e "${RED}=${NC}";done
    


    if [[ ! -z "$ansible_datacenter" ]]; then
        # GO TO DYNAMIC DATACENTER CONFIGURATION
    
        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/global/oz_router/products/"$product"/"$inventory" -i "$ansible_dir"/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ "$ansible_dir"/playbook-library/_oZ_router/ozrouter.develop.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e stage="0" -e ansible_datacenter="$ansible_datacenter"
    
    else
        # STATIC DATACENTER CONFIGURATION
    
        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/global/oz_router/products/"$product"/"$inventory" -i "$ansible_dir"/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ "$ansible_dir"/playbook-library/_oZ_router/ozrouter.develop.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e stage="0"
    
    fi
    # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ "$ansible_dir"/\!_root_playbooks/"$typeofcloud"/bootstrap-ng.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e stage="0"

    terminal_custom_logging "
    
                    ${GREEN}{******* DEVELOPMENT SLEEP PLACE **********************************************************************************************************************************************************************}${NC}
                    
                    " "info"


}

rnd_development_run_deploy_to_infra(){

    typeofcloud=$1
    ansible_dir=$2
    product=$3
    inventory=$4
    ansible_datacenter=$5


    #for i in {1..$(stty size | cut -d" " -f2)};do echo -n -e "${RED}=${NC}";done

    terminal_custom_logging "
    
        ${GREEN}{******* DEVELOPMENT DEPLOY  *********************************************************************************************************************************************************************************}${NC}
        
        " "info"


    #for i in {1..$(stty size | cut -d" " -f2)};do echo -n -e "${RED}=${NC}";done
    


    if [[ ! -z "$ansible_datacenter" ]]; then
        # GO TO DYNAMIC DATACENTER CONFIGURATION
    
        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/global/oz_router/products/"$product"/"$inventory" -i "$ansible_dir"/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ "$ansible_dir"/playbook-library/_oZ_router/ozrouter.develop.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e stage="0" -e ansible_datacenter="$ansible_datacenter"
    
    else
        # STATIC DATACENTER CONFIGURATION
    
        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/global/oz_router/products/"$product"/"$inventory" -i "$ansible_dir"/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ "$ansible_dir"/playbook-library/_oZ_router/ozrouter.develop.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e stage="0"
    
    fi
    # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ "$ansible_dir"/\!_root_playbooks/"$typeofcloud"/bootstrap-ng.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e stage="0"

    terminal_custom_logging "
    
                    ${GREEN}{******* DEVELOPMENT SLEEP PLACE **********************************************************************************************************************************************************************}${NC}
                    
                    " "info"


}



development_run_bootstrap_and_check_infra_oz(){

    typeofcloud=$1
    ansible_dir=$2
    product=$3
    inventory=$4
    ansible_datacenter=$5


    #for i in {1..$(stty size | cut -d" " -f2)};do echo -n -e "${RED}=${NC}";done

    terminal_custom_logging "
                    
                    ${GREEN}{******* DEVELOPMENT  *********************************************************************************************************************************************************************************}${NC}
                    
                    " "info"

    #for i in {1..$(stty size | cut -d" " -f2)};do echo -n -e "${RED}=${NC}";done
    


    terminal_custom_logging "
    
                    ${GREEN}{******* DEVELOPMENT SLEEP PLACE **********************************************************************************************************************************************************************}${NC}
    
                    " "info"


    # sleep 500

    # NEXUS INSTALL

    #    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/"$product"/"$inventory" "$ansible_dir"/playbook-library/\!_cloud_entry/nexus.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e stage="1" 

    # # Prevents cause when children dynamic inventory cannot access to main temporarity inventory for recreate local
    # echo -e "     ${GREEN}{**************************************************************************************************************************************************************************************************}${NC}"
    # echo -e "            ${GREEN}Inventory not${NC} a ${RED}production, current environment is${NC}: $inventory"
    # echo -e "     ${GREEN}{**************************************************************************************************************************************************************************************************}${NC}"


    # if [ "$typeofcloud" == "bare" ]; then

    #     echo -e "     ****************************************************************************************************************************************************************************************************"
    #     echo -e "         Bootstap the ${GREEN}infrastructure${NC} is ${RED}not possible${NC}, go next step"
    #     echo -e "     ****************************************************************************************************************************************************************************************************"

    #     # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/0z-cloud/products/types/\\!_$typeofcloud/$product/$inventory/bootstrap_vms/ \
    #     #     ./\\!_root_playbooks/$typeofcloud/bootstrap-ng-bare.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e destroy_instances="true"

    # else

    #     echo -e "     ****************************************************************************************************************************************************************************************************"
    #     echo -e "         Bootstaping the ${GREEN}infrastructure${NC} is ${RED}possible${NC}, go to ${GREEN}check and validate${NC} cloud configuration"
    #     echo -e "     ****************************************************************************************************************************************************************************************************"

    # fi
}



development_run_bootstrap_and_check_infra(){

    typeofcloud=$1
    ansible_dir=$2
    product=$3
    inventory=$4
    ansible_datacenter=$5


    #for i in {1..$(stty size | cut -d" " -f2)};do echo -n -e "${RED}=${NC}";done

    terminal_custom_logging "
                    
                    ${GREEN}{******* DEVELOPMENT  *********************************************************************************************************************************************************************************}${NC}
                    
                    " "info"

            #for i in {1..$(stty size | cut -d" " -f2)};do echo -n -e "${RED}=${NC}";done

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ "$ansible_dir"/\!_root_playbooks/"$typeofcloud"/bootstrap-ng.yml -e ansible_product="$product" -e ansible_environment="$inventory"  -e ansible_cloud_type="$typeofcloud" -e stage="0"


    # if [[ ! -z "$ansible_datacenter" ]]; then
    #     # GO TO DYNAMIC DATACENTER CONFIGURATION
    #     function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/global/oz_router/products/"$product"/"$inventory" -i "$ansible_dir"/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ "$ansible_dir"/\!_root_playbooks/"$typeofcloud"/bootstrap-ng.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e stage="0" -e ansible_datacenter="$ansible_datacenter"
    
    # else
    #     # STATIC DATACENTER CONFIGURATION
    #     function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/global/oz_router/products/"$product"/"$inventory" -i "$ansible_dir"/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ "$ansible_dir"/\!_root_playbooks/"$typeofcloud"/bootstrap-ng.yml-e ansible_product="$product" -e ansible_environment="$inventory" -e stage="0"
    
    # fi
    # # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ "$ansible_dir"/\!_root_playbooks/"$typeofcloud"/bootstrap-ng.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e stage="0"
    
    # timeout_view=10

    # while timeout_view -ne 0; do

    #     terminal_custom_logging "
        
    #                     ${GREEN}{******* DEVELOPMENT SLEEP PLACE ${timeout_view} **********************************************************************************************************************************************************************}${NC}
        
    #                     " "info"
    #                     sleep 1 ; clear
    #                     timeout_view=$(expr ${timeout_view} - 1)
    # done 
    #     terminal_custom_logging "
    
    #                 ${GREEN}{******* DEVELOPMENT SLEEP PLACE 3 **********************************************************************************************************************************************************************}${NC}
    
    #                 " "info"
    #                 sleep 1 ; clear

    #  terminal_custom_logging "
    
    #                 ${GREEN}{******* DEVELOPMENT SLEEP PLACE 1 **********************************************************************************************************************************************************************}${NC}
    
    #                 " "info"
    #                 sleep 1 ; clear

    # OBTAIN CERTIFICATES

            # auto_type;

            # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            #     "$ansible_dir"/playbook-library/!_bootstrap/letsencrypt-ca-sync-pacemaker.yml \
            #     -u $username --become-user root \
            #     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="3"
            #     # -vvvv


    # V.O.R.T.E.X
    # =|<*>|=1111

     terminal_custom_logging "
    

                    ${GREEN}{******* R GO PLACE Vx **********************************************************************************************************************************************************************}${NC}
    
                    " "warn"
                    sleep 1 
    # NEXUS INSTALL

    #    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/"$product"/"$inventory" "$ansible_dir"/playbook-library/\!_cloud_entry/nexus.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e stage="1" 

    # # Prevents cause when children dynamic inventory cannot access to main temporarity inventory for recreate local
    # echo -e "     ${GREEN}{**************************************************************************************************************************************************************************************************}${NC}"
    # echo -e "            ${GREEN}Inventory not${NC} a ${RED}production, current environment is${NC}: $inventory"
    # echo -e "     ${GREEN}{**************************************************************************************************************************************************************************************************}${NC}"


    # if [ "$typeofcloud" == "bare" ]; then

    #     echo -e "     ****************************************************************************************************************************************************************************************************"
    #     echo -e "         Bootstap the ${GREEN}infrastructure${NC} is ${RED}not possible${NC}, go next step"
    #     echo -e "     ****************************************************************************************************************************************************************************************************"


    #     # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/0z-cloud/products/types/\\!_$typeofcloud/$product/$inventory/bootstrap_vms/ \
    #     #     ./\\!_root_playbooks/$typeofcloud/bootstrap-ng-bare.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e destroy_instances="true"

    # else

    #     echo -e "     ****************************************************************************************************************************************************************************************************"
    #     echo -e "         Bootstaping the ${GREEN}infrastructure${NC} is ${RED}possible${NC}, go to ${GREEN}check and validate${NC} cloud configuration"
    #     echo -e "     ****************************************************************************************************************************************************************************************************"

    #     function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ "$ansible_dir"/\!_root_playbooks/"$typeofcloud"/bootstrap-ng.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e stage="0"

    # fi
}


# check_and_replace_in_source_inventory

target_inventory_link_devops_service_zone_live(){

    ### [_INIT_Z_] -> Init from nothing

        typeofcloud=$1
        ansible_dir=$2
        product=$3
        inventory=$4
        ansible_datacenter=$5
        source_inventory=$6

    ### [_INFO_0_] -> You follow by ... really stucky and thin edge between heaven and hell    

    # SETUP DNS BACKEND SERVICE TO DNS BACKEND HOSTS

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/!_bootstrap/dns-backend.yml \
            -e HOSTS="master-bind-master-backend" -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="2"

    ### [_DONE_2.87_] <- ### DNS-BACKEND  ###  BACKEND DNS MASTER/RECURSOR/FORWARDER  #####################

    echo -e "${GREEN}{******* BAREMETAL LINKED OBJECT REPRESENT FUN WRAPPER ON DEVOPS SERVICE ZONE LIVE DONE!!!  *********************************************************************************************************************************************************************************}${NC}"

}

eve_simple_flow_inventory_link_devops_service_zone_live(){

    ### [_INIT_Z_] -> Init from nothing

        typeofcloud=$1
        ansible_dir=$2
        product=$3
        inventory=$4
        ansible_datacenter=$5

    ### [_INFO_0_] -> You follow by ... really stucky and thin edge between heaven and hell    

    # SETUP EVE & EDEN SERVICES

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/_eve_/eve-eden-raw-grow-up.yml \
            -e HOSTS="eve:eden" -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="2"

    ### [_DONE_2.87_] <- ### EVE & EDEN SERVICES ### BACKEND EVE & EDEN SERVICES #####################

    echo -e "${GREEN}{******* BAREMETAL LINKED OBJECT REPRESENT FUN WRAPPER ON DEVOPS SERVICE ZONE LIVE DONE!!!  *********************************************************************************************************************************************************************************}${NC}"

}

devops_service_zone_live(){

    ### [_INIT_Z_] -> Init from nothing

        typeofcloud=$1
        ansible_dir=$2
        product=$3
        inventory=$4
        ansible_datacenter=$5

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library!_Banners/banner_test.yml \
            -e HOSTS="all" -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

    ### [_INFO_0_] -> You follow by ... really stucky and thin edge between heaven and hell

    ### [_START_0_] -> ##################  Run the apt_install.yml playbook for all hosts  #############################

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/!_bootstrap/rc_local.yml \
            -e HOSTS="all" -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

        ### [_DONE_0_] <- ########################################################################################################

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/\!_bootstrap/apt_install.yml \
            -e HOSTS='all' \
            -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

        # SSH AND IDENTITY EXCHANGE WITH FULL CLEAN
        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/playbook-library/\!_0_init/afterinstall.yml \
            -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1" -e full_clean="1"

        # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/playbook-library/\!_0_init/afterinstall.yml \
        #     -u $username --become-user root \
        #     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"


        # # # SETUP DNS INITIALIZATION TO ALL HOSTS

        #     function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        #         "$ansible_dir"/playbook-library/!_bootstrap/dns-initialization.yml \
        #         -e HOSTS="all" -u $username --become-user root  --become \
        #         -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

        # SETUP SYSTEMD RESOLVED SERVICE TO ALL HOSTS

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/!_bootstrap/systemd_resolved.yml \
            -u $username --become-user root --become -e "ansible_become_pass='$password'" \
            -e "ansible_ssh_pass='$password'" -e stage="1"

    # ### [_START_1_] -> ###  NETWORK  ###  INSTALLING NEW MAIN NETPLAN CONFIGURATION FOR BACKEND HOSTS  #####################

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/\!_network/netplan.yml \
            -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

        ### [_DONE_1_] <- ###  NETWORK  ###  INSTALLING NEW MAIN NETPLAN CONFIGURATION FOR BACKEND HOSTS  #####################


    ### [_START_2.11_] -> ###  NTP  ###  NTP ROLE  ###############################################################

        # NTP ROLE

            function_selector_runner ansible-playbook -i inventories/products/$product/$inventory/ \
                playbook-library/services/ntp-service.yml \
                -e HOSTS="all" -u $username --become-user root  --become \
                -e "ansible_become_pass=$password" -e "ansible_ssh_pass=$password" -e stage="2"

        ### [_DONE_2.11_] <- ###  NTP  ###  NTP ROLE  ###############################################################

    ### [_START_3.0_] -> ###  CORE-DNS  ###  FRONTEND DNS RECURSOR/FIREWALL/PROXY  #####################

        # SETUP CoreDNS FRONTEND SERVICE TO IDS HOSTS

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/!_bootstrap/core-dns.yml \
            -e HOSTS="cloud-bind-frontend-dns" -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="2"

        ### [_DONE_3.0_] <- ###  CORE-DNS  ###  FRONTEND DNS RECURSOR/FIREWALL/PROXY  #####################

    ### [_START_2.87_] -> ### DNS-BACKEND  ###  BACKEND DNS MASTER/RECURSOR/FORWARDER  #####################

        # SETUP DNS BACKEND SERVICE TO DNS BACKEND HOSTS

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/!_bootstrap/dns-backend.yml \
            -e HOSTS="master-bind-master-backend" -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="2"

        ### [_DONE_2.87_] <- ### DNS-BACKEND  ###  BACKEND DNS MASTER/RECURSOR/FORWARDER  #####################
    ### [_START_2_] -> ###  STORAGE  ###  CREATE CLOUD BIND GLUSTERFS STORAGE  #####################

        #  GLUSTERFS PRIMARY SYNC STORAGE ON FE{0..i}

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/storage/glusterfs-cluster.yml \
            -e GLUSTERFS_CLUSTER_HOSTS="glusterfs-storage-cloud-main-frontend-dns" \
            -u $username --become-user root --become \
            -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1" \
            -e clean_glusterfs_all="da"

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/storage/glusterfs-cluster.yml \
            -e GLUSTERFS_CLUSTER_HOSTS="cloud-bind-frontend-persistence-dns-glusterfs-storage" \
            -u $username --become-user root --become \
            -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1" \
            -e clean_glusterfs_all="da"

        ### [_DONE_2_] <- ###  STORAGE  ###  CREATE CLOUD BIND GLUSTERFS STORAGE  #####################

    ### [_START_3.1_] -> ###  K8S  ###  CREATE CLOUD K8 CLUSTER  #####################

        # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        #     "$ansible_dir"/playbook-library/cloud/k8/k8-cluster.yml \
        #     -e GLUSTERFS_CLUSTER_HOSTS="bind-master-glusterfs" \
        #     -u $username --become-user root --become \
        #     -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"
            
        # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        #     "$ansible_dir"/playbook-library/cloud/k8/k8-cluster.yml \
        #     -e GLUSTERFS_CLUSTER_HOSTS="bind-master-glusterfs" \
        #     -u $username --become-user root --become \
        #     -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1" -e reset_cluster="1"

        ### [_DONE_3.1_] <- ###  K8S  ###  CREATE CLOUD K8 CLUSTER  #####################

    ### [_START_4_] -> ###  WEB PUBLISH  ###  NGINX PUBLISH SERVICES EACH TO BY ITSELF APPLICATION NAME  #####################
    ####
        #### ! [service as object in inventory represented as 'prefix' to merge] as example www,docs,api,etc -
        ####
        ####    published serivces as endpoints follow like example by _{{ item_name }}_service_name !
        ####
        ####
    # CONSUL MASTERS
        
        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/cloud/consul/!_consul_cloud_playbook.yml \
            -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="3" 
            # -vvvv

    ### SWARM CLUSTERS >

        # CREATE A DOCKER SWARM CLUSTER

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ "$ansible_dir"/playbook-library/cloud/swarm/swarm-cluster.yml \
            -e SWARM_MASTERS="swarm-cluster" -u $username --become-user root --become -e "ansible_become_pass='$password'" \
            -e "ansible_ssh_pass='$password'" -e leave_cluster="true" -e stage="2"

    # OBTAIN CERTIFICATES

        auto_type;

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/!_bootstrap/letsencrypt-ca-sync-pacemaker.yml \
            -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="3"
            # -vvvv

    # NGINX FRONTEND ROLE

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/cloud/nginx/nginx-frontend-ng.yml \
            -e HOSTS="nginx-frontend" -u $username --become-user root  --become \
            -e "ansible_become_pass=$password" -e "ansible_ssh_pass=$password" -e stage="2"

        ### [_DONE_4_] <- ###  WEB PUBLISH  ###  NGINX PUBLISH SERVICES EACH TO BY ITSELF APPLICATION NAME  #####################

    # TEAMCITY SERVER

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/teamcity/teamcity-server.yml \
            -e HOSTS="teamcity-server" -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

    # GITLAB SERVER

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/services/gitlab-server.yml \
            -e HOSTS="gitlab-server" -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

    # NETWORK BALANCERS 

        # Perform keealived install for k8s masters

            # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            #     "$ansible_dir"/playbook-library/\!_network/keepalive_deploy.yml \
            #     -e HOSTS="vortex-core-master-backend" -u $username --become-user root \
            #     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

        # # INSTALLING THE MAIN NETWORK BALANCER FOR BACKEND HOSTS

            # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            #     "$ansible_dir"/playbook-library/\!_network/keepalive_deploy.yml \
            #     -e HOSTS="network-balancer-stack" -u $username --become-user root \
            #     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

    # SECURITY PLAYBOOKS AND MANAGEMENT LOGS

        # INSTALLING AUDITD & LOGROTATE CONFIGURATIONS

            # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            #     "$ansible_dir"/playbook-library/compliance/audit.yml \
            #     -u $username --become-user root \
            #     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

            # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            #     "$ansible_dir"/playbook-library/\!_bootstrap/logrotate.yml \
            #     -u $username --become-user root \
            #     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

            # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            #     "$ansible_dir"/playbook-library/system/pam_d-all.yml \
            #     -u $username --become-user root \
            #     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

        # ANTIVIRUS CLAMAV

            # terminal_line_green
            # echo -e "       Run the ${RED}clamav.yml${NC} playbook for all hosts, for install ${RED}Antivirus${NC} system packages"
            # terminal_line_green

            # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            #     "$ansible_dir"/playbook-library/security/clamav.yml \
            #     -u $username --become-user root \
            #     -e HOSTS='all' \
            #     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

    # # MAIL SERVICES SCENARIOS 
        # 
        #     echo -e "       Run the ${RED}postfix.yml${NC} playbook for all hosts, for install ${RED}necessary${NC} system packages"
        # 

        #     function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        #         "$ansible_dir"/playbook-library/\!_bootstrap/postfix.yml \
        #         -u $username --become-user root \
        #         --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

    # REPOSITORIES AND REGIESTIES

    ## APT REPOSITORY UBUNTU MIRROR
        
        ### WEBSERVER_CONFIGURE

            # terminal_line_green
            # echo -e "       Run the ${RED}apache2 web server${NC} playbook on mirror server host, for serving ${RED}public mirrors in private zone${NC}"
            # terminal_line_green

            # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            #     "$ansible_dir"/playbook-library/system/repository_mirror_server_apache.yml \
            #     -u $username --become-user root \
            #     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

        ### APT MIRROR

            # terminal_line_green
            # echo -e "       Run the ${RED}apt-mirror.yml${NC} playbook for all hosts, for install ${RED}Antivirus${NC} system packages"
            # terminal_line_green
            # echo -e "       ${RED}IMPORTANT!${NC} Be careful playbook change the sources.list after complete"
            # terminal_line_green
            # echo -e "       ${RED}You must hold and wait full apt-mirror sync before continue run a other playbooks or start deploy pipelines${NC}"
            # terminal_line_green

            # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            #     "$ansible_dir"/playbook-library/security/apt-mirror.yml \
            #     -u $username --become-user root \
            #     -e HOSTS='all' \
            #     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

        ### NEXUS OSS

            function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/"$product"/"$inventory" "$ansible_dir"/playbook-library/\!_cloud_entry/nexus.yml -e ansible_product="$product" -u "$username" --become-user root --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

    # LOGGING CLUSTER AND VIEWER

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/logging/logging-kibana-service.yml \
            -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/logging/logging-elasticsearch-cluster.yml \
            -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

    # FLUENTD PREPARE DIRS AND CONF

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/logging/fluentd-service.yml \
            -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="1"

    # INSTALL GRAFANA ALERTMANAGER PROMETHEUS

        function_selector_runner ansible-playbook -i inventories/products/$product/$inventory/ \
            playbook-library/services/monitoring.yml \
            -e HOSTS="all" -u $username --become-user root \
            --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="2"

    echo -e "${GREEN}{******* DEVOPS SERVICE ZONE LIVE DONE!!!  *********************************************************************************************************************************************************************************}${NC}"

}



selfbox_development_run_bootstrap_and_check_infra(){

    typeofcloud=$1
    ansible_dir=$2
    product=$3
    inventory=$4
    ansible_datacenter=$5

    #for i in {1..$(stty size | cut -d" " -f2)};do echo -n -e "${RED}=${NC}";done

    echo -e "${GREEN}{******* SELFHOST DEVELOPMENT  *********************************************************************************************************************************************************************************}${NC}"

    #for i in {1..$(stty size | cut -d" " -f2)};do echo -n -e "${RED}=${NC}";done

    if [[ ! -z "$ansible_datacenter" ]]; then
        # GO TO DYNAMIC DATACENTER CONFIGURATION
    
        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/global/oz_router/products/"$product"/"$inventory" -i "$ansible_dir"/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ "$ansible_dir"/_selfbox_/_selfbox_.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e stage="0" -e ansible_datacenter="$ansible_datacenter" -vvvvv
    
    else
        # STATIC DATACENTER CONFIGURATION
    
        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/global/oz_router/products/"$product"/"$inventory" -i "$ansible_dir"/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ "$ansible_dir"/_selfbox_/_selfbox_.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e stage="0" 
        # -vvvvv
    
    fi
    # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ "$ansible_dir"/\!_root_playbooks/"$typeofcloud"/bootstrap-ng.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e stage="0"

    echo -e "${GREEN}{******* DEVELOPMENT SLEEP PLACE **********************************************************************************************************************************************************************}${NC}"

}

function_services_internal_publish(){

    typeofcloud=$1
    ansible_dir=$2
    product=$3
    inventory=$4

    echo -e "     ${RED}|>... UPDATE NGINX & DNS BACKEND .................................................................................................................................................<|${NC}"

    # NTP ROLE

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        "$ansible_dir"/playbook-library/services/ntp-service.yml \
        -e HOSTS="all" -u $username --become-user root  --become \
        -e "ansible_become_pass=$password" -e "ansible_ssh_pass=$password" -e stage="2"

    # INSTALL GRAFANA ALERTMANAGER PROMETHEUS

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        "$ansible_dir"/playbook-library/services/monitoring.yml \
        -e HOSTS="all" -u $username --become-user root \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="2"

    # NGINX FRONTEND ROLE

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        "$ansible_dir"/playbook-library/cloud/nginx/nginx-frontend-ng.yml \
        -e HOSTS="nginx-frontend" -u $username --become-user root  --become \
        -e "ansible_become_pass=$password" -e "ansible_ssh_pass=$password" -e stage="2"

    # UPDATE DNS BACKEND SERVICE TO IDS HOSTS

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        "$ansible_dir"/playbook-library/!_bootstrap/dns-backend.yml \
        -e HOSTS="master-bind-master-backend" -u $username --become-user root \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="2"

    # WAZUH STACK INSTALL

    # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
    #     playbook-library/services/wazuh.yml \
    #     -e HOSTS="all:wazuh-manager:wazuh-agent:wazuh-elasticsearch:wazuh-kibana" -u $username --become-user root \
    #     --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="2" \
    #     -e acme_domain_for_obtain="vortex.com" -e acme_domain_prefix_txt=""

    #n EVELOPMENT GO PLACE Vx

    # SECURITY APPS INSTALL

    # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
    #     docker-stack-deploy-playbook_pci_security-apps.yml \
    #     -u $username --become-user root --become -e HOSTS="security-apps" \
    #     -e "ansible_become_pass=$password" -e "ansible_ssh_pass=$password" -e stage="docker-stack-deploy" -e version_ansible_build_id="${version_ansible_build_id}" -e "@../.local/current_tags.yml"

    echo -e "     ${RED}|>... UPDATE NGINX & DNS BACKEND .................................................................................................................................................<|${NC}"

}

lf_edge_iac_rechange_cloud_target(){

    typeofcloud=$1
    ansible_dir=$2
    product=$3
    inventory=$4
    ansible_datacenter=$5

    echo -e "${GREEN}{******* LF EDGE EVE IaC vx-2z-cloud REPLACE CLOUD TARGET ADAPTER TYPE FOR ITSELF BOOTSTRAPING TO EVE STARTED *********************************************************************************************************************************************************************************}${NC}"
    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ "$ansible_dir"/_selfbox_/_selfbox_.yml -e ansible_product="$product" -e ansible_environment="$inventory" -e stage="0"

    echo -e "${GREEN}{******* LF EDGE EVE IaC 0z-cloud BOOTSTRAP, SLEEP PLACE **********************************************************************************************************************************************************************}${NC}"

}

lf_edge_iac_bootstrap(){

    typeofcloud=$1
    ansible_dir=$2
    product=$3
    inventory=$4
    ansible_datacenter=$5

    #for i in {1..$(stty size | cut -d" " -f2)};do echo -n -e "${RED}=${NC}";done

    echo -e "${GREEN}{******* LF EDGE EVE IaC 0z-cloud BOOTSTRAPING STARTED *********************************************************************************************************************************************************************************}${NC}"

    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/0z-cloud/products/types/\!_"${typeofcloud}"/"$product"/"$inventory"/bootstrap_vms/ "$ansible_dir"/\!_root_playbooks/"$typeofcloud"/bootstrap-ng.yml  -e ansible_cloud_type="$typeofcloud" -e ansible_product="$product" -e ansible_environment="$inventory" -e stage="0"

    echo -e "${GREEN}{******* LF EDGE EVE IaC 0z-cloud BOOTSTRAP, SLEEP PLACE **********************************************************************************************************************************************************************}${NC}"

}

lf_edge_iac_deploy(){

    ### [_INIT_Z_] -> Init from nothing

        typeofcloud=$1
        ansible_dir=$2
        product=$3
        inventory=$4
        ansible_datacenter=$5

    ### [_INFO_0_] -> You follow by ... really stucky and thin edge between heaven and hell


    echo -e "${GREEN}{******* LF EDGE EVE SERVICE CHAIN PIPELINE ARE DONE!!!  *********************************************************************************************************************************************************************************}${NC}"

}


prepare_ci(){

    username=$1
    product=$2
    typeofcloud=$3
    inventory=$4
    root_path_dir=$5
    ansible_dir=$6
    runpath=$7
    LOCAL_DIRECTORY=$8
    ANSIBLE_CI_VERSION=$9
    ANSIBLE_BUILD_ID=${10}

    build_runpath=`echo $runpath | sed  's/\/ansible//g'`

    terminal_custom_logging "
    
                            ${YELLOW}PREPARE CI NG${NC}
                            
                            ${RED}RUN FILE${NC}: libsh/deploy/prepare_ci.sh
                            ${RED}RUN PATH${NC}: $runpath
                            ${RED}ANSIBLE ROOT${NC}: $ansible_dir
                            
                            ${RED}Current Build Run Path${NC}: $build_runpath

                            Environment: $inventory
                            Type of Cloud: $typeofcloud
                            Product: $product
                            Vault job type: $vault_job_type
                            Local Directory Path: $LOCAL_DIRECTORY
                            Root Folder Path: $root_path_dir
                            Username: $username
                            Ansible Main Path: $ansible_dir

                            " "info"

    initial_shared_runners_registration_token="${initial_shared_runners_registration_token}"

    echo $initial_shared_runners_registration_token

    terminal_custom_logging "
    
                            ${YELLOW}Fetch Arrays of Applications/Services/Images which need to Build and Push to Docker Registry ${NC} 
                            
                            Project Root Path: ${build_runpath}
                            
                            " "info"

    # extended_applications_groups_list=$(ls -la "$build_runpath"/extended/ | grep -v 'README.md' | awk '{print $9}' |sed 1,3d)

    # for item in $extended_applications_groups_list; do
        
    #     terminal_custom_logging "                                                                                                      " "info"
    #     terminal_custom_logging "Container Group Name: $item" "info"
    #     terminal_custom_logging "root_path: $build_runpath" "info"
    #     group_root_path="$build_runpath"/extended/"$item/"
    #     terminal_custom_logging "ext_service_name: $item" "info"
    #     terminal_custom_logging "group_root_path: $group_root_path" "info"
    #     terminal_custom_logging "                                                                                                      " "info"

    # done
    # sleep 20

    #declare -a extended_applications_groups_list_array=()
    # extended_applications_groups_list_array+=('foo' 'bar')

    # array_of_applications=`ls -la ${build_runpath}/services/ | grep -v "README.md" | awk '{print $9}' |sed 1,3d`
    # array_of_services=`ls -la ${build_runpath}/dockerfiles/ | grep -v "README.md" | awk '{print $9}' |sed 1,3d`
    # array_of_docs=`ls -la ${build_runpath}/docs/ | grep -v "README.md" | awk '{print $9}' | sed 1,3d`

    # terminal_line_green_stars
    # echo -e "         ${RED}Deploy applications${NC}:"
    # terminal_line_green_stars
    # for service_name in ${array_of_applications[@]}; do
    #     terminal_custom_logging "Container name: $service_name" "info"
    # done
    # terminal_line_green_stars
    # terminal_line_green_stars
    # echo -e "         ${RED}Deploy services${NC}:"
    # terminal_line_green_stars
    # for service_name in ${array_of_services[@]}; do
    #     terminal_custom_logging "Container name: $service_name" "info"
    # done
    # terminal_line_green_stars
    # terminal_line_green_stars
    # echo -e "         ${RED}Deploy documents services${NC}:"
    # terminal_line_green_stars
    # for service_name in ${array_of_docs[@]}; do
    #     terminal_custom_logging "Container name: $service_name" "info"
    # done
    # terminal_line_green_stars
    # terminal_line_green_stars
    # echo -e "         ${RED}Deploy extended services${NC}:"
    # terminal_line_green_stars

    # for ext_service_name in ${extended_applications[@]}; do

    #     terminal_custom_logging "Container Group Name: $ext_service_name" "info"

    #     extended_applications_list=`ls -la $build_runpath/extended/${ext_service_name} | grep -v 'README.md' | awk '{print $9}' |sed 1,3d` 

    #     for item_list_entity in ${extended_applications_list[@]}; 
    #     do

    #         terminal_custom_logging "Container Image Name in Group Name: $ext_service_name" "info"
    #         terminal_custom_logging "ext_service_name: $ext_service_name" "info"
    #         terminal_custom_logging "item_list_entity: $item_list_entity" "info"

    #     done

    # done
    # terminal_line_green_stars


    terminal_custom_logging "
    
                            ${RED}Get current run Version ID${NC}
                    
                            " "info"

    ANSIBLE_COMMIT_SHA_SHORT=`echo "$ANSIBLE_COMMIT_SHA" | head -c 8`

    DATE_YEAR=`date '+%Y'`
    DATE_MOUTH=`date '+%m'`
    CI_VERSION_DATE=`date +%Y.%m`

    if [ -z "$ANSIBLE_BUILD_ID" ]; then
        ANSIBLE_BUILD_ID=`date +%d_%w_%H_%m_%Y_%s | shasum | head -c 8`
        ANSIBLE_CI_VERSION="${DATE_YEAR}.${DATE_MOUTH}.${ANSIBLE_BUILD_ID}"
    else
        ANSIBLE_CI_VERSION="${DATE_YEAR}.${DATE_MOUTH}.${ANSIBLE_BUILD_ID}-${ANSIBLE_COMMIT_SHA_SHORT}"
    fi

    version_ansible_build_id="${ANSIBLE_CI_VERSION}"

    export ANSIBLE_CI_VERSION=$ANSIBLE_CI_VERSION
    export version_ansible_build_id=$version_ansible_build_id

    CI_ANSIBLE_ENVIRONMENT="$inventory"
    terminal_custom_logging "
                                ${RED}Version ID${NC}: $version_ansible_build_id

                                ${RED}CI Version ID${NC}: ${ANSIBLE_BUILD_ID}
                                ${RED}CI Pipeline NAME${NC}: ${PIPELINE_NAME}
                    
                                ${RED}CI Ansible Environment${NC}: ${CI_ANSIBLE_ENVIRONMENT}

                            " "info"

}

function_selector_runner_test(){

    escaped_list=`echo $@ |sed 's/[!]/\\\!/g'`

    test=`echo "${@}" | grep -E "\\!\_"  && echo 1 || echo 0`

    echo "test: $test"
    echo "escaped_list: $escaped_list"

    if [ "${test}" == 1 ]; then
        #echo "test = 1"
        IFS='"\!_' in=($escaped_list)
        #IFS='"\!_' in=($escaped_list)
        #\\!
        command_echo_run="${in[@]}"
        #command_echo_run=`echo ${in[command_echo_run]}|sed 's/[!]/\\\!/g'`
        
    else
        #echo "else test != 1"
        IFS='"\' in=($escaped_list)

        command_echo_run=`echo ${in[@]}|sed 's/[!]/\\\!/g'`

    fi

    echo "DEPLOY-HEAD - done first test"

    if [[ "$type_of_run" == "print_only" ]] || [[ "$type_of_run" == "run_from_wrapper" ]]; 
    then

        if [[ "$type_of_run" == "run_from_wrapper" ]]; then
            
            echo "type_of_run:         $type_of_run"  

        else

            string_column_one=`echo $command_echo_run | awk '{print $4}'` 

            terminal_custom_logging "${YELLOW}Print type_of_run is${NC} print_only for manual run ${GREEN}${string_column_one}${NC}" "info"
        
            echo "escaped_list:         $escaped_list"        

        fi

    else

        if [[ "$type_of_run" == "debug" ]]; then

            terminal_custom_logging "Start running command: $escaped_list" "info"
        
            eval "$escaped_list"
        
            terminal_custom_logging "Finish running command: $escaped_list" "info"
        
        else
        
            eval "$escaped_list"
        
        fi

    fi

}

function_selector_runner(){

    escaped_list=$(echo $@ |sed 's/[!]/\\\!/g')

    test=$(echo "${@}" | grep -E "\\!\_"  && echo 1 || echo 0)

    if [[ "$test" == "1" ]]; then

        #echo "test = 1"
        IFS='"\!_' in=($escaped_list)
        command_echo_run="${in[@]}"
        command_echo_run=$(echo ${in[@]} | sed 's/[!]/\\\!/g')
        #echo "done escape"

    else

        #echo "else test != 1"
        IFS='"\' in=($@)
        command_echo_run=$(echo ${in[@]} | sed 's/[!]/\\\!/g')
        #echo "done else escape"
    fi

    #echo -e "           ${RED}VAULT - done first test${NC}"

    if [[ "$type_of_run" == "print_only" ]] || [[ "$type_of_run" == "run_from_wrapper" ]]; then

            #echo -e "           Run when print_only and or wrapper"


        if [[ "$type_of_run" == "run_from_wrapper" ]]; then
            
            #echo -e "           Run from wrapper"
            echo -e "          ${RED}DEBUG: LINE TO RUN IS -${NC} Command explain this place will be runned: 

           $command_echo_run

                    "

        else

            #echo -e "           Run from print_only"

            string_column_one=`echo $command_echo_run | awk '{print $4}'` 

            terminal_custom_logging "
            
                        ${YELLOW}Print Command to explain what in this place will be runned: ${NC} ${GREEN}${string_column_one}${NC}
                        
                        ${RED}DEBUG: LINE TO RUN IS -${NC} $command_echo_run

                        " "info"
            # #terminal_line
            # echo -e "         "
            # echo  -e "          "
            # echo -e "         "
            # #terminal_line

        fi

    else

        if [ "$type_of_run" = "debug" ]; then

            #terminal_line
            terminal_custom_logging "
            
                    Start running command: $command_echo_run
                    
                    " "info"
            #terminal_line
            eval "$command_echo_run"
            #terminal_line
            terminal_custom_logging "
            
                    Finish running command: $command_echo_run
                    
                    " "info"
            #terminal_line

        else

            #terminal_line
            terminal_custom_logging "
            
                    Command to run: $command_echo_run
                
                    " "info"
            eval "$command_echo_run"
            #terminal_line
        fi

    fi

}

auto_type(){
    #
    public_consul_domain=`cat "$ansible_dir"/inventories/products/$product/$inventory/group_vars/all.yml | grep 'public_consul_domain: \"' | grep -e "[\"]" | awk '{print $2}' | sed 's/"//g'`
    terminal_custom_logging "
    
                    ${RED}  Public Consul Domain${NC} $public_consul_domain
                    
                    " "info"

    #
    # declare prefixes_list=( 
    #     *.example.$public_consul_domain=_acme-challenge.example
    #     example.$public_consul_domain=_acme-challenge.example
    #     *.$public_consul_domain=_acme-challenge
    #     $public_consul_domain=_acme-challenge
    # )
    #

    declare prefixes_list=( 
        *.$public_consul_domain=_acme-challenge
        $public_consul_domain=_acme-challenge
    )

    #

    for item in ${prefixes_list[@]}; do
        
        domain_acme_name=`echo $item| cut -d "=" -f 1`
        domain_acme_txt_prefix=`echo $item| cut -d "=" -f 2`
        # echo "key=$key"
        # echo "value=$value"
        terminal_custom_logging "${RED}Run obtain certificate for domain${NC} $domain_acme_name with prefix $domain_acme_txt_prefix" "info"

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        "$ansible_dir"/playbook-library/!_bootstrap/letsencrypt-pacemaker.yml \
        -u $username --become-user root \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="3" \
        -e "acme_domain_for_obtain='$domain_acme_name'" -e acme_domain_prefix_txt="$domain_acme_txt_prefix"

    done 

}

check_input_version(){

    input_version=$1

    if [[ "$input_version" == "" ]]; then

        # terminal_line
        terminal_custom_logging "
        
                    Usage: $0 ${RED}input_version${NC} is must to be a specified!
                    
                    " "red"
        # terminal_line

        print_run_info
        exit

    fi

}

deploy_pipeline_swarm_and_minimal(){

        root_dir=$1

        echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
        echo "              Perform Minimal Security Configuration Environment Deploy Pipeline"
        echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

        # Deploy the docker-stack.yml from template on target application cluster

        function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
            "$ansible_dir"/playbook-library/\!_A_Deploy_pipeline/docker-stack-deploy-playbook.yml \
            -u $username --become-user root --become -e HOSTS="cloud-bind-frontend-dns" \
            -e "ansible_become_pass=$password" -e "ansible_ssh_pass=$password" -e stage="docker-stack-deploy" \
            -e ansible_root_directory="$ansible_dir" -e root_dir_path="$root_dir" -e version_ansible_build_id="${version_ansible_build_id}" \
            -e "@../.local/current_tags.yml" -e ANSIBLE_APPLICATION_TYPE="$apps" -e ANSIBLE_REGISTRY_URL="$ansible_global_gitlab_registry_site_name"

        echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

}

function_to_initial_make_eve_are_possible_to_live(){

    # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
    #     "$ansible_dir"/playbook-library/\!_0_init/docker-compose-eve-build-itself.yml \
    #     -u $username --become-user root --become -e HOSTS="localhost" \
    #         -e "ansible_become_pass=$password" -e "ansible_ssh_pass=$password" -e stage="docker-stack-deploy" \
    #         -e ansible_root_directory="$ansible_dir" -e root_dir_path="$root_dir" -e version_ansible_build_id="${version_ansible_build_id}" \
    #         -e "@../.local/current_tags.yml" -e ANSIBLE_APPLICATION_TYPE="$apps" -e ANSIBLE_REGISTRY_URL="$ansible_global_gitlab_registry_site_name"


    function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
        "$ansible_dir"/_selfbox_/_selfbox_docker_.yml \
        -e HOSTS="localhost" -u $username --become-user root \
        --become -e "ansible_become_pass='$password'" -e "ansible_ssh_pass='$password'" -e stage="2" \
            -e ansible_root_directory="$ansible_dir" -e root_dir_path="$root_dir" -e ANSIBLE_APPLICATION_TYPE="$apps" -e version_ansible_build_id="${version_ansible_build_id}" \
            -e ansible_environment="$inventory" -e ansible_product="$product"

    echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"




    # function_selector_runner ansible-playbook -i "$ansible_dir"/inventories/products/$product/$inventory/ \
    #     "$ansible_dir"/playbook-library/\!_A_Deploy_pipeline/docker-compose-eve-localhost.yml \
    #     -u $username --become-user root --become -e HOSTS="localhost" \
    #     -e "ansible_become_pass=$password" -e "ansible_ssh_pass=$password" -e stage="docker-stack-deploy" -e version_ansible_build_id="${version_ansible_build_id}" -e "@../.local/current_tags.yml"

    # echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"


}

check_input_vcs_project_group(){

    input_vcs_project_group=$1

    if [[ "$input_vcs_project_group" == "" ]]; then

        #terminal_line
        terminal_custom_logging "
        
                    Usage: When run $0 send VCS Project Group as ${RED}input_vcs_project_group${NC} - must to be a specified!
                    
                    " "red"
        #terminal_line

        print_run_info
        exit

    fi

}

check_input_vcs_project_name(){

    input_vcs_project_name=$1

    if [[ "$input_vcs_project_name" == "" ]]; then

        #terminal_line
        terminal_custom_logging "
        
                    Usage: When run $0 send VCS Project Name as ${RED}input_vcs_project_name${NC} - must to be a specified!
                    
                        " "red"
        #terminal_line

        print_run_info
        exit

    fi

}

last_info_show(){

    EXEC_TIMESTAMP=$1
    
    terminal_custom_logging "{****************************************************************************************************************************************************************************************************}${NC}${LIEV} Zen...${NC}" "forever"

    END_EXEC_TIMESTAMP=`date +%s`
    TOTAL_EXEC_TIME_SECS=`expr $END_EXEC_TIMESTAMP - $EXEC_TIMESTAMP`
    TOTAL_EXEC_TIME_MINS=`expr $TOTAL_EXEC_TIME_SECS / 60`

    # SHOW OVERALL RUNTIME
    if [ "$type_of_run" != "run_from_wrapper" ]; then

    terminal_custom_logging "

            .....    .....    .....    .....    .....    .....    .....    .....    .....    .....    .....    .....
            ${GREEN}DEPLOY HAS BEEN COMPLETED ${NC}
            
            ТOTAL DEPLOY TIME: 
            
            in mins: ${TOTAL_EXEC_TIME_MINS}
            in secs: ${TOTAL_EXEC_TIME_SECS}

            .....    .....    .....    .....    .....    .....    .....    .....    .....    .....    .....    .....

        " "info"

    terminal_custom_logging "
    
            We ${RED}love${NC} Ansible!
            
            " "defaults"

    fi
}

function_applications_sorted_list_in_object(){
    applications_sorted_list_in_object=$(printf "\n" ; for i in ${array_of_applications[@]}; do printf "                                $i\n"; done);
}
function_services_sorted_list_in_object(){
    services_applications_sorted_list_in_object=$(printf "\n" ; for i in ${array_of_services[@]}; do printf "                                $i\n"; done);
}
function_docs_sorted_list_in_object(){
    docs_applications_sorted_list_in_object=$(printf "\n" ; for i in ${array_of_docs[@]}; do printf "                                $i\n"; done);
}
function_ext_applications_sorted_list_in_object(){
    extended_applications_sorted_list_in_object=$(printf '\n' ; for i in ${extended_applications[@]}; do printf "                                $i\n"; done);
}
