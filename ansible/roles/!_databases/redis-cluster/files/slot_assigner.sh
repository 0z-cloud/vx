#!/usr/bin/env bash

count=0
hosts=( )
ports=( )

for arg in "$@"
do
  if [ "$[$count%2]" = "0" ]
  then
    hosts[${#hosts[*]}]=$arg
  else
    ports[${#ports[*]}]=$arg
  fi

  count=$[$count+1]
done

if [ "$count" = "0" ]
then
  echo "You should specify at least one host to assign slots."
  echo "Usage:"
  echo "redis-cluster-initial-config host1 port1 host2 port2 ..."
  exit 1
fi

if [ "$[$count%2]" = "1" ]
then
  echo "One of the host doesn't have ports"
  exit 1
fi

count=$[$count/2]

echo "Assigning slots. No progress here, just wait"
slots=16384
slots_per_node=$[$slots/$count]

for i in `seq 0 $[$slots-1]`
do
  index=$[$i/$slots_per_node]
  if [ "$index" = "$count" ]
  then
    index=$[$count-1]
  fi

  redis-cli -h ${hosts[$index]} -p ${ports[$index]} cluster addslots $i > /dev/null 
done

echo "Done!"