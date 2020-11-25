#!/bin/bash

linked_env_in_product=$1

runpath=`pwd`

ansible_dir="$runpath/ansible"
ansible_dir=$(echo "$runpath"/ansible | sed -e "s/ansible\/ansible/ansible/g")

if [ ! -z $linked_env_in_product ]; then
    . $ansible_dir/\!_tests/lf_edge_eve_development_feel_local.sh $linked_env_in_product
else
    . $ansible_dir/\!_tests/lf_edge_eve_development_feel_local.sh
fi

# WIP CHANGE TARGET ON FLY
echo "!!!!!!!!! TESTS INJECT VAULT CONTAINER !!!!!!!!!"
$ansible_dir/.files/vault_container.sh "$ANSIBLE_DEPLOY_USERNAME" "$ANSIBLE_PRODUCT_NAME" encrypt "$A_VAULT_PASSWORD" "$ANSIBLE_CLOUD_TYPE" "$ANSIBLE_ENVIRONMENT"
echo "!!!!!!!!! DONE TESTS INJECT VAULT CONTAINER !!!!!!!!!"
#. ./!_tests/feel_local.sh

# BUILD IMAGES INSIDE

if [ ! -z $linked_env_in_product ]; then

    /bin/bash "$ansible_dir"/reference_0z-eve-cloud.sh \
    "$ANSIBLE_ENVIRONMENT" \
    "$ANSIBLE_PRODUCT_NAME" \
    "$ANSIBLE_DEPLOY_USERNAME" \
    "$A_DEPLOY_PASSWORD" \
    "$ANSIBLE_APPLICATION_TYPE" \
    "$ANSIBLE_RUN_TYPE" \
    "$ANSIBLE_CLOUD_TYPE" \
    "$A_VAULT_PASSWORD" \
    "$ANSIBLE_REGISTRY_URL" \
    "$ANSIBLE_CI_PROJECT_NAME" \
    "$ANSIBLE_CI_PROJECT_NAMESPACE" \
    "$ANSIBLE_CI_VERSION" \
    "$ANSIBLE_SECURITY" \
    "$ANSIBLE_CLUSTER_TYPE" \
    "$ANSIBLE_REGISTRY_USERNAME" \
    "$ANSIBLE_TRIGGER_TOKEN" \
    "$ANSIBLE_COMMIT_SHA" \
    "$ANSIBLE_BUILD_ID" \
    "$ANSIBLE_CI_DATACENTER" \
    "EXTRA_MILK_COW" \
    "REINSTALL_PIP_TRUE" \
    "$linked_env_in_product" 

else
    /bin/bash "$ansible_dir"/reference_0z-eve-cloud.sh \
    "$ANSIBLE_ENVIRONMENT" \
    "$ANSIBLE_PRODUCT_NAME" \
    "$ANSIBLE_DEPLOY_USERNAME" \
    "$A_DEPLOY_PASSWORD" \
    "$ANSIBLE_APPLICATION_TYPE" \
    "$ANSIBLE_RUN_TYPE" \
    "$ANSIBLE_CLOUD_TYPE" \
    "$A_VAULT_PASSWORD" \
    "$ANSIBLE_REGISTRY_URL" \
    "$ANSIBLE_CI_PROJECT_NAME" \
    "$ANSIBLE_CI_PROJECT_NAMESPACE" \
    "$ANSIBLE_CI_VERSION" \
    "$ANSIBLE_SECURITY" \
    "$ANSIBLE_CLUSTER_TYPE" \
    "$ANSIBLE_REGISTRY_USERNAME" \
    "$ANSIBLE_TRIGGER_TOKEN" \
    "$ANSIBLE_COMMIT_SHA" \
    "$ANSIBLE_BUILD_ID" \
    "$ANSIBLE_CI_DATACENTER" \
    "EXTRA_MILK_COW" \
    "REINSTALL_PIP_TRUE" 

fi

# # DEPLOY

# ./!_all_services_deployer.sh "$ANSIBLE_ENVIRONMENT" "$ANSIBLE_PRODUCT_NAME" "$ANSIBLE_DEPLOY_USERNAME" "$A_DEPLOY_PASSWORD" "$ANSIBLE_APPLICATION_TYPE" "$ANSIBLE_RUN_TYPE" "$ANSIBLE_CLOUD_TYPE" "$A_VAULT_PASSWORD" "$ANSIBLE_REGISTRY_URL" "$ANSIBLE_CI_PROJECT_NAME" "$ANSIBLE_CI_PROJECT_NAMESPACE" "$ANSIBLE_CI_VERSION" "$ANSIBLE_SECURITY"
