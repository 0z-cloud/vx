#!/bin/bash
linked_env_in_product=$1
runpath=`pwd`

ansible_dir_pre=$(echo "$runpath" | sed -e "s/ansible\/ansible/ansible/g")

ansible_dir=$(echo "$ansible_dir_pre" | sed -e "s/ansible\/ansible/ansible/g")

if [ ! -z $linked_env_in_product ]; then

  . $ansible_dir/\!_tests/adam_service_devops_zone_env.sh $linked_env_in_product

else

  . $ansible_dir/\!_tests/adam_service_devops_zone_env.sh

fi

LOCAL_ANSIBLE_DIRECTORY="$runpath/.local"
ROOT_DIRECTORY=`echo $LOCAL_ANSIBLE_DIRECTORY | sed -e "s/\/ansible\/\.local//g"`
LOCAL_DIRECTORY="$ROOT_DIRECTORY/.local"
LOCAL_DIRECTORY_NAME=".local"
echo "LOCAL_DIRECTORY: $LOCAL_DIRECTORY"
#DIRECTORY="$runpath/.local"
uname=`uname`

if [ "$uname" == "Darwin" ]; then

  #found=`find --type d -name "$LOCAL_DIRECTORY"`
  found=`find $ROOT_DIRECTORY -type d -name "${LOCAL_DIRECTORY_NAME}"`

elif [ "$uname" == "Linux" ]; then

  found=`find $ROOT_DIRECTORY --type d -name "$LOCAL_DIRECTORY_NAME"`

elif [ "$uname" == "MINGW32_NT" ]; then
    
  found=`find --type d -name "$LOCAL_DIRECTORY"`

elif [ "$uname" == "MINGW64_NT" ]; then

  found=`find --type d -name "$LOCAL_DIRECTORY"`

fi

echo "found: $found"

if [ -z "$found" ]; then
  # Control will enter here if $LOCAL_DIRECTORY exists.
  mkdir $LOCAL_DIRECTORY
fi

echo '' > $LOCAL_DIRECTORY/ci_version.sh
echo '' > $LOCAL_DIRECTORY/ci_version.yml
echo '' > $LOCAL_DIRECTORY/current_tags.yml

echo "passed_ci_docker_tag_eve: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_adam: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_eden: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_zina: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_luka: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_business: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_business_sidekiq: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_business_whenever: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_business_default: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_card_storage: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_core: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_core_sidekiq: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_demo: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_flexy_guard: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_flexy_guard_admin: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_rate: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_frontend: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_backend: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_settings: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_wallet: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_wc_proxy: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_elastic_hq: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_elasticsearch: latest" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_kibana: latest" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_metabase: latest" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_minio: latest" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_mongo: latest" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_mongo_express: latest" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_postgres: latest" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_redis: latest" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_business_docs: latest" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_sms_gate: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_wc_proxy: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_nginx: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml
echo "passed_ci_docker_tag_mariadb: $ANSIBLE_CI_VERSION" >>  $LOCAL_DIRECTORY/current_tags.yml

if [ ! -z $ANSIBLE_TARGET_LINKED_DATACENTER_CHANGE_BETWEEN ]; then
  echo "ANSIBLE_TARGET_LINKED_DATACENTER_CHANGE_BETWEEN=$ANSIBLE_TARGET_LINKED_DATACENTER_CHANGE_BETWEEN" >> $LOCAL_DIRECTORY/ci_version.sh
  echo "ANSIBLE_TARGET_LINKED_DATACENTER_CHANGE_BETWEEN: $ANSIBLE_TARGET_LINKED_DATACENTER_CHANGE_BETWEEN" >> $LOCAL_DIRECTORY/ci_version.yml
