#!/bin/bash

FINAL_STATUS="success"

FAILED_STATUS=( "failed" "canceled" "skipped" )

PENDING_RUNNING_STATUS=( "pending" "running" "created" )

#PENDING_RUNNING_STATUS="pending"

RUNNING_STATUS="running"

declare -A a_json_list_array
#a_json_list_array=()

gitlab_project_name=$1

echo gitlab_project_name $gitlab_project_name

echo gitlab_project_name array ${gitlab_project_name[@]}

if [ -z "$gitlab_project_name" ]; then
  echo "ERROR - Project must be exists"
  exit 1
  break
fi

LAST_CHECK=`echo "${gitlab_project_name: -1}"`

echo "LAST CHECK: $LAST_CHECK"

if [[ "$LAST_CHECK" == "," ]]; then
  echo "last OK"
else
  echo "ERROR - Last must by a comma!"
  exit 1
  return 1
fi

#@TEST

# ./CI/\!_ci/hooks/gitlab/pipeline_get_url.sh && echo OK || echo FAIL
# ./CI/\!_ci/hooks/gitlab/pipeline_get_url.sh @all, && echo OK || echo FAIL
# ./CI/\!_ci/hooks/gitlab/pipeline_get_url.sh @all,@app && echo OK || echo FAIL
# ./CI/\!_ci/hooks/gitlab/pipeline_get_url.sh @all,@app, && echo OK || echo FAIL

#@EXEC

if [[ "$gitlab_project_name" == "@all," ]]; then

    build_t="all"
    echo "START TO BUILD ALL"
    
    ##TODO
    echo "APP TO GET 'ci.tc': $item"
    
    
else 

  if [[ "$gitlab_project_name" =~ ^@[A-Za-z0-9]+, ]]; then

    MATCH="TRUE"
    echo "MATCH: $MATCH"
    echo "GET AND PARSE A LIST"

    build_t_array=()
    return_build_t_array=()
    IFS=',' read -r -a build_t_array <<< "$gitlab_project_name"
    
    for item in ${build_t_array[@]}; do
      
      echo "APP TO GET ci.tc: $item";
      echo "TO ARRAY ITEM: ${item//@}"
      return_build_t_array+=("${item//@}")
      #return_build_t_array+="${item//@}"
      if [[ "$item" == "@all" ]]; then
      
        echo "YOU CANNOT HAVE A MIXED BUILD WITH STANDALONE AND ALL"
        echo "BUILD BRAKED"
        
        exit 1
        return 1
        
      fi
      echo "ITEM $item"
      
    done
    
    
  else 
  
    MATCH="FALSE"
    echo "MATCH: $MATCH"
    echo "GET AND PARSE A LIST"
  
  fi

fi

echo "return_build_t_array ${return_build_t_array[@]}"

result_array_list=()

#declare -A result_array_list

if [ -z $build_t ]; then
    
    for app in ${return_build_t_array[@]}; do
    
    
    app_settings=`ls -la ./inventories/vortex/production/group_vars/.php-laravel/.$item/.ci.tc`
    
    echo "$app_settings"
    
    result_array_list+=("${app}")
    
    done
    
else

    
    all_apps=`ls -laq ./inventories/vortex/production/group_vars/.php-laravel/ | awk '{print $9}' | grep -v placer | sed 1,3d | tr -d . `
    
    #app_settings=`ls -laq ./inventories/vortex/production/group_vars/.php-laravel/ | awk '{print $9}' | grep -v placer | sed 1,3d | tr -d . `
    
    for app in ${all_apps[@]}; do
    
      echo "app: $app"
      
      . ./inventories/vortex/production/group_vars/.php-laravel/.$app/.ci.tc
      
      echo "Project: $gitlab_project"
      echo "hosts: $hosts"
      echo "service_tag: $service_tag"
      
      
      
      result_array_list+=( "$service_tag":"$hosts":"$gitlab_project" )
      
      #result_array_list+=("${build_t}")
    
    done
        
    #echo "app_settings $app_settings"
    
    result_array_list+=("${build_t}")

fi

