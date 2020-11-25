#!/bin/bash
environment=$1
echo $environment

silver_path=`pwd`
echo $silver_path

cd $ansiblepath && ansible-playbook full-deploy.yml -i inventories/$environment/
