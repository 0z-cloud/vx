#!/bin/bash

run=$1
# registry by param NEED! 

APP_NAME=$(basename "$PWD")

baseport=$(cat README.md | grep port | awk '{print $2}')

docker build -f Dockerfile ../ --build-arg APP_NAME=${APP_NAME} -t registry.local.cloud.eve.vortice.eden/python-qa-${APP_NAME}-v1:latest

docker push registry.local.cloud.eve.vortice.eden/python-qa-${APP_NAME}-v1:latest

docker rm -f python-qa-${APP_NAME}-v1

if [ ! -z "$run" ]; then

    docker run -d  --name python-qa-${APP_NAME}-v1 -p ${baseport}:${baseport} registry.local.cloud.eve.vortice.eden/python-qa-${APP_NAME}-v1:latest

fi