#@rnd history
# all_projects_full=`curl -X GET -s --header "PRIVATE-TOKEN: uA9zrH7DUXyR3Bi5kqxX" https://gitlab.vortex.ru/api/v4/projects?&per_page=10000 | jq '.[]' | jq '{path_with_namespace,name,id}'`
# all_projects_full=`curl -X GET -s --header "PRIVATE-TOKEN: uA9zrH7DUXyR3Bi5kqxX" "https://gitlab.vortex.ru/api/v4/projects/?page=1&per_page=100000" | jq '.[] | select(.path_with_namespace)' |  jq '{path_with_namespace,name,id}'`
# curl -X GET -s --header "PRIVATE-TOKEN: uA9zrH7DUXyR3Bi5kqxX" "https://gitlab.vortex.ru/api/v4/projects/?page=1&per_page=100000" | jq '.[] | select(.path_with_namespace)' |  jq '{path_with_namespace,name,id}' | sed -n "/{/,/}/{s/[^:]*:[[:blank:]]*//p;}"
# x_array=( $(curl -X GET -s --header "PRIVATE-TOKEN: uA9zrH7DUXyR3Bi5kqxX" "https://gitlab.vortex.ru/api/v4/projects/?page=1&per_page=100000" | jq '.[] | select(.path_with_namespace)' |  jq '{path_with_namespace,name,id}' | sed -n "/{/,/}/{s/[^:]*:[[:blank:]]*//p;}" json ) )
# readarray -t values < <(awk -F\" 'NF>=3 {print $4}' myfile.json)
# x_array=( $(curl -X GET -s --header "PRIVATE-TOKEN: uA9zrH7DUXyR3Bi5kqxX" "https://gitlab.vortex.ru/api/v4/projects/?page=1&per_page=100000" | jq '.[] | select(.path_with_namespace)' |  jq '{path_with_namespace,name,id}' | sed -n "/{/,/}/{s/[^:]*:[[:blank:]]*//p;}" ) )
# all_in_string=`jq -r '{path_with_namespace,name,id}' <<<"$all_projects_full" | awk 'NR > 1 { printf(",") } {printf "%s",$0}'`
# result_list_git=`echo $all_in_string | tr -s ".{" "\n" | tr -s ", " " " | awk '{print $2,$4,$6}' | sed 's/\"//g' | sed 's/\ /=/g' | tail -n +2`
# `( $(curl -X GET -s --header "PRIVATE-TOKEN: uA9zrH7DUXyR3Bi5kqxX" "https://gitlab.vortex.ru/api/v4/projects/?page=1&per_page=100000" | jq '.[] | select(.path_with_namespace)' |  jq '{path_with_namespace,name,id}' | jq -r '(.path_with_namespace|tostring)+":"+(.id|tostring)'  ) )`

x_array=( $(curl -X GET -s --header "PRIVATE-TOKEN: uA9zrH7DUXyR3Bi5kqxX" "https://gitlab.vortex.ru/api/v4/projects/?page=1&per_page=100000" | jq '.[] | select(.path_with_namespace)' |  jq '{path_with_namespace,name,id}' | jq -r '(.path_with_namespace|tostring)+":"+(.id|tostring)+":"+(.name|tostring)'  ) )

#@debug
#echo "all_projects_full ${x_array[@]}"
#echo "all_in_string $all_in_string"
#echo "result_list $result_list"

