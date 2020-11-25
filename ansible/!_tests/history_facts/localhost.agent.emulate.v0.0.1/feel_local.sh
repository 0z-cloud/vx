#!/bin/bash

# FOR RUN TEST YOU MUST EXPORT YOUR DEPLOY PASSWORD

export ANSIBLE_APPLICATION_TYPE=rails
export ANSIBLE_CI_PROJECT_NAME=ng-engine-vortex
export ANSIBLE_CI_PROJECT_NAMESPACE=vortex
export ANSIBLE_CLOUD_TYPE=bare
export ANSIBLE_DEPLOY_USERNAME=vortex
export ANSIBLE_ENVIRONMENT=sandbox
export ANSIBLE_PRODUCT_NAME=do-dev
export ANSIBLE_REGISTRY_URL=registry.vortex.com
export ANSIBLE_REGISTRY_USERNAME=root
export ANSIBLE_RUN_TYPE=true
export ANSIBLE_TRIGGER_TOKEN=VPRP2xQh4o5hqKNkto4
export ANSIBLE_CI_VERSION="2019.09.1107-ce981199"
#export ANSIBLE_SECURITY=minimal
export ANSIBLE_SECURITY=pci
#export A_DEPLOY_PASSWORD=*****
export A_VAULT_PASSWORD=asd819hr1br12br18mM

echo '' > ../.local/ci_version.sh
echo '' > ../.local/ci_version.yml
echo '' > ../.local/current_tags.yml

echo "passed_ci_docker_tag_business: $ANSIBLE_CI_VERSION" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_business_sidekiq: $ANSIBLE_CI_VERSION" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_business_whenever: $ANSIBLE_CI_VERSION" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_business_default: $ANSIBLE_CI_VERSION" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_card_storage: $ANSIBLE_CI_VERSION" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_core: $ANSIBLE_CI_VERSION" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_core_sidekiq: $ANSIBLE_CI_VERSION" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_demo: $ANSIBLE_CI_VERSION" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_flexy_guard: $ANSIBLE_CI_VERSION" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_flexy_guard_admin: $ANSIBLE_CI_VERSION" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_rate: $ANSIBLE_CI_VERSION" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_settings: $ANSIBLE_CI_VERSION" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_wallet: $ANSIBLE_CI_VERSION" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_wc_proxy: $ANSIBLE_CI_VERSION" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_elastic_hq: $ANSIBLE_CI_VERSION" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_elasticsearch: latest" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_kibana: latest" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_metabase: latest" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_minio: latest" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_mongo: latest" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_mongo_express: latest" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_postgres: latest" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_redis: latest" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_business_docs: latest" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_sms_gate: $ANSIBLE_CI_VERSION" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_wc_proxy: $ANSIBLE_CI_VERSION" >>  ../.local/current_tags.yml
echo "passed_ci_docker_tag_nginx: $ANSIBLE_CI_VERSION" >>  ../.local/current_tags.yml

echo "ANSIBLE_SECURITY=$ANSIBLE_SECURITY" >> ../.local/ci_version.sh
echo "ANSIBLE_CI_PROJECT_NAME=$ANSIBLE_CI_PROJECT_NAME" >> ../.local/ci_version.sh
echo "ANSIBLE_CI_PROJECT_NAMESPACE=$ANSIBLE_CI_PROJECT_NAMESPACE" >> ../.local/ci_version.sh
echo "ANSIBLE_CLOUD_TYPE=$ANSIBLE_CLOUD_TYPE" >> ../.local/ci_version.sh
echo "ANSIBLE_DEPLOY_USERNAME=$ANSIBLE_DEPLOY_USERNAME" >> ../.local/ci_version.sh
echo "ANSIBLE_ENVIRONMENT=$ANSIBLE_ENVIRONMENT" >> ../.local/ci_version.sh
echo "ANSIBLE_PRODUCT_NAME=$ANSIBLE_PRODUCT_NAME" >> ../.local/ci_version.sh
echo "ANSIBLE_REGISTRY_URL=$ANSIBLE_REGISTRY_URL" >> ../.local/ci_version.sh
echo "ANSIBLE_REGISTRY_USERNAME=$ANSIBLE_REGISTRY_USERNAME" >> ../.local/ci_version.sh
echo "ANSIBLE_RUN_TYPE=$ANSIBLE_RUN_TYPE" >> ../.local/ci_version.sh
echo "ANSIBLE_TRIGGER_TOKEN=$ANSIBLE_TRIGGER_TOKEN" >> ../.local/ci_version.sh
echo "ANSIBLE_CI_VERSION=$ANSIBLE_CI_VERSION" >> ../.local/ci_version.sh
echo "ANSIBLE_SECURITY=$ANSIBLE_SECURITY" >> ../.local/ci_version.sh
echo "A_DEPLOY_PASSWORD=$A_DEPLOY_PASSWORD" >> ../.local/ci_version.sh
echo "A_VAULT_PASSWORD=$A_VAULT_PASSWORD" >> ../.local/ci_version.sh

echo "ANSIBLE_SECURITY: $ANSIBLE_SECURITY" >> ../.local/ci_version.yml 
echo "ANSIBLE_CI_PROJECT_NAME: $ANSIBLE_CI_PROJECT_NAME" >> ../.local/ci_version.yml 
echo "ANSIBLE_CI_PROJECT_NAMESPACE: $ANSIBLE_CI_PROJECT_NAMESPACE" >> ../.local/ci_version.yml 
echo "ANSIBLE_CLOUD_TYPE: $ANSIBLE_CLOUD_TYPE" >> ../.local/ci_version.yml 
echo "ANSIBLE_DEPLOY_USERNAME: $ANSIBLE_DEPLOY_USERNAME" >> ../.local/ci_version.yml 
echo "ANSIBLE_ENVIRONMENT: $ANSIBLE_ENVIRONMENT" >> ../.local/ci_version.yml 
echo "ANSIBLE_PRODUCT_NAME: $ANSIBLE_PRODUCT_NAME" >> ../.local/ci_version.yml 
echo "ANSIBLE_REGISTRY_URL: $ANSIBLE_REGISTRY_URL" >> ../.local/ci_version.yml 
echo "ANSIBLE_REGISTRY_USERNAME: $ANSIBLE_REGISTRY_USERNAME" >> ../.local/ci_version.yml 
echo "ANSIBLE_RUN_TYPE: $ANSIBLE_RUN_TYPE" >> ../.local/ci_version.yml 
echo "ANSIBLE_TRIGGER_TOKEN: $ANSIBLE_TRIGGER_TOKEN" >> ../.local/ci_version.yml 
echo "ANSIBLE_CI_VERSION: $ANSIBLE_CI_VERSION" >> ../.local/ci_version.yml 
echo "ANSIBLE_SECURITY: $ANSIBLE_SECURITY" >> ../.local/ci_version.yml 
echo "A_DEPLOY_PASSWORD: $A_DEPLOY_PASSWORD" >> ../.local/ci_version.yml 
echo "A_VAULT_PASSWORD: $A_VAULT_PASSWORD" >> ../.local/ci_version.yml 

cat ../.local/ci_version.sh