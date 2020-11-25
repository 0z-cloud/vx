rm -rf ./ci_version.yml
rm -rf ./ci_version.sh

echo "MAIN_ANSIBLE_BUILD_ID: %MAIN_ANSIBLE_BUILD_ID%"
echo "ANSIBLE_COMMIT_SHA: %ANSIBLE_COMMIT_SHA%"

ANSIBLE_COMMIT_SHA_SHORT=`echo %ANSIBLE_COMMIT_SHA% | head -c 8`
DATE_YEAR=`date '+%Y'`
DATE_MOUTH=`date '+%m'`
ANSIBLE_CI_VERSION="${DATE_YEAR}.${DATE_MOUTH}.%MAIN_ANSIBLE_BUILD_ID%-${ANSIBLE_COMMIT_SHA_SHORT}"

echo "ANSIBLE_CI_VERSION: $ANSIBLE_CI_VERSION" >> ./ci_version.yml

echo "Creating the temp shell settings file for pass values to next step"

ls -la ./

rm -rf ./ci_settings.sh
rm -rf ./ci_version.yml

. ./ci_vault.sh

RUNNING_ONLY_QA="%RunningOnlyQA%"

echo "RUNNING_ONLY_QA is $RUNNING_ONLY_QA"

if [ "$RUNNING_ONLY_QA" = true ]; then

  echo "RUNNING_ONLY_QA is true"

else

    bash -x
    echo "Docker Login:"

    docker login "%ANSIBLE_REGISTRY_URL%" -u "%ANSIBLE_REGISTRY_USERNAME%" -p "%ANSIBLE_TRIGGER_TOKEN%"

    echo "Docker Login complete"

    cd ./ansible
    
    echo "RUNNING_ONLY_QA is false"

    RUNNING_DISABLE_BUILD="%RunningOfferForBuild%"

    echo "RUNNING_DISABLE_BUILD is $RUNNING_DISABLE_BUILD"

    if [ "$RUNNING_DISABLE_BUILD" = true ]; then
    
      echo "RUNNING_DISABLE_BUILD is true"

    else
    
      echo "RUNNING_DISABLE_BUILD is false"
    
      ./!_all_services_builder.sh "%ANSIBLE_ENVIRONMENT%" "%ANSIBLE_PRODUCT_NAME%" "%ANSIBLE_DEPLOY_USERNAME%" "%A_DEPLOY_PASSWORD%" "%ANSIBLE_APPLICATION_TYPE%" "%ANSIBLE_RUN_TYPE%" "%ANSIBLE_CLOUD_TYPE%" "%A_VAULT_PASSWORD%" "%ANSIBLE_REGISTRY_URL%" "%ANSIBLE_CI_PROJECT_NAME%" "%ANSIBLE_CI_PROJECT_NAMESPACE%" "$ANSIBLE_CI_VERSION"

    fi

    cd ../

fi

echo "MAIN_ANSIBLE_BUILD_ID: %MAIN_ANSIBLE_BUILD_ID%"
echo "ANSIBLE_COMMIT_SHA: %ANSIBLE_COMMIT_SHA%"

ANSIBLE_COMMIT_SHA_SHORT=`echo %ANSIBLE_COMMIT_SHA% | head -c 8`

DATE_YEAR=`date '+%Y'`
DATE_MOUTH=`date '+%m'`
ANSIBLE_CI_VERSION="${DATE_YEAR}.${DATE_MOUTH}.%MAIN_ANSIBLE_BUILD_ID%-${ANSIBLE_COMMIT_SHA_SHORT}"


