#!/bin/bash

echo "#ossec" >> /etc/apt/sources.list
echo "deb [arch=amd64] http://vortex-repo-01.vortex.com/ossec_local/ bionic main" >> /etc/apt/sources.list

wget http://vortex-repo-01:80/gpg/ossec.key && cat ossec.key  | sudo apt-key add -
apt update -yy
apt install ossec-hids-agent -yy