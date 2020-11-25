#!/usr/bin/env bash

sudopassword=$1
runtype=$2

if [ "${sudopassword}" == "" ]; then
echo "ERROR! MISSED PARAM! You must pass as first param your sudo password of YOUR LOCALHOST MAC/PC MACHINE"
exit 1
fi

if [ "${runtype}" == "" ]; then
echo "ACCEPTED 3 TYPES OF RUN: default / recreate / cleanfirst"
runtype='default'
echo "RUNTYPE: ${runtype}"
fi

if [ "${runtype}" == "cleanfirst" ]; then
echo "Removing all localhost docker containers"
docker ps -a | awk '{print $1}' | tail -n +2 | xargs -I ID docker rm -f ID
fi

ansible-playbook -i ansible/inventories/0z-cloud/inventory ansible/playbook-library/\!_0_init/docker-compose-local.yml -e RUNTYPE="${runtype}" -e ansible_become_pass="${sudopassword}"
