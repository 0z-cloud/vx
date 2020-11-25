#!/bin/bash

eth0_mac_address="{{ response_awaiter_router_mac_eth0 }}"
eth1_mac_address="{{ response_awaiter_router_mac_eth1 }}"

rm -rf /tmp/70-persistent-net.rules
tee -a /tmp/70-persistent-net.rules > /dev/null <<EOT
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="$eth0_mac_address", NAME="eth0"
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="$eth1_mac_address", NAME="eth1"
EOT

rm -rf /etc/udev/rules.d/70-persistent-net.rules
cp /tmp/70-persistent-net.rules /etc/udev/rules.d/70-persistent-net.rules

udevadm control --reload-rules && udevadm trigger

anycloud_result_direct_network_name="{{ anycloud_result_direct_network_name }}"
anycloud_result_routed_network_name="{{ anycloud_result_routed_network_name }}"
anycloud_result_vpnmesh_network_name="{{ anycloud_result_vpnmesh_network_name }}"
anycloud_result_isolated_network_name="{{ anycloud_result_isolated_network_name }}"

anycloud_result_direct_network_router_without_prefix="{{ anycloud_result_direct_network_router_without_prefix }}"
anycloud_result_routed_network_router_without_prefix="{{ anycloud_result_routed_network_router_without_prefix }}"
anycloud_result_vpnmesh_network_router_without_prefix="{{ anycloud_result_vpnmesh_network_router_without_prefix }}"
anycloud_result_isolated_network_router_without_prefix="{{ anycloud_result_isolated_network_router_without_prefix }}"

anycloud_result_direct_network_router="{{ anycloud_result_direct_network_router }}"
anycloud_result_routed_network_router="{{ anycloud_result_routed_network_router }}"
anycloud_result_vpnmesh_network_router="{{ anycloud_result_vpnmesh_network_router }}"
anycloud_result_isolated_network_router="{{ anycloud_result_isolated_network_router }}"

anycloud_result_direct_network_itself_without_prefix ="{{ anycloud_result_direct_network_itself_without_prefix }}"
anycloud_result_routed_network_itself_without_prefix ="{{ anycloud_result_routed_network_itself_without_prefix }}"
anycloud_result_vpnmesh_network_itself_without_prefix ="{{ anycloud_result_vpnmesh_network_itself_without_prefix }}"
anycloud_result_isolated_network_itself_without_prefix ="{{ anycloud_result_isolated_network_itself_without_prefix }}"

anycloud_result_direct_network_itself="{{ anycloud_result_direct_network_itself }}"
anycloud_result_routed_network_itself="{{ anycloud_result_routed_network_itself }}"
anycloud_result_vpnmesh_network_itself="{{ anycloud_result_vpnmesh_network_itself }}"
anycloud_result_isolated_network_itself="{{ anycloud_result_isolated_network_itself }}"

ROUTED_LOCAL_NETWORK_ROUTER="{{ anycloud_result_routed_network_router }}"
ROUTED_LOCAL_NETWORK_SUBNET_CUT="{{ anycloud_result_routed_network_cut }}"
ROUTED_LOCAL_NETWORK_SUBNET="{{ anycloud_result_routed_network_cut }}0"
OZ_ITSELF_IP="{{ anycloud_result_routed_network_cut }}2"
ROUTED_LOCAL_NETWORK_ROUTER_WITHOUT_PREFIX="{{ anycloud_result_routed_network_cut }}1"
ROUTED_LOCAL_NETWORK="{{ anycloud_result_routed_network_name }}"
ROUTED_LOCAL_NETWORK_DHCP_START="{{ anycloud_result_routed_network_dhcp_start }}"
ROUTED_LOCAL_NETWORK_DHCP_END="{{ anycloud_result_routed_network_dhcp_end }}"
ROUTED_LOCAL_NETWORK_STATIC_ZONE_START="{{ anycloud_result_routed_network_static_pool_start }}"
ROUTED_LOCAL_NETWORK_STATIC_ZONE_END="{{ anycloud_result_routed_network_static_pool_end }}"

