# Copyright © 2018 VMware, Inc. All Rights Reserved.
# SPDX-License-Identifier: BSD-2-Clause OR GPL-3.0-only

#!/usr/bin/python

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'community'
}

DOCUMENTATION = '''
---
module: vcd_vapp_vm_nic
short_description: Ansible Module to manage (add/delete/update) NICs in vApp VMs in vCloud Director.
version_added: "2.4"
description:
    - "Ansible Module to manage (add/delete/update) NICs in vApp VMs."
options:
    user:
        description:
            - vCloud Director user name
        required: false
    password:
        description:
            - vCloud Director user password
        required: false
    host:
        description:
            - vCloud Director host address
        required: false
    org:
        description:
            - Organization name on vCloud Director to access
        required: false
    api_version:
        description:
            - Pyvcloud API version
        required: false
    verify_ssl_certs:
        description:
            - whether to use secure connection to vCloud Director host
        required: false
    nic_id:
        description:
            - NIC ID (required for operation update, optional for state present)
        required: false
    nic_ids:
        description:
            - List of NIC IDs (required for state absent)
        required: false
    adapter_type:
        description:
            - Adapter type (VMXNET3, E1000E, ...)
        required: false
    network:
        description:
            - vApp network name
        required: false
    vm_name:
        description:
            - VM name
        required: true
    vapp:
        description:
            - vApp name
        required: true
    vdc:
        description:
            - VDC name
        required: true
    ip_allocation_mode:
        description:
            - IP allocation mode (DHCP, POOL or MANUAL)
        required: false
    ip_address:
        description:
            - NIC IP address (required for MANUAL IP allocation mode)
        required: false
    state:
        description:
            - state of nic (present/absent).
            - One from state or operation has to be provided.
        required: true
    operation:
        description:
            - operation on nic (update/read).
            - One from state or operation has to be provided.
        required: false
author:
    - mtaneja@vmware.com
'''

EXAMPLES = '''
- name: Test with a message
  vcd_vapp_vm_nic:
    user: terraform
    password: abcd
    host: csa.sandbox.org
    org: Terraform
    api_version: 30
    verify_ssl_certs: False
    vm: "vm1"
    vapp = "vapp1"
    vdc = "vdc1"
    nic_id = "2"
    ip_allocation_mode = "MANUAL"
    ip_address = "172.16.0.11"
    state = "present"
'''

RETURN = '''
msg: success/failure message corresponding to nic state
changed: true if resource has been changed else false
'''

import os
import unittest
import yaml
from copy import deepcopy
from lxml import etree
from collections import defaultdict
from pyvcloud.vcd.vm import VM
from pyvcloud.vcd.org import Org
from pyvcloud.vcd.vdc import VDC
from pyvcloud.vcd.client import E
from pyvcloud.vcd.client import Client
from pyvcloud.vcd.client import ApiVersion
from pyvcloud.vcd.vapp import VApp
from collections import defaultdict
from pyvcloud.vcd.client import E_RASD
from pyvcloud.vcd.client import NSMAP
from pyvcloud.vcd.client import EntityType
from pyvcloud.vcd.client import find_link
from pyvcloud.vcd.client import IpAddressMode
from pyvcloud.vcd.client import MetadataDomain
from pyvcloud.vcd.client import MetadataValueType
from pyvcloud.vcd.client import MetadataVisibility
from pyvcloud.vcd.client import NSMAP
from pyvcloud.vcd.client import QueryResultFormat
from pyvcloud.vcd.client import RelationType
from pyvcloud.vcd.client import ResourceType
from pyvcloud.vcd.client import VCLOUD_STATUS_MAP
from pyvcloud.vcd.client import VmNicProperties
from pyvcloud.vcd.exceptions import EntityNotFoundException
from pyvcloud.vcd.exceptions import InvalidParameterException
from pyvcloud.vcd.exceptions import InvalidStateException
from pyvcloud.vcd.exceptions import MultipleRecordsException
from pyvcloud.vcd.exceptions import OperationNotSupportedException
from pyvcloud.vcd.metadata import Metadata
from pyvcloud.vcd.utils import retrieve_compute_policy_id_from_href
#from pyvcloud.vcd.utils import update_vm_compute_policy_element
from pyvcloud.vcd.utils import uri_to_api_uri
from ansible.module_utils.vcd import VcdAnsibleModule
from pyvcloud.vcd.exceptions import EntityNotFoundException, OperationNotSupportedException


