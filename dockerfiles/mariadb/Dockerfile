#Image from hub.docker.com
FROM mariadb:10.5.4

#Creator
LABEL MAINTAINER="unknownarcitector"

#Create WORKDIR
RUN mkdir -p /var/lib/mysql \
    && chmod 777 -R /var/lib/mysql

RUN mkdir -p /var/lib/mysql-scripts \
    && chmod 777 -R /var/lib/mysql-scripts

EXPOSE 3306

#Add entrypoint.sh
# COPY ./Dockerfile/mariadb/entrypoint.sh /var/lib/mysql-scripts
COPY ./entrypoint.sh /var/lib/mysql-scripts

COPY ./mysql/ansible_environment_database_init_db.sql /var/lib/mysql
RUN chmod +x /var/lib/mysql-scripts/entrypoint.sh
RUN chmod 777 /var/lib/mysql-scripts/entrypoint.sh
# CMD /var/lib/mysql-scripts/entrypoint.sh
