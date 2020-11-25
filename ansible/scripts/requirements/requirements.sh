#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

uname=`uname -s`

echo "         REQUIREMENTS HOST OS $uname"
echo "         DIR: $DIR"

if [[ "$uname" == "Darwin" ]]; then
    echo "         OS TYPE: $uname"
    echo "         Installing brew..."
    ram_gb=`expr $(sysctl -a | grep hw.memsize | awk '{print $2}' | xargs -I ID echo ID) / 1024 / 1024 / 1024`
    echo "         Total Physical Mem $ram_gb GB"
    yes '' |/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"  2>&1
    brew update 2>&1
    pip3 install --upgrade pip

    ansible-playbook $DIR/ansible_localhost_playbook_pip_requirements.yml
    
    if [[ $ram_gb == "32" ]]; then
        echo "You have a enough resources for able up private stackable little-cloud on localhost"
        echo "Installing virtualization and Vagrant"
        ansible-playbook $DIR/ansible_localhost_playbook_brew_mac_os_x.yml
    fi
fi

if [[ "$uname" == "Linux" ]]; then
    echo "         OS TYPE: $uname"
    echo "         Installing apt packages..."
    apt install software-properties-common -y -qq
    apt-repository ppa:ansible/ansible -y
    apt update -y -qq
    apt install ansible -y -qq
    apt install sshpass -y -qq
    apt install python3-pip -y -qq 2>&1
    #pip --install upgrade pip 2>&1
    #pip install -r $DIR/requirements.yml 2>&1
    #pip install --upgrade -r $DIR/requirements.yml 2>&1
    pip3 install -r $DIR/requirements.yml 2>&1
    pip3 install --upgrade -r $DIR/requirements.yml 2>&1
    echo vm.overcommit_memory=1 >> /etc/sysctl.conf &>/dev/null
    echo vm.max_map_count=262144 >> /etc/sysctl.conf &>/dev/null
    sysctl -p /etc/sysctl.conf &>/dev/null
    stable_vbox=$(curl -X GET http://download.virtualbox.org/virtualbox/LATEST-STABLE.TXT 2&>1)
    echo $stable_vbox
    anno=$(curl -X GET https://download.virtualbox.org/virtualbox/$stable_vbox/SHA256SUMS &>1 | awk '{print $2}' | grep amd64.run | sed 's/*//g')
    ext_pack=$(curl -X GET https://download.virtualbox.org/virtualbox/$stable_vbox/SHA256SUMS &>1 | awk '{print $2}' | grep $stable_vbox.vbox-extpack | sed 's/*//g')
    echo $ext_pack
    echo $anno
    mkdir -p /opt/src/vbox/$stable_vbox
    cd /opt/src/vbox/$stable_vbox
    wget -c http://download.virtualbox.org/virtualbox/$stable_vbox/$anno -O $anno
    wget -c http://download.virtualbox.org/virtualbox/$stable_vbox/$ext_pack -O $ext_pack
    chmod +x /opt/src/vbox/$ext_pck
    chmod +x /opt/src/vbox/$anno
fi