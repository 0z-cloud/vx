## Consul INFO Role
This section about work and monitoring works Consul Server's Agent's & Consul Client Agent's

### What the file peers.INFO ?

I. File needed if you broke the cluster, please, just read consul manual section:

``` https://www.consul.io/docs/guides/outage.html ```

II. For generate the peers.info just like your playbook with extra-vars:

``` ansible-playbook consul.yml -extra-vars="peers_recovery=true" ```