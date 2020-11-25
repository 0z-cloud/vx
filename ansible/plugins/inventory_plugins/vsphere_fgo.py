
# Verify the server's SSL certificate
validate_certs = False
vmware_inventory_fast.py
#!/usr/bin/env python
# VMware vSphere Python SDK
# Copyright (c) 2008-2015 VMware, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
Python program for listing the vms on an ESX / vCenter host
Converted into an Ansible Dynamic Inventory - 26/11/2019
Takes 1-2secs as compared to 2-4mins on a non-cached vmware_inventory dynamic list :)
"""

from __future__ import print_function

from pyVim.connect import SmartConnect, Disconnect
from pyVmomi import vim

import argparse
import atexit
import getpass
import ssl

import json

import sys

if sys.version_info[0] > 2:
   import ConfigParser
   config = ConfigParser.ConfigParser()
else:
   import configparser
   config = configparser.ConfigParser()

VMFAST_INI = 'vmware_inventory_fast.ini'

inventory = {
   "all": { 'hosts': [] },
   "_meta": {
      "hostvars" : {}
   }
}

def GetArgs():
   """
   Supports the command-line arguments listed below.
   """
   parser = argparse.ArgumentParser(
       description='Process args for retrieving all the Virtual Machines')
   parser.add_argument('--host', required=False, action='store', help='Single host to list')
   parser.add_argument('--list', required=False, action="store_true", help='List all hosts')

   args = parser.parse_args()
   return args


def PrintVmInfo(vm, depth=1):
   """
   Print information for a particular virtual machine or recurse into a folder
   or vApp with depth protection
   """
   maxdepth = 10

   # if this is a group it will have children. if it does, recurse into them
   # and then return
   if hasattr(vm, 'childEntity'):
      if depth > maxdepth:
         return
      vmList = vm.childEntity
      for c in vmList:
         PrintVmInfo(c, depth+1)
      return

   # if this is a vApp, it likely contains child VMs
   # (vApps can nest vApps, but it is hardly a common usecase, so ignore that)
   if isinstance(vm, vim.VirtualApp):
      vmList = vm.vm
      for c in vmList:
         PrintVmInfo(c, depth + 1)
      return

   summary = vm.summary

   if summary.guest != None:
      ip = summary.guest.ipAddress

      

      hostname = summary.config.name.lower()

      inventory['all']['hosts'].append(hostname)

      inventory['_meta']['hostvars'][hostname] = {}
      inventory['_meta']['hostvars'][hostname]['name'] = hostname

      if ip != None and ip != "":
         inventory['_meta']['hostvars'][hostname]['ansible_ssh_host'] = ip 
         
      inventory['_meta']['hostvars'][hostname]['state'] = summary.runtime.powerState
      inventory['_meta']['hostvars'][hostname]['guest_full_name'] = summary.config.guestFullName

def main():
   """
   Simple command-line program for listing the virtual machines on a system.
   """

   args = GetArgs()

   config.read(VMFAST_INI)

   context = None
   if hasattr(ssl, '_create_unverified_context'):
      context = ssl._create_unverified_context()
   si = SmartConnect(host=config.get('vmware','server'),
                     user=config.get('vmware','username'),
                     pwd=config.get('vmware','password'),
                     port=config.getint('vmware','port'),
                     sslContext=context)
   if not si:
       print("Could not connect to the specified host using specified "
             "username and password")
       return -1

   atexit.register(Disconnect, si)

   content = si.RetrieveContent()
   for child in content.rootFolder.childEntity:
      if hasattr(child, 'vmFolder'):
         datacenter = child
         vmFolder = datacenter.vmFolder
         vmList = vmFolder.childEntity
         for vm in vmList:
            PrintVmInfo(vm)

         # pretty print the results
         json_str = json.dumps(inventory,sort_keys=True, indent=4, separators=(',', ': '))
         print(json_str)
   return 0

# Start program
if __name__ == "__main__":
   main()
