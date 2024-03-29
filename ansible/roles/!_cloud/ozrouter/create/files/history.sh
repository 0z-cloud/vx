#!/bin/sh

DATE=`date '+%H:%M:%S'`

touch /tmp/$DATE.log

echo "Data: $DATE"

INSTANCE=$1
STATUS=$2

SUBNET_VPN=$3
SUBNET_PRV=$4
NAME_SERVER=$5
SERVER_PORT=$6

echo "Instance: $INSTANCE"
echo "Status: $STATUS"
echo "Subnet_VPN: $SUBNET_VPN"
echo "Subnet_PRV: $SUBNET_PRV"

systemctl stop pritunl

#SUBNET_VPN=`/opt/ipnew.py`/24
#SUBNET_PRV=`/opt/ipnew.py`/24

echo "Subnet_VPN: $SUBNET_VPN"
echo "Subnet_PRV: $SUBNET_PRV"


DEFAULT_AWAIT_PORT_TIMEOUT="12"
MONGO_DEFAULT_PORT="27017"
PRITUNL_WEB_PORT="11443"

rm -rf /tmp/vpn.json
tee -a /tmp/vpn.json > /dev/null <<EOT
{"_id":{"\$oid":"5ef27ddeace2398addb12a7f"},"allowed_devices":null,"auth_box_private_key":"j8XyVx9LfZIYI7o7upLhgt56AhYFGe7MMy4P4b8RwUw=","auth_box_public_key":"z5mNbZIvjs9tu21boPeQ7KzTIzR9+5hlXL+UBnrwlHw=","auth_private_key":"-----BEGIN RSA PRIVATE KEY-----\nMIIJKAIBAAKCAgEA0GJSx6W7MLwjRhvDcWnZ5IET1ibZVT33+gIoy342DVtW9OVx\ny4TVXb9ZKQosftkIoMHpxJXePoCjQE+V32PruvF2hcomY5yYozo+wzjkMnWbb4Z3\nn/TTQZufBJmP0x3Niju0dGYduylwtaDCLwdZ9RfL7PirunbosHpGlkIyI5UCDnH0\nDLS8/lC4DumBXtJvhy3lXxxVgBTXaNpzoSmn3TVOeEK6JxIV6hrOdwbR/7aXvyyt\nS9mTxjWpRG/p+VfU5uhiYkPSeHRksZoJCH/GVEKP0J5yNy7hRMHOpwCLqRKw/k0y\nWF5tjmPuyn3L1zmoHWKz+4BCRzZg0flhoZc4rXubDMn3TejJFBKTJspFwaDLy3Gk\nXofFOO0JqC+ud5JEw735sRtp+KAJ7C8jXbfx/4YKJykVKAYb22KQ94ELX69K2jfL\nQBRA35IAnsI1o0iDrtU4C51nsC6zKJGjXGEcURnvrzknXXwJcd+3iP9/wUAT7Lup\nYMStgEDTKq+eMGcTX63fzBqEzS7oCCksV5AHHwIJq23CaO+1ChPlmJZLCI52daap\nLMqccrlcS5uLtpQdd8NI9vuPnKxoXc6juJQhol2QGChJo2GB/N54O7diFXjrd5oT\nq/4UjSL56r/x5ZQ9WVnENTFUzr+jdricKp8Dczp/VYsZPpz+s6Pgdi2hJmsCAwEA\nAQKCAgB/8t9BFtHJKru94G4wxP21AExdwZzQaixIperGh8hIizzpQbiNbhJUbZkh\nSc3oVPqnOml++0ZqujGC21r6vy+OqZRMscLAhvZxwuGmnNgA45V89OOeo4TTU+pf\nuKpGxpXduqsijVDUCq3Z18tjdPAXPXVJG6bV5w0YzvtoZ1zB3ExW8kEXTCJ/RLC+\n90EoJ62zIssjixI0gpeBGiDFY/5eJMz5qn8CXmh2Rd9f1iA7ErI6AASn/gBuQ6Sb\nENxo7TUcUrOWAm7I5y6snhfN0CbGtdf4EFGw8GgA/78Ta5JVTdS/UEcJW3GJbHLC\nglsW26AN6vz3/9iyQQFR6/22alOxldsdnk25b8kTdLLRhFKO0m8sx7FFkyWMyKoA\nHbcVKeZQ1qJeJ09WSBfApOmc+DST/6aReF1wotD8pjl8xGzG2jN5BjO5ukpNlFCw\nhUnkrJotTmAInUPS32zOXjJi1HmwjXvCFKHSmJ3yQNyudWaZnjRg8IthDN0rH7jf\n7sDUaekmKm4xftGxJaoXFCYRNAZXpRjxiE5TS2SFVhwRJTGV3KkHwLmDD27EoSsb\nfvZ2aBXJ10b53sK3TFzyoFHNfyf41JJufg3AMTi5l0Z6MezvisGu4l7DpUfPZw53\nqQ+NGSa43geriN0RiM3fttR8fmkfXVDYFab6ihMEj5MjiYlZgQKCAQEA7o4WiHfB\nFQcRn3gUVxH8fYq1DkfHQdFgB7xUIZpZZWyqKUsrnL+79HLkE1WY7hpMvlgDPFF7\nI0vOsYi01Qb26vbyB0CcJlSbKsLGOlJHM7xwzaI8kOD6odpnC9xUKz4c0Hqs3wiV\nKnznucYCUA/VmymYLVBau/bDib6pof5ZudwFoYB85CKbbEpA7q8jlE4aj3hxGHbW\n8Uy4yInp0N3mBXZtB+hDFsx2cEEtbPDcP0zOToISla4RA/zT1fY+IJcdrm0ZhwLB\nV80rkadaCuUpZSUlB56nrDl/eGwBvYYS/dpyK4SvnU4No277ywY/0ewSP4NKm0m1\nuhbHPnIE1ii81wKCAQEA359qIkdQLTbx30SQAzVG4yPG8uWd3IelTMdRXADcg80J\n0qanOi1BTijxIB2PPFh8Zc8kpOh3Pc1N/o6AXpi/CjD5Bmvmgx7OcDXGEaUAU+Ua\n9a/slcLDk5EcP6POc8cq+n34K630OaADlyPQeCIo5AmVxYp7pmWPcE+lV+z5haK9\nKxW94FnzHO8G26O/RMJo1zuuxavkE22bIDDIhA9rHz+FqDZAeMNWeKSoCt1JfpKo\n90P73/K1mdZSg31ym4JtF0wZF5R1IUPDQM3rmH3uRIYiTFbZVsU9nb4Qjr4hhULt\nqjlahJn6LTUjdg7saU1XXwrEjx3pRiqAlbt6N+98jQKCAQBTJDBURbCEnJ8WvioQ\nopMmSgaKQJgAp3FZoNiNkZbgk3vGwo0jp2thaf11g5q2OXJP0KroBdnt1kjmdSfZ\nKwE5qPF3d5w0e75Mq++cefqY3G9QK+AB+nc/m7fYWWT4YUB3pJnFbd9XHItCovFB\naBNhbaC9AkltQzapNks2y0gIT9eijv54IFuc5VA2H9I9qO7229pG1XxaQwwP0Iku\nI3g8pSag3+Ep+/63Zu/nDRcl9KXelNTXWABULHTEGHtUrnZIyXthI6Ow7y/lJrdq\nHq5LsyNxwWjczHlRxgrhO+44jT7HTgpKv95e/JpDCx2JE0bU3fRNpOXyQmgUqnZn\nEXGnAoIBADG9Mo03UXUNIJVpmaKtCfxhq9HBEvDHVxQRzV3qbyH9zC6HlPCSulDZ\nOHDNQlvIzrqSbXMkpckgTjXNmm3wCaYJqIouG9KUWpSI0WqBSeZfMjTtkXDqJjg/\ncYoSNEx6Q2v98uI8SfM7TTEj7S2bY379RsvudnxXYKU5gexhsEpyHSNlLZumRjXs\nUJkv/c4cc9dT1hbvmcZcfcGWODNvfoMvzNnSX1q9EBG7hgkMmVlG48BD5dU1FgGG\ns0m98Gz4gK1K5tXg1oC0osxaQQnlEMc7EovqUWNEceURLnuhfLE4ZsaTBTgzS3sc\ns6uBvEHbyxA/w+KVY5qQv5MOZSvl380CggEBAI2Hu8mHoMT/Wxu8vhcVbGaAurQh\n7Sg3sWjj6mTLGWqoc4Oz5tXTQVVjhTnJw9llAm1vzvklXmv9kpUrG4Gs2oUlaiwP\n1AEY94bdy9EDoPB9vFbgVqUDuEq471ojfAYxp7Sr9fU/LIt3rALRN/HUiYTRFZqh\nkqlmtNENlo9DaQrLeFv2DIzqZPfT/i4n1IBcIqo2pRN3B1gohaW1Ouc+XOFo5Sir\npc7WgMMAIaT3UsY0iQu2rY5Xt5MT1PYToGYzW91yUqNtmUs4a+beR9A8sJgWwmIm\nBmQuSYQAijF45gwtoTe7LGuX1042yQqxW3/mtVnkdKkoF3e4yCodS+KLOg8=\n-----END RSA PRIVATE KEY-----\n","auth_public_key":"-----BEGIN RSA PUBLIC KEY-----\nMIICCgKCAgEA0GJSx6W7MLwjRhvDcWnZ5IET1ibZVT33+gIoy342DVtW9OVxy4TV\nXb9ZKQosftkIoMHpxJXePoCjQE+V32PruvF2hcomY5yYozo+wzjkMnWbb4Z3n/TT\nQZufBJmP0x3Niju0dGYduylwtaDCLwdZ9RfL7PirunbosHpGlkIyI5UCDnH0DLS8\n/lC4DumBXtJvhy3lXxxVgBTXaNpzoSmn3TVOeEK6JxIV6hrOdwbR/7aXvyytS9mT\nxjWpRG/p+VfU5uhiYkPSeHRksZoJCH/GVEKP0J5yNy7hRMHOpwCLqRKw/k0yWF5t\njmPuyn3L1zmoHWKz+4BCRzZg0flhoZc4rXubDMn3TejJFBKTJspFwaDLy3GkXofF\nOO0JqC+ud5JEw735sRtp+KAJ7C8jXbfx/4YKJykVKAYb22KQ94ELX69K2jfLQBRA\n35IAnsI1o0iDrtU4C51nsC6zKJGjXGEcURnvrzknXXwJcd+3iP9/wUAT7LupYMSt\ngEDTKq+eMGcTX63fzBqEzS7oCCksV5AHHwIJq23CaO+1ChPlmJZLCI52daapLMqc\ncrlcS5uLtpQdd8NI9vuPnKxoXc6juJQhol2QGChJo2GB/N54O7diFXjrd5oTq/4U\njSL56r/x5ZQ9WVnENTFUzr+jdricKp8Dczp/VYsZPpz+s6Pgdi2hJmsCAwEAAQ==\n-----END RSA PUBLIC KEY-----\n","availability_group":"default","bind_address":"","block_outside_dns":false,"ca_certificate":"-----BEGIN CERTIFICATE-----\nMIIFcTCCA1mgAwIBAgIIWXD1mDy/vXgwDQYJKoZIhvcNAQELBQAwRjEhMB8GA1UE\nCgwYNWVlZDBiMzBlOTQ1M2NlOTBhM2M0ZGQ2MSEwHwYDVQQDDBg1ZWVkMGIzMGU5\nNDUzY2U5MGEzYzRkZGEwHhcNMjAwNjE5MTkwMDAwWhcNNDAwNjE0MTkwMDAwWjBG\nMSEwHwYDVQQKDBg1ZWVkMGIzMGU5NDUzY2U5MGEzYzRkZDYxITAfBgNVBAMMGDVl\nZWQwYjMwZTk0NTNjZTkwYTNjNGRkYTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCC\nAgoCggIBAOnLggSB5O4SdCuq6QbOX1z6IBsUbYoAxMbKKaShugTWg8WBEHtZ4ky5\n36B4YI0Bx4oAIcgQ/h595CpbWY5rP3Vuk72O5GkKLyC3hgptiULjsgX0L9WM+f+A\n7sbQSHJ1TVTIZmlDDpmuI24aYz80RXL6djC0pM3NIG3Ds7N8XGA3lmkNTQvh1q4a\nbW8AI8uxH6orhuYa38cgf8WC4B1qO240lK+DpWzH869p973/qWuNUGihLqVKq0k8\n7jIs2QzuJsjTqjkFlu+ZX0i+A/fVfzBRaaW5MvziL1f8XkFGe/WjbekTRQO9zha2\nBbZLAqjVoUS4uHkEWWqJNYRyVa4wnBnymcWfab4zlJV3BxO59KCDfrK14uodmlpK\nubijThLBvFF5AKMycMT8OpD1bPRPrA9sV3rwEsYJ+rckyBTQh36A0Yemp4ayWQJ2\nWqSPTuEFDtD5KM14TMdejzra4MQ+uT9HN6cBYfivL4aeWuZ2PyJ6m3CeXytW1cdW\nBg/t5PYmA/mIYuaKYSpPM5yqF0nUrH3+vewWNY2I4+Msk2+z1sLHEqhsU0YovQns\nyosw30a4UIBHyoDJKiQWT0FOd4bApP7MjZjnEr/NaBatWl2ty5a/EoL54y0XSb6n\n21ZWyq7/5aLtJUg9DELKNqPXnCQdQ5opYF/CzPcpGKCVPHTOQi4HAgMBAAGjYzBh\nMA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBSm6FAa\nWm+KHuXGSOZ94N5bY2Yf5TAfBgNVHSMEGDAWgBSm6FAaWm+KHuXGSOZ94N5bY2Yf\n5TANBgkqhkiG9w0BAQsFAAOCAgEAe5kLqND/MjmX+zfxRBcWOfm3PChn698VJd/x\nlrh9vaJoTohjL7PHhq3ASQ9oDgRjeiNlb+qbDahJHdD8a5gp+7mFjYvsgy1EZock\nCi242KE2elNiq4pMFg3efmbwbTjbK0hAbPHI9KUDzFtKpBxtJaz7od+q6FEyLo74\noWMZdMOzaKJEROPbfDe3OiiUloK/LncaoKLW+sSRnDJNeulU4T1iuOcKONMC204e\ncgaQ9wCYa8TMripsWZr5VUWvF+S4pbK7sJrup485Gi7tuW1S7e76jwNcIvwjOVZY\ny9abiI/iarUgP+xTDFvha2rN7+OB3BrStj/xd7R7K3NVvy/SJuUXzmXWJdx5ze/+\nvF1T5UZL4N8PeJ0q+5Cg8lDRY9GGDiqGccwyyDBc9fQwdvzZULYGe9xchSCDhkwq\nUn93+jOtM5q3vD/XqZriU/keuOjYus7SU2BhvBM6ljZM2DYDLhvS/nVjM/Mk3E0B\nZHEtimKW7kb0u7r9o+rXE5wbeBiAjLX7sHe86ediWfuNfbOKzc0xd8nq5D77jIw9\nsKB3aZHoec2L+0vOeIsh2vkTklllpnqa/0nwKolZpQlp1XCZl5XxpIU/lBemH79r\nSK5ce5Z25VCy9u5SQhe2qtZk84DnzvOQuRI2eU0fM/FLFmKIFoIS2/oUu6Tj+gEC\nectZS8c=\n-----END CERTIFICATE-----","cipher":"aes128","debug":false,"dh_param_bits":2048,"dh_params":"-----BEGIN DH PARAMETERS-----\nMIIBCAKCAQEA22GoW7xraAF11/8ALdQTP2oi+cXFFQoOA/hJxCOKvbb612XE+xWE\nP+F+/W24XvU2ya6HIOWgvSM7aMHYGPTRnyENNcU0otBj92HbKxZel6xlvoRShlos\nCeesdXvrurwUzmbqAMwtyRN2FpL8jDjyd6ap5FkduOQegPcPXfSlHWPN6+8fCrrQ\n5wh9fGPmcY9A4/YC/LThkBrjqg3IyuQQa6hElhJks9nmuk2TZxA19jYBV96hkh4+\nJGtaVVYest8Fpv7vKcxUlJz1vASQSpSQqU+KrQDB3l+4ksITuAyme5/utpRrE4UT\ntTRuVre7Mr5GkGyKmuRdWo37as/PxtTokwIBAg==\n-----END DH PARAMETERS-----","dns_mapping":false,"dns_servers":["8.8.8.8"],"groups":[],"hash":"sha1","hosts":["e3c3cd0d72524b6080562efe45b8b7c5"],"inactive_timeout":null,"instances":[],"instances_count":0,"inter_client":true,"ipv6":false,"ipv6_firewall":true,"jumbo_frames":false,"link_ping_interval":1,"link_ping_timeout":5,"links":[],"lzo_compression":false,"max_clients":2000,"max_devices":0,"mss_fix":null,"multi_device":false,"name":"$NAME_SERVER","network":"$SUBNET_VPN","network_end":"","network_mode":"tunnel","network_start":"","network_wg":null,"organizations":[{"\$oid":"5eed0b30e9453ce90a3c4dd6"}],"otp_auth":false,"ping_interval":10,"ping_timeout":60,"ping_timeout_wg":360,"port":"$SERVER_PORT","port_wg":null,"pre_connect_msg":null,"primary_organization":{"\$oid":"5eed0b30e9453ce90a3c4dd6"},"primary_user":{"\$oid":"5eed0b30e9453ce90a3c4de8"},"protocol":"tcp","replica_count":1,"restrict_routes":true,"routes":[],"search_domain":null,"session_timeout":null,"start_timestamp":{"\$date":"2020-06-23T22:10:52.498Z"},"status":"online","tls_auth":true,"tls_auth_key":"#\n# 2048 bit OpenVPN static key\n#\n-----BEGIN OpenVPN Static key V1-----\n7874b5701842edd84e5c4499b67550ed\nc8d23f0decfa4013bbfd2e6e6afe290b\n81ea8578b373c60a1311f22d7de4b8ba\nf28357bd59349e4475f2a54ea82fbcff\nb63de195fed9f0f59eeefefe96b9a624\n005bed9500b6e17feb3368954eb8bb79\n34d70fd378bb34e40580669247980e11\n6c4c0540172a8741569618f19a63042a\n617b1d8f6a099f1ed851548af87017cf\n116ad1d8ce4a33ca4176f8e2078f7fd2\na8a716a3cdb6dba375ff672b1bab626a\n31ec75276986b0bfa799713287e83b27\nd139c453d338059c4246102901a30021\na1dd8d519ba8f1dc1f670a5ff710e02b\n1bd164a150fba6d558eeb69418e4e20c\nf96a15d766541585be17109863ec8cea\n-----END OpenVPN Static key V1-----","vxlan":true,"wg":false,"pool_cursor":null}
EOT




cat /tmp/vpn.json
#cat /tmp/vpn.json | tr -d '\n' > /tmp/vpnresult.json


mongoimport --drop --host=localhost --port=27017  --collection=servers --db=pritunl --file=/tmp/vpn.json

# rs_string=''

# rs_runstring=$(echo mongo $RUN_NODE --eval \"$rs_string\")

#   echo "rs_runstring: $rs_runstring"

#    eval $rs_runstring


systemctl restart pritunl

#https://37.18.116.46:11443/key/J2mr1C7myl8gA4Cvx6xik1YNiEDu5Fi6.tar
