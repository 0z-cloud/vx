#!/usr/bin/awk -f
/^$/ {next}
{
system("redis-cli -h "$1" -p "$2" cluster meet "$3" "$4)
system("redis-cli -h "$3" -p "$4" cluster meet "$1" "$2)
system("sleep 1");
system("node_id=$(redis-cli -h "$3" -p "$4" cluster nodes | grep myself | cut -d\047 \047 -f1); redis-cli -h "$1" -p "$2" cluster replicate $node_id")
}