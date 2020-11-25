#!/bin/env python
import consul
import postgresql
from dns import resolver

# db.execute("CREATE TABLE emp (emp_name text PRIMARY KEY, emp_salary numeric)")
# # Create the statements.
# make_emp = db.prepare("INSERT INTO emp VALUES ($1, $2)")
# raise_emp = db.prepare("UPDATE emp SET emp_salary = emp_salary + $2 WHERE emp_name = $1")
# get_emp_with_salary_lt = db.prepare("SELECT emp_name FROM emp WHERE emp_salay < $1")
# # Create some employees, but do it in a transaction--all or nothing.
# with db.xact():
#  make_emp("John Doe", "150,000")
#  make_emp("Jane Doe", "150,000")
#  make_emp("Andrew Doe", "55,000")
#  make_emp("Susan Doe", "60,000")
# # Give some raises
# with db.xact():
#  for row in get_emp_with_salary_lt("125,000"):
#   print(row["emp_name"])
#   raise_emp(row["emp_name"], "10,000")
#

# def get_masters_from_consul(consul_resolver):
# 	answer = consul_resolver.query("
# 	{% for dict_item in crazy_hop_consul_services %}
# 	{% for key, value in dict_item.items() %}
# 	{% if item == key %}'{{ value.name }}.service.{{ cloud_consul_url }}',
#     {% endif %}
# 	{% endfor %}{% endfor %}", 'A')
# 	for answer_ip in answer:
# 		print(answer_ip)
# 	return answer_ip

def get_masters_from_consul(consul_resolver):
	print("START CHECK: {{ value.name }}")
	answer = consul_resolver.query("{{ value.name }}.service.{{ cloud_consul_url }}'", 'A')
	for answer_ip in answer:
		print("ANSWER_IP: {0}".format(answer_ip))
	print("DONE CHECK: {{ value.name }}")
	return answer_ip
	
def main():
	consul_resolver = resolver.Resolver()
	consul_resolver.port = 8600
	consul_resolver.nameservers = ["{{ ansible_default_ipv4['address'] }}"]
	masters_live_array = get_masters_from_consul(consul_resolver)
	print(masters_live_array)

if __name__ == "__main__":
	main()
