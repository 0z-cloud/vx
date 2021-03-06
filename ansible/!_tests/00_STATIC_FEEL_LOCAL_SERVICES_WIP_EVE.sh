#!/bin/bash

runpath=`pwd`

ansible_dir="$runpath/ansible"
ansible_dir=$(echo "$runpath"/ansible | sed -e "s/ansible\/ansible/ansible/g")

. $ansible_dir/\!_tests/lf-edge-eve-static-bare-vcenter_env.sh
echo "!!!!!!!!! TESTS INJECT VAULT CONTAINER !!!!!!!!!"
$ansible_dir/.files/vault_container.sh $ANSIBLE_DEPLOY_USERNAME $ANSIBLE_PRODUCT_NAME encrypt $A_VAULT_PASSWORD $ANSIBLE_CLOUD_TYPE $ANSIBLE_ENVIRONMENT

echo "!!!!!!!!! DONE TESTS INJECT VAULT CONTAINER !!!!!!!!!"
#. ./!_tests/feel_local.sh

# BUILD IMAGES
# echo './!_all_services_builder.sh "$ANSIBLE_ENVIRONMENT" "$ANSIBLE_PRODUCT_NAME" "$ANSIBLE_DEPLOY_USERNAME" "$A_DEPLOY_PASSWORD" "$ANSIBLE_APPLICATION_TYPE" "$ANSIBLE_RUN_TYPE" "$ANSIBLE_CLOUD_TYPE" "$A_VAULT_PASSWORD" "$ANSIBLE_REGISTRY_URL" "$ANSIBLE_CI_PROJECT_NAME" "$ANSIBLE_CI_PROJECT_NAMESPACE" "$ANSIBLE_CI_VERSION" "$ANSIBLE_SECURITY"'

echo "!!!!!!!!!!!!!! DEBUG !!!!!!!!!!!!!!!!!!!!!"

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

echo "!!!!!!!!!!!!!! DEBUG !!!!!!!!!!!!!!!!!!!!!"

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
    "$ANSIBLE_CLUSTER_TYPE"

# # DEPLOY

# ./!_all_services_deployer.sh "$ANSIBLE_ENVIRONMENT" "$ANSIBLE_PRODUCT_NAME" "$ANSIBLE_DEPLOY_USERNAME" "$A_DEPLOY_PASSWORD" "$ANSIBLE_APPLICATION_TYPE" "$ANSIBLE_RUN_TYPE" "$ANSIBLE_CLOUD_TYPE" "$A_VAULT_PASSWORD" "$ANSIBLE_REGISTRY_URL" "$ANSIBLE_CI_PROJECT_NAME" "$ANSIBLE_CI_PROJECT_NAMESPACE" "$ANSIBLE_CI_VERSION" "$ANSIBLE_SECURITY"
