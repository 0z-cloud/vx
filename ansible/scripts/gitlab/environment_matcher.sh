#!/bin/bash

teamcity_environment=$1
gitlab_tag_environment=$2

# teamcity_environment="develop-vortex"
# gitlab_tag_environment="vortex"

echo "teamcity_environment: $teamcity_environment"
echo "gitlab_tag_environment: $gitlab_tag_environment"

if [[ $teamcity_environment == *"$gitlab_tag_environment"* ]]; then
  echo "MATCHED. ALL RIGHT"
else
  echo "ENVIRONMENTS NOT RIGHT, GO EXIT 1"
  exit 1
fi