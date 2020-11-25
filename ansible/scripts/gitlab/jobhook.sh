#!/bin/bash
gitlab_job_id=$1
gitlab_token=$2

# gitlab_job_id="1021"
# gitlab_token="kBQiVykkqmXcnMS_XSaL"

echo "Gitlab Job ID: $gitlab_job_id"
echo "Gitlab Token: $gitlab_token"

all_projects=`curl -X GET -s --header "PRIVATE-TOKEN: ${gitlab_token}" https://gitlab.vortex.ru/api/v4/projects |  jq '.[]' | jq '.id'`
# echo "ALL PROJECTS: $all_projects"
for project in $all_projects
do
    echo "Try to matching project: $project"
    project_jobs_ids=`curl -X GET -s --header "PRIVATE-TOKEN: ${gitlab_token}" "https://gitlab.vortex.ru/api/v4/projects/${project}/jobs?" | jq '.[]' | jq '.id'`
    project_tags=`curl -X GET -s --header "PRIVATE-TOKEN: ${gitlab_token}" "https://gitlab.vortex.ru/api/v4/projects/${project}" | jq '.tag_list' | jq '.[]'`
    project_name=`curl -X GET -s --header "PRIVATE-TOKEN: ${gitlab_token}" "https://gitlab.vortex.ru/api/v4/projects/${project}" | jq '.path'`
    echo "project_jobs_ids: $project_jobs_ids"
    echo "project_tags: $project_tags"
    echo "project_name: $project_name"
    for project_job in $project_jobs_ids
    do
       if [ $gitlab_job_id -eq $project_job ]; then
          echo "matched job ID: $gitlab_job_id"
          echo "matched project ID: $project"
          echo "matched project Name: $project_name"
          echo "matched tags: $project_tags"
          echo "##teamcity[setParameter name='env.gitlab_project_id' value='$project']"
          echo "##teamcity[setParameter name='env.gitlab_project_name' value='$project_name']"
          for project_tag in $project_tags
          do
          normalized_tag=`echo $project_tag | tr -d '"'`
          echo "project_tag: $project_tag"
          echo "normalized_tag: $normalized_tag"
            if [[ "$normalized_tag" == "java" ]]; then
              echo "Project app type is Java"
              project_type_app=`echo $project_tag`
            fi
            if [[ "$normalized_tag" == "laravel" ]]; then
              echo "Project app type is Laravel"
              project_type_app=`echo $project_tag`
            fi
            if [[ "$normalized_tag" == "vortex" ]]; then
              echo "Project env type is vortex"
              project_type_env=`echo $project_tag`
            fi
            if [[ "$normalized_tag" == "vortex" ]]; then
              echo "Project env type is vortex"
              project_type_env=`echo $project_tag`
            fi
          done
          echo "project_type_env: $project_type_env"
          echo "project_type_app: $project_type_app"
          echo "##teamcity[setParameter name='env.gitlab_project_type_env' value='$project_type_env']"
          echo "##teamcity[setParameter name='env.gitlab_project_type_app' value='$project_type_app']"
          set_mathed="1"
       fi
    done
done

# if [ $set_mathed -ne 1 ]; then
#     echo "We not match job ID: $gitlab_job_id"
# else
#     echo "OK"
# fi
