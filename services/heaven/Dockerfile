FROM alpine AS builder
RUN apk update
RUN apk add curl
WORKDIR /qemu
# downloaded here...
RUN curl -L https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-arm.tar.gz | tar zxvf - -C . && mv qemu-3.0.0+resin-arm/qemu-arm-static .

FROM area51/gdal:arm64v8-2.2.3
# ...then added here
COPY --from=builder /qemu/qemu-arm-static /usr/bin

RUN apt-get update
RUN apk add make golang python3-dev python-dev gcc
RUN apt-get install -y libgdal-dev python3-pip libspatialindex-dev unar bc

ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal

###################################################################### RFC TO J2 FOR ANY BASE AND DYNAMIC A12Vx Build Flow
# - Vx - HH alpha Release - AT EDGE POINT OF ENTER TO SPACE JOURNIES -
#FROM alpine:3.12.0
######################################################################
RUN apk update
RUN apk add curl git
WORKDIR /qemu
# RUN apk add qemu-utils qemu-system-x86 
RUN mkdir /anubis && mkdir /anubis/qemu
WORKDIR /anubis/quemu

# RUN cd /anubis && git clone https://github.com/lf-edge/eden

######################################################################
RUN apt install -yy apt-transport-https ca-certificates curl gnupg-agent software-properties-common
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
######################################################################
RUN apt update -y && apk add docker-ce-cli containerd.io
RUN apk add iproute2 inetutils-tools iproute2 inetutils-ping
# ENV DOCKER_HOST=tcp://127.0.0.1:2376
COPY ./_vx_edge/* /anubis/
COPY ./docker-entrypoint.sh /
#
# RUN ./docker_outside_env_init.sh
# RUN docker ps
######################################################################
# AT CREATION MOMENT OF TIME, PLACE WHERE ALL=ALL(ALL) ARE START RACE!
# RUN i=0 && echo "started" && while true; do i=i+1 ; echo "Time at point of pure zen infinity are elapsed, or it only the random value is: ${i}" ; sleep 1 ; done
########## BREAKPOINT 
# RUN export DOCKER_HOST=tcp://127.0.0.1:2376 && docker ps -a 
ENTRYPOINT [ "/docker-entrypoint.sh" ]