fi
echo "ANSIBLE_APPLICATION_TYPE=$ANSIBLE_APPLICATION_TYPE" >> $LOCAL_DIRECTORY/ci_version.sh
echo "ANSIBLE_CI_DATACENTER=$ANSIBLE_CI_DATACENTER" >> $LOCAL_DIRECTORY/ci_version.sh
echo "ANSIBLE_CLUSTER_TYPE=$ANSIBLE_CLUSTER_TYPE" >> $LOCAL_DIRECTORY/ci_version.sh
echo "ANSIBLE_SECURITY=$ANSIBLE_SECURITY" >> $LOCAL_DIRECTORY/ci_version.sh
echo "ANSIBLE_CI_PROJECT_NAME=$ANSIBLE_CI_PROJECT_NAME" >> $LOCAL_DIRECTORY/ci_version.sh
echo "ANSIBLE_CI_PROJECT_NAMESPACE=$ANSIBLE_CI_PROJECT_NAMESPACE" >> $LOCAL_DIRECTORY/ci_version.sh
echo "ANSIBLE_CLOUD_TYPE=$ANSIBLE_CLOUD_TYPE" >> $LOCAL_DIRECTORY/ci_version.sh
echo "ANSIBLE_DEPLOY_USERNAME=$ANSIBLE_DEPLOY_USERNAME" >> $LOCAL_DIRECTORY/ci_version.sh
echo "ANSIBLE_ENVIRONMENT=$ANSIBLE_ENVIRONMENT" >> $LOCAL_DIRECTORY/ci_version.sh
echo "ANSIBLE_PRODUCT_NAME=$ANSIBLE_PRODUCT_NAME" >> $LOCAL_DIRECTORY/ci_version.sh
echo "ANSIBLE_REGISTRY_URL=$ANSIBLE_REGISTRY_URL" >> $LOCAL_DIRECTORY/ci_version.sh
echo "ANSIBLE_REGISTRY_USERNAME=$ANSIBLE_REGISTRY_USERNAME" >> $LOCAL_DIRECTORY/ci_version.sh
echo "ANSIBLE_RUN_TYPE=$ANSIBLE_RUN_TYPE" >> $LOCAL_DIRECTORY/ci_version.sh
echo "ANSIBLE_TRIGGER_TOKEN=$ANSIBLE_TRIGGER_TOKEN" >> $LOCAL_DIRECTORY/ci_version.sh
echo "ANSIBLE_CI_VERSION=$ANSIBLE_CI_VERSION" >> $LOCAL_DIRECTORY/ci_version.sh
echo "ANSIBLE_SECURITY=$ANSIBLE_SECURITY" >> $LOCAL_DIRECTORY/ci_version.sh
echo "A_DEPLOY_PASSWORD=$A_DEPLOY_PASSWORD" >> $LOCAL_DIRECTORY/ci_version.sh
echo "A_VAULT_PASSWORD=$A_VAULT_PASSWORD" >> $LOCAL_DIRECTORY/ci_version.sh
echo "ANSIBLE_COMMIT_SHA=$ANSIBLE_COMMIT_SHA" >> $LOCAL_DIRECTORY/ci_version.sh
echo "ANSIBLE_BUILD_ID=$ANSIBLE_BUILD_ID" >> $LOCAL_DIRECTORY/ci_version.sh

echo "ANSIBLE_APPLICATION_TYPE: $ANSIBLE_APPLICATION_TYPE" >> $LOCAL_DIRECTORY/ci_version.yml
echo "ANSIBLE_CI_DATACENTER: $ANSIBLE_CI_DATACENTER" >> $LOCAL_DIRECTORY/ci_version.yml
echo "ANSIBLE_CLUSTER_TYPE: $ANSIBLE_CLUSTER_TYPE" >> $LOCAL_DIRECTORY/ci_version.yml
echo "ANSIBLE_SECURITY: $ANSIBLE_SECURITY" >> $LOCAL_DIRECTORY/ci_version.yml
echo "ANSIBLE_CI_PROJECT_NAME: $ANSIBLE_CI_PROJECT_NAME" >> $LOCAL_DIRECTORY/ci_version.yml
echo "ANSIBLE_CI_PROJECT_NAMESPACE: $ANSIBLE_CI_PROJECT_NAMESPACE" >> $LOCAL_DIRECTORY/ci_version.yml
echo "ANSIBLE_CLOUD_TYPE: $ANSIBLE_CLOUD_TYPE" >> $LOCAL_DIRECTORY/ci_version.yml
echo "ANSIBLE_DEPLOY_USERNAME: $ANSIBLE_DEPLOY_USERNAME" >> $LOCAL_DIRECTORY/ci_version.yml
echo "ANSIBLE_ENVIRONMENT: $ANSIBLE_ENVIRONMENT" >> $LOCAL_DIRECTORY/ci_version.yml
echo "ANSIBLE_PRODUCT_NAME: $ANSIBLE_PRODUCT_NAME" >> $LOCAL_DIRECTORY/ci_version.yml
echo "ANSIBLE_REGISTRY_URL: $ANSIBLE_REGISTRY_URL" >> $LOCAL_DIRECTORY/ci_version.yml
echo "ANSIBLE_REGISTRY_USERNAME: $ANSIBLE_REGISTRY_USERNAME" >> $LOCAL_DIRECTORY/ci_version.yml
echo "ANSIBLE_RUN_TYPE: $ANSIBLE_RUN_TYPE" >> $LOCAL_DIRECTORY/ci_version.yml
echo "ANSIBLE_TRIGGER_TOKEN: $ANSIBLE_TRIGGER_TOKEN" >> $LOCAL_DIRECTORY/ci_version.yml
echo "ANSIBLE_CI_VERSION: $ANSIBLE_CI_VERSION" >> $LOCAL_DIRECTORY/ci_version.yml
echo "ANSIBLE_SECURITY: $ANSIBLE_SECURITY" >> $LOCAL_DIRECTORY/ci_version.yml
echo "A_DEPLOY_PASSWORD: $A_DEPLOY_PASSWORD" >> $LOCAL_DIRECTORY/ci_version.yml
echo "A_VAULT_PASSWORD: $A_VAULT_PASSWORD" >> $LOCAL_DIRECTORY/ci_version.yml
echo "ANSIBLE_COMMIT_SHA: $ANSIBLE_COMMIT_SHA" >> $LOCAL_DIRECTORY/ci_version.yml
echo "ANSIBLE_BUILD_ID: $ANSIBLE_BUILD_ID" >> $LOCAL_DIRECTORY/ci_version.yml

cat $LOCAL_DIRECTORY/ci_version.sh