for key in ${!result_array_list[@]}; do
    
    #@debug
    #echo "ключ ${key}"
    #echo "значение ${result_array_list[${key}]}"

    result_key_namespace=`echo ${result_array_list[${key}]} | awk -F ":" '{print $3}' | tr -d ' '`
    result_key_hosts=`echo ${result_array_list[${key}]} | awk -F ":" '{print $2}'`
    result_key_service_tag=`echo ${result_array_list[${key}]} | awk -F ":" '{print $1}'`
    #@debug
    #echo "RESULT_NAMESPACE: $result_key_namespace"
    #echo "RESULT_HOSTS: $result_key_hosts"
    #echo "RESULT_SERVICE_TAG: $result_key_service_tag"

    for znacenie in ${x_array[@]}; do
  
      #@debug
      # echo "item_id $item_id"
      # echo "item_name $item_name"
      # echo "full item $item"
      # echo "item $item"
      
      item_namespace=`echo $znacenie | awk -F ":" '{print $1}' | tr -d ' '`
      item_name=`echo $znacenie | awk -F ":" '{print $3}'`
      item_id=`echo $znacenie | awk -F ":" '{print $2}'`

      #@debug
      #echo "item_namespace $item_namespace"

      if [[ "$item_namespace" == "$result_key_namespace" ]]; then
        
        #@info
        echo "NAMESPACE FOR BUILD MATCHED: ${result_key_namespace} equal $item_namespace"
        
        #@debug
        #echo "item_namespace $item_namespace"
        #echo "item_name $item_name"
        #echo "item_id $item_id"

        new_pipeline_json=`curl -s --request POST --header "PRIVATE-TOKEN: uA9zrH7DUXyR3Bi5kqxX" "https://gitlab.vortex.ru/api/v4/projects/$item_id/pipeline?ref=master"`

        pipeline_id=`echo $new_pipeline_json | jq '.id'`
        
        #@info
        echo "pipeline_id $pipeline_id"
        
        if [ -z "$pipeline_id" ]; then
          echo "ALERT!!! CRITIAL_ERROR: PIPELINE must be exists, something wrong, please check you last changes and commits for critical changes in build procedures."
          exit 1
          break
        fi
        
        de_normolized_project_name_hosts=`echo $result_key_hosts | tr '-' '_'`
        
        a_json_list_array+=([$result_key_service_tag]=$pipeline_id:$item_id:$de_normolized_project_name_hosts)
        #a_json_list_array+=(['$de_normolized_project_name_hosts']='$pipeline_id')

      fi

    done
    
done

#@info
echo "Creating PIPELINES done..."
echo "Go check pass status in overall waiting, for each PIPELINE"


#@info
echo "Show for info all pipelines:"

#@remark: calculate pipelines count

APPS_NOT_ARRAY=0
declare -A GK_ARRAY

for K in "${!a_json_list_array[@]}"; do 

  K_PIPELINE=`echo ${a_json_list_array[$K]} | awk -F ":" '{print $1}'`
  K_PROJECT_ID=`echo ${a_json_list_array[$K]} | awk -F ":" '{print $2}'`
  K_PROJECT_NAME=`echo ${a_json_list_array[$K]} | awk -F ":" '{print $3}'`

  echo "SERVICE TAG: $K"
  echo "PROJECT NAME: $K_PROJECT_NAME";
  echo "PIPELINE: $K_PIPELINE"; 
  echo "K_PROJECT_ID: $K_PROJECT_ID"; 

  #@remark: calculate overall apps count
  APPS_NOT_ARRAY=$((APPS_NOT_ARRAY + 1))
  #@remark: create null GK_ARRAY for checking in next steps
  GK_ARRAY+=([$K_PIPELINE]='SINGULARITY')
  
done

#@remark - starting checking pipeline jobs section
#FINISHED_PIPELINES=()
#AWAITING_PIPELINES=()
#PENDINGS_PIPELINES=()
declare -A AWAITING_PIPELINES
declare -A PENDINGS_PIPELINES
declare -A FINISHED_PIPELINES
declare -A GOAL_PIPELINES

FINISHED_SUCCESS_COUNT=0
GENERAL_TAIL_COUNTER=0
RETRY_WAIT_TIME=30
MAX_WAIT_TIME_COUNTER=44
COMMAND_STATUS=0

#@RND INFO: RUN_TAIL must have 0 value when APPS_NOT_ARRAY=0, when all pipelines SUCCESS
RUN_TAIL=1
TARGET_TAIL=0


