FROM python:latest
MAINTAINER Ros aka vortex <support@vortex.com>

ADD ./scripts/requirements/requirements.txt /tmp/requirements.txt
RUN cd /tmp \
    && pip3 install -r requirements.txt
RUN mkdir /volume \
    && mkdir /ansible
WORKDIR /opt/ansible
RUN cd /opt/ansible
# ADD .dockerbuild/pass.yml /volume/pass.yml
# ADD .dockerbuild/ansible.yml /ansible.yml
# ADD .  /ansible
# ADD .dockerbuild/id_rsa /root/.ssh/id_rsa
# COPY ansible.cfg /etc/ansible/ansible.cfg
COPY . .
# RUN chmod 644 /volume/pass.yml \
#     && chmod 500 /root/.ssh/id_rsa