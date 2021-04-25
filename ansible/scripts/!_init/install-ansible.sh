#!/usr/bin/env bash
sudo apt-get update -yy -qq
sudo apt-get upgrade -yy -qq
sudo apt-get install curl wget -yy -qq
sudo apt-get install apt-transport-https ca-certificates software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update -yy -qq

# sudo apt-get -y install unzip mc nano htop python3-pip smartmontools build-essential checkinstall software-properties-common libreadline-gplv2-dev
# libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev python-py python-pip -qq

sudo apt-get install -yy  docker-ce unzip mc nano htop python3-pip smartmontools build-essential checkinstall software-properties-common libreadline-gplv2-dev
sudo apt install -yy  libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev python-py python3-dev

sudo apt install -yy python-dockerpty gnupg2
sudo apt install -yy pass

wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py

ln -s /usr/local/bin/pip3 /usr/bin/pip3

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pip3 install -r $DIR/river_uniq_all.yml
pip3 install --upgrade -r $DIR/river_uniq_all.yml

rm /etc/locales

cat > /etc/locales <<EOF
LANG=C
LANGUAGE=
LC_CTYPE="en_US.UTF-8"
LC_NUMERIC="C"
LC_TIME="C"
LC_COLLATE="en_US.UTF-8"
LC_MONETARY="C"
LC_MESSAGES="en_US.UTF-8"
LC_PAPER="C"
LC_NAME="C"
LC_ADDRESS="C"
LC_TELEPHONE="C"
LC_MEASUREMENT="C"
LC_IDENTIFICATION="C"
LC_ALL="en_US.UTF-8"
EOF

source /etc/locales

pushd /

sudo -H pip3 install --upgrade pip3
sudo -H pip3 install --upgrade virtualenv