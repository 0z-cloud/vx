# oZrouter

## ZONE EXAMPLE LAYOUT - 0001. DHCP: SETUP ZONE

* Example connect flow:

              ``` 
           /---------------\ ------------\ ------------\ ------------\ ------------\ ------------\ ------------\ ------------\ ------------\
           | 0010.                                                                                                                         |
           |---------------\ ------------\ ------------\ ------------\ ------------\ ------------\ ------------\ ------------\ ------------\
           |                 ____________                          ____________                                                            |
           |                /------------\   <<----------------   /------------\                                                           |
           |               |              |    << ZONE INFO [1]  |              |                                                          |
           | DEFAULT VPN   | PRIME router |  <<----------------  |  NEW vOZvpc  | 192.168.228.0/24                                         |
           |               |              |                      |              |                                                          |
           |                \------------/   [2] CALLBACK VPN >>  \------------/                                                           |
           |                     \\=================================->>>//                                                                 |
           |--------------\ ------------\ ------------\ ------------\ ------------\ ------------\ ------------\ ------------\ ------------\|
           | 0011. WAIT FOR PRIMARY ACCESS OZ.local.cloud.eve.vortice.eden                                                                           |
           |--------------\ ------------\ ------------\ ------------\ ------------\ ------------\ ------------\ ------------\ ------------\|
           | 0100. API: CREATE ITSELF BY API USER, ORG, SERVER, ETC                                                                        |
           | 0101. GET CONFIGS: CREATE SITE TO SITE                                                                                        |
           | 0110: NAT OPEN PORT                                                                                                           |
           |                      //<<<-============[IPsec]===============\\                                                               |
           |                 ____________                          ____________                                                            |
           |                /------------\                        /------------\                                                           |
           |               |              |                      |              |                                                          |
           |               | PRIME router | :11443 <<-->> :11443 |  NEW vOZvpc  | 192.168.228.0/24                                         |
           |               |              | :19247 <<-->> :19247 |              |                                                          |
           |                \------------/                        \------------/                                                           |
           |                      \\================[IPsec]==========->>>//                                                                |
           \--------------\ ------------\ ------------\ ------------\ ------------\ ------------\ ------------\ ------------\ ------------\|
              ```

## CALL VM TEMPLATE STEPS -

       1. Update netplan network Configuration: 

              params: 

                     VPN_SUBNET_PUBLIC_INTERFACE
                     VPN_SUBNET_PUBLIC_ROUTER
                     VPN_PUBLIC_EDGE_ROUTER
                     VPN_SUBNET_PRIVATE_INTERFACE
                     VPN_SUBNET_PRIVATE_ROUTER

              command:

                     /anycloud/netplan.sh $VPN_SUBNET_PUBLIC_INTERFACE $VPN_SUBNET_PUBLIC_ROUTER $VPN_PUBLIC_EDGE_ROUTER $VPN_SUBNET_PRIVATE_INTERFACE $VPN_SUBNET_PRIVATE_ROUTER

       2. Setup dhcpd service for configuring the LAN hosts:

              params: 

                     VPN_SUBNET_PRIVATE
                     VPN_PRIVATE_SUBNET_NETMASK
                     PRIMARY_DOMAIN
                     CLOUD_DNS_SERVICE_GEO
                     VPN_SUBNET_PRIVATE_ROUTER
                     VPN_SUBNET_PRIVATE_START
                     VPN_SUBNET_PRIVATE_END
                     OZ_DHCP_SERVER_INTERFACE

              command:

                     /anycloud/dhcp.sh $VPN_SUBNET_PRIVATE $VPN_PRIVATE_SUBNET_NETMASK $PRIMARY_DOMAIN $CLOUD_DNS_SERVICE_GEO $VPN_SUBNET_PRIVATE_ROUTER $VPN_SUBNET_PRIVATE_START $VPN_SUBNET_PRIVATE_END $OZ_DHCP_SERVER_INTERFACE

       3. Setup Internal Vpn Server and Notify with Exec call-back VPN connect to/from bootstraped zone:

              params: 

                     VPN_SERVER_NAME
                     SUBNET_VPN
                     SUBNET_PRIVATE
                     VPN_SERVER_WEB_PORT
                     VPN_SERVER_VPN_PORT

              command:

                     /anycloud/vpn.sh $VPN_SERVER_NAME $SUBNET_VPN $SUBNET_PRIVATE $VPN_SERVER_WEB_PORT $VPN_SERVER_VPN_PORT

