#!/bin/bash

environment=$1
application=$2
deploy_type=$3
version=$4
buildcheckoutdir=$5
teamcity_build_id=$6

echo "ansible_environment: $environment" >> $buildcheckoutdir/scripts/ansible_ci/vars/ansible_deploy_settings.yml
echo "application: $application" >> $buildcheckoutdir/scripts/ansible_ci/vars/ansible_deploy_settings.yml
echo "deploy_type: $deploy_type" >> $buildcheckoutdir/scripts/ansible_ci/vars/ansible_deploy_settings.yml
echo "version: $version" >> $buildcheckoutdir/scripts/ansible_ci/vars/ansible_deploy_settings.yml
echo "buildcheckoutdir: $buildcheckoutdir" >> $buildcheckoutdir/scripts/ansible_ci/vars/ansible_deploy_settings.yml
echo "teamcity_build_id: $teamcity_build_id" >> $buildcheckoutdir/scripts/ansible_ci/vars/ansible_deploy_settings.yml