echo "ANSIBLE_COMMIT_SHA_SHORT: $ANSIBLE_COMMIT_SHA_SHORT" >> ./ci_version.yml
echo "ANSIBLE_APPLICATION_TYPE: %ANSIBLE_APPLICATION_TYPE%" >> ./ci_version.yml
echo "ANSIBLE_CI_PROJECT_NAME: %ANSIBLE_CI_PROJECT_NAME%" >> ./ci_version.yml
echo "ANSIBLE_CI_PROJECT_NAMESPACE: %ANSIBLE_CI_PROJECT_NAMESPACE%" >> ./ci_version.yml
echo "ANSIBLE_CLOUD_TYPE: %ANSIBLE_CLOUD_TYPE%" >> ./ci_version.yml
echo "ANSIBLE_DEPLOY_USERNAME: %ANSIBLE_DEPLOY_USERNAME%" >> ./ci_version.yml
echo "ANSIBLE_ENVIRONMENT: %ANSIBLE_ENVIRONMENT%" >> ./ci_version.yml
echo "ANSIBLE_PRODUCT_NAME: %ANSIBLE_PRODUCT_NAME%" >> ./ci_version.yml
echo "ANSIBLE_REGISTRY_URL: %ANSIBLE_REGISTRY_URL%" >> ./ci_version.yml
echo "ANSIBLE_REGISTRY_USERNAME: %ANSIBLE_REGISTRY_USERNAME%" >> ./ci_version.yml
echo "ANSIBLE_RUN_TYPE: %ANSIBLE_RUN_TYPE%" >> ./ci_version.yml
echo "ANSIBLE_TRIGGER_TOKEN: %ANSIBLE_TRIGGER_TOKEN%" >> ./ci_version.yml 
echo "ANSIBLE_CI_VERSION: $ANSIBLE_CI_VERSION" >> ./ci_version.yml

echo "ANSIBLE_COMMIT_SHA_SHORT=$ANSIBLE_COMMIT_SHA_SHORT" >> ./ci_version.sh
echo "ANSIBLE_APPLICATION_TYPE=%ANSIBLE_APPLICATION_TYPE%" >> ./ci_version.sh
echo "ANSIBLE_CI_PROJECT_NAME=%ANSIBLE_CI_PROJECT_NAME%" >> ./ci_version.sh
echo "ANSIBLE_CI_PROJECT_NAMESPACE=%ANSIBLE_CI_PROJECT_NAMESPACE%" >> ./ci_version.sh
echo "ANSIBLE_CLOUD_TYPE=%ANSIBLE_CLOUD_TYPE%" >> ./ci_version.sh
echo "ANSIBLE_DEPLOY_USERNAME=%ANSIBLE_DEPLOY_USERNAME%" >> ./ci_version.sh
echo "ANSIBLE_ENVIRONMENT=%ANSIBLE_ENVIRONMENT%" >> ./ci_version.sh
echo "ANSIBLE_PRODUCT_NAME=%ANSIBLE_PRODUCT_NAME%" >> ./ci_version.sh
echo "ANSIBLE_REGISTRY_URL=%ANSIBLE_REGISTRY_URL%" >> ./ci_version.sh
echo "ANSIBLE_REGISTRY_USERNAME=%ANSIBLE_REGISTRY_USERNAME%" >> ./ci_version.sh
echo "ANSIBLE_RUN_TYPE=%ANSIBLE_RUN_TYPE%" >> ./ci_version.sh
echo "ANSIBLE_TRIGGER_TOKEN=%ANSIBLE_TRIGGER_TOKEN%" >> ./ci_version.sh 
echo "ANSIBLE_CI_VERSION=$ANSIBLE_CI_VERSION" >> ./ci_version.sh

CURRENT_PATH=`pwd`
echo "CURRENT_PATH $CURRENT_PATH"

LOCAL_FOLDER_PATH="${CURRENT_PATH}/.local"

echo "LOCAL_FOLDER_PATH $LOCAL_FOLDER_PATH"

if test -f "$LOCAL_FOLDER_PATH"; then
    echo "$LOCAL_FOLDER_PATH exist"
    rm -rf $LOCAL_FOLDER_PATH
    mkdir ./.local
fi

mv ./vault_pass.yml ./.local
mv ./pass.yml ./.local
mv ./ci_vault.sh ./.local
mv ./ci_version.sh ./.local
mv ./ci_version.yml ./.local

ls -la ./.local