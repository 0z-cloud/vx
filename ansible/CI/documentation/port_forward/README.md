# Port Forward possible PCI environment services

- > Services list

``

OSSIM WEB
NAGIOS WEB
SWITCH WEB

``

## For port forward to localhost 8088 from 10.10.0.250 80 via 10.10.0.250 (NAGIOS WEB)

``

  ssh \
     -L 8088:10.10.0.250:80 \
     -p 22 \
     -l %username% \
     -N \
     10.10.0.250

``

## For port forward to localhost 444 from 10.10.10.5 443 via 10.10.0.250 (OSSIM WEB)

``

  ssh \
     -L 444:10.10.10.5:443 \
     -p 22 \
     -l %username% \
     -N \
     10.10.0.250

``

## For port forward to localhost 8443 from 10.90.90.91 443 via 10.10.0.250 (SWITCH WEB)

``
  ssh \
     -L 8443:10.90.90.91:443 \
     -p 22 \
     -l %username% \
     -N \
     10.10.0.250

``

``
 sudo ssh \
     -L 8444:10.10.0.250:80 \
     -p 22 \
     -l %username% \
     -N \
     10.10.0.250

``

## Port forward Domain Controller in Office environment

``

 sudo ssh \
     -L 3389:10.20.194.11:3389 \
     -p 22 \
     -l %username% \
     -N \
     89.223.18.33

``

## Port forward Exchange Server in Office environment

``
 sudo ssh \
     -L 3390:10.20.194.12:3389 \
     -p 22 \
     -l %username% \
     -N \
     89.223.18.33

``

sudo ssh \
     -L 3390:10.91.91.103:11443 \
     -p 22 \
     -l vortex \
     -N \
     77.243.80.66

sudo ssh \
     -L 3460:10.16.211.181:15672 \
     -p 22 \
     -l vortex \
     -N \
     10.16.131.250

ssh \
     -L 3461:10.16.211.181:15672 \
     -p 22 \
     -l vortex \
     -N \
     10.16.131.250

ssh \
     -L 8088:10.16.131.251:3000 \
     -p 22 \
     -l vortex \
     -N \
     10.16.131.250

ssh \
     -L 8089:10.91.91.103:11443 \
     -p 22 \
     -l vortex \
     -N \
     10.16.131.250
     
     
sudo ssh \
     -L 443:10.16.128.254:443 \
     -p 22 \
     -l vortex \
     -N \
     10.16.131.250

sudo ssh \
     -L 444:10.16.120.42:443 \
     -p 22 \
     -l vortex \
     -N \
     10.16.131.250