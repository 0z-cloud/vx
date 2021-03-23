#!/usr/bin/env python3

import yaml
import json
import sys
import re
import os
import argparse
from collections import defaultdict
from collections import OrderedDict
from collections import namedtuple
import ipaddress

_data = { "_meta" : { "hostvars": {} }}
_matcher = {}
_hostlog = []
inventory_uniq_groups=[]
var_inventory_uniq_groups=[]

class Ansible_inventory_groups_map:
    global arraygroups_map
    arraygroups_map = []
    def addhost(self,hostname):
        self.arraygroups_map.update(hostname)
        #print(str(self.array))
    def removeremove(self,hostname):
        self.arraygroups_map.update(hostname)

def appendload(group):
    global_hosts_result_inventory.append(globals()['local{}'.format(group)])

class my_dictionary(dict):  
  
    # __init__ function  
    def __init__(self):  
        self = dict()  
          
    # Function to add key:value  
    def add(self, key, value):  
        self[key] = value  

def remove_duplicates(l):
    return list(set(l))

def is_ip_private(ip):

    priv_lo = re.compile("^127\.\d{1,3}\.\d{1,3}\.\d{1,3}$")
    priv_24 = re.compile("^10\.\d{1,3}\.\d{1,3}\.\d{1,3}$")
    priv_20 = re.compile("^192\.168\.\d{1,3}.\d{1,3}$")
    priv_16 = re.compile("^172.(1[6-9]|2[0-9]|3[0-1]).[0-9]{1,3}.[0-9]{1,3}$")

    public = "public"
    private = "private"
    res = priv_lo.match(ip) or priv_24.match(ip) or priv_20.match(ip) or priv_16.match(ip)
    if res is not None:
        return private
    else:
        return public

# Nice output
def print_json(data):
    print(json.dumps(data, indent=2))

# Load the YAML file
def load_file(file_name):
    with open(file_name, 'r') as fh:
        return yaml.load(fh, Loader=yaml.SafeLoader)

def get_yaml(file_name):
    path_normalized_loc = get_runpath()
    full_pre_path = "/" + path_normalized_loc + loadpath_all_declared
    replace_duplicate_slash_path = full_pre_path.replace('\\\\', '\\')
    # script_path = os.path.dirname(os.path.realpath(__file__))
    # file_name = file_name.replace(replace_duplicate_slash_path, '')
    inventory_object = load_file("{}/{}".format(replace_duplicate_slash_path, file_name))
    return inventory_object

def get_runpath():
    script_path_normalized = os.path.dirname(os.path.realpath(__file__)).replace("/vortex-py", "")
    return script_path_normalized

def to_num_if(n):
    try:
        return int(n)
    except:
        pass
    try:
        return float(n)
    except:
        return n

class Group_Inventory_Object_Properties:
    def __init__(self, inventory_object, path=[""]):

        for g in inventory_object:
             if g in 'ansible_inventory_groups':
                for item in inventory_object['ansible_inventory_groups']:
                    list_groups.append(item)

class CompareInventoryObjects:
    global arraygroups_map
    global local
    global names
    names = []
    def __init__(self, ifile, uniq_groups, global_hosts_result_inventory, path=[""]):

        json_data_raw = get_yaml(ifile)
        json_data = json_data_raw['cloud_bootstrap']['servers']
        json_data_services = json_data_raw['cloud_bootstrap']['services']

        for uniq_group in uniq_groups:
            for s in json_data:
                inventory_obj = json_data[s]
                for g in inventory_obj:
                    if g in 'ansible_inventory_groups':
                        list_groups = inventory_obj['ansible_inventory_groups']
                        for item in list_groups:
                            if item in uniq_group:
                                names.append({item: inventory_obj['name']})

        for group in uniq_groups:
            global_hosts_result_inventory.append("[" + group + ":children]")
            for k in names:
                for key,value in k.items():
                    for uniq_group in uniq_groups:
                        if re.match(uniq_group, key) and re.match(group, key) and re.match(group, uniq_group):
                            global_hosts_result_inventory.append(value)

