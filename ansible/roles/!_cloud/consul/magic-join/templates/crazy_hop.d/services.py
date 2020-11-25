#!/bin/env python
import consul
import postgresql
from dns import resolver

def get_masters_from_consul(consul_resolver):
	answer = consul_resolver.query("{{ value.name }}.service.{{ cloud_consul_url }}", 'A')
	for answer_ip in answer:
		print(answer_ip)
	return answer_ip

def main():
	consul_resolver = resolver.Resolver()
	consul_resolver.port = 8600
	consul_resolver.nameservers = ["{{ ansible_default_ipv4['address'] }}"]
	masters_live_array = get_masters_from_consul(consul_resolver)
	print(masters_live_array)

if __name__ == "__main__":
	main()