# until [ $DISKFUL -ge "90" ]; do 
#@remark - start main until timeout loop
until [ ${TARGET_TAIL} -ne ${RUN_TAIL} || ${COMMAND_STATUS} -ne 1 || ${MAX_WAIT_TIME_COUNTER} -ne 0 ]; do
  
  echo "CURRENT MAX_WAIT_TIME_COUNTER: $MAX_WAIT_TIME_COUNTER"
  
  #@remark - start main while loop
  while [ $TARGET_TAIL -ne $RUN_TAIL ];
  do
    #@info
    echo "Start while... check targets for all..."
    
    #@remark - start main for loop
    #@remark: start of (II)
    for K in "${!a_json_list_array[@]}"; do 
      
      K_PIPELINE=`echo ${a_json_list_array[$K]} | awk -F ":" '{print $1}'`
      K_PROJECT_ID=`echo ${a_json_list_array[$K]} | awk -F ":" '{print $2}'`
      K_PROJECT_NAME=`echo ${a_json_list_array[$K]} | awk -F ":" '{print $3}'`

      #@debug
      echo "SERVICE TAG: $K"
      echo "PROJECT NAME: $K_PROJECT_NAME";
      echo "PIPELINE: $K_PIPELINE"; 
      echo "K_PROJECT_ID: $K_PROJECT_ID"; 
      
      get_pipeline_status=`curl -s --header "PRIVATE-TOKEN: uA9zrH7DUXyR3Bi5kqxX" "https://gitlab.vortex.ru/api/v4/projects/$K_PROJECT_ID/pipelines/$K_PIPELINE"`
      pipeline_status_string=`echo $get_pipeline_status | jq '.status' | tr -d '"'`
      #@debug
      echo "get_pipeline_status STATUS: $get_pipeline_status"
      #@info
      echo "CURRENT STATUS: $pipeline_status_string"

      #@remark: start if (III)
      if [ "$pipeline_status_string" == "$RUNNING_STATUS" ]; then
          
          #@debug
          # echo "Please wait... pipeline still running..."
          #echo "PIPELINE ID: $K_PIPELINE"
          #echo "K_PROJECT_ID: $K_PROJECT_ID"; 
          
          eval GK_ARRAY[$K_PIPELINE]="RUNNING"
          
          #GK_ARRAY+=(['$de_normolized_project_name_hosts']='$pipeline_id:$item_id')
          
      else
      
          #@remark: start if (IV)
          if [ "$pipeline_status_string" == "$FINAL_STATUS" ]; then
              
              echo "PIPELINE DONE: $K_PIPELINE"
              
              # let APPS_NOT_ARRAY=APPS_NOT_ARRAY-1
              eval GK_ARRAY[$K_PIPELINE]="FINISHED"
              FINISHED_PIPELINES+=([$K_PIPELINE]=$K_PROJECT_ID)
              
          else
              
              #@remark - start checking for FAILED_STATUS
              for item_failed_status_check in ${FAILED_STATUS[@]}; 
              do 
                
                #@debug
                #echo "FAILED CONDITION TO CHECK : $item_failed_status_check"
                
                if [ "$pipeline_status_string" == "$item_failed_status_check" ]; then
                  
                  echo "BREAK RUN BECAUSE GET ERROR STATUS: $pipeline_status_string"
                  
                  case $pipeline_status_string in
                  "failed")
                    echo "Detects a FAILED status."
                    eval GK_ARRAY[$K_PIPELINE]="FAILED"
                    echo "BREAK RUN BECAUSE GET ERROR STATUS: $pipeline_status_string"
                    BREAK="yes"
                    break;
                    ;;
                  "canceled")
                    echo "Detects a CANCELED status."
                    eval GK_ARRAY[$K_PIPELINE]="CANCELED"
                    echo "BREAK RUN BECAUSE GET ERROR STATUS: $pipeline_status_string"
                    BREAK="yes"
                    break;
                    ;;
                  "skipped")
                    echo "Detects a SKIPPED status."
                    eval GK_ARRAY[$K_PIPELINE]="SKIPPED"
                    echo "BREAK RUN BECAUSE GET ERROR STATUS: $pipeline_status_string"
                    BREAK="yes"
                    break;
                    ;;
                  *)
                    echo "No detects a Failed status."
                    ;;
                  esac
                
                fi
                  
                #@debug
                #echo "CHECKING TO ERROR CODE DONE"
              
              done
              #@remark: done checking for FAILED_STATUS
              
              #@remark: start foreach check for awating
              for item_waiting_status_check in ${PENDING_RUNNING_STATUS[@]};
              do
                  #@debug
                  #echo "AWAITING CONDITION TO CHECK: $item_waiting_status_check"      
                  
                  if [ "$pipeline_status_string" == "$item_waiting_status_check" ]; then
                    
                    echo "AWAITING STATUS MATCHED: $item_waiting_status_check"
                    
                    case $pipeline_status_string in
                    "pending")
                      echo "Detects a PENDING status."
                      eval GK_ARRAY[$K_PIPELINE]="PENDING"
                      ;;
                    "running")
                      echo "Detects a RUNNING status."
                      eval GK_ARRAY[$K_PIPELINE]="RUNNING"
                      ;;
                    *)
                      echo "No detects a Awaiting status."
                      ;;
                    esac
                    
                  fi
                  
                  #@debug
                  #echo "CHECKING TO AWAITING CODES DONE"
                  
              done
              #@remark: done foreach check for awating

              #@remark: creack check
              if [ "$BREAK" == "yes" ]; then
                COMMAND_STATUS=1
                break;
              fi

          
          fi
          #@remark: end fi (IV)
          
      fi
      #@remark: end fi (III)
      
    done
    #@remark: end of (II)
  
    #@remark: show array items statuses for pipelines
    # for BPR in "${!GK_ARRAY[@]}"; do 
      
    #   #@debug
    #   echo "BPR ${GK_ARRAY[$BPR]}"
    #   echo "BPR ${BPR}"
      
    # done
    
    FINISHED_SUCCESS_COUNT=`echo ${FINISHED_PIPELINES[@]} | cut -d/ -f1 | wc -w | tr -d ' '`
    
    #@debug
    echo "FINISHED_SUCCESS_COUNT: $FINISHED_SUCCESS_COUNT"
    
    if [ $FINISHED_SUCCESS_COUNT -eq $APPS_NOT_ARRAY ]; then
    
      echo "FINISHED PIPELINES SUCCESS EQUAL COUNT OF PLACED BUILDS COUNTER"
      echo "BUILDS ARE A FINISHED, GO NEXT STEPS..."
      RUN_TAIL=0
      
    else
      
      echo "FINISHED PIPELINES COUNT NOT EQUAL OF PLACED BUILDS COUNTER"
      echo "FINISHED_PIPELINES EQUAL: $FINISHED_PIPELINES"
      echo "TOTAL BUILDS TO EQUAL: $APPS_NOT_ARRAY"
      
    fi
    
    echo "Please wait... pipeline still running..."
    #@remark: overall build timeout incode
    sleep $RETRY_WAIT_TIME
    #@remark: decrement MAX_WAIT_TIME_COUNTER
    let MAX_WAIT_TIME_COUNTER=MAX_WAIT_TIME_COUNTER-1
    
  done
  #@remark: end fi (I)

