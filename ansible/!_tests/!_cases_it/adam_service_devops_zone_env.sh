#!/bin/bash
env=$1

if [ ! -z $env ]; then
    # remap target linked inventory by proovided value from stdin
    export ANSIBLE_TARGET_LINKED_DATACENTER_CHANGE_BETWEEN="${env}"
fi

# FOR RUN TEST YOU MUST EXPORT YOUR DEPLOY PASSWORD
export ANSIBLE_TARGET_LINKED_DATACENTER_CHANGE_BETWEEN="baremetal"
export ANSIBLE_APPLICATION_TYPE="eden_vortice"
export ANSIBLE_CI_PROJECT_NAME="adam"
export ANSIBLE_CI_PROJECT_NAMESPACE="repository"
export ANSIBLE_CLOUD_TYPE="vcd"
export ANSIBLE_DEPLOY_USERNAME="template"
export ANSIBLE_ENVIRONMENT="production"
# export ANSIBLE_ENVIRONMENT=IAC_TEST
# export ANSIBLE_ENVIRONMENT=poc
# export ANSIBLE_PRODUCT_NAME="eden-vortice"
export ANSIBLE_PRODUCT_NAME="adam"
export ANSIBLE_REGISTRY_URL="registry.adam.adam.local.cloud.eve.vortice.eden"
export ANSIBLE_REGISTRY_USERNAME="teamcity_adam"
# export ANSIBLE_RUN_TYPE="true"
export ANSIBLE_RUN_TYPE="print_only"
export ANSIBLE_TRIGGER_TOKEN="K4V11bsMsagsr-5QqQpn"
export ANSIBLE_CI_VERSION="2020.08.999-alfav1"
# export ANSIBLE_CI_VERSION="latest"
# export ANSIBLE_SECURITY="pci"
export ANSIBLE_SECURITY="minimal"
export A_DEPLOY_PASSWORD="7539148620cloud777"
export A_VAULT_PASSWORD="7539148620qQ"
# export ANSIBLE_CLUSTER_TYPE="k8s"
export ANSIBLE_CLUSTER_TYPE="swarm"
export ANSIBLE_COMMIT_SHA="ffffaa"
export ANSIBLE_BUILD_ID="888"
export ANSIBLE_CI_DATACENTER="source777"