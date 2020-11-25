#!/bin/bash

keys=(
launchpad.key
mongo.key
ossec.key
percona.key
php.key
pritunl.key
rabbitmq.key
redis.key
docker.key
)

for key in ${keys[@]}; do
  echo 
  wget http://vortex-repo-01:80/gpg/$key && cat $key | sudo apt-key add -
done