oz_router_subnet_anycloud_vpn_port="{{ oz_router_subnet_anycloud_vpn_port }}"
oz_router_subnet_anycloud_web_port="{{ oz_router_subnet_anycloud_web_port }}"
anycloud_result_edge_router="{{ anycloud_result_edge_router }}"
edge_whole_fetched_ips="{{ public_ips_from_edge }}"
edge_whole_fetched_ips_primary="{{ edge_whole_fetched_ips }}"
edge_whole_fetched_ips_list="{{ edge_whole_fetched_ips }}"
ISOLATED_CONNECT="{{ anycloud_result_isolated_network_name }}"
ISOLATED_CONNECT_SUBNET_CUT="{{ anycloud_result_isolated_network_cut }}"
ISOLATED_CONNECT_ROUTER="{{ anycloud_result_isolated_network_router }}"
OZ_ISOLATED_ITSELF="{{ anycloud_result_isolated_network_cut }}2"
ISOLATED_CONNECT_ROUTER_WITHOUT_PREFIX="{{ anycloud_result_isolated_network_cut }}1"

VPN_MESH_INTERCONNECT="{{ anycloud_result_vpnmesh_network_name }}"
VPN_MESH_INTERCONNECT_SUBNET_CUT="{{ anycloud_result_vpnmesh_network_cut }}"
VPN_MESH_INTERCONNECT_ROUTER="{{ anycloud_result_vpnmesh_network_router }}"
VPN_MESH_INTERCONNECT_DHCP_START="{{ anycloud_result_vpnmesh_network_dhcp_start }}"
VPN_MESH_INTERCONNECT_DHCP_END="{{ anycloud_result_vpnmesh_network_dhcp_end }}"
VPN_MESH_INTERCONNECT_STATIC_ZONE_START="{{ anycloud_result_vpnmesh_network_static_pool_start }}"
VPN_MESH_INTERCONNECT_STATIC_ZONE_END="{{ anycloud_result_vpnmesh_network_static_pool_end }}"
VPN_SERVER_PUBLIC_IP="{{ VPN_SERVER_PUBLIC_IP }}"
VPN_SERVER_WEB_PORT="{{ VPN_SERVER_WEB_PORT }}"
PRIMARY_MASTER_PRIVATE_BEHIND_NAT="{% for host in groups['oz-primary-master-vpn-mesh-endpoint-host'] %}{{ hostvars[host].ansible_host }}{% endfor %}"
PRIMARY_MASTER_PUBLIC_NAT="{% for host in groups['oz-primary-master-vpn-mesh-endpoint-host'] %}{{ hostvars[host].public_nat_ip }}{% endfor %}"

# SHOW PASSED PARAMS TO VMWARE LOG
echo "{{ INSTANCE_NAME }} {{ INSTANCE_TARGET_STATE }} {{ INSTANCE_VPN_SUBNET }} {{ INSTANCE_PRIVATE_SUBNET }} {{ INSTANCE_VPN_PRIVATE_PORT }}" >> /var/log/startup.log

# APPLY NETWORK CONFIGURATION
#/anycloud/netplan.sh "{{ VPN_SUBNET_PUBLIC_INTERFACE }}" "{{ VPN_SUBNET_PUBLIC_ROUTER }}" "{{ VPN_PUBLIC_EDGE_ROUTER }}" "{{ VPN_SUBNET_PRIVATE_INTERFACE }}" "{{ VPN_SUBNET_PRIVATE_ROUTER }}"
/anycloud/netplan.sh "{{ VPN_SUBNET_PUBLIC_INTERFACE }}" "{{ anycloud_result_routed_network_cut }}2" "{{ anycloud_result_routed_network_cut }}1" "{{ VPN_SUBNET_PRIVATE_INTERFACE }}" "{{ anycloud_result_isolated_network_cut }}2"

