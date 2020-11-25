#!/bin/bash

cd ../../
main_path=`pwd`

echo "main path: $main_path"
docker_path="$main_path/Docker"
projects_path="$main_path/projects/woinc/"

woinc_api_path="$main_path/Docker/wo-api/"

echo "projects path: $projects_path"
echo "woinc_api path: $woinc_api_path"
echo "docker path: $docker_path"
cd $docker_path
# tar -czh ./wo-api/ | docker build -t woinc/api-labirint -f ./wo-api/Dockerfile -
cd ./wo-api/
tar -ch ../wo-api | docker build -t woinc/api-labirint -f ../wo-api/Dockerfile - 
# tar -czh ./wo-api/ | docker build -t woinc/api-labirint -f ./wo-api/Dockerfile .
cd $woinc_api_path

docker rm -f woinc-api-postgresql
docker rm -f woinc-api-service

docker run -d --name woinc-api-postgresql -p 5432:5432 -e POSTGRES_PASSWORD=7539148620qQ -e POSTGRES_DB=woincapi postgres
echo "Sleep wait when postgres UP"
sleep 50
docker run -d --name woinc-api-service -p 4444:4444 -e POSTGRES_PASSWORD=7539148620qQ --link woinc-api-postgresql:woinc-api-postgresql -e POSTGRES_DB=woincapi -v $projects_path:/wo-api/woinc woinc/api-labirint:latest