class Inventory_Object_Properties:

    def __init__(self, inventory_object, hosts_result_inventory, path=[""]):

        self.host_ip_line = ""
        self.host_ip = ""
        self.host_ssh_line = ""
        self.host_name_parent_object = ""
        self.host_name_target_object = ""
        self.host_name_target_vars_object = ""
        self.array_vars = []
        self.list_groups = []
        self.groups_array_objects = defaultdict(list)
        self.groups_array_objects_hosts = []
        self.public_ip_check = ""
        self.second_ip_check = ""
        self.green_ip = ""
        self.green_subnet = ""
        self.ansible_ssh_host_result = ""
        self.ansible_ssh_host_ip_check_result = ""
        self.extra_vars = my_dictionary()
        for g in inventory_object:
            if type(g) == dict:
                for k,v in g:
                    if k == 'gw':
                        self.name = g['gw']
                        gw_value = g['gw']
                    elif k == 'gw':
                        for tag in g[k]:
                            self.gw.append(tag)
                    else:
                        self.var[k] = g[k]
            elif type(g) == str:
                self.name = g
                if g in 'ansible_inventory_groups':
                    self.list_groups = inventory_object['ansible_inventory_groups']
                if g in 'ansible_inventory_vars':
                    self.array_vars = inventory_object['ansible_inventory_vars'].items()
                if g in 'ssh':
                    self.host_ssh_line = inventory_object['ssh']
                if g in 'name':
                    self.host_name_parent_object = inventory_object['name']
                if g in 'ip':
                    if connection_type_result in "nat":
                        self.host_ip = inventory_object['ansible_inventory_vars']['public_nat_ip']
                    elif connection_type_result in "green":
                        self.host_ip = inventory_object['ansible_inventory_vars']['green_ip']
                    elif connection_type_result in "public":
                        self.host_ip = inventory_object['ip']
                    else:
                        if connection_type_result in "private":
                            self.host_ip = inventory_object['ansible_inventory_vars']['second_ip']
                        else:
                            exit(1)
                    self.extra_vars.add('connection_type', connection_type_result)
                    self.public_ip_check = is_ip_private(inventory_object['ip'])
                    self.second_ip_check = is_ip_private(inventory_object['ansible_inventory_vars']['second_ip'])
                    self.ansible_ssh_host_result = self.host_ip
                    self.ansible_ssh_host_ip_check_result = is_ip_private(self.ansible_ssh_host_result)
                    self.extra_vars.add('public_ip_check', self.public_ip_check)
                    self.extra_vars.add('second_ip_check', self.second_ip_check)
                    self.extra_vars.add('ansible_ssh_host_ip_check_result', self.ansible_ssh_host_ip_check_result)
        self.host_name_parent_object
        self.host_name_target_vars_object = ("[" + self.host_name_parent_object + ":vars]")
        self.host_name_target_object = ("[" + self.host_name_parent_object + "]")
        self.host_ip_line = (self.host_name_parent_object + " ansible_ssh_host=" + self.host_ip + " " + self.host_ssh_line)
        some_value_one = self.host_name_target_object
        some_value_two = self.host_ip_line
        hosts_result_list_list.append(some_value_one)
        hosts_result_list_list.append(some_value_two)
        vars_result_list_list.append(self.host_name_target_vars_object)
        for k,v in self.array_vars:
            if k in 'public_nat_ip':
                if v in 'REPLACED':
                    v = inventory_object['ip']
            if k in 'public_nat_gw':
                if v in 'REPLACED':
                    v = inventory_object['gw']
            if k in 'second_ip':
                if v in 'REPLACED':
                    v = self.host_ip
            return_value = (k + "=\"" + v + "\"")
            vars_result_list_list.append(return_value)
        for key,value in self.extra_vars.items():
            return_value = (key + "=\"" + value + "\"")
            vars_result_list_list.append(return_value)

