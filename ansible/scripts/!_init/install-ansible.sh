#!/usr/bin/env bash
sudo apt-get update -y -qq
sudo apt-get upgrade -y -qq
sudo apt-get install curl -y -qq
sudo apt-get install -y -qq \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update -y

# sudo apt-get -y install unzip mc nano htop python3-pip smartmontools build-essential checkinstall software-properties-common libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev python-py python-pip -qq 

sudo apt-get -y install docker-ce unzip mc nano htop python3-pip smartmontools build-essential checkinstall software-properties-common libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev python-py -qq 

sudo apt install -y -qq python-dockerpty gnupg2 pass

wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py

ln -s /usr/local/bin/pip /usr/bin/pip

pushd /tmp
cat > req.txt <<EOF
cryptography
pywinrm
dnspython
urllib3<1.25
ansible

EOF

# DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# sudo -H pip install --upgrade pip
# sudo -H pip install --upgrade virtualenv

pip install -r $DIR/req.txt

rm /tmp/req.txt

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

sudo -H pip install --upgrade pip
sudo -H pip install --upgrade virtualenv