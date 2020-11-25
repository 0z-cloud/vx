# ElasticSearch Cluster on Swarm Overlay Network

### General

- > Created containers placed to both networks, internal (overlay - it 'dmz') and public
- > REST HTTP ElasticSearch service availible in both networks

### info about role templates

../roles/es-service/templates/elasticsearch.yml.j2

- > Its initial config, when you can see 'magic' string
- > Magic string replaced every time when container restart by custom docker-entrypoint.sh

../roles/es-service/templates/docker-entrypoint.sh

- > One change from original - added support auto place current docker public IP in config.
- > This settings availible only if docker on your host have a enabled API function.
