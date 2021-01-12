FROM ubuntu:latest
MAINTAINER Westsouthnight <ros@woinc.ru>
ENV LANG en_US.UTF-8
ENV TERM xterm

#RUN apt update -q -yy && apt upgrade -yy -q
RUN apt update -q -yy
#
RUN apt install -q -yy expect
#RUN apt install -q -yy libssl-dev python python3 python-dev python3-dev python-pip python3-pip 
RUN apt install -q -yy python3 python3-pip expect
#
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

RUN ls -la /
RUN ls -la /codecloudcoin/woinc
RUN ls -la /codecloudcoin/

RUN cd /
RUN pip3 install python-ldap

RUN pip3 install -r /codecloudcoin/requirements.txt \
    && pip3 install -r /codecloudcoin/optionals.txt
COPY /codecloudcoin/start.sh /
COPY /codecloudcoin/extended.sh /
COPY /codecloudcoin/while.sh /
COPY /codecloudcoin/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN pip3 install psycopg2
EXPOSE 4444
HEALTHCHECK --interval=10s --timeout=10s --retries=5 \
    CMD curl --fail http://localhost:4444/ || exit 1

CMD ["/bin/bash", "/start.sh"]
