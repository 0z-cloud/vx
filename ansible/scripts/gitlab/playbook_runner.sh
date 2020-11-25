#!/bin/bash

project_type_app=$1
ansible_environment=$2
running_path=$3
running_username=$4
gitlab_token=$5
gitlab_job_id=$6

echo "PROJECT TYPE: $project_type_app"

if [[ $project_type_app == "laravel" ]]; then
  ansible-playbook -i $running_path/inventories/$ansible_environment -e "HOSTS=$ansible_environment" $running_path/playbook-library/deploy-playbooks/laravel-teamcity.yml -u $running_username --extra-vars "GITLAB_JOB=$gitlab_job_id
GITLAB_TOKEN=$gitlab_token"
elif [[ $project_type_app == "java" ]]; then
  echo "this will be a java runner"
else
  echo "Something wrong"
fi

echo "Done"
