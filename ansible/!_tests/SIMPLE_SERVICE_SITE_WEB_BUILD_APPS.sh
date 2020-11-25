#!/bin/bash

linked_env_in_product=$1

runpath=`pwd`

ansible_dir="$runpath/ansible"
ansible_dir=$(echo "$runpath"/ansible | sed -e "s/ansible\/ansible/ansible/g")

if [ ! -z $linked_env_in_product ]; then
    . $ansible_dir/\!_tests/adam_service_zone_devops_live.sh $linked_env_in_product
else
    . $ansible_dir/\!_tests/adam_service_zone_devops_live.sh
fi

# WIP CHANGE TARGET ON FLY
echo "!!!!!!!!! TESTS INJECT VAULT CONTAINER !!!!!!!!!"
$ansible_dir/.files/vault_container.sh template adam encrypt 7539148620qQ vcd production
echo "!!!!!!!!! DONE TESTS INJECT VAULT CONTAINER !!!!!!!!!"
#. ./!_tests/feel_local.sh

# BUILD IMAGES
# echo './!_all_services_builder.sh "$ANSIBLE_ENVIRONMENT" "$ANSIBLE_PRODUCT_NAME" "$ANSIBLE_DEPLOY_USERNAME" "$A_DEPLOY_PASSWORD" "$ANSIBLE_APPLICATION_TYPE" "$ANSIBLE_RUN_TYPE" "$ANSIBLE_CLOUD_TYPE" "$A_VAULT_PASSWORD" "$ANSIBLE_REGISTRY_URL" "$ANSIBLE_CI_PROJECT_NAME" "$ANSIBLE_CI_PROJECT_NAMESPACE" "$ANSIBLE_CI_VERSION" "$ANSIBLE_SECURITY"'

echo "!!!!!!!!!!!!!! 1 APPLICATION SET SOLUTION FROM SERVICES FOLDERBUILD APPS LIVE SH ONLY !!!!!!!!!!!!!!!!!!!!!"

echo "ANSIBLE_CI_DATACENTER: $ANSIBLE_CI_DATACENTER"
echo "ANSIBLE_ENVIRONMENT: $ANSIBLE_ENVIRONMENT"
echo "ANSIBLE_PRODUCT_NAME: $ANSIBLE_PRODUCT_NAME"
echo "ANSIBLE_DEPLOY_USERNAME: $ANSIBLE_DEPLOY_USERNAME"
echo "A_DEPLOY_PASSWORD: $A_DEPLOY_PASSWORD"
echo "ANSIBLE_APPLICATION_TYPE: $ANSIBLE_APPLICATION_TYPE"
echo "ANSIBLE_RUN_TYPE: $ANSIBLE_RUN_TYPE"
echo "ANSIBLE_CLOUD_TYPE: $ANSIBLE_CLOUD_TYPE"
echo "A_VAULT_PASSWORD: $A_VAULT_PASSWORD"
echo "ANSIBLE_REGISTRY_URL: $ANSIBLE_REGISTRY_URL"
echo "ANSIBLE_CI_PROJECT_NAME: $ANSIBLE_CI_PROJECT_NAME"
echo "ANSIBLE_CI_PROJECT_NAMESPACE: $ANSIBLE_CI_PROJECT_NAMESPACE"
echo "ANSIBLE_CI_VERSION: $ANSIBLE_CI_VERSION" 
echo "ANSIBLE_SECURITY: $ANSIBLE_SECURITY"
echo "ANSIBLE_CLUSTER_TYPE: $ANSIBLE_CLUSTER_TYPE"
echo "ANSIBLE_BUILD_ID: $ANSIBLE_BUILD_ID"
echo "ANSIBLE_COMMIT_SHA: $ANSIBLE_COMMIT_SHA"
echo "ANSIBLE_TRIGGER_TOKEN: $ANSIBLE_TRIGGER_TOKEN"
echo "ANSIBLE_REGISTRY_USERNAME: $ANSIBLE_REGISTRY_USERNAME"

if [ ! -z $ANSIBLE_TARGET_LINKED_DATACENTER_CHANGE_BETWEEN ]; then
    echo "ANSIBLE_TARGET_LINKED_DATACENTER_CHANGE_BETWEEN: $ANSIBLE_TARGET_LINKED_DATACENTER_CHANGE_BETWEEN"
fi

echo "!!!!!!!!!!!!!! 2 APPLICATION SET SOLUTION FROM SERVICES FOLDERBUILD APPS LIVE SH ONLY !!!!!!!!!!!!!!!!!!!!!"

if [ ! -z $linked_env_in_product ]; then

    echo "!!!!!!!!!!!!!! 2 target $linked_env_in_product ZONE LIVE SH ONLY !!!!!!!!!!!!!!!!!!!!!"

    /bin/bash "$ansible_dir"/reference_builder.sh \
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
    /bin/bash "$ansible_dir"/reference_builder.sh \
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
    "EXTRA_MILK_COW"
    #  \
    # "REINSTALL_PIP_TRUE" \
    # "$linked_env_in_product" 

fi


# # DEPLOY

# ./!_all_services_deployer.sh "$ANSIBLE_ENVIRONMENT" "$ANSIBLE_PRODUCT_NAME" "$ANSIBLE_DEPLOY_USERNAME" "$A_DEPLOY_PASSWORD" "$ANSIBLE_APPLICATION_TYPE" "$ANSIBLE_RUN_TYPE" "$ANSIBLE_CLOUD_TYPE" "$A_VAULT_PASSWORD" "$ANSIBLE_REGISTRY_URL" "$ANSIBLE_CI_PROJECT_NAME" "$ANSIBLE_CI_PROJECT_NAMESPACE" "$ANSIBLE_CI_VERSION" "$ANSIBLE_SECURITY"