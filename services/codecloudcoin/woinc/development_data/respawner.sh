docker rm -f  woinc-api-powerdns
docker run -d --name woinc-api-powerdns -p 5432:5432 -e POSTGRES_PASSWORD=7539148620qQ -e POSTGRES_DB=woincapi postgres
docker build woinc/api-labirint:latest 
#python3 ./create_db.py 
