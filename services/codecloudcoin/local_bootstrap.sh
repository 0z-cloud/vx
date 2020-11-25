#!/bin/bash
docker rm -f woinc-api-postgresql
docker rm -f woinc-api-service

docker run -d --name woinc-api-postgresql -p 5432:5432 -e POSTGRES_PASSWORD=7539148620qQ -e POSTGRES_DB=woincapi postgres
echo "Sleep wait when postgres UP"
sleep 50
# docker run -d --name woinc-api-service -p 4444:4444 -e POSTGRES_PASSWORD=7539148620qQ --link woinc-api-postgresql:woinc-api-postgresql -e POSTGRES_DB=woincapi -v /Users/westsouthnight/REPOS/dev.trb/projects/woinc/:/wo-api/woinc woinc/api-labirint:latest
docker run -d --name woinc-api-service -p 4444:4444 -e POSTGRES_PASSWORD=7539148620qQ --link woinc-api-postgresql:woinc-api-postgresql -e POSTGRES_DB=woincapi -v /Users/westsouthnight/TWO_REPO/dev.trb/projects/woinc/:/wo-api/woinc woinc/api-labirint:latest


#docker run -d --name woinc-api-service -p 4444:4444 -e POSTGRES_PASSWORD=7539148620qQ --link woinc-api-postgresql:postgres-db-host -e POSTGRES_DB=woincapi -v woinc:/wo-api/woinc woinc/api-labirint:latest