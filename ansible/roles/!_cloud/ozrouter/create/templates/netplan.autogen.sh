#!/bin/sh
# NETPLAN INIT SH
###########################
DATE=`date '+%H:%M:%S'`
touch /var/log/oz-netplan-local-cloud-init-$DATE.log
echo "CURRENT DATE: $DATE"
###########################

VPN_SUBNET_PUBLIC_INTERFACE=$1
VPN_SUBNET_PUBLIC_ROUTER=$2
VPN_PUBLIC_EDGE_ROUTER=$3
VPN_SUBNET_PRIVATE_INTERFACE=$4
VPN_SUBNET_PRIVATE_ROUTER=$5
CLOUD_DNS_SERVICE_GEO=$6

echo "VPN_SUBNET_PUBLIC_INTERFACE: $VPN_SUBNET_PUBLIC_INTERFACE" > /var/log/oz-netplan-local-cloud-init-$DATE.log
echo "VPN_SUBNET_PUBLIC_ROUTER: $VPN_SUBNET_PUBLIC_ROUTER" > /var/log/oz-netplan-local-cloud-init-$DATE.log
echo "VPN_PUBLIC_EDGE_ROUTER: $VPN_PUBLIC_EDGE_ROUTER" > /var/log/oz-netplan-local-cloud-init-$DATE.log
echo "VPN_SUBNET_PRIVATE_INTERFACE: $VPN_SUBNET_PRIVATE_INTERFACE" > /var/log/oz-netplan-local-cloud-init-$DATE.log
echo "CLOUD_DNS_SERVICE_GEO: $CLOUD_DNS_SERVICE_GEO" > /var/log/oz-netplan-local-cloud-init-$DATE.log
echo "VPN_SUBNET_PRIVATE_ROUTER: $VPN_SUBNET_PRIVATE_ROUTER" > /var/log/oz-netplan-local-cloud-init-$DATE.log


echo "REPLACE NETPLAN SERVER ENTITY MAIN CONFIG" >> /var/log/oz-netplan-local-cloud-init-$DATE.log

rm -rf /tmp/11-ozrouter-autogen-conf.yml
tee -a /tmp/11-ozrouter-autogen-conf.yml > /dev/null <<EOT
network:
  version: 2
  renderer: networkd
  ethernets:
    $VPN_SUBNET_PUBLIC_INTERFACE:
      dhcp4: no
      dhcp6: no
      addresses:
      - $VPN_SUBNET_PUBLIC_ROUTER/24
      gateway4: "$VPN_PUBLIC_EDGE_ROUTER"
      nameservers:
        addresses:
          - 8.8.8.8
    $VPN_SUBNET_PRIVATE_INTERFACE:
      dhcp4: no
      dhcp6: no
      addresses:
      - $VPN_SUBNET_PRIVATE_ROUTER/24
      nameservers:
        addresses:
          - 8.8.8.8
EOT

cp /tmp/11-ozrouter-autogen-conf.yml /etc/netplan/11-ozrouter-autogen-conf.yaml

echo "RELOAD SYSTEMCTL DAEMONS" >> /var/log/oz-netplan-local-cloud-init-$DATE.log
systemctl daemon-reload
echo "APPLY NETPLAN" >> /var/log/oz-netplan-local-cloud-init-$DATE.log
netplan apply