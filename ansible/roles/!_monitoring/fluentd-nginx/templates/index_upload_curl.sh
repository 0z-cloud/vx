#!/bin/bash

attempt_counter=0
max_attempts=12
#max_sleep[5]=
max_sleep=5

until $(curl --output /dev/null --silent --head --fail http://elasticsearch:9200); do
    if [ ${attempt_counter} -eq ${max_attempts} ];then
      echo "Max attempts reached, skip step with exit error"
      exit 1
    fi

    printf '...in awaiting elasticsearch...'
    attempt_counter=$(($attempt_counter+1))
    sleep $max_sleep
done

    printf '...elasticsearch reached...'

curl -H 'Content-Type: application/json' -XPUT elasticsearch:9200/_cluster/settings -d '{
    "persistent": { 
      "cluster.routing.allocation.same_shard.host": "true",
      "cluster.routing.allocation.enable": "all",
      "cluster.max_shards_per_node": "10000",
      "cluster.routing.allocation.balance.shard": "10f",
      "cluster.routing.allocation.node_initial_primaries_recoveries": "30",
      "cluster.routing.allocation.balance.index": "10f",
      "cluster.routing.allocation.balance.threshold": "10f",
      "cluster.routing.allocation.total_shards_per_node": "30",
      "cluster.routing.allocation.cluster_concurrent_rebalance": "30",
      "cluster.routing.allocation.node_concurrent_recoveries": "30",
      "cluster.routing.allocation.allow_rebalance": "always"
    },
    "transient": { 
      "cluster.routing.allocation.same_shard.host": "true",
      "cluster.routing.allocation.enable": "all",
      "cluster.max_shards_per_node" : "10000",
      "cluster.routing.allocation.balance.shard": "10f",
      "cluster.routing.allocation.node_initial_primaries_recoveries": "30",
      "cluster.routing.allocation.balance.index": "10f",
      "cluster.routing.allocation.balance.threshold": "10f",
      "cluster.routing.allocation.total_shards_per_node": "30",
      "cluster.routing.allocation.cluster_concurrent_rebalance": "30",
      "cluster.routing.allocation.node_concurrent_recoveries": "30",
      "cluster.routing.allocation.allow_rebalance": "always"
    },
    "order": "0",
    "index_patterns": ["docker-*", "logstash-*", "nginx-*"],
    "settings": {
      "index": {
        "refresh_interval" : "5s",
        "priority" : "1000",
        "number_of_shards": "10",
        "number_of_replicas": "1",
        "auto_expand_replicas": "0-10"
        }
    }
}'

curl -H 'Content-Type: application/json' -XPUT elasticsearch:9200/_template/docker -d '{
    "order" : 1,
    "index_patterns" : [
      "docker-*"
    ],
    "settings" : {
      "index" : {
        "unassigned" : {
          "node_left" : {
            "delayed_timeout" : "10s"
          }
        },
        "number_of_routing_shards" : "1",
        "number_of_shards" : "1",
        "auto_expand_replicas" : "0-1",
        "number_of_replicas" : "1"
      }
    },
    "mappings" : { },
    "aliases" : { }
}'

curl -H 'Content-Type: application/json' -XPUT elasticsearch:9200/_template/nginx -d '{
    "order" : 1,
    "index_patterns" : [
      "nginx-*"
    ],
    "settings" : {
      "index" : {
        "unassigned" : {
          "node_left" : {
            "delayed_timeout" : "10s"
          }
        },
        "number_of_routing_shards" : "1",
        "number_of_shards" : "1",
        "auto_expand_replicas" : "0-1",
        "number_of_replicas" : "1"
      }
    },
    "mappings" : { },
    "aliases" : { }
}'