# APPLY DHCP CONFIGURATION
/anycloud/dhcp.sh "{{ anycloud_result_routed_network_cut }}0" "{{ VPN_PRIVATE_SUBNET_NETMASK }}" "{{ PRIMARY_DOMAIN }}" "{{ CLOUD_DNS_SERVICE_GEO }}" "{{ anycloud_result_routed_network_cut }}2" "{{ anycloud_result_routed_network_static_pool_start }}" "{{ anycloud_result_routed_network_static_pool_end }}" "{{ OZ_DHCP_SERVER_INTERFACE }}"

# APPLY VPN CONFIGURATION
/anycloud/vpn.sh "{{ VPN_SERVER_PUBLIC_IP }}" "{{ VPN_SERVER_NAME }}" "{{ anycloud_result_vpnmesh_network_cut }}0/24" "{{ anycloud_result_routed_network_cut }}0/24" "{{ oz_router_subnet_anycloud_web_port }}" "{{ oz_router_subnet_anycloud_vpn_port }}"

rm -rf /tmp/dhcp.conf
tee -a /tmp/dhcp.conf > /dev/null <<EOT
default-lease-time 7200;
max-lease-time 43200;
authoritative;
 
# specify network address and subnet-mask
subnet {{ anycloud_result_routed_network_cut }}0 netmask {{ VPN_PRIVATE_SUBNET_NETMASK }} {
    # specify dns servers and client domain
    option domain-name "{{ PRIMARY_DOMAIN }}";
    option domain-name-servers {{ CLOUD_DNS_SERVICE_GEO }};
    # specify listen interface
    interface eth0;
    # specify default gateway
    option routers {{ anycloud_result_routed_network_cut }}2;
    # specify subnet-mask
    option subnet-mask {{ VPN_PRIVATE_SUBNET_NETMASK }};
    option broadcast-address {{ anycloud_result_routed_network_cut }}255;
    # specify the range of leased IP address
    range {{ anycloud_result_routed_network_static_pool_start }} {{ anycloud_result_routed_network_static_pool_end }};
}

subnet {{ anycloud_result_isolated_network_cut }}0 netmask {{ VPN_PRIVATE_SUBNET_NETMASK }} {
    # specify dns servers and client domain
    option domain-name "{{ PRIMARY_DOMAIN }}";
    option domain-name-servers {{ CLOUD_DNS_SERVICE_GEO }};
    # specify listen interface
    interface eth1;
    # specify default gateway
    option routers {{ anycloud_result_isolated_network_cut }}2;
    # specify subnet-mask
    option subnet-mask {{ VPN_PRIVATE_SUBNET_NETMASK }};
    option broadcast-address {{ anycloud_result_isolated_network_cut }}255;
    # specify the range of leased IP address
    range {{ anycloud_result_isolated_network_cut }}20 {{ anycloud_result_isolated_network_cut }}100;
}

EOT

cp /tmp/dhcp.conf /etc/dhcp/dhcpd.conf
echo "SET DHCP SERVICE INTERFACE: $OZ_DHCP_SERVER_INTERFACE" >> /var/log/oz-dhcp-local-cloud-init-$DATE.log

rm -rf /tmp/isc.conf
tee -a /tmp/isc.conf > /dev/null <<EOT
INTERFACESv4="$OZ_DHCP_SERVER_INTERFACE"
EOT
rm -rf /etc/default/isc-dhcp-server
cp /tmp/isc.conf /etc/default/isc-dhcp-server

echo "RELOAD SYSTEMCTL DAEMONS" >> /var/log/oz-dhcp-local-cloud-init-$DATE.log
systemctl daemon-reload
echo "RESTART ISC DHCP SERVER" >> /var/log/oz-dhcp-local-cloud-init-$DATE.log
systemctl restart isc-dhcp-server