#!/bin/bash

fail_timeout=300
check_count=10
timeout_check_interval=` expr $fail_timeout / $check_count`

n=0
while :
do
    result=`ipvsadm -L --stats -n | grep '{{ backend_service_ip }}:{{ backend_service_port }}'`
    [[ ! -z "$result" ]] && exit 0 || ((n++))
    (( n >= $check_count )) && exit 1
done