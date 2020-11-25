#!/bin/bash
# FOR RUN TEST YOU MUST EXPORT YOUR DEPLOY PASSWORD

export ANSIBLE_APPLICATION_TYPE="eden_vortice"
export ANSIBLE_CI_PROJECT_NAME="adam-vortex"
export ANSIBLE_CI_PROJECT_NAMESPACE="vortice"
export ANSIBLE_CLOUD_TYPE="vcd"
export ANSIBLE_DEPLOY_USERNAME="template"
export ANSIBLE_ENVIRONMENT="production"
#export ANSIBLE_ENVIRONMENT=IAC_TEST
#export ANSIBLE_ENVIRONMENT=poc
#export ANSIBLE_PRODUCT_NAME="eden-vortice"
export ANSIBLE_PRODUCT_NAME="matreshka"
export ANSIBLE_REGISTRY_URL="registry.adam.local.cloud.eve.vortice.eden"
export ANSIBLE_REGISTRY_USERNAME="teamcity"
export ANSIBLE_RUN_TYPE="true"
#export ANSIBLE_RUN_TYPE="print_only"
export ANSIBLE_TRIGGER_TOKEN="ZQzkrRjHiz_C1hhkosmW"
export ANSIBLE_CI_VERSION="2020.05.777-ffffaa"
export ANSIBLE_SECURITY="pci"
#export ANSIBLE_SECURITY="minimal"
export A_DEPLOY_PASSWORD="7539148620cloud777"
export A_VAULT_PASSWORD="7539148620qQ"
export ANSIBLE_CLUSTER_TYPE="k8s"
export ANSIBLE_COMMIT_SHA="ffffaa"
export ANSIBLE_BUILD_ID="777"

export ANSIBLE_CI_DATACENTER="dc911rs"