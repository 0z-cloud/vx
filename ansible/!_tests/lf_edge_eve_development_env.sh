#!/bin/bash
################################################################################################

env=$1
run_choise_one_button_happy_place=$2

# FOR RUN TEST YOU MUST EXPORT YOUR DEPLOY PASSWORD
################################################################################################

################################################################################################
# DETERMINATE USE THE SEPARATED CLOUD TYPES FOR BOOTSTRAP IaC 0 LEVEL and DEPLOYMENT IaC 1 LEVEL
# USED FOR EXTEND, OR REPLACE CORE PARTS OF APPLYED LAYOUT OF SOLUTION ECOSYSTEM
# export ANSIBLE_TARGET_LINKED_DATACENTER_CHANGE_BETWEEN="vagrant"
# export ANSIBLE_TARGET_LINKED_DATACENTER_CHANGE_BETWEEN="vcd"
# export ANSIBLE_TARGET_LINKED_DATACENTER_CHANGE_BETWEEN="eve"
# export ANSIBLE_TARGET_LINKED_DATACENTER_CHANGE_BETWEEN="gcp"

if [ ! -z $env ]; then
    # remap target linked inventory by proovided value from stdin
    export ANSIBLE_TARGET_LINKED_DATACENTER_CHANGE_BETWEEN="${env}"
else
    export ANSIBLE_TARGET_LINKED_DATACENTER_CHANGE_BETWEEN="vcenter"
fi

################################################################################################
# APPLICATION SET - LAYOUT OF BUILD, TEST, PUBLISH, DEPLOY AND RUN SELECTED PRODUCT SOLUTION
export ANSIBLE_APPLICATION_TYPE="lf_edge_eve"

################################################################################################
# VCS PROJECT NAME IN NAMESPACE, SIMPLY ARE REPOSITORY PRIMARY NAME, - IF NO CHAGES IN FLY.
export ANSIBLE_CI_PROJECT_NAME="adam-vortex"

################################################################################################
# VCS PROJECT NAMESPACE FOR NEGOTIATE THE REPOSITORY LOCATION, 
# IN MOST CASES NAME OF PROJECT/COMPANY/ORGANIZATION
export ANSIBLE_CI_PROJECT_NAMESPACE="lf-edge"

################################################################################################
# ANSIBLE PRIMARY IF CHANGE BETWEEN NOT AR7E SET, 
# OR JUMPS TO OTHER CLOUD TYPE, IF PARENT ROOT ECOSYSTEM CLOUD ARE IS DEFINED TO CHANGE FROM IT.
# export ANSIBLE_CLOUD_TYPE="eve"
# export ANSIBLE_CLOUD_TYPE="gcp"
export ANSIBLE_CLOUD_TYPE="vsphere"
################################################################################################
# USER WHICH INITIATE THE CHAINED PIPELINES FLOW, MUST HAVE A NECESSARY SETTINGS IN VAULT PLACE
export ANSIBLE_DEPLOY_USERNAME="template"

################################################################################################
# TARGET BOOTSTRAPING AND DEPLOYING ENVIRONMENT.
# WHEN SET BE CAREFUL, BECAUSE YOU CAN CHANGE IT ON FLY. YOU MUST KNOWNS WHAT YOU ARE DOING YET.
export ANSIBLE_ENVIRONMENT="production"
# export ANSIBLE_ENVIRONMENT=dev2
# export ANSIBLE_ENVIRONMENT=dev1

################################################################################################
# INVENTORY PRODUCT NAME 
# export ANSIBLE_PRODUCT_NAME="lf-edge-eve"
export ANSIBLE_PRODUCT_NAME="lf-edge-eve"

################################################################################################
# LOCAL REGISTRY URI ENDPOINT CONSTRAIN
export ANSIBLE_REGISTRY_URL="registry.local.eve.eden"
# export ANSIBLE_REGISTRY_URL="registry.adam.local.cloud.eve.vortice.eden"

################################################################################################
# LOCAL REGISTRY USERNAME CONSTRAIN
export ANSIBLE_REGISTRY_USERNAME="registry_local"
# export ANSIBLE_REGISTRY_USERNAME="teamcity"

################################################################################################
##### THIS FLAG DETERMINATE THE VORTEX REACTION ON PLAY, 
## IF get TRUE - ALL CHAINED PIPELINES ARE GO TO EXECUTION IMADENTLY
## IF at FALSE - ONLY PRINT ALL STEPS WHICH WILL BE EXECUTED BY TRUE, VERY NICE FOR DEV, TEST
##  or run selected parts of needed chained pipelines workflow.
# if [ ! -z $run_choise_one_button_happy_place ]; then
#     # remap target linked inventory by proovided value from stdin
#     export ANSIBLE_RUN_TYPE="true"
# else
#     export ANSIBLE_RUN_TYPE="print_only"
# fi
ANSIBLE_RUN_TYPE="true"
################################################################################################
# LOCAL REGISTRY AUTH CREDENTIALS ARE DEFAULT REPLACED CONSTRAIN
export ANSIBLE_TRIGGER_TOKEN="notuniqbutveryverywellguys"

################################################################################################
# CI GENERATED BUILD RELEASE VERSION
export ANSIBLE_CI_VERSION="2020.10.999-223344"

################################################################################################
# SETTING ENVIRONMENT LANDSCAPE OVERALL LEVEL OF APPLYED SECURITY REQUIREMENTS FOR ALL ECOSYSTEM
# export ANSIBLE_SECURITY="pci"
export ANSIBLE_SECURITY="minimal"

################################################################################################
# ACCESS TO INSTANCE PASSWORD WHEN NOT USED RSA KEYS FOR SSH MANAGE THE BOOTSTRAPED INSTANCES
export A_DEPLOY_PASSWORD="12345"

################################################################################################
# INTERNAL VAULT PASSWORD FOR ABLE IMITATE THE PUSHING CI BUTTON IN DEVELOPING MODE
################################################################################################
export A_VAULT_PASSWORD="7539148620qQ"

################################################################################################
# SETS A CLUSTER TYPE - k8s/swarm/standalone/nomad/etc
export ANSIBLE_CLUSTER_TYPE="k8s"

################################################################################################
# CURRENT COMMIT SHA SUM MARKER
export ANSIBLE_COMMIT_SHA="ffffaa"

################################################################################################
# CI/CD Tool Solution internal Build ID
export ANSIBLE_BUILD_ID="777"

################################################################################################
# Logical/Physical Datacenter placement variable
export ANSIBLE_CI_DATACENTER="dc911rs"