done
#@remark - end of main until timeout loop








#@old rnd... clear after tests =>

# && [ "$GENERAL_TAIL_COUNTER" != 10 ]; do


# while [ $TARGET_TAIL -ne $ ]
# do
  
  
  
# done





# #TODO

# get_pipeline_status=`curl -s --request POST --header "PRIVATE-TOKEN: uA9zrH7DUXyR3Bi5kqxX" "https://gitlab.vortex.ru/api/v4/projects/$item_id/pipelines/$pipeline_id"`

#         pipeline_status_string=`echo $get_pipeline_status | jq '.status' | tr -d '"'`
        
#         COUNTER=0
        
#         while [ "$pipeline_status_string" != "$FINAL_STATUS" ]
#         do
          
#           echo "CURRENT STATUS: $pipeline_status_string"
          
#           if [ "$pipeline_status_string" == "$RUNNING_STATUS" ]; then
          
#               echo "please wait..."
          
#           else
            
#             for item_failed_status_check in ${FAILED_STATUS[@]}; 
#             do 
                
#                 echo "FAILED CONDITION TO CHECK : $item_failed_status_check"
                
#                 if [ "$pipeline_status_string" == "$item_failed_status_check" ]; then
                  
#                   echo "BREAK RUN BECAUSE GET ERROR STATUS: $pipeline_status_string"
#                   BREAK="yes"
#                   break;
                
