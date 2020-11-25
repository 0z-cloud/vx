#!/bin/bash

KP_INSTANCE=$2
KP_STATUS=$3
KP_PR=$4

#

# arbiter
# mongod
# NEIGHBOR
# pritunl

# SETTINGS
# LOGS SETTINGS TYPES: TRACE / PRODUCTION / LOGFILE

#LOGGING="PRODUCTION"
LOGGING="TRACE"
#LOGGING="LOGFILE"

LOG_FILE="/var/log/vpn_restart_`hostname`.log"
DEFAULT_AWAIT_PORT_TIMEOUT="12"
MONGO_DEFAULT_PORT="27017"
PRITUNL_WEB_PORT="11443"

#PRITUNL_WEB_IP="185.243.244.68"

PRITUNL_WEB_IP="10.91.91.103"
PRIMARY_KEEPALIVED_NODE="10.91.91.102"
BACKUP_KEEPALIVED_NODE="10.91.91.101"
KEEPALIVED_ARBITER_SERVICE="10.91.91.103"

PRIMARY_KEEPALIVED_MONGO_ID="0"
BACKUP_KEEPALIVED_MONGO_ID="1"
KEEPALIVED_ARBITER_SERVICE_MONGO_ID="2"

MONGO_ARBITER_SERVICE_NAME="mongo-arbiter"

MONGODB_SERVICE_NAME="mongodb"

PRITUNL_SERVICE_NAME="pritunl"

########################################################
# COUNT AWAITING THE SECOND NODE BEFORE PERFORM FAILOVER

NEIGHBOR_PING_TIMES='30'

########################################################

while_counter=0
check_counter=0

# END SETTINGS

function change_current_to_primary() {

  logit "START: change_current_to_primary"
  logit "Call the get_my_id function"

  get_my_id;
  get_remote_id;
  get_arbiter_id;
  get_remote_votes_and_priority;
  get_my_votes_and_priority;
  get_arbiter_votes_and_priority;

  run_mongo_reconfigure;

}