class Host:

    def __init__(self, host, path):
        self.path = path
        self.var = {}
        self.name = ""
        self.path = ""
        self.tags = []
        if type(host) == dict:
            for k in host:
                print(k)
                if k == 'name':
                    self.name = host['name']
                elif k == 'tags':
                    for tag in host[k]:
                        self.tags.append(tag)
                else:
                    self.var[k] = host[k]
        elif type(host) == str:
            self.name = host
        if self.name in _hostlog:
            raise Exception("Error, host {} defined twice".format(self.name))
        _hostlog.append(self.name)
        self.tags = self.tags + self.split_tag() + self.matcher_tags()
        if len(self.var) > 0:
            _data['_meta']['hostvars'][self.name] = self.var
        for tag in self.tags:
            if not tag in _data:
                _data[tag] = { "hosts": [] }
            if not 'hosts' in _data[tag]:
                _data[tag]['hosts'] = []
            _data[tag]['hosts'].append(self.name)

    def split_tag(self):
        tags = []
        for part in re.compile('[^a-z]').split(self.name):
            if part == "": continue
            tags.append(part)
        return tags

    def matcher_tags(self):
        tag = []
        for match in _matcher:
            m = re.compile(match['regexp']).match(self.name)
            if m:
                if 'groups' in match:
                    for g in match['groups']:
                        tag.append(g)
                if 'capture' in match and match['capture']:
                    for m2 in m.groups():
                        tag.append(m2)
        return tag

    def group(self):
        return "-".join(self.path)

    def __repr__(self):
        return "host: {} group: {} vars: {} tags: {}".format(
                self.name, self.group(), self.var, self.tags)

class Groups:
    def __init__(self, groups, path=["root"]):

        if type(groups) == dict:
            for g in groups:
                print(g)
                p = path + [g]
                fullpath = "-".join(p)
                if 'vars' == p[-1]:
                    _data["-".join(path)]['vars'] = groups['vars']
                elif 'include' in p[-1]:
                    for f in groups['include']:
                        Groups(get_yaml(f), p[:len(p)-1])
                else:
                    if 'hosts' != p[-1]:
                        if not fullpath in _data:
                            _data[fullpath] = {}
                        if not 'children' in _data["-".join(path)]:
                            _data["-".join(path)]['children'] = []
                            if not 'vars' in _data["-".join(path)]:
                                _data["-".join(path)]['vars'] = {}
                        _data["-".join(path)]['children'].append("-".join(p))
                    Groups(groups[g], p)
        elif type(groups) == list:
            for h in groups:
                if 'hosts' == path[-1]:
                    path.pop()
                hst = Host(h, path)
                fullpath = "-".join(path)
                for t in hst.tags:
                    tagfullpath = "{}-{}".format(fullpath,t)
                    if not tagfullpath in _data:
                        _data[tagfullpath] = {}
                    if not 'hosts' in _data[tagfullpath]:
                        _data[tagfullpath]['hosts'] = []
                    _data[tagfullpath]['hosts'].append(hst.name)
                    if not 'children' in _data[fullpath]:
                        _data[fullpath]['children'] = []
                        if not 'vars' in _data[fullpath]:
                            _data[fullpath]['vars'] = {}
                    _data[fullpath]['children'].append(tagfullpath)

class TagVars:
    def __init__(self, tag, val):
        for k, v in val.items():
            if not tag in _data:
                _data[tag] = {}
            if not 'vars' in _data[tag]:
                _data[tag]['vars'] = {}
            _data[tag]['vars'][k] = v

class Inventory:
    commands = ["include", "matcher", "tagvars"]
    
    def __init__(self, ifile, hosts_result_inventory):
        json_data_raw = get_yaml(ifile)
        json_data = json_data_raw['cloud_bootstrap']['servers']
        global _matcher
        for el in json_data:
            parsed_object = Inventory_Object_Properties(json_data[el], [el], hosts_result_inventory)

