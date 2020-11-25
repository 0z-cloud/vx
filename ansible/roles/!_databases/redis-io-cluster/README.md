## Redis Swarm Cluster with Docker



### For Deploy Redis Swarm Cluster you need run as example:

``` ansible-playbook -i inventories/{{ your_env }} redis-io-cluster.yml --ask-vault-pass --extra-vars "network_name={{ your_network_name }}" ```

- > This role deploy Master-Slave's Replication when in Your inventories Group vars present the 

``` redis_io_cluster_enabled: "false" ```

- > This role deploy Master-Master's Cluster with one Slave per Master when in Your inventories Group vars present the 

``` redis_io_cluster_enabled: "true" ```