function run_mongo_reconfigure() {

  logit "---------------------------------------------------"
  logit "server_id $server_id"
  logit "local_server_id_votes $local_server_id_votes"
  logit "local_server_id_priority $local_server_id_priority"
  logit "---------------------------------------------------"
  logit "remote_server_id $remote_server_id"
  logit "remote_server_id_votes $remote_server_id_votes"
  logit "remote_server_id_priority $remote_server_id_priority"
  logit "---------------------------------------------------"
  logit "arbiter_server_id $arbiter_server_id"
  logit "arbiter_server_id_votes $arbiter_server_id_votes"
  logit "arbiter_server_id_priority $arbiter_server_id_priority"
  logit "---------------------------------------------------"

  rs_string='cfg = rs.conf(); cfg.members['$server_id'].priority = 0; cfg.members['$remote_server_id'].priority = 3; cfg.members['$arbiter_server_id'].priority = 0; cfg.members['$server_id'].votes = 0; cfg.members['$remote_server_id'].votes = 1; cfg.members['$arbiter_server_id'].votes = 1; rs.reconfig(cfg,{"force":true}); rs.reconfig(cfg, {force : true})'
  #rs_string='cfg = rs.conf(); cfg.members['$server_id'].priority = 3; cfg.members['$remote_server_id'].priority = 0; cfg.members['$arbiter_server_id'].priority = 0; cfg.members['$server_id'].votes = 1; cfg.members['$remote_server_id'].votes = 0; cfg.members['$arbiter_server_id'].votes = 1; rs.reconfig(cfg,{"force":true}); rs.reconfig(cfg, {force : true})'
  rs_runstring=$(echo mongo $RUN_NODE --eval \"$rs_string\")

  echo "rs_runstring: $rs_runstring"

  eval $rs_runstring

  logit "rs_string $rs_string"

}

function uptime_int() {

  # FUNCTION - GET UPTIME IN INT VALUE.
  # RESULT - RETURN UPTIME

  if [ -e /proc/uptime ] ; then
    echo `cat /proc/uptime | awk '{printf "%0.f", $1}'`
  else
    set +e
    sysctl kern.boottime &> /dev/null
    if [ $? -eq 0 ] ; then
      local kern_boottime=`sysctl kern.boottime 2> /dev/null | sed "s/.* sec\ =\ //" | sed "s/,.*//"`
      local time_now=`date +%s`
      local uptime=$(($time_now - $kern_boottime))
      echo $uptime
    else
      echo "-1"
    fi
    set -e
  fi
}

function logit()
{
  # FUNCTION - LOGGING TO FILE WITH DATETIME MARKERS.

  if [[ $LOGGING == "PRODUCTION" ]]; then

    echo "["`date`"] - ${*}" &>/dev/null

  else

    if [[ $LOGGING == "TRACE" ]]; then

      echo "["`date`"] - ${*}" >> ${LOG_FILE}
      echo "["`date`"] - ${*}"

    else

      if [[ $LOGGING == "LOGFILE" ]]; then

        echo "["`date`"] - ${*}" >> ${LOG_FILE}

      fi

    fi

  fi

}

function get_owner() {

  owner=`ip a | grep $KEEPALIVED_ARBITER_SERVICE | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"`

}

function check_owner_to_escape() {

  # FUNCTION - CHECK CURRENT VIP OWNER

  logit "STARTING CHECK THE VIP OWNER"

  get_owner;

  logit "owner $owner"

  logit "Go check owner"

  if [[ -z $owner ]]; then

      logit "STATE: 1";
      logit "Im not a owner, go exit"

      NEED_TO_CHECK_HEIGHBOR="0"

      exit 0

  else

      logit "STATE: 0";
      logit "Im a owner VIP, go works"

      NEED_TO_CHECK_HEIGHBOR="1"

  fi

      logit "NEED_TO_CHECK_HEIGHBOR: $NEED_TO_CHECK_HEIGHBOR"

}

function await_with_timeout() {

  # FUNCTION - AWAITING SERVICE WITH TIMEOUT.
  # USAGE EXAMPLE :
  # await_with_timeout 12 mail.vortex.com 8086 - get 1
  # await_with_timeout 12 mail.vortex.com 8080 - get 0
  # set to some variable :
  # service_to_check=$(await_with_timeout 12 mail.vortex.com 8080)
  # then echo $service_to_check for check result

  # BREACK POINT TO ESCAPE
  #check_owner_to_escape;
  # EXIT ANY LOOP AND FUNCTION IF OWNER CHANGED

  COMMAND_TIMEOUT=$1
  HOSTNAME_TO_CHECK=$2
  PORT_TO_CHECK=$3

  timeout $COMMAND_TIMEOUT bash -c 'until printf "" 2>>/dev/null >>/dev/tcp/$0/$1; do sleep 1; done' $HOSTNAME_TO_CHECK $PORT_TO_CHECK && echo 0 || echo 1

}

function set_current_cutted_ips() {

  logit "start: set_current_cutted_ips"


  RUN_CAT_IP=$(echo $RUN_NODE | cut -f4 -d ".")
  REMOTE_CAT_IP=$(echo $REMOTE_NODE | cut -f4 -d ".")

  logit "RUN_CAT_IP $RUN_CAT_IP"
  logit "REMOTE_CAT_IP $REMOTE_CAT_IP"

  logit "end: set_current_cutted_ips"

}

function get_target() {

  # FUNCTION - GET SELFTARGET IP

  logit "start: get_target"

  become_mongo_to_be_a_master_ip=`ifconfig bond0.200 | grep inet | awk '{print $2}' | grep 10.91`
  become_vip_owner_ip_last=`echo $become_mongo_to_be_a_master_ip | cut -f4 -d "."`

  logit "become_vip_owner_ip_last: $become_vip_owner_ip_last"
  logit "target: $become_mongo_to_be_a_master_ip"
  logit "done: get_target"
  logit "go set the variables for next steps"

  if [ $become_vip_owner_ip_last -eq "102" ]; then

      logit "eq 102"

      RUN_NODE=$PRIMARY_KEEPALIVED_NODE
      REMOTE_NODE=$BACKUP_KEEPALIVED_NODE

  else

      logit "not eq 102"

      RUN_NODE=$BACKUP_KEEPALIVED_NODE
      REMOTE_NODE=$PRIMARY_KEEPALIVED_NODE

  fi

  logit "RUN_NODE IS: $RUN_NODE"
  logit "REMOTE_NODE IS: $REMOTE_NODE"

}

function get_my_id() {

  logit "start: get_my_id"

  logit "become_mongo_to_be_a_master_ip: $become_mongo_to_be_a_master_ip"

  server_id_call_rs_status=$(echo 'rs.status()')
  server_id_call_rs_status_run_string=$(echo mongo $RUN_NODE --eval \"$server_id_call_rs_status\" --quiet)
  eval $server_id_call_rs_status_run_string

  server_id=$(eval $server_id_call_rs_status_run_string | grep -C2 $RUN_NODE | grep id | cut -f2 -d ":" | cut -f1 -d ",")

  server_id=$(echo $server_id | xargs )

  logit "server_id $server_id"

}

function get_my_votes_and_priority() {

  logit "start: get_my_votes"

  server_id_call_rs_conf_votes=$(echo 'rs.conf()')
  server_id_call_rs_conf_votes_run_string=$(echo mongo $RUN_NODE --eval \"$server_id_call_rs_conf_votes\" --quiet)
  eval $server_id_call_rs_conf_votes_run_string

  local_server_id_votes=$(eval $server_id_call_rs_conf_votes_run_string | grep -A9 $RUN_NODE | grep votes | cut -f2 -d ":" | cut -f1 -d ",")
  local_server_id_priority=$(eval $server_id_call_rs_conf_votes_run_string | grep -A7 $RUN_NODE | grep priority | cut -f2 -d ":" | cut -f1 -d ",")

  local_server_id_votes=$(echo $local_server_id_votes | xargs )
  local_server_id_priority=$(echo $local_server_id_priority | xargs )

  logit "local_server_id_votes $local_server_id_votes"
  logit "local_server_id_priority $local_server_id_priority"

}




function get_arbiter_votes_and_priority() {

  logit "start: get_my_votes"

  arbiter_id_call_rs_conf_votes=$(echo 'rs.conf()')
  arbiter_id_call_rs_conf_votes_run_string=$(echo mongo $RUN_NODE --eval \"$arbiter_id_call_rs_conf_votes\" --quiet)
  eval $arbiter_id_call_rs_conf_votes_run_string

  arbiter_server_id_votes=$(eval $arbiter_id_call_rs_conf_votes_run_string | grep -A9 $KEEPALIVED_ARBITER_SERVICE | grep votes | cut -f2 -d ":" | cut -f1 -d ",")
  arbiter_server_id_priority=$(eval $arbiter_id_call_rs_conf_votes_run_string | grep -A7 $KEEPALIVED_ARBITER_SERVICE | grep priority | cut -f2 -d ":" | cut -f1 -d ",")

  arbiter_server_id_votes=$(echo $arbiter_server_id_votes | xargs )
  arbiter_server_id_priority=$(echo $arbiter_server_id_priority | xargs )

  logit "arbiter_server_id_votes $arbiter_server_id_votes"
  logit "arbiter_server_id_priority $arbiter_server_id_priority"

}

function get_remote_votes_and_priority() {

  logit "start: get_remote_votes_and_priority"

  remote_server_id_call_rs_conf_votes=$(echo 'rs.conf()')
  remote_server_id_call_rs_conf_votes_run_string=$(echo mongo $RUN_NODE --eval \"$remote_server_id_call_rs_conf_votes\" --quiet)
  eval $remote_server_id_call_rs_conf_votes_run_string

  remote_server_id_votes=$(eval $remote_server_id_call_rs_conf_votes_run_string | grep -A9 $REMOTE_NODE | grep votes | cut -f2 -d ":" | cut -f1 -d ",")
  remote_server_id_priority=$(eval $remote_server_id_call_rs_conf_votes_run_string | grep -A7 $REMOTE_NODE | grep priority | cut -f2 -d ":" | cut -f1 -d ",")

  remote_server_id_votes=$(echo $remote_server_id_votes | xargs )
  remote_server_id_priority=$(echo $remote_server_id_priority | xargs )

  logit "remote_server_id_votes $remote_server_id_votes"
  logit "remote_server_id_priority $remote_server_id_priority"

}

function get_remote_id() {

  logit "start: get_remote_id"

  server_remote_id_call_rs_status=$(echo 'rs.status()')
  server_remote_id_call_rs_status_run_string=$(echo mongo $RUN_NODE --eval \"$server_remote_id_call_rs_status\" --quiet)
  eval $server_remote_id_call_rs_status_run_string

  remote_server_id=$(eval $server_remote_id_call_rs_status_run_string | grep -C2 $REMOTE_NODE | grep id | cut -f2 -d ":" | cut -f1 -d ",")

  remote_server_id=$(echo $remote_server_id | xargs )

  logit "remote_server_id $remote_server_id"

}

function get_arbiter_id() {

  logit "start: get_arbiter_id"

  server_arbiter_id_call_rs_status=$(echo 'rs.status()')
  server_arbiter_id_call_rs_status_run_string=$(echo mongo $RUN_NODE --eval \"$server_arbiter_id_call_rs_status\" --quiet)
  eval $server_arbiter_id_call_rs_status_run_string

  arbiter_server_id=$(eval $server_arbiter_id_call_rs_status_run_string | grep -C2 $KEEPALIVED_ARBITER_SERVICE | grep id | cut -f2 -d ":" | cut -f1 -d ",")

  arbiter_server_id=$(echo $arbiter_server_id | xargs )

  logit "arbiter_server_id $arbiter_server_id"

}

$N

function check_neighbor_by_ping() {

  logit "REMOTE_NODE : $REMOTE_NODE"
  #PROD 30 sec
  neighbor_ping_result=`ping -w -q -c $NEIGHBOR_PING_TIMES $REMOTE_NODE > /dev/null 2>&1 && echo 0 || echo 1`

  #DEV 2 sec
  #neighbor_ping_result=`ping -w -q -c 1 $REMOTE_NODE > /dev/null 2>&1 && echo 0 || echo 1`

  logit "PING RESULT: $neighbor_ping_result"

}

function get_status_trail() {

  logit "START: function get_status_trail"

  logit "RUN_NODE: $RUN_NODE"

  logit "MONGO_DEFAULT_PORT: $MONGO_DEFAULT_PORT"
  get_any_service_status_mongo_arbiter=$(await_with_timeout $DEFAULT_AWAIT_PORT_TIMEOUT $KEEPALIVED_ARBITER_SERVICE $MONGO_DEFAULT_PORT):mongo_arbiter
  get_any_service_status_mongodb=$(await_with_timeout $DEFAULT_AWAIT_PORT_TIMEOUT $RUN_NODE $MONGO_DEFAULT_PORT):mongodb
  get_any_service_status_NEIGHBOR=$(await_with_timeout $DEFAULT_AWAIT_PORT_TIMEOUT $REMOTE_NODE $MONGO_DEFAULT_PORT):NEIGHBOR
  get_any_service_status_pritunl=$(await_with_timeout $DEFAULT_AWAIT_PORT_TIMEOUT $PRITUNL_WEB_IP $PRITUNL_WEB_PORT):pritunl

  array_gathering=()

  array_gathering+=($get_any_service_status_mongo_arbiter)
  array_gathering+=($get_any_service_status_mongodb)
  array_gathering+=($get_any_service_status_NEIGHBOR)
  array_gathering+=($get_any_service_status_pritunl)

  logit "array_gathering array: ${array_gathering[@]}"

  logit "get_any_service_status_mongo_arbiter: $get_any_service_status_mongo_arbiter"
  logit "get_any_service_status_mongodb: $get_any_service_status_mongodb"
  logit "get_any_service_status_NEIGHBOR: $get_any_service_status_NEIGHBOR"
  logit "get_any_service_status_pritunl: $get_any_service_status_pritunl"

  logit "END: function get_status_trail"

}

function pritunl_service_while_up() {

  logit "START: pritunl_service_while_up"

  if [[ $service_name == "pritunl" ]]; then

    # RESTART WITH 3 TIMES AWAITING

    pritunl_cc=0

    while [ $pritunl_cc -le 3 ]; do

        logit "current try is: $pritunl_cc"

        logit "restarting pritunl service"

        logit "PRITUNL_WEB_IP: $PRITUNL_WEB_IP"
        logit "PRITUNL_WEB_PORT: $PRITUNL_WEB_PORT"

        systemctl restart pritunl

        logit "Restarted pritunl service"
        logit "Waiting 30 seconds for get warmup application"

        sleep 30

        logit "Done awaiting, go get status of pritunl service"

        pritunl_status_daemon=`systemctl status pritunl | grep Active | cut -f2 -d ":" | cut -f1 -d "(" | xargs`

        logit "Check getted pritunl service status"

        if [ $pritunl_status_daemon == "active" ]; then

            logit "pritunl Successfuly restarted, try to access to port"

            get_any_service_status_pritunl=$(await_with_timeout $DEFAULT_AWAIT_PORT_TIMEOUT $PRITUNL_WEB_IP $PRITUNL_WEB_PORT)
            #get_any_service_status_pritunl=$(await_with_timeout $DEFAULT_AWAIT_PORT_TIMEOUT $RUN_NODE $PRITUNL_WEB_PORT)

            if [ $get_any_service_status_pritunl -eq 0 ]; then

                logit "Service Successful to bind to port, port is answer"

                pritunl_BACKUP_PLAN="0"
                logit "pritunl_BACKUP_PLAN $pritunl_BACKUP_PLAN"
                exit 0

            else

                logit "Service not to binded to port, port is not a answer"

                pritunl_BACKUP_PLAN="1"
                logit "pritunl_BACKUP_PLAN $pritunl_BACKUP_PLAN"
            fi

        else

            logit "pritunl not active after restart, try other way"
            # TO DO
            pritunl_BACKUP_PLAN="1"
            logit "pritunl_BACKUP_PLAN $pritunl_BACKUP_PLAN"
        fi

        let "pritunl_cc++"

    done

  fi

  logit "END: pritunl_service_while_up"

}


function mongodb_service_while_up() {

  logit "START: mongodb_service_while_up"

  if [[ $service_name == "mongodb" ]]; then

    # RESTART WITH 5 TIMES AWAITING

    mongo_db_cc=0

    while [ $mongo_db_cc -le 10 ]; do

        logit "current try is: $mongo_db_cc"

        logit "MONGODB_SERVICE_NAME: $MONGODB_SERVICE_NAME"

        /etc/init.d/$MONGODB_SERVICE_NAME restart

        sleep 10

        logit "MONGODB_SERVICE_NAME: $MONGODB_SERVICE_NAME"

        #mongo_status_daemon=`/etc/init.d/$MONGODB_SERVICE_NAME status | grep Active | cut -f2 -d ":" | cut -f1 -d "(" | xargs`
        mongo_status_daemon=`systemctl status $MONGODB_SERVICE_NAME | grep Active | cut -f2 -d ":" | cut -f1 -d "(" | xargs`

        if [ $mongo_status_daemon == "active" ]; then

            logit "Mongo Database Successfuly restarted, try to access to port"

            get_any_service_status_mongo=$(await_with_timeout $DEFAULT_AWAIT_PORT_TIMEOUT $RUN_NODE $MONGO_DEFAULT_PORT)

            if [ $get_any_service_status_mongo -eq 0 ]; then

                logit "Service Successful to bind to port, port is answer"

                logit "RUN_NODE : $RUN_NODE"



                local_mongodb_state=`mongo $RUN_NODE --eval "rs.status()" | grep -A3 $RUN_NODE | grep stateStr | cut -f2 -d ":" | cut -f2 -d "\""`

                logit "Service local_mongodb_state: $local_mongodb_state"

                if [ $local_mongodb_state == "PRIMARY" ]; then

                  logit "Service MongoDB state: $local_mongodb_state"

                else

                  if [ $local_mongodb_state == "SECONDARY" ]; then

                  logit "Service MongoDB state: $local_mongodb_state"

                  else

                    if [ $local_mongodb_state == "UNKNOWN" ]; then

                      logit "Service MongoDB state: $local_mongodb_state"

                    else

                      logit "Service MongoDB state: $local_mongodb_state"

                    fi

                  fi

                fi

                MONGODB_BACKUP_PLAN="0"
                logit "MONGODB_BACKUP_PLAN $MONGODB_BACKUP_PLAN"

            else

                logit "Service not to binded to port, port is not a answer"

                MONGODB_BACKUP_PLAN="1"
                logit "MONGODB_BACKUP_PLAN $MONGODB_BACKUP_PLAN"
            fi

        else

            logit "Mongo Database not active after restart, try other way"
            # TO DO
            MONGODB_MAIN_BACKUP_PLAN="1"
            logit "MONGODB_MAIN_BACKUP_PLAN $MONGODB_MAIN_BACKUP_PLAN"
        fi

        let "mongo_db_cc++"

    done

  fi

  logit "END: mongo_db_service_while_up"

}

function mongo_arbiter_service_while_up() {

  logit "START: mongo_arbiter_service_while_up"

  if [[ $service_name == "mongo_arbiter" ]]; then

    # RESTART WITH 5 TIMES AWAITING

    mongo_arb_cc=0

    while [ $mongo_arb_cc -le 10 ]; do

        logit "current try is: $mongo_arb_cc"

        /etc/init.d/$MONGO_ARBITER_SERVICE_NAME restart

        sleep 10

        mongo_arbiter_status_daemon=`/etc/init.d/$MONGO_ARBITER_SERVICE_NAME status | grep Active |cut -f2 -d ":" | cut -f1 -d "(" | xargs`

        if [ $mongo_arbiter_status_daemon == "active" ]; then

            logit "Mongo Arbiter Successfuly restarted, try to access to port"

            get_any_service_status_mongo_arbiter=$(await_with_timeout $DEFAULT_AWAIT_PORT_TIMEOUT $KEEPALIVED_ARBITER_SERVICE $MONGO_DEFAULT_PORT)

            if [ $get_any_service_status_mongo_arbiter -eq 0 ]; then

                logit "Service Successful to bind to port, port is answer"

                arbiter_state=`mongo $KEEPALIVED_ARBITER_SERVICE --eval "rs.status()" | grep -C3 $KEEPALIVED_ARBITER_SERVICE | grep -q ARBITER && echo 0 || echo 1`

                logit "Service arbiter_state: $arbiter_state"

                if [ $arbiter_state -eq 0 ]; then

                  logit "Service restarted successfuly"
                  MONGODB_ARBITER_BACKUP_PLAN="0"
                  logit "MONGODB_ARBITER_BACKUP_PLAN $MONGODB_ARBITER_BACKUP_PLAN"

                else

                  logit "Something wrong when try to restart, need backup plan to use"

                  MONGODB_ARBITER_BACKUP_PLAN="1"
                  logit "MONGODB_ARBITER_BACKUP_PLAN $MONGODB_ARBITER_BACKUP_PLAN"

                fi

            else

                logit "Service not to binded to port, port is not a answer"

            fi

        else

            logit "Mongo Arbiter not active after restart, try other way"
            # TO DO
            MONGODB_ARBITER_BACKUP_PLAN="1"
            logit "MONGODB_ARBITER_BACKUP_PLAN $MONGODB_ARBITER_BACKUP_PLAN"
        fi

        let "mongo_arb_cc++"

    done

  fi

  logit "END: mongo_arbiter_service_while_up"

}

function works_with_status_for_get_stats() {

  logit "START: works_with_status_for_get_stats"

  service_internal_status_array=()

  check_owner_to_escape;

  for i in ${array_gathering[@]}; do

    service_status=$(echo $i | cut -f1 -d ":")
    service_name=$(echo $i | cut -f2 -d ":")

    logit "I: $i"
    logit "service_name: $service_name"
    logit "service_status: $service_status"

    if [[ $service_name == "NEIGHBOR" ]]; then

    logit "service_name: $service_name"
    logit "service_status: $service_status"
    logit "no need any actions now for heighbor"

    else

        logit "service_name: $service_name"

        if [ $service_status -eq 1 ]; then

            logit "Service $service_name not currently up, go restart/await/get_stats"
            logit "service_status: $service_status"

            # RESTART, AWAIT, GET STATS

            mongo_arbiter_service_while_up;
            mongodb_service_while_up;

            check_double_secondary;
            check_current_primary;

            # CHECK AND FAILOVER BEFOR WARMUP PRITUNL

            #    pritunl_service_while_up;

            #

        else

            logit "Service $service_name looks currently up, go get_stats"
            logit "service_status: $service_status"

            # TRY TO GET STATS

            check_double_secondary;
            check_current_primary;

        fi

    fi

  done

  logit "END: works_with_status_for_get_stats"

}


function validate_counts_in_cluster() {

  check_double_secondary;
  check_current_primary;

}

function check_double_secondary() {

  logit "Get all secondary"

  secondary_count=$(mongo $become_mongo_to_be_a_master_ip --eval "rs.status()" | grep SECONDARY | wc -l)

  logit "secondary_count $secondary_count"

}

function get_current_primary_ip_from_rs_status() {


  logit "Get current primary by get_current_primary_ip_from_rs_status"

  current_primary_ip_rs_status=$(mongo $become_mongo_to_be_a_master_ip --eval "rs.status()" | grep -C3 PRIMARY | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

  logit "current_primary_ip_rs_status is: $current_primary_ip_rs_status"

  current_primary_ip_rs_status_last=`echo $current_primary_ip_rs_status | cut -f4 -d "."`

  logit "current_primary_ip_rs_status_last is: $current_primary_ip_rs_status_last"
  logit "become_vip_owner_ip_last is: $become_vip_owner_ip_last"

  if [ $become_vip_owner_ip_last -eq $current_primary_ip_rs_status_last ]; then

      logit "PRIMARY CURRENTLY ON RIGHT NODE, NEED TO CHECK PORT AND RESTART PRITUNL"

      MASTER_CHECK_AND_RESTART_PRITUNL="true"

  else

      logit "PRIMARY MUST TO BE CHANGED TO RIGHT NODE, AFTER NEED TO CHECK PORT AND RESTART PRITUNL"

      MASTER_CHECK_AND_RESTART_PRITUNL="migration"

  fi

  logit "MASTER_CHECK_AND_RESTART_PRITUNL $MASTER_CHECK_AND_RESTART_PRITUNL"

  logit "END current primary by get_current_primary_ip_from_rs_status"

}

function check_current_primary() {

  logit "Get current primary"

  logit "become_mongo_to_be_a_master_ip: $become_mongo_to_be_a_master_ip"

  primary_count=$(mongo $become_mongo_to_be_a_master_ip --eval "rs.status()" | grep PRIMARY | wc -l)

  logit "primary_count $primary_count"

  if [ $primary_count -eq 0 ]; then

    logit "We need perform migration PRIMARY TO CURRENT NODE"

    MASTER_CHECK_AND_RESTART_PRITUNL="migration"

    logit "MASTER_CHECK_AND_RESTART_PRITUNL $MASTER_CHECK_AND_RESTART_PRITUNL"

    # TO DO

  else

    logit "Check count of PRIMARY NODES"

    if [ $primary_count -eq 1 ]; then

        logit "ONE PRIMARY EXISTS. NEED TO CHECK WHO PRIMARY NOW"

        get_current_primary_ip_from_rs_status;

    else

        logit "MORE ONE PRIMARY IS EXITS, OR CLUSTER CONFIGURATION FAILED"

        MASTER_CHECK_AND_RESTART_PRITUNL="wrong"

        logit "MASTER_CHECK_AND_RESTART_PRITUNL $MASTER_CHECK_AND_RESTART_PRITUNL"

    fi

  fi

  logit "END current primary"

}

function check_and_stats() {

  logit "START: check_and_stats"

  set_current_cutted_ips

  logit "END: check_and_stats"

}

# MAIN RUN
# new...
logit "START MAIN DAO SCRIPT"
logit "WRITE TO LOG CURRENT UPTIME"
logit $(uptime_int)
logit "START AWAITING AND CHECK CURRENT UPTIME"

uptimeint=`uptime_int;`
logit "uptimeint $uptimeint"

while [[ $uptimeint -lt 30 ]]; do

  uptimeint=`uptime_int;`

  logit "Time since poweron $(uptime_int)"
  logit "We need wait more 30 seconds after poweron for next operations"

  sleep 5

done

logit "LOCALHOST UPTIME IS $(uptime_int)"
logit "Gathering current states"
logit "STARTING CHECK THE PORTS"

check_owner_to_escape;

if [ $NEED_TO_CHECK_HEIGHBOR -eq 0 ]; then

    logit "No need check neighbor"

    NEIGHBOR_STATUS="2"

else

    logit "We need to check neighbor"

    check_neighbor_by_ping;

    if [ $neighbor_ping_result -eq 0 ]; then

        NEIGHBOR_STATUS="0"

    else

        NEIGHBOR_STATUS="1"

    fi

    logit "NEIGHBOR_STATUS: $NEIGHBOR_STATUS"

fi

get_target

case "$NEIGHBOR_STATUS" in
          0)
              logit "We need to check owner to escape again"

              check_owner_to_escape;

              logit "If in this place, need all check and perform failover."
              logit "After get all checks and stats, need to check again neighbor"

              get_status_trail

              ;;
          1)
              logit "Heighbor possibly down now"
              logit "If in this place, need all check and perform failover."
              logit "After get all checks and stats, need to check again neighbor"

              get_status_trail

              ;;
          2)
              logit "No need to check neighbor"

              ;;
          *)
              logit "Something wrong with status NEIGHBOR_STATUS"
              exit 1
esac

check_and_stats

logit "INPUT STAT: $KP_INSTANCE $KP_STATUS $KP_PR"


if [[ $KP_STATUS == "MASTER" ]]; then

logit "start wants to be a master"

fi

logit "start works_with_status_for_get_stats"
works_with_status_for_get_stats
logit "done works_with_status_for_get_stats"

logit "go to if"

if [[ $MASTER_CHECK_AND_RESTART_PRITUNL == "migration" ]]; then

    logit "Case with Migration PRIMARY, MAIN PART"


    logit "We must perform migration of the PRIMARY, CHECK, AND RESTART PritUNL"

    get_any_service_status_mongo_arbiter_last=$(await_with_timeout $DEFAULT_AWAIT_PORT_TIMEOUT $KEEPALIVED_ARBITER_SERVICE $MONGO_DEFAULT_PORT)

    if [ $get_any_service_status_mongo_arbiter_last -eq 0 ]; then

        logit "Service Successful to bind to port, port is answer"

        arbiter_state=`mongo $KEEPALIVED_ARBITER_SERVICE --eval "rs.status()" | grep -C3 $KEEPALIVED_ARBITER_SERVICE | grep -q ARBITER && echo 0 || echo 1`

        logit "Service arbiter_state: $arbiter_state"

        if [ $arbiter_state -eq 0 ]; then

          logit "Service restarted successfuly"
          MONGODB_ARBITER_BACKUP_PLAN="0"
          logit "MONGODB_ARBITER_BACKUP_PLAN $MONGODB_ARBITER_BACKUP_PLAN"

        else

          logit "Something wrong when try to restart, need backup plan to use"

          MONGODB_ARBITER_BACKUP_PLAN="1"
          logit "MONGODB_ARBITER_BACKUP_PLAN $MONGODB_ARBITER_BACKUP_PLAN"

          mongo_arbiter_service_while_up;

        fi

    else

        logit "Service not to binded to port, port is not a answer"
        mongo_arbiter_service_while_up;

    fi

    if [ $MONGODB_ARBITER_BACKUP_PLAN -eq 0 ]; then

        logit "Arbiter is UP, we can try perform change PRIMARY"

        change_current_to_primary;

        logit "Check after changing the PRIMARY"

        check_current_primary;

        if [ $MASTER_CHECK_AND_RESTART_PRITUNL == "migration" ]; then

            logit "Case with Migration PRIMARY, wrapper last call"
            logit "Changed PRIMARY to current node successful"
            logit "Call restart Pritunl Service"
            pritunl_service_while_up;
        fi


    else

        logit "Something wrong with arbiter service"
        MONGODB_ARBITER_BACKUP_PLAN="3"
        logit "MONGODB_ARBITER_BACKUP_PLAN $MONGODB_ARBITER_BACKUP_PLAN"
    fi

else

   if [[ $MASTER_CHECK_AND_RESTART_PRITUNL == "true" ]]; then

      logit "We must check primary on selfip and restart pritunl"

      check_current_primary;

      if [ $MASTER_CHECK_AND_RESTART_PRITUNL == "true" ]; then

          logit "Changed PRIMARY to current node successful"
          logit "Call restart Pritunl Service"
          pritunl_service_while_up;

      fi

   else

      logit "We get wrong status for continue"

   fi

fi