class Groups_In_Inventory:
    commands = ["include", "matcher", "tagvars"]
    
    def __init__(self, ifile, hosts_result_inventory):
        json_data_raw = get_yaml(ifile)
        json_data = json_data_raw['cloud_bootstrap']['servers']
        for el in json_data:
            parsed_object = Group_Inventory_Object_Properties(json_data[el], [el])

def to_json(in_dict):
    return json.dumps(in_dict, sort_keys=True, indent=2)

def main(argv):

    global hosts_result_list_list
    hosts_result_list_list = []
    global vars_result_list_list
    vars_result_list_list = []
    # global connection_type
    global connection_type_result 
    global _meta
    global result_groups
    global result_groups_hosts
    global list_groups
    global result_groups
    global result_inventory
    global global_hosts_result_inventory
    global hosts_result_inventory
    global global_group_vars_array
    global script_path_result
    global bootstrap_file_dynamic_check
    global bootstrap_file_static_check
    global loadpath_all_declared
    loadpath_all_declared = ""
    bootstrap_file_static_check = ""
    bootstrap_file_dynamic_check = ""
    script_path_result = ""
    global_group_vars_array = []
    hosts_result_inventory = []
    global_hosts_result_inventory = []
    result_inventory = []
    result_groups = []
    list_groups = []
    result_groups = {}
    result_groups_hosts = {}
    parser = argparse.ArgumentParser(description='Ansible Inventory System')
    parser.add_argument('--connection_type', help='Network connection mode for primary ip: private or public', required=True)
    parser.add_argument('--file', help='File to open, default bootstrap_vms/group_vars/all.yml', default='bootstrap_vms/group_vars/all.yml')
    parser.add_argument('--product', help='Ansible Product for create a correct load path', required=True)
    parser.add_argument('--cloudtype', help='Ansible Cloud Type for create a correct load path', required=True)
    parser.add_argument('--environment', help='Ansible Environment for create a correct load path', required=True)
    args = parser.parse_args()
    loadpath_all_declared = '/products/types/!_' + args.cloudtype + "/" + args.product + "/" + args.environment
    if args.connection_type in "nat":
        connection_type_result = "nat"
    elif args.connection_type in "public":
        connection_type_result = "public"
    elif args.connection_type in "private":
        connection_type_result = "private"
    elif args.connection_type in "green":
        connection_type_result = "green"
    else:
        connection_type_result = "none"
    bootstrap_file_dynamic_check = "bootstrap_vms/group_vars/.dynamic.all.yml"
    bootstrap_file_static_check = "bootstrap_vms/group_vars/.dynamic.all.yml"
    path_normalized_loc_top = get_runpath()
    full_pre_path_loc_top = "/" + path_normalized_loc_top + loadpath_all_declared
    replace_duplicate_slash_path_loc_top = full_pre_path_loc_top.replace('\\\\', '\\')
    bootstrap_file_dynamic_check_target = replace_duplicate_slash_path_loc_top + '\\' + bootstrap_file_dynamic_check
    if os.path.isfile(bootstrap_file_dynamic_check_target):
        oz_dictionary_file_to_read = bootstrap_file_dynamic_check # "bootstrap_vms/group_vars/.dynamic.all.yml"
    else:
        oz_dictionary_file_to_read = bootstrap_file_static_check # args.file
    inventory = Inventory(oz_dictionary_file_to_read, hosts_result_inventory)
    result_groups = Groups_In_Inventory(oz_dictionary_file_to_read, hosts_result_inventory)
    uniq_groups_data = remove_duplicates(list_groups)
    uniq_groups = set(uniq_groups_data)
    result_items = CompareInventoryObjects(oz_dictionary_file_to_read, uniq_groups, global_hosts_result_inventory)
    global_hosts_result_inventory = hosts_result_list_list + global_hosts_result_inventory + vars_result_list_list
    for item in global_hosts_result_inventory:
        print (item)

if __name__ == '__main__':
    sys.exit(main(sys.argv))