#!/bin/bash

EXEC_TIMESTAMP=$1

END_EXEC_TIMESTAMP=`date +%s`
TOTAL_EXEC_TIME_SECS=`expr $END_EXEC_TIMESTAMP - $EXEC_TIMESTAMP`
TOTAL_EXEC_TIME_MINS=`expr $TOTAL_EXEC_TIME_SECS / 60`

# SHOW OVERALL RUNTIME
if [ "$type_of_run" != "run_from_wrapper" ]; then

    echo "
         .....    .....    .....    .....    .....    .....    .....    .....    .....    .....    .....    .....
         TOTAL EXEC TIME: 
        
         in mins: ${TOTAL_EXEC_TIME_MINS}
         in secs: ${TOTAL_EXEC_TIME_SECS}

         .....    .....    .....    .....    .....    .....    .....    .....    .....    .....    .....    .....
    "
    echo -e "We ${RED}love${NC} Ansible!"

fi