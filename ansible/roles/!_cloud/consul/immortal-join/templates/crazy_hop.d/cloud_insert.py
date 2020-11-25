#!/bin/env python
import consul
import postgresql
from dns import resolver
import psycopg2
connect_str = "dbname='powerdns_main_consul1' user='postgres' host='95.163.76.59' " + \
			"password='as9f87sa8ut5931214'"

def check_master_record_in_database():
	try:
		connect_str = "dbname='powerdns_main_consul1' user='postgres' host='95.163.76.59' " + \
					"password='as9f87sa8ut5931214'"
		connect_str = "dbname='{{ }}' user='{{ }}' host='{{ }}' " + \
					"password='{{ }}'"
		# use our connection values to establish a connection
		conn = psycopg2.connect(connect_str)
		# create a psycopg2 cursor that can execute queries
		cursor = conn.cursor()
		# create a new table with a single column called "name"
		# cursor.execute("""CREATE TABLE tutorials (name char(40));""")
		# run a SELECT statement - no data in there, but we can try it
		cursor.execute("""SELECT * from tutorials""")
		rows = cursor.fetchall()
		print(rows)
	except Exception as e:
		print("Uh oh, can't connect. Invalid dbname, user or password?")
		print(e)


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