#                 fi
                
#                 echo "CHECKING TO ERROR CODE DONE"
            
#             done
            
#             if [ "$BREAK" == "yes" ]; then
#               break;
#             fi
            
#             for item_waiting_status_check in ${PENDING_RUNNING_STATUS[@]};
#             do
                
#                 echo "AWAITING CONDITION TO CHECK: $item_waiting_status_check"      
                
#                 if [ "$pipeline_status_string" == "$item_waiting_status_check" ]; then
                  
#                   echo "AWAITING STATUS MATCHED: $item_waiting_status_check"
                  
#                 fi
            
#                 echo "CHECKING TO AWAITING CODES DONE"
                
#             done
          
#           fi
          
#           echo "Sleep about 30 seconds before next try to check, it's check № $COUNTER"
                
#           sleep 30
          
#           echo "Get pipeline status again..."
          
#           get_pipeline_status=`curl -s --header "PRIVATE-TOKEN: uA9zrH7DUXyR3Bi5kqxX" "https://gitlab.vortex.ru/api/v4/projects/$item_id/pipelines/$pipeline_id"`

#           pipeline_status_string=`echo $get_pipeline_status | jq '.status' | tr -d '"'`

#           let COUNTER=COUNTER+1

#         done

#         if [ "$BREAK" == "yes" ]; then
#           echo "ERROR"
#           exit 1;
#         fi
        
#         #@debug
#         echo "DONE BUILDING, NEED TO GET JOB ID"
#         echo "curl --header 'PRIVATE-TOKEN: uA9zrH7DUXyR3Bi5kqxX' 'https://gitlab.vortex.ru/api/v4/projects/$item_id/pipelines/$pipeline_id/jobs'"
#         success_jobs=`curl -s --header 'PRIVATE-TOKEN: uA9zrH7DUXyR3Bi5kqxX' 'https://gitlab.vortex.ru/api/v4/projects/$item_id/pipelines/${pipeline_id}/jobs' `
        
#         echo "success jobs : $success_jobs"
        
#         #pipeline_jobs=`curl -s --request POST --header "PRIVATE-TOKEN: uA9zrH7DUXyR3Bi5kqxX" "https://gitlab.vortex.ru/api/v4/projects/$item_id/pipelines/$pipeline_id/jobs"`
        

# #

# test_array_1=()
# test_array_2=()

# test_app1_name="app1"
# test_app1_namespace="vortex/services/test-app-01"
# test_app1_pipeline_id="7024"

# test_app2_name="app2"
# test_app2_namespace="vortex/services/test-app-02"
# test_app2_pipeline_id="7013"



# add_json_list_array() {
  
#   id=$1
#   namespace=$2
#   name=$3
#   project_id=$4
#   echo "id $id"
#   echo "namespace $namespace"
#   echo "name $name"
  
#    /projects/:id/pipelines/:pipeline_id/jobs
  
#   a_json_list_array+=([id]=Beeblebrox)
  
# }

# add_json_list_array $test_app1_pipeline_id $test_app1_namespace $test_app1_name;
# add_json_list_array $test_app2_pipeline_id $test_app2_namespace $test_app2_name;

# echo $gitlab_project_name

# echo "################################"

# echo "PROJECT NAME $gitlab_project_name"

# echo "################################"
# echo "MAGIC PROJECTS BUILDER"


# all_projects_full=`curl -X GET -s --header "PRIVATE-TOKEN: uA9zrH7DUXyR3Bi5kqxX" https://gitlab.vortex.ru/api/v4/projects/ | jq '.[]' | jq '{name,id}'`

# all_in_string=`jq -r '{name,id}' <<<"$all_projects_full" | awk 'NR > 1 { printf(",") } {printf "%s",$0}'`
# result_list=`echo $all_in_string | tr -s ".{" "\n" | tr -s ", " " " | awk '{print $2,$4}' | sed 's/\"//g' | sed 's/\ /=/g' | tail -n +2`