VAPP_VM_NIC_STATES = ['present', 'absent', 'update']
VAPP_VM_NIC_OPERATIONS = ['read', 'validate']


def vapp_vm_nic_argument_spec():
    return dict(
        vm_name=dict(type='str', required=True),
        vapp=dict(type='str', required=True),
        vdc=dict(type='str', required=True),
        nic_id=dict(type='int', required=False),
        nic_ids=dict(type='list', required=False),
        is_connected=dict(type='bool', required=False, default=False),
        ip_allocation_mode=dict(type='str', required=False),
        ip_address=dict(type='str', required=False),
        network=dict(type='str', required=False),
        adapter_type=dict(type='str', required=False),
        is_primary=dict(type='bool', required=False, default=False),
        state=dict(choices=VAPP_VM_NIC_STATES, required=False),
        operation=dict(choices=VAPP_VM_NIC_OPERATIONS, required=False),
    )

class VappVMNIC(VcdAnsibleModule):
    def __init__(self, **kwargs):
        super(VappVMNIC, self).__init__(**kwargs)
        vapp_resource = self.get_resource()
        vapp = VApp(self.client, resource=vapp_resource)
        self.vapp = vapp
        
    def manage_states(self):
        state = self.params.get('state')
        if state == "present":
            return self.add_nic_ng()

        if state == "update":
            return self.update_nic()

        if state == "absent":
            return self.delete_nic()

        if state == "validate":
            return self.validate_nic()

    def manage_operations(self):
        operation = self.params.get('operation')

        if operation == "read":
            return self.read_nics()

        if operation == "validate":
            return self.validate_nic()
        
    def create_list_with_present_nics(self):
        response = defaultdict(dict)
        response['changed'] = False
        response['msg'] = []
        present_nics_list = []

        vm = self.get_vm()
        nics = self.client.get_resource(
            vm.resource.get('href') + '/networkConnectionSection')

        for nic in nics.NetworkConnection:
            present_nics_list.append(nic.NetworkConnectionIndex.text)
            response['msg'].append({
                'index': nic.NetworkConnectionIndex.text,
                'network': nic.get('network')
            })
        self.present_nics_list = present_nics_list
        return self.present_nics_list

        # vapp_name = self.params.get('vapp')
        # network = self.params.get('network')
        # self.network = network
        # self.vapp_name = vapp_name
        # vdc = self.params.get('vdc')
        # #vm_name = self.params.get('vm_name')
        # vapp_resource = self.get_resource_ng()
        # #vm_resource = self.get_vm_ng()
        # nics_index_resource = self.get_vm_nics_ng()
        # vapp = VApp(self.client, resource=vapp_resource)
        # org_resource = Org(self.client, resource=self.client.get_org())
        # vdc_resource = VDC(self.client, resource=org_resource.get_vdc(vdc))
        # #vapp_vm_resource = vapp.get_vm_ng(vm_name)
        # self.nics_index_resource = nics_index_resource
        # #self.vm_resource = VM(self.client, resource=vapp_vm_resource)
        # self.vapp_resource_href = vdc_resource.get_vapp_resource_href(name=vapp_name, entity_type=EntityType.VAPP)
        # self.vapp_resource = self.client.get_vapp_resource(self.vapp_resource_href)
        # #self.vm = VM(self.client, resource=vm_resource)
        # self.vapp = vapp
        # self.nic_mapping = defaultdict(list)

    def get_vm_nic_section(self):
        vm = self.get_vm()

        return self.client.get_resource(
            vm.resource.get('href') + '/networkConnectionSection')

    def get_resource(self):
        #vapp = self.params.get('vapp')
        vdc = self.params.get('vdc')
        org_resource = Org(self.client, resource=self.client.get_org())
        vdc_resource = VDC(self.client, resource=org_resource.get_vdc(vdc))
        vapp_resource_href = vdc_resource.get_resource_href(name=self.vapp, entity_type=EntityType.VAPP)
        vapp_resource = self.client.get_resource(vapp_resource_href)

        return vapp_resource

    def get_vm_nics_ng(self):
        vm = self.get_vm_ng()

        return self.client.get_resource(
            self.vapp_vm_resource.resource.get('href') + '/networkConnectionSection')

    def return_nics_indexes(self):
        nics_returned_indexes = self.get_vm_nics_ng()
        nics_indexes = [int(nic.NetworkConnectionIndex) for nic in nics_returned_indexes.NetworkConnection]
        nics_indexes.sort()
        return self.nics_indexes
        
    def get_vm_ng(self):
        vm_resource = VM(self.client, resource=vapp_vm_resource)
        vapp_vm_resource = vm.get_vm(self.params.get('vm_name'))

        return VM(self.client, resource=vapp_vm_resource)


    def get_vapp_resource(self):
        vapp = self.params.get('vapp')
        vdc = self.params.get('vdc')
        org_resource = Org(self.client, resource=self.client.get_org())
        vdc_resource = VDC(self.client, resource=org_resource.get_vdc(vdc))
        vapp_resource = vdc_resource.get_vapp_resource_href(name=vapp, entity_type=EntityType.VAPP)
        vapp_resource_htef = self.client.get_vapp_resource(vapp_resource)
        return vapp_resource

    def get_vm_resource(self):
        
        return vm_resource

    def get_vm(self):
        vapp_vm_resource = self.vapp.get_vm(self.params.get('vm_name'))
        self.local_vm = VM(self.client, resource=vapp_vm_resource)
        return VM(self.client, resource=vapp_vm_resource)

    def get_vm_nics(self):
        vm = self.get_vm()
        return self.client.get_vapp_resource(vm.resource.get('href') + '/networkConnectionSection')

    def add_nic_ng(self):
        # get network connection section.
        vm_name = self.params.get('vm_name')
        nic_id = self.params.get('nic_id')
        is_primary = self.params.get('is_primary')
        network_name = self.params.get('network')
        is_connected = self.params.get('is_connected')
        ip_address = self.params.get('ip_address')
        ip_allocation_mode = self.params.get('ip_allocation_mode')
        adapter_type = self.params.get('adapter_type')
        self.nic_id = nic_id
        self.network_name = network_name
        self.ip_address = ip_address
        self.is_connected = is_connected
        net_conn_section = self.get_vapp_resource()
        nic_index = self.nic_id
        insert_index = net_conn_section.index(
            net_conn_section['{' + NSMAP['ovf'] + '}Info']) + 1
        # check if any nics exists
        if hasattr(net_conn_section, 'PrimaryNetworkConnectionIndex'):
            # calculate nic index and create the networkconnection object.
            indices = [None] * 10
            insert_index = net_conn_section.index(
                net_conn_section.PrimaryNetworkConnectionIndex) + 1
            for nc in net_conn_section.NetworkConnection:
                indices[int(nc.NetworkConnectionIndex.
                            text)] = nc.NetworkConnectionIndex.text
            nic_index = indices.index(None)
            if nic_index:
                net_conn_section.NetworkConnectionIndex = E.NetworkConnectionIndex(nic_index)

        net_conn = E.NetworkConnection(network=network_name)
        net_conn.set('needsCustomization', 'true')
        net_conn.append(E.NetworkConnectionIndex(nic_index))
        if ip_allocation_mode == IpAddressMode.MANUAL.value:
            net_conn.append(E.IpAddress(ip_address))
        else:
            net_conn.append(E.IpAddress())
            net_conn.append(E.IsConnected(is_connected))
            net_conn.append(E.IpAddressAllocationMode(ip_allocation_mode))
            net_conn.append(E.NetworkAdapterType(adapter_type))
            net_conn_section.insert(insert_index, net_conn)
            vm_resource = self.get_vapp_resource()
            vm_resource.NetworkConnectionSection = net_conn_section
            return self.client.post_linked_resource(
                vm_resource, RelationType.RECONFIGURE_VM, EntityType.VM.value,
                vm_resource)
        self.net_conn = net_conn

    def net_connection_obj_create(self):
        net_conn = E.NetworkConnection(network=network_name)
        net_conn.set('needsCustomization', 'true')
        net_conn.append(E.NetworkConnectionIndex(nic_index))
        if ip_address_mode == IpAddressMode.MANUAL.value:
            net_conn.append(E.IpAddress(ip_address))
        else:
            net_conn.append(E.IpAddress())
        net_conn.append(E.IsConnected(is_connected))
        net_conn.append(E.IpAddressAllocationMode(ip_address_mode))
        net_conn.append(E.NetworkAdapterType(adapter_type))
        net_conn_section.insert(insert_index, net_conn)

    def net_connection_section_obj_create(self):
        net_conn_section = self.get_vapp_resource()
        #
        insert_index = net_conn_section.index(
            net_conn_section['{' + NSMAP['ovf'] + '}Info']) + 1
        # check if any nics exists
        if hasattr(net_conn_section, 'PrimaryNetworkConnectionIndex'):
            # calculate nic index and create the networkconnection object.
            indices = [None] * 10
            insert_index = net_conn_section.index(
                net_conn_section.PrimaryNetworkConnectionIndex) + 1
            for nc in net_conn_section.NetworkConnection:
                indices[int(nc.NetworkConnectionIndex.
                            text)] = nc.NetworkConnectionIndex.text
            nic_index = indices.index(None)
            if is_primary:
                net_conn_section.PrimaryNetworkConnectionIndex = \
                    E.PrimaryNetworkConnectionIndex(nic_index)
        vm_resource = self.get_vapp_resource()
        vm_resource.NetworkConnectionSection = net_conn_section
        return self.client.post_linked_resource(
            vm_resource, RelationType.RECONFIGURE_VM, EntityType.VM.value,
            vm_resource)

    def add_nic(self):
        vm = self.get_vm()
        vm_name = self.params.get('vm_name')
        nic_id = self.params.get('nic_id')
        network = self.params.get('network')
        ip_address = self.params.get('ip_address')
        ip_allocation_mode = self.params.get('ip_allocation_mode')
        adapter_type = self.params.get('adapter_type')
        uri = vm.resource.get('href') + '/networkConnectionSection'
        response = defaultdict(dict)
        response['changed'] = False
        new_nic_id = None
        nics = self.get_vm_nics()
        nics_indexes = [int(nic.NetworkConnectionIndex) for nic in nics.NetworkConnection]
        nics_indexes.sort()

        for nic in nics.NetworkConnection:
            if nic.NetworkConnectionIndex == nic_id:
                response['warnings'] = 'NIC {} is already present on VM {}'.format(
                    nic_id, vm_name)
                return response

        if not adapter_type:
            nics_adapters = [str(nic.NetworkAdapterType) for nic in nics.NetworkConnection]
            adapter_type = nics_adapters[0] # select the first nic NetworkAdapterType

        if nic_id is None or nic_id < 0:
            for index, nic_index in enumerate(nics_indexes):
                new_nic_id = nic_index + 1
                if index != nic_index:
                    new_nic_id = index
                    break
            nic_id = new_nic_id

        if ip_allocation_mode not in ('DHCP', 'POOL', 'MANUAL'):
            raise Exception('IpAllocationMode should be one of DHCP/POOL/MANUAL')

        # if ip_allocation_mode in ('DHCP', 'POOL'):
        #     nic = E.NetworkConnection(
        #         E.NetworkConnectionIndex(nic_id),
        #         E.IsConnected(True),
        #         E.IpAddressAllocationMode(ip_allocation_mode),
        #         E.NetworkAdapterType(adapter_type),
        #         network=network)
        # else:
        #     if not ip_address:
        #         raise Exception('IpAddress is missing.')
        #     nic = E.NetworkConnection(
        #         E.NetworkConnectionIndex(nic_id),
        #         E.IpAddress(ip_address),
        #         E.IsConnected(True),
        #         E.IpAddressAllocationMode(ip_allocation_mode),
        #         E.NetworkAdapterType(adapter_type),
        #         network=network)
        add_nic_task = vm.add_nic(adapter_type=adapter_type,
                                is_connected=is_connected,
                                network_name=network,
                                ip_address_mode=ip_allocation_mode,
                                ip_address=ip_address,
                                network=network,
                                nic_id=nic_id
                                )
        self.execute_task(add_nic_task)
        response['msg'] = {
            'nic_id': nic_id,
            'adapter_type': adapter_type,
            'ip_allocation_mode': ip_allocation_mode,
            'ip_address': ip_address,
            'network': network,
            'is_connected': is_connected,
            'malinki': "vecerinki"
        }
        response['changed'] = True
        return response
        # nics.NetworkConnection.addnext(nic)
        
        # add_nic_task = self.client.put_resource(uri, nics, EntityType.NETWORK_CONNECTION_SECTION.value)
        # self.execute_task(add_nic_task)
        # response['msg'] = {
        #     'nic_id': nic_id,
        #     'adapter_type': adapter_type,
        #     'ip_allocation_mode': ip_allocation_mode,
        #     'ip_address': ip_address,
        #     'network': network
        # }
        # response['changed'] = True

        # return response

    def validate_add_nic(self):
        '''
            Error - More than 10 Nics are not permissible in vCD
        '''
        vm = self.get_vm()
        vm_name = self.params.get('vm_name')
        nic_id = self.params.get('nic_id')
        network = self.params.get('network')
        ip_address = self.params.get('ip_address')
        ip_allocation_mode = self.params.get('ip_allocation_mode')
        adapter_type = self.params.get('adapter_type')
        uri = vm.resource.get('href') + '/networkConnectionSection'
        response = defaultdict(dict)
        response['changed'] = False
        new_nic_id = None
        network_section = self.net_connection_section_obj_create()
        net_conn = self.net_connection_obj_create()
        nics = self.get_vm_nics()
        nics_indexes = [int(nic.NetworkConnectionIndex) for nic in nics.NetworkConnection]
        nics_indexes.sort()

        for nic in nics.NetworkConnection:
            if nic.NetworkConnectionIndex == nic_id:
                response['warnings'] = 'Validate add: NIC {} is already present on VM {}'.format(
                    nic_id, vm_name)
                return response

        if not adapter_type:
            nics_adapters = [int(nic.NetworkAdapterType) for nic in nics.NetworkConnection]
            adapter_type = nics_adapters[0] # select the first nic NetworkAdapterType

        if nic_id is None or nic_id < 0:
            for index, nic_index in enumerate(nics_indexes):
                new_nic_id = nic_index + 1
                if index != nic_index:
                    new_nic_id = index
                    break
            nic_id = new_nic_id

        if ip_allocation_mode not in ('DHCP', 'POOL', 'MANUAL'):
            raise Exception('IpAllocationMode should be one of DHCP/POOL/MANUAL')

        if ip_allocation_mode in ('DHCP', 'POOL'):
            nic = E.NetworkConnection(
                E.NetworkConnectionIndex(nic_id),
                E.IsConnected(True),
                E.IpAddressAllocationMode(ip_allocation_mode),
                E.NetworkAdapterType(adapter_type),
                network=network)
        else:
            if not ip_address:
                raise Exception('IpAddress is missing.')
            nic = E.NetworkConnection(
                E.NetworkConnectionIndex(nic_id),
                E.IpAddress(ip_address),
                E.IsConnected(True),
                E.IpAddressAllocationMode(ip_allocation_mode),
                E.NetworkAdapterType(adapter_type),
                network=network)

        nics.NetworkConnection.addnext(nic)
        add_nic_task = self.client.put_resource(uri, nics, EntityType.NETWORK_CONNECTION_SECTION.value)
        self.execute_task(add_nic_task)
        response['msg'] = {
            'nic_id': nic_id,
            'adapter_type': adapter_type,
            'ip_allocation_mode': ip_allocation_mode,
            'ip_address': ip_address,
            'network': network,
            'Validate add: ': 'true'
        }
        response['changed'] = True

        return response

    def update_nic(self):
        '''
            Following update scenarios are covered
            1. IP allocation mode change: DHCP, POOL, MANUAL
            2. Update IP address in MANUAL mode
            3. Network change
        '''
        vm = self.get_vm()
        nic_id = self.params.get('nic_id')
        network = self.params.get('network')
        ip_address = self.params.get('ip_address')
        ip_allocation_mode = self.params.get('ip_allocation_mode')
        uri = vm.resource.get('href') + '/networkConnectionSection'
        response = defaultdict(dict)
        response['changed'] = False

        nics = self.get_vm_nics()
        nic_indexs = [nic.NetworkConnectionIndex for nic in nics.NetworkConnection]
        if nic_id not in nic_indexs:
            response['warnings'] = 'NIC not found.'
            return response
        nic_to_update = nic_indexs.index(nic_id)

        if network:
            nics.NetworkConnection[nic_to_update].set('network', network)
            response['changed'] = True

        if ip_allocation_mode:
            allocation_mode_element = E.IpAddressAllocationMode(ip_allocation_mode)
            nics.NetworkConnection[nic_to_update].IpAddressAllocationMode = allocation_mode_element
            response['changed'] = True

        if ip_address:
            response['changed'] = True
            if hasattr(nics.NetworkConnection[nic_to_update], 'IpAddress'):
                nics.NetworkConnection[nic_to_update].IpAddress = E.IpAddress(ip_address)
            else:
                network = nics.NetworkConnection[nic_to_update].get('network')
                nics.NetworkConnection[nic_to_update] = E.NetworkConnection(
                    E.NetworkConnectionIndex(nic_id),
                    E.IpAddress(ip_address),
                    E.IsConnected(True),
                    E.IpAddressAllocationMode(ip_allocation_mode),
                    network=network)

        if response['changed']:
            update_nic_task = self.client.put_resource(uri, nics, EntityType.NETWORK_CONNECTION_SECTION.value)
            self.execute_task(update_nic_task)
            response['msg'] = 'vApp VM nic has been updated.'

        return response

    def validate_nic(self):
        '''
            Following update scenarios are covered
            1. IP allocation mode change: DHCP, POOL, MANUAL
            2. Update IP address in MANUAL mode
            3. Network change
        '''
        vm = self.get_vm()
        nic_id = self.params.get('nic_id')
        network = self.params.get('network')
        ip_address = self.params.get('ip_address')
        adapter_type = self.params.get('adapter_type')
        is_connected = self.params.get('is_connected')
        ip_allocation_mode = self.params.get('ip_allocation_mode')
        uri = vm.resource.get('href') + '/networkConnectionSection'
        response = defaultdict(dict)
        response['changed'] = False
        vm_name = self.params.get('vm_name')
        nics = self.get_vm_nics()
        nic_indexes = []
        if hasattr(nics, "NetworkConnection"):
            # If we find attr in nics object
            for nic in nics.NetworkConnection:
                nic_indexes.append(nic.NetworkConnectionIndex)
                self.nic_indexes = nic_indexes
                return self.nic_indexes
        else:
            #if getattr(nics, 'NetworkConnection', None):
            # Go add nic because no any adapters are present in VM
            #   we find attr in nics object
            # nic_id = self.params.get('nic_id')
            # nic = E.NetworkConnection(
            #     E.NetworkConnectionIndex(nic_id),
            #     E.IpAddress(ip_address),
            #     E.IsConnected(True),
            #     E.IpAddressAllocationMode(ip_allocation_mode),
            #     network=network)
            add_nic_task = vm.add_nic(adapter_type=adapter_type,
                                  is_connected=is_connected,
                                  network_name=network,
                                  ip_address_mode=ip_allocation_mode,
                                  ip_address=ip_address,
                                  nic_id=nic_id
                                  )
            self.execute_task(add_nic_task)
            response['msg'] = {
                'nic_id': nic_id,
                'adapter_type': adapter_type,
                'ip_allocation_mode': ip_allocation_mode,
                'ip_address': ip_address,
                'network': network,
                'is_connected': is_connected,
                'malinki': "vecerinki"
            }
            response['changed'] = True
            nics = self.vm.list_nics()
            nic_indexes = [nic.NetworkConnectionIndex for nic in nics.NetworkConnection]
            # for nic in nics.NetworkConnection:
            #     nic_indexes.append(nic.NetworkConnectionIndex)
            #     self.nic_indexes = nic_indexes
            #     return self.nic_indexes
            return response
        #     # adding_nic = self.execute_task(add_nic_task)
        #     nics.NetworkConnection.addnext(nic_id)
        #     #add_nic_task = self.client.put_resource(uri, nics, EntityType.NETWORK_CONNECTION_SECTION.value)
        #     self.execute_task(add_nic_task)
        #     response['msg'] = {
        #         'VM': vm_name,
        #         'A added nic with ID:': nic_id,
        #         'ip_allocation_mode': ip_allocation_mode,
        #         'ip_address': ip_address,
        #         'we_at_here': "we_at_here"
        #     }
        #     response['changed'] = True
        #     return response

        #     # response['msg'] = 'A new nic has been added to VM {0}, NICs list: {1}'.format(vm_name,str(nics))
        #     # response['changed'] = True
        #     # return self.add_nic()
        # #else:

        if nic_id not in nic_indexes:
            response['changed'] = 'go add NIC, because his not are found.'
            return self.validate_add_nic()
            #response['warnings'] = 'NIC not found.'
            # nic_to_update = nic_indexes.index(nic_id)
        if network:
            nics.NetworkConnection[nic_id].set('network', network)
            response['changed'] = True

        if ip_allocation_mode:
            allocation_mode_element = E.IpAddressAllocationMode(ip_allocation_mode)
            nics.NetworkConnection[nic_id].IpAddressAllocationMode = allocation_mode_element
            response['changed'] = True

        if ip_address:
            response['changed'] = True
            if hasattr(nics.NetworkConnection[nic_id], 'IpAddress'):
                nics.NetworkConnection[nic_id].IpAddress = E.IpAddress(ip_address)
            else:
                network = nics.NetworkConnection[nic_id].get('network')
                nics.NetworkConnection[nic_id] = E.NetworkConnection(
                    E.NetworkConnectionIndex(nic_id),
                    E.IpAddress(ip_address),
                    E.IsConnected(True),
                    E.IpAddressAllocationMode(ip_allocation_mode),
                    network=network)

        if response['changed']:
            update_nic_task = self.client.put_resource(uri, nics, EntityType.NETWORK_CONNECTION_SECTION.value)
            self.execute_task(update_nic_task)
            response['msg'] = 'vApp VM nic has been updated.'

        return response

    def read_nics(self):
        response = defaultdict(dict)
        response['changed'] = False

        nics = self.get_vm_nics()
        for nic in nics.NetworkConnection:
            meta = defaultdict(dict)
            nic_id = str(nic.NetworkConnectionIndex)
            meta['Network'] = str(nic.get('network'))
            meta['MACAddress'] = str(nic.MACAddress)
            meta['IsConnected'] = str(nic.IsConnected)
            meta['NetworkAdapterType'] = str(nic.NetworkAdapterType)
            meta['NetworkConnectionIndex'] = str(nic.NetworkConnectionIndex)
            meta['IpAddressAllocationMode'] = str(nic.IpAddressAllocationMode)

            if hasattr(nic, 'IpAddress'):
                meta['IpAddress'] = str(nic.IpAddress)

            response['msg'][nic_id] = meta

        return response

    def delete_nic(self):
        vm = self.get_vm()
        nic_ids = self.params.get('nic_ids')
        response = defaultdict(dict)
        response['changed'] = False
        uri = vm.resource.get('href') + '/networkConnectionSection'

        nics = self.get_vm_nics()
        for nic in nics.NetworkConnection:
            if nic.NetworkConnectionIndex in nic_ids:
                nics.remove(nic)
                nic_ids.remove(nic.NetworkConnectionIndex)

        if len(nic_ids) > 0:
            nic_ids = [str(nic_id) for nic_id in nic_ids]
            err_msg = 'Can\'t find the specified VM nic(s) {0}'.format(','.join(nic_ids))
            raise EntityNotFoundException(err_msg)

        remove_nic_task = self.client.put_resource(uri, nics, EntityType.NETWORK_CONNECTION_SECTION.value)
        self.execute_task(remove_nic_task)
        response['msg'] = 'VM nic(s) has been deleted.'
        response['changed'] = True

        return response

def main():
    argument_spec = vapp_vm_nic_argument_spec()
    response = dict(
        msg=dict(type='str')
    )
    module = VappVMNIC(argument_spec=argument_spec, supports_check_mode=True)

    try:
        if module.params.get('state'):
            response = module.manage_states()
        elif module.params.get('operation'):
            response = module.manage_operations()
        else:
            raise Exception('One of the state/operation should be provided.')

    except Exception as error:
        response['msg'] = error
        module.fail_json(**response)

    module.exit_json(**response)


if __name__ == '__main__':
    main()