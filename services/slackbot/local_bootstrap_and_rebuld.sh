#!/bin/bash

no_build=$1

# MUST HAVE THE cgroupfs-mount package installed at you system

cd ../../
main_path=`pwd`

echo "main path: $main_path"
docker_path="$main_path/services/slackbot/"
projects_path="$main_path/services/"

woinc_api_path="$main_path/services/slackbot/woinc/"

echo "projects path: $projects_path"
echo "woinc_api path: $woinc_api_path"
echo "docker path: $docker_path"
cd $docker_path

if [ ! -z $no_build ]; then
    #### WORKS EXAMPLE
    #
    tar -ch ../slackbot | docker build -t woinc/slackbot-labirint:latest -f ./slackbot/Dockerfile -
    #
    #### OLD EXAMPLE
    # tar -czh ./slackbot/ | docker build -t woinc/api-labirint -f ./slackbot/Dockerfile -
    # cd ./woinc/
    # 
    # tar -ch ../slackbot | docker build -t woinc/api-labirint -f ../slackbot/Dockerfile - 
    # tar -czh ./slackbot/ | docker build -t woinc/api-labirint -f ./slackbot/Dockerfile .
    #################
fi
# chmod -R 777 /dev/shm

cd $woinc_api_path

docker ps -a | awk '{print $1}' | tail -n +2 | xargs -I ID docker rm -f ID

# docker rm -f woinc-api-postgresql
# docker rm -f woinc-api-service
# chmod -R 777 ./data
# cgroupfs-mount;
# docker run -d \
#     --name woinc-db \
#     -p 5432:5432 \
#     -e POSTGRES_PASSWORD=7539148620qQ \
#     -e POSTGRES_DBNAME=woincapi \
#     -v ${woinc_api_path}data:/var/lib/postgresql/data \
#     frodenas/postgresql

#     # -e POSTGRES_USERNAME=postgres \

# # docker run -d --privileged --memory 256m --memory-swap -1 --name woinc-api-postgresql -p 5432:5432 -e POSTGRESQL_SHARED_BUFFERS=256MB -v /dev/shm:/dev/shm -v ${woinc_api_path}data:/var/lib/postgresql/data -e POSTGRES_PASSWORD=7539148620qQ -e POSTGRES_DB=woincapi postgres
# echo "Sleep wait when postgres UP"
# sleep 50
# docker run -d --name woinc-api-service -p 4444:4444 -e POSTGRES_PASSWORD=7539148620qQ --link woinc-api-postgresql:woinc-api-postgresql -e POSTGRES_DB=woincapi -v $projects_path:/slackbot/woinc woinc/api-labirint:latest
# docker run -d --privileged --name woinc-api-service -p 4444:4444 -e POSTGRES_PASSWORD=7539148620qQ --link woinc-db:woinc-api-postgresql -e POSTGRES_DB=woincapi woinc/api-labirint
docker run -d --privileged --name woinc-api-service -p 4444:4444 -e POSTGRES_PASSWORD=7539148620qQ -e POSTGRES_DB=woincapi -e SLACKBOT_API_TOKEN=xoxb-2047533411056-2023757814562-8KoMdbG2KgQju0DqhBZbpWAu woinc/slackbot-labirint

# sleep 10

# docker exec -it woinc-api-service 'python3 /slackbot/woinc/create_db.py &'
# docker exec -it woinc-api-service 'bash -x /extended.sh'
