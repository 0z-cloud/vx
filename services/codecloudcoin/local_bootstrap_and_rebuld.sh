#!/bin/bash

# INJECTED PARAMETERS # 
DO_REBUILD=$1
DO_APPS_CLEAN=$2
DATABASE_PASSWORD=$3
DATABASE_NAME=$4
DATABASE_USER=$5

if [ ! -z $DO_REBUILD ]; then

    echo "DO_REBUIL: PASSED THE NOT ZERO STRING, MUST GO re/BUILD"

    #### WORKS EXAMPLE for EXAMPLE APPLICATION CONTAINER BUILD IMAGE
    #
    tar -ch ../codecloudcoin | docker build -t woinc/api-labirint:latest -f ./codecloudcoin/Dockerfile -
    #
    #### OLD-NG EXAMPLE END

else

    echo "PASSED NULL OR EMPTY VALUE, IGNORE re/BUILD"

fi

if [ ! -z $DO_APPS_CLEAN ]; then

    echo "DO_APPS_CLEAN: PASSED THE NOT ZERO STRING, MUST GO re/Clean"

else

    echo "PASSED NULL OR EMPTY VALUE, IGNORE re/Clean"

fi 

if [ ! -z $DATABASE_PASSWORD ]; then

    echo "DATABASE_PASSWORD: PASSED THE NOT ZERO STRING AND NEXT USE IT VALUE TO INJECT"

else

    echo "PASSED NULL OR EMPTY VALUE, SETUP DEFAULT DATABASE_PASSWORD CONSTRAIN FOR IT"

    DATABASE_PASSWORD="7539148620qQ"

fi 

if [ ! -z $DATABASE_NAME ]; then

    echo "DATABASE_NAME: PASSED THE NOT ZERO STRING AND NEXT USE IT VALUE TO INJECT"

else

    echo "PASSED NULL OR EMPTY VALUE, SETUP DEFAULT DATABASE_NAME CONSTRAIN FOR IT"

    DATABASE_NAME="woincapi"

fi 

if [ ! -z $DATABASE_USER ]; then

    echo "DATABASE_USER: PASSED THE NOT ZERO STRING AND NEXT USE IT VALUE TO INJECT"

else

    echo "PASSED NULL OR EMPTY VALUE, SETUP DEFAULT DATABASE_USER CONSTRAIN FOR IT"

    DATABASE_USER="postgres"

fi 

# or/MUST HAVE THE cgroupfs-mount package installed at you system

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

#################
cd $woinc_api_path

docker ps -a | awk '{print $1}' | tail -n +2 | xargs -I ID docker rm -f ID

rm -rf  ${woinc_api_path}data/
mkdir -p ${woinc_api_path}data/
chmod -R 777 ./data

# cgroupfs-mount;

docker run -d \
    --name woinc-db \
    -p 5432:5432 \
    -e POSTGRES_PASSWORD=$DATABASE_PASSWORD \
    -e POSTGRES_DBNAME=$DATABASE_NAME \
    -v ${woinc_api_path}data:/var/lib/postgresql/data \
    frodenas/postgresql

echo "Sleep wait when postgres UP"
sleep 25

echo -e "a/Wait when database are done Database is complete bootstrap"
sleep 50
docker exec -it woinc-db 'su -l postgres -c "/db_create.sh ${DATABASE_USER} ${DATABASE_PASSWORD}"'

echo -e "Create the Application Container Instance ..."
docker run -d --privileged --name woinc-api-service -p 4444:4444 -e POSTGRES_PASSWORD=$DATABASE_PASSWORD --link woinc-db:woinc-api-postgresql -e POSTGRES_DB=$DATABASE_NAME woinc/api-labirint

echo -e "a/Wait when application are starts complete"
sleep 5

echo -e "Perform run inside Application processes applying some migrations and re/validation re/creation default data[base][set]"
docker exec -it woinc-api-service bash -c 'python3 /codecloudcoin/woinc/create_db.py'
docker exec -it woinc-api-service bash -c '/extended.sh'

# By default after complete Vx injected to DB constrains, like Admin password and other, 
# and you can get it... or ... \
#   you must know, if you are not know, please send to us your request, 
#     for get trial version our compelte Vx Enterprise Cloud Box Suite,
#       which can be run in you private zone for testing,
#         by email us write letter to corporate@0z-cloud.com

# Best regards, Wizards of 0z
# In many Clouds We Trust
