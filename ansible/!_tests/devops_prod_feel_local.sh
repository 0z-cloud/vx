#!/bin/bash

runpath=`pwd`

ansible_dir_pre=$(echo "$runpath" | sed -e "s/ansible\/ansible/ansible/g")

ansible_dir=$(echo "$ansible_dir_pre" | sed -e "s/ansible\/ansible/ansible/g")

. $ansible_dir/\!_tests/devops_prod_env.sh


LOCAL_DIRECTORY="$runpath/.local"

#DIRECTORY="$runpath/.local"

found=`find -type d -name "$LOCAL_DIRECTORY"`

if [ -n "$found" ]; then
  # Control will enter here if $LOCAL_DIRECTORY exists.
  mkdir $LOCAL_DIRECTORY
fi

echo '' > $runpath/.local/ci_version.sh
echo '' > $runpath/.local/ci_version.yml
echo '' > $runpath/.local/current_tags.yml

echo "passed_ci_docker_tag_business: $ANSIBLE_CI_VERSION" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_business_sidekiq: $ANSIBLE_CI_VERSION" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_business_whenever: $ANSIBLE_CI_VERSION" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_business_default: $ANSIBLE_CI_VERSION" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_card_storage: $ANSIBLE_CI_VERSION" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_core: $ANSIBLE_CI_VERSION" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_core_sidekiq: $ANSIBLE_CI_VERSION" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_demo: $ANSIBLE_CI_VERSION" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_flexy_guard: $ANSIBLE_CI_VERSION" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_flexy_guard_admin: $ANSIBLE_CI_VERSION" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_rate: $ANSIBLE_CI_VERSION" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_settings: $ANSIBLE_CI_VERSION" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_wallet: $ANSIBLE_CI_VERSION" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_wc_proxy: $ANSIBLE_CI_VERSION" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_elastic_hq: $ANSIBLE_CI_VERSION" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_elasticsearch: latest" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_kibana: latest" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_metabase: latest" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_minio: latest" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_mongo: latest" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_mongo_express: latest" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_postgres: latest" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_redis: latest" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_business_docs: latest" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_sms_gate: $ANSIBLE_CI_VERSION" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_wc_proxy: $ANSIBLE_CI_VERSION" >>  $runpath/.local/current_tags.yml
echo "passed_ci_docker_tag_nginx: $ANSIBLE_CI_VERSION" >>  $runpath/.local/current_tags.yml

echo "ANSIBLE_CLUSTER_TYPE=$ANSIBLE_CLUSTER_TYPE" >> $runpath/.local/ci_version.sh
echo "ANSIBLE_SECURITY=$ANSIBLE_SECURITY" >> $runpath/.local/ci_version.sh
echo "ANSIBLE_CI_PROJECT_NAME=$ANSIBLE_CI_PROJECT_NAME" >> $runpath/.local/ci_version.sh
echo "ANSIBLE_CI_PROJECT_NAMESPACE=$ANSIBLE_CI_PROJECT_NAMESPACE" >> $runpath/.local/ci_version.sh
echo "ANSIBLE_CLOUD_TYPE=$ANSIBLE_CLOUD_TYPE" >> $runpath/.local/ci_version.sh
echo "ANSIBLE_DEPLOY_USERNAME=$ANSIBLE_DEPLOY_USERNAME" >> $runpath/.local/ci_version.sh
echo "ANSIBLE_ENVIRONMENT=$ANSIBLE_ENVIRONMENT" >> $runpath/.local/ci_version.sh
echo "ANSIBLE_PRODUCT_NAME=$ANSIBLE_PRODUCT_NAME" >> $runpath/.local/ci_version.sh
echo "ANSIBLE_REGISTRY_URL=$ANSIBLE_REGISTRY_URL" >> $runpath/.local/ci_version.sh
echo "ANSIBLE_REGISTRY_USERNAME=$ANSIBLE_REGISTRY_USERNAME" >> $runpath/.local/ci_version.sh
echo "ANSIBLE_RUN_TYPE=$ANSIBLE_RUN_TYPE" >> $runpath/.local/ci_version.sh
echo "ANSIBLE_TRIGGER_TOKEN=$ANSIBLE_TRIGGER_TOKEN" >> $runpath/.local/ci_version.sh
echo "ANSIBLE_CI_VERSION=$ANSIBLE_CI_VERSION" >> $runpath/.local/ci_version.sh
echo "ANSIBLE_SECURITY=$ANSIBLE_SECURITY" >> $runpath/.local/ci_version.sh
echo "A_DEPLOY_PASSWORD=$A_DEPLOY_PASSWORD" >> $runpath/.local/ci_version.sh
echo "A_VAULT_PASSWORD=$A_VAULT_PASSWORD" >> $runpath/.local/ci_version.sh
echo "ANSIBLE_COMMIT_SHA=$ANSIBLE_COMMIT_SHA" >> $runpath/.local/ci_version.sh
echo "ANSIBLE_BUILD_ID=$ANSIBLE_BUILD_ID" >> $runpath/.local/ci_version.sh

