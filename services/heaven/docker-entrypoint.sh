#!/bin/bash

RUN_CONTAINER_MAIN_LOOP=$1

cat /etc/environment

if [ -z $RUN_CONTAINER_MAIN_LOOP ]; then
    
    echo "RUNNING SOMEWHERE BETWEEN HEAVEN AND HELL"
    i=0 
    echo "started" 
    
    while true; do 
        i=i+1 
        echo "Time at point of pure zen infinity are elapsed, or it only the random value is: ${i}"
        sleep 1
    done

else

    echo "WE ARE RUNNING IN $RUN_CONTAINER_MAIN_LOOP"

fi    
