
{% if second_network_zone == 'cluster' %}
# cluster
{% endif %}

{% endif %}



net                                                      
sec                                                      
wan                                                      
dmz                                                      
nginx                                                    
bas                                                  
repo                                                     
cde                                                      
vrrp                                                     
vip                                                      
{% for network_subnet in docker_networks_array.results %}
{% set network_subnet_joined = network_subnet.stdout_lines %}
{% set network_subnet_joined_cleaned = network_subnet_joined | join %}
{% set network_subnet_joined_kv = network_subnet_joined_cleaned | replace(': ', "=") %}
{% set network_subnet_name_cleaned = network_subnet_joined_kv |  regex_replace('=[^=]+$', '') %}
{% set network_subnet_cleaned = network_subnet_joined_kv |  regex_replace('.*=', '') %}
{% if 'bridge' in network_subnet_name_cleaned and 'docker_gwbridge' not in network_subnet_name_cleaned %}
{{ network_subnet_name_cleaned }}
{% endif %}
{% if 'ess' in network_subnet_name_cleaned %}
{{ network_subnet_name_cleaned }}
{% endif %}
{% if 'docker_gwbridge' in network_subnet_name_cleaned and 'ess' in network_subnet_name_cleaned %}
ess
{% endif %}
{% if 'docker_gwbridge' not in network_subnet_name_cleaned and 'ess' not in network_subnet_name_cleaned and 'bridge' not in network_subnet_name_cleaned %}
ess_{{ network_subnet_name_cleaned |  replace('-', "_") }}
{% endif %}
{% endfor %}