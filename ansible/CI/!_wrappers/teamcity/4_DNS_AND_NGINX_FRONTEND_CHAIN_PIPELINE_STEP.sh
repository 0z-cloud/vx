rm -rf ./ci_version.yml

echo "MAIN_ANSIBLE_BUILD_ID: %MAIN_ANSIBLE_BUILD_ID%"
echo "ANSIBLE_COMMIT_SHA: %ANSIBLE_COMMIT_SHA%"

ANSIBLE_COMMIT_SHA_SHORT=`echo %ANSIBLE_COMMIT_SHA% | head -c 8`
DATE_YEAR=`date '+%Y'`
DATE_MOUTH=`date '+%m'`
ANSIBLE_CI_VERSION="${DATE_YEAR}.${DATE_MOUTH}.%MAIN_ANSIBLE_BUILD_ID%-${ANSIBLE_COMMIT_SHA_SHORT}"

echo "ANSIBLE_CI_VERSION: $ANSIBLE_CI_VERSION" >> ./ci_version.yml

echo "Creating the temp shell settings file for pass values to next step"
ls -la ../
ls -la ./

rm -rf ./ci_settings.sh
rm -rf ./ci_version.yml

#. ./ci_vault.sh

echo "..............................."
ls -la 
echo "..............................."
cd ./ansible
echo "..............................."

echo "pass %A_DEPLOY_PASSWORD%"
echo "user %ANSIBLE_DEPLOY_USERNAME%"

echo %RunningOnlyQA%

RUNNING_ONLY_QA="%RunningOnlyQA%"

echo "RUNNING_ONLY_QA is $RUNNING_ONLY_QA"

if [ "$RUNNING_ONLY_QA" = true ]; then

  echo "RUNNING_ONLY_QA is true"

else

    echo "RUNNING_ONLY_QA is false"

    ./!_all_services_internal.sh "%ANSIBLE_ENVIRONMENT%" "%ANSIBLE_PRODUCT_NAME%" "%ANSIBLE_DEPLOY_USERNAME%" "%A_DEPLOY_PASSWORD%" "%ANSIBLE_APPLICATION_TYPE%" "%ANSIBLE_RUN_TYPE%" "%ANSIBLE_CLOUD_TYPE%" "%A_VAULT_PASSWORD%" "%ANSIBLE_REGISTRY_URL%" "%ANSIBLE_CI_PROJECT_NAME%" "%ANSIBLE_CI_PROJECT_NAMESPACE%" "$ANSIBLE_CI_VERSION"

fi

echo "..............................."