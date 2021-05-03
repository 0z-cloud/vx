FROM ubuntu:focal
MAINTAINER Westsouthnight <ros@woinc.ru>
ENV LANG en_US.UTF-8
ENV TERM xterm

# RUN apt update -q -yy && apt upgrade -yy -q
RUN apt update -q -yy
#
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata

# RUN apt install -q -yy libssl-dev python python3 python-dev python3-dev python-pip python3-pip 
RUN apt install -q -yy python3 python3-pip expect net-tools
#
#--------
RUN apt install -q -yy git curl postgresql-client
# libffi-dev linux-headers-generic python-ldap gcc
# RUN apt install -q -yy python-psycopg2 git supervisor 
RUN apt install -q -yy python3-psycopg2 python3-ldap git 
# python libsasl2-dev libldap2-dev 
RUN apt install -q -yy mc nano 
# libpq-dev build-essential postgresql-server-dev-all

#RUN apt install supervisor
#RUN mkdir -p /wrk/tmp \
#    && cd /wrk/tmp \
#    && git clone https://github.com/encode/django-rest-framework.git \
#    && cd django-rest-framework

RUN mkdir -p /app/woinc
COPY ./ /

RUN cp -R /slackbot/woinc/* /app/woinc/

RUN ls -la /
RUN ls -la /slackbot/woinc
RUN ls -la /slackbot/

RUN cd /
RUN pip3 install python-ldap

RUN pip3 install -r /slackbot/requirements.txt \
    && pip3 install -r /slackbot/optionals.txt
COPY /slackbot/start.sh /
COPY /slackbot/extended.sh /
COPY /slackbot/while.sh /
COPY /slackbot/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN pip3 install psycopg2
EXPOSE 4444
# HEALTHCHECK --interval=10s --timeout=10s --retries=5 \
#     CMD curl --fail http://localhost:4444/ || exit 1

CMD ["/bin/bash", "/start.sh"]
