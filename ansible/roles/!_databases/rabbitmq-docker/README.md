## Rabbit MQ Swarm Cluster with Docker

### For Deploy Rabbit MQ Swarm Cluster you need run as example:

``` ansible-playbook -i inventories/{{ your_env }} rabbitmq-cluster.yml --ask-vault-pass --extra-vars "network_name={{ your_network_name }}" ```