echo "ANSIBLE_CLUSTER_TYPE: $ANSIBLE_CLUSTER_TYPE" >> $runpath/.local/ci_version.yml
echo "ANSIBLE_SECURITY: $ANSIBLE_SECURITY" >> $runpath/.local/ci_version.yml
echo "ANSIBLE_CI_PROJECT_NAME: $ANSIBLE_CI_PROJECT_NAME" >> $runpath/.local/ci_version.yml
echo "ANSIBLE_CI_PROJECT_NAMESPACE: $ANSIBLE_CI_PROJECT_NAMESPACE" >> $runpath/.local/ci_version.yml
echo "ANSIBLE_CLOUD_TYPE: $ANSIBLE_CLOUD_TYPE" >> $runpath/.local/ci_version.yml
echo "ANSIBLE_DEPLOY_USERNAME: $ANSIBLE_DEPLOY_USERNAME" >> $runpath/.local/ci_version.yml
echo "ANSIBLE_ENVIRONMENT: $ANSIBLE_ENVIRONMENT" >> $runpath/.local/ci_version.yml
echo "ANSIBLE_PRODUCT_NAME: $ANSIBLE_PRODUCT_NAME" >> $runpath/.local/ci_version.yml
echo "ANSIBLE_REGISTRY_URL: $ANSIBLE_REGISTRY_URL" >> $runpath/.local/ci_version.yml
echo "ANSIBLE_REGISTRY_USERNAME: $ANSIBLE_REGISTRY_USERNAME" >> $runpath/.local/ci_version.yml
echo "ANSIBLE_RUN_TYPE: $ANSIBLE_RUN_TYPE" >> $runpath/.local/ci_version.yml
echo "ANSIBLE_TRIGGER_TOKEN: $ANSIBLE_TRIGGER_TOKEN" >> $runpath/.local/ci_version.yml
echo "ANSIBLE_CI_VERSION: $ANSIBLE_CI_VERSION" >> $runpath/.local/ci_version.yml
echo "ANSIBLE_SECURITY: $ANSIBLE_SECURITY" >> $runpath/.local/ci_version.yml
echo "A_DEPLOY_PASSWORD: $A_DEPLOY_PASSWORD" >> $runpath/.local/ci_version.yml
echo "A_VAULT_PASSWORD: $A_VAULT_PASSWORD" >> $runpath/.local/ci_version.yml
echo "ANSIBLE_COMMIT_SHA: $ANSIBLE_COMMIT_SHA" >> $runpath/.local/ci_version.yml
echo "ANSIBLE_BUILD_ID: $ANSIBLE_BUILD_ID" >> $runpath/.local/ci_version.yml

cat $runpath/.local/ci_version.sh