#!/bin/bash

cd ../../
main_path=`pwd`

echo "main path: $main_path"
docker_path="$main_path/services/codecloudcoin/"
projects_path="$main_path/services/"

woinc_api_path="$main_path/services/codecloudcoin/woinc/"

echo "projects path: $projects_path"
echo "woinc_api path: $woinc_api_path"
echo "docker path: $docker_path"
cd $docker_path

#### WORKS EXAMPLE
#
tar -ch ../codecloudcoin | docker build -t woinc/api-labirint:latest -f ./codecloudcoin/Dockerfile -
#
#### OLD EXAMPLE
# tar -czh ./codecloudcoin/ | docker build -t woinc/api-labirint -f ./codecloudcoin/Dockerfile -
# cd ./woinc/
# 
# tar -ch ../codecloudcoin | docker build -t woinc/api-labirint -f ../codecloudcoin/Dockerfile - 
# tar -czh ./codecloudcoin/ | docker build -t woinc/api-labirint -f ./codecloudcoin/Dockerfile .
#################
cd $woinc_api_path

docker ps -a | awk '{print $1}' | tail -n +2 | xargs -I ID docker rm -f ID

# docker rm -f woinc-api-postgresql
# docker rm -f woinc-api-service

docker run -d --privileged --name woinc-api-postgresql -p 5432:5432 -v data:/var/lib/postgresql/data -e POSTGRES_PASSWORD=7539148620qQ -e POSTGRES_DB=woincapi postgres
echo "Sleep wait when postgres UP"
sleep 50
# docker run -d --name woinc-api-service -p 4444:4444 -e POSTGRES_PASSWORD=7539148620qQ --link woinc-api-postgresql:woinc-api-postgresql -e POSTGRES_DB=woincapi -v $projects_path:/codecloudcoin/woinc woinc/api-labirint:latest
docker run -d --privileged --name woinc-api-service -p 4444:4444 -e POSTGRES_PASSWORD=7539148620qQ --link woinc-api-postgresql woinc-api-postgresql -e POSTGRES_DB=woincapi woinc/api-labirint:latest
