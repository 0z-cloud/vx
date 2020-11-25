ls -la ./

. ./ci_version.sh

mkdir ./.local/

mv ./current_tags.yml ./.local/
mv ./ci_version.yml ./.local/
mv ./ci_version.sh ./.local/
mv ./ci_vault.sh ./.local/
mv ./id_rsa ./.local/
mv ./id_rsa.pub ./.local/
mv ./pass.yml ./.local/
mv ./vault-password-file-tmp.yml ./.local/
mv ./vault-password-file.yml ./.local/
mv ./vault_pass.yml ./.local/

cat ./.local/current_tags.yml

echo "Docker Login:"

docker login "%ANSIBLE_REGISTRY_URL%" -u "%ANSIBLE_REGISTRY_USERNAME%" -p "%ANSIBLE_TRIGGER_TOKEN%"

echo "Docker login complete"

echo "Change dir to ansible"
cd ./ansible
echo "Show contents of parent .local folder"
ls -la ../.local

A_DEPLOY_PASSWORD=`cat ../.local/pass.yml`
A_VAULT_PASSWORD=`cat ../.local/vault_pass.yml`

RUNNING_ONLY_QA="%RunningOnlyQA%"

echo "RUNNING_ONLY_QA is $RUNNING_ONLY_QA"

if [ "$RUNNING_ONLY_QA" = true ]; then

  echo "RUNNING_ONLY_QA is true"

else

    echo "RUNNING_ONLY_QA is false"

    RUNNING_DISABLE_PUBLISH="%RunningOfferForPublish%"

    echo "RUNNING_DISABLE_PUBLISH is $RUNNING_DISABLE_PUBLISH"

    if [ "$RUNNING_DISABLE_PUBLISH" = true ]; then
    
      echo "RUNNING_DISABLE_PUBLISH is true"

    else
    
      echo "RUNNING_DISABLE_PUBLISH is false"
      ./!_all_services_deployer.sh "$ANSIBLE_ENVIRONMENT" "$ANSIBLE_PRODUCT_NAME" "$ANSIBLE_DEPLOY_USERNAME" "$A_DEPLOY_PASSWORD" "$ANSIBLE_APPLICATION_TYPE" "$ANSIBLE_RUN_TYPE" "$ANSIBLE_CLOUD_TYPE" "$A_VAULT_PASSWORD" "$ANSIBLE_REGISTRY_URL" "$ANSIBLE_CI_PROJECT_NAME" "$ANSIBLE_CI_PROJECT_NAMESPACE" "$ANSIBLE_CI_VERSION"

    fi

fi