#  #echo $all_projects_full
#  #echo $all_in_string
#  #echo result_list

# for item in $result_list; do
  
#   # echo "item_id $item_id"
#   # echo "item_name $item_name"
#   # echo "full item $item"
  
#   item_name=`echo $item | awk -F "=" '{print $1}'`
#   item_id=`echo $item | awk -F "=" '{print $2}'`

#   if [ $item_name == $gitlab_project_name ]; then
#     #echo "match found! it is $gitlab_project_name"
#     #echo "project id is $item_id"
#     new_pipeline_json=`curl -s --request POST --header "PRIVATE-TOKEN: uA9zrH7DUXyR3Bi5kqxX" "https://gitlab.vortex.ru/api/v4/projects/$item_id/pipeline?ref=master"`

#     #echo "new_pipeline_json $new_pipeline_json"

#     pipeline_id=`echo $new_pipeline_json | jq '.id'`

#     #echo "pipeline_id $pipeline_id"

#     get_pipeline_status=`curl -s --header "PRIVATE-TOKEN: uA9zrH7DUXyR3Bi5kqxX" "https://gitlab.vortex.ru/api/v4/projects/$item_id/pipelines/$pipeline_id"`

#     pipeline_status_string=`echo $get_pipeline_status | jq '.status' | tr -d '"'`

#     COUNTER=0
             
#     while [ "$pipeline_status_string" != "$FINAL_STATUS" ]
#     do
      
#       echo "CURRENT STATUS: $pipeline_status_string"
      
#       if [ "$pipeline_status_string" == "$RUNNING_STATUS" ]; then
      
#           echo "please wait..."
      
#       else
        
#         for item_failed_status_check in ${FAILED_STATUS[@]}; 
#         do 
            
#             echo "FAILED CONDITION TO CHECK : $item_failed_status_check"
            
#             if [ "$pipeline_status_string" == "$item_failed_status_check" ]; then
              
#               echo "BREAK RUN BECAUSE GET ERROR STATUS: $pipeline_status_string"
#               BREAK="yes"
#               break;
            
#             fi
            
#             echo "CHECKING TO ERROR CODE DONE"
        
#         done
        
#         if [ "$BREAK" == "yes" ]; then
#           break;
#         fi
        
#         for item_waiting_status_check in ${PENDING_RUNNING_STATUS[@]};
#         do
            
#             echo "AWAITING CONDITION TO CHECK: $item_waiting_status_check"      
            
#             if [ "$pipeline_status_string" == "$item_waiting_status_check" ]; then
              
#               echo "AWAITING STATUS MATCHED: $item_waiting_status_check"
              
#             fi
        
#             echo "CHECKING TO AWAITING CODES DONE"
            
#         done
      
#       fi
      
#       echo "Sleep about 30 seconds before next try to check, it's check № $COUNTER"
            
#       sleep 30
      
#       echo "Get pipeline status again..."
      
#       get_pipeline_status=`curl -s --header "PRIVATE-TOKEN: uA9zrH7DUXyR3Bi5kqxX" "https://gitlab.vortex.ru/api/v4/projects/$item_id/pipelines/$pipeline_id"`

#       pipeline_status_string=`echo $get_pipeline_status | jq '.status' | tr -d '"'`

#       let COUNTER=COUNTER+1

#     done

#     if [ "$BREAK" == "yes" ]; then
#       echo "ERROR"
#       exit 1;
#     fi

#     echo "DONE BUILDING, NEED TO GET JOB ID"
#     echo "curl --header 'PRIVATE-TOKEN: uA9zrH7DUXyR3Bi5kqxX' 'https://gitlab.vortex.ru/api/v4/projects/$item_id/pipelines/$pipeline_id/jobs'"
#     success_jobs=`curl -s --header 'PRIVATE-TOKEN: uA9zrH7DUXyR3Bi5kqxX' 'https://gitlab.vortex.ru/api/v4/projects/$item_id/pipelines/${pipeline_id}/jobs' `
    
#     echo "success jobs : $success_jobs"

#   fi

# done