# To do

1. Must generate correct pg_hba.conf for Postgres
2. Maybe ` docker service ls | grep stage | awk '{print $2}' | xargs -I ID docker service update ID` need in future
3. Need to investigate paused containers
4. DNS service needs to check named/bind9 possible 2 services in systemctl
5. Necessary forvcenter as a requirement - https://github.com/vmware/vsphere-automation-sdk-python
6. Zookeeper
7. Kafka
8. Hadoop
9. Nomad
10. Ceph