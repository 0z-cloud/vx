# Copyright © 2018 VMware, Inc. All Rights Reserved.
# SPDX-License-Identifier: BSD-2-Clause OR GPL-3.0-only

# !/usr/bin/python

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'community'
}

DOCUMENTATION = '''
---
module: vcd_vapp_vm_nic
short_description: Manage VM NIC's states/operations in vCloud Director
version_added: "2.4"
description:
    - Manage VM NIC's states/operations in vCloud Director

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
    nic_ids:
        description:
            - List of NIC IDs
        required: false
    network:
        description:
            - VApp network name
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
            - state of nic (present/update/absent).
            - One from state or operation has to be provided.
        required: true
    operation:
        description:
            - operation on nic (read).
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
    vm: vm1
    vapp = vapp1
    vdc = vdc1
    network: acme_internal_direct
    ip_allocation_mode: DHCP
    is_connected: True
    adapter_type: E1000
    state = "present"
'''

RETURN = '''
msg: success/failure message corresponding to nic state
changed: true if resource has been changed else false
'''

from pyvcloud.vcd.vm import VM
from pyvcloud.vcd.org import Org
from pyvcloud.vcd.vdc import VDC
from pyvcloud.vcd.vapp import VApp
from pyvcloud.vcd.client import E
from pyvcloud.vcd.client import NSMAP
from pyvcloud.vcd.client import E_RASD
from copy import deepcopy
from lxml import etree
from pyvcloud.vcd.client import EntityType
from ansible.module_utils.vcd import VcdAnsibleModule
from pyvcloud.vcd.exceptions import OperationNotSupportedException
from pyvcloud.vcd.exceptions import EntityNotFoundException, InvalidParameterException
from collections import defaultdict
from collections import OrderedDict
from functools import reduce
from operator import or_

VAPP_VM_NIC_OPERATIONS = ['update', 'read', 'validate', 'get_nics_indexes']
IP_ALLOCATION_MODE = ["DHCP", "POOL", "MANUAL"]
VAPP_VM_NIC_STATES = ['read', 'present', 'absent', 'update', 'validate', 'get_nics_indexes']
NETWORK_ADAPTER_TYPE = ['VMXNET', 'VMXNET2', 'VMXNET3', 'E1000', 'E1000E', 'PCNet32']
METATYPE_STATES = ['meta', 'present', 'absent', 'update', 'validate', 'get_nics_indexes']
#app_defaults = {'username':'admin', 'password':'admin'}


def merge(*dicts):
    return { k: reduce(lambda d, x: x.get(k, d), dicts, None) for k in reduce(or_, map(lambda x: x.keys(), dicts), set()) }

def vapp_vm_nic_argument_spec():
    return dict(
        vm_name=dict(type='str', required=True),
        vapp=dict(type='str', required=True),
        vdc=dict(type='str', required=True),
        nic_id=dict(type='int', required=True),
        nic_ids=dict(type='list', required=False),
        ip_address=dict(type='str', required=False, default=None),
        network=dict(type='str', required=False),
        is_primary=dict(type='bool', required=False, default=False),
        is_connected=dict(type='bool', required=False, default=False),
        ip_allocation_mode=dict(choices=IP_ALLOCATION_MODE, required=False),
        adapter_type=dict(choices=NETWORK_ADAPTER_TYPE, required=True),
        state=dict(choices=VAPP_VM_NIC_STATES, required=False),
        operation=dict(choices=VAPP_VM_NIC_OPERATIONS, required=False),
        verification=dict(choices=METATYPE_STATES, required=False)
    )


class VappVMNICmeta(VcdAnsibleModule):
    def __init__(self, **kwargs):
        super(VappVMNIC, self).__init__(**kwargs)
        vapp_resource = self.get_resource()
        #vapp_vm_resource = self.get_vm_resource()
        #vapp = self.params.get('vapp')
        self.vapp = VApp(self.client, resource=vapp_resource)
        vapp = self.vapp
        nic_mapping = dict()
        self.nic_mapping = nic_mapping
        new_nic_id = None
        adapter_type = self.params.get('adapter_type')
        #vapp = self.vapp
        #nic_mapping = self.nic_mapping

    def manage_meta(self):
        verification = self.params.get('verification')
        if verification == "meta":
            return self.read_nics()
            #return self

    def manage_operations(self):
        operation = self.params.get('operation')
        if operation == "read":
            return self.read_nics()
        if operation == "update":
            return self.update_nics()
        if operation == "validate":
            return self.validate_nics()
        # if operation == "get_nics_indexes":
        #     return self.get_nics_with_indexes()

    def manage_states(self):
        state = self.params.get('state')
        if state == "validate":
            return self.add_nic()
        if state == "present":
            return self.add_nic()
        # if state == "sumo":
        #     return self.validate_nics()
        # if state == "update":
        #     return self.update_nic()
        # if state == "absent":
        #     return self.delete_nic()
        # if state == "get_nics_indexes":
        #     return self.get_nics_with_indexes()

    def get_nics_with_indexes(self):
        nic_id = self.params.get('nic_id')
        adapter_type = self.params.get('adapter_type')
        ip_allocation_mode = self.params.get('ip_allocation_mode')
        ip_address = self.params.get('ip_address')
        network = self.params.get('network')
        is_connected = self.params.get('is_connected')
        if ip_address is None:
            ip_address = "192.168.233.233"
        response = dict()
        response['changed'] = False
        #nics_read = self.read_nics()
        nics = self.get_vm_nics()
        nics_indexes = [int(nic.NetworkConnectionIndex) for nic in nics.NetworkConnection]
        nics_indexes.sort()
        # if nics_indexes is not None:
        #     for 
        #nics = self.get_vm_nics()
        #nic_indexs = [nic.NetworkConnectionIndex for nic in nics.NetworkConnection]
        # if nic_id not in nic_indexs:
        #     response['warnings'] = 'NIC not found.'
        #     response['msg'] = {
        #     'nic_id': nic_id,
        #     'adapter_type': adapter_type,
        #     'ip_allocation_mode': ip_allocation_mode,
        #     'ip_address': ip_address,
        #     'network': network,
        #     'is_connected': is_connected
        #     }
        #     return response
        # if nic_id in nic_indexs:
        #     response['changed'] = 'NIC ID has been found.'
        #     response['msg'] = {
        #     'nic_id': nic_id,
        #     'adapter_type': adapter_type,
        #     'ip_allocation_mode': ip_allocation_mode,
        #     'ip_address': ip_address,
        #     'network': network,
        #     'is_connected': is_connected
        #     }
        #     return response
        response['warnings'] = 'NIC ID NO CASE'
        return response
        #nic_to_update = nic_indexs.index(nic_id)

    def validate_nics(self):
        vm_name = self.params.get('vm_name')
        nic_id = self.params.get('nic_id')
        nic_state = self.params.get('nic_ids')
        gtntci = self.gtntci
        ip_allocation_mode = self.params.get('ip_allocation_mode')
        ip_address = self.params.get('ip_address')
        network = self.params.get('network')
        is_connected = self.params.get('is_connected')
        response['msg'] = {
            'A new nic has been added to VM:': vm_name,
            'A added nic with ID:': nic_id,
            'Ip allocation model': ip_allocation_mode,
            'Ip address': ip_address,
            'We at end of add_nic method': "add_nic",
            'nic_state:': nic_state,
            'gtntci:': gtntci,
            'is_connected:': is_connected,
            'network:': network
        }
        response['changed'] = True
        return response
        #self.meta = self.read_nics_ng()
        #vapp_resource = self.get_vapp_resource_resource_stateful()
        #self.read_nics()

        # GENERATE RESPONSE
        #read_nics = self.read_nics()
        # FETCH LIST NICS
        #return_nics = self.return_nics()

    def read_nics_ng(self):
        nics = self.get_vm_nics()
        meta = dict()
        if hasattr(nics, 'NetworkConnection'):
            meta['NetworkConnection'] = str(nics.NetworkConnection)
            for nic in nics.NetworkConnection:
                if hasattr(nic, 'NetworkConnectionIndex'):
                    nic_id = str(nic.NetworkConnectionIndex)
                    meta['Network'] = str(nic.get('network'))
                    meta['MACAddress'] = str(nic.MACAddress)
                    meta['IsConnected'] = str(nic.IsConnected)
                    meta['NetworkAdapterType'] = str(nic.NetworkAdapterType)
                    meta['NetworkConnectionIndex'] = str(nic.NetworkConnectionIndex)
                    meta['IpAddressAllocationMode'] = str(nic.IpAddressAllocationMode)
                    if hasattr(nic, 'IpAddress'):
                        meta['IpAddress'] = str(nic.IpAddress)
                    meta['index'] += nic_id
        return meta

    def get_vm_resource(self):
        vapp = self.params.get('vapp')
        vdc = self.params.get('vdc')
        vm_name = self.params.get('vm_name')
        nic_id = self.params.get('nic_id')
        org_resource = Org(self.client, resource=self.client.get_org())
        vdc_resource = VDC(self.client, resource=org_resource.get_vdc(vdc))
        vapp_vm_resource = self.get_vm()
        vapp_resource_href = vdc_resource.get_resource_href(
            name=vapp, entity_type=EntityType.VAPP)
        vapp_resource = self.client.get_resource(vapp_resource_href)
        return vapp_vm_resource

    def get_vapp_resource_resource_stateful(self):
        vapp = self.params.get('vapp')
        vdc = self.params.get('vdc')
        org_resource = Org(self.client, resource=self.client.get_org())
        vdc_resource = VDC(self.client, resource=org_resource.get_vdc(vdc))
        vapp_resource_href = vdc_resource.get_resource_href(name=vapp, entity_type=EntityType.VAPP)
        vapp_resource = self.client.get_resource(vapp_resource_href)
        return vapp_resource

    def get_resource(self):
        vapp = self.params.get('vapp')
        vdc = self.params.get('vdc')
        nic_id = self.params.get('nic_id')
        vm_name = self.params.get('vm_name')
        org_resource = Org(self.client, resource=self.client.get_org())
        vdc_resource = VDC(self.client, resource=org_resource.get_vdc(vdc))
        #vapp_vm_resource = self.get_vm()
        vapp_resource_href = vdc_resource.get_resource_href(
            name=vapp, entity_type=EntityType.VAPP)
        vapp_resource = self.client.get_resource(vapp_resource_href)
        return vapp_resource

    def get_vm(self):
        # vapp = self.params.get('vapp')
        vapp_vm_resource = self.vapp.get_vm(self.params.get('vm_name'))
        return VM(self.client, resource=vapp_vm_resource)

    def get_vm_nics(self):
        vm = self.get_vm()
        return self.client.get_resource(
            vm.resource.get('href') + '/networkConnectionSection')

    def add_nic(self):
        vm = self.get_vm()
        #self.':  = global.': 
        # vapp = self.params.get('vapp')
        vm_name = self.params.get('vm_name')
        nic_id = self.params.get('nic_id')
        network = self.params.get('network')
        ip_address = self.params.get('ip_address')
        ip_allocation_mode = self.params.get('ip_allocation_mode')
        adapter_type = self.params.get('adapter_type')
        is_primary = self.params.get('is_primary')
        is_connected = self.params.get('is_connected')
        response = dict()
        response['changed'] = False
        add_nic_task = vm.add_nic(adapter_type=adapter_type,
                                  is_primary=is_primary,
                                  is_connected=is_connected,
                                  network_name=network,
                                  ip_address_mode=ip_allocation_mode,
                                  ip_address=ip_address)
        self.execute_task(add_nic_task)
        response['msg'] = {
            'A new nic has been added to VM:': vm_name,
            'A added nic with ID:': nic_id,
            'Ip allocation model': ip_allocation_mode,
            'Ip address': ip_address,
            'We at end of add_nic method': "add_nic"
        }
        response['changed'] = True
        return response

    def update_nic(self):
        vm = self.get_vm()
        nic_id = self.params.get('nic_id')
        vapp = self.params.get('vapp')
        vm_name = self.params.get('vm_name')
        network = self.params.get('network')
        ip_address = self.params.get('ip_address')
        ip_allocation_mode = self.params.get('ip_allocation_mode')
        adapter_type = self.params.get('adapter_type')
        is_primary = self.params.get('is_primary')
        is_connected = self.params.get('is_connected')
        response = dict()
        response['changed'] = False

        try:
            update_nic_task = vm.update_nic(network_name=network,
                                            is_connected=is_connected,
                                            is_primary=is_primary,
                                            adapter_type=adapter_type,
                                            ip_address=ip_address,
                                            ip_address_mode=ip_allocation_mode)
            self.execute_task(update_nic_task)
            msg = 'A nic attached with VM {0} has been updated'
            response['msg'] = msg.format(vm_name)
            response['changed'] = True
        except EntityNotFoundException as error:
            response['msg'] = error.__str__()

        return response

    def read_nics(self):
        vm = self.get_vm()
        vm_in_vapp = self.return_vm_from_vapp()
        self.vm_in_vapp = vm_in_vapp
        nitc = self.params.get('nic_id')
        nids = self.params.get('nic_ids')
        rsp = d()
        nltl = list()
        try:
            ncls = vm.list_nics()
        except:
            rsp['changed'] = True
            ncls = ""
            # response['msg'] = 'not able to get any network connection entity because not are was found'
            # return response
        rsp['changed'] = False
        rsp['msg'] = ncls
        ':  = vm.list_nics()
        nap = False
        vncc = None
        for gnic in nids:
            nltl += gnic
        vntci = len(nltl)
        gtntci = len(ncls)
        mms = None

        if vntci == gtntci:
            mms = True
        else:
            mms = False

        if vntci > 0:
            vncc = True
        else:
            vncc = False
        nrcl = []
        if len(ncls) > 0:
            nap = True
            nrcl = len(ncls)
        else:
            nap = False
        self.nap = nap
        self.nrcl = nrcl
        self.vncc = vncc
        self.mms = mms
        self.gtntci = gtntci
        self.vntci = vntci
        self.':  = ': 
        self.ncls = ncls
        self.nltl = nltl
        self.nids = nids
        self.nitc = nitc
        rsp['meta_response'] = {
            'self.nap:': self.nap,
            'self.gtntci:': self.gtntci,
            'vntci': self.vntci,
            'self.': ': self.': ,
            'We at end of add_nic methxod': 'a_meta_response'
        }
        self.rsp = rsp
        self.rsp['changed'] = True
        #response['changed'] = True
        #return response
        return self
        # nics_readed_count = DeepDict(lambda: int(gtntci))
        # return vm, nitc, nrcl, nap, vncc, mms, vntci, gtntci, nltl, ncls, nids, rsp, ': 

    # def index_nic(self):
    #     vapp = self.params.get('vapp')
    #     if nic_id not in self.nic_mapping['vm_name']:
    #         self.nic_mapping['vm_name'].append(nic_id)

    # def read_nics_si(self):
    #     vapp = self.params.get('vapp')
    #     response = defaultdict(dict)
    #     response['changed'] = False

    #     nics = self.get_vm_nics()
    #     for nic in nics.NetworkConnection:
    #         meta = defaultdict(dict)
    #         nic_id = str(nic.NetworkConnectionIndex)
    #         meta['Network'] = str(nic.get('network'))
    #         meta['MACAddress'] = str(nic.MACAddress)
    #         meta['IsConnected'] = str(nic.IsConnected)
    #         meta['NetworkAdapterType'] = str(nic.NetworkAdapterType)
    #         meta['NetworkConnectionIndex'] = str(nic.NetworkConnectionIndex)
    #         meta['IpAddressAllocationMode'] = str(nic.IpAddressAllocationMode)

    #         if hasattr(nic, 'IpAddress'):
    #             meta['IpAddress'] = str(nic.IpAddress)

    #         response['msg'][nic_id] = meta

    #     return response

    # def return_nics_si(self):
    #     response = defaultdict(dict)
    #     response['changed'] = False
    #     vapp = self.params.get('vapp')
    #     nics = self.get_vm_nics()
    #     for nic in nics.NetworkConnection:
    #         meta = defaultdict(dict)
    #         nic_id = str(nic.NetworkConnectionIndex)
    #         if nic_id not in self.nic_mapping['vm_name']:
    #             self.nic_mapping['vm_name'].append(nic_id)
    #         meta['Network'] = str(nic.get('network'))
    #         meta['MACAddress'] = str(nic.MACAddress)
    #         meta['IsConnected'] = str(nic.IsConnected)
    #         meta['NetworkAdapterType'] = str(nic.NetworkAdapterType)
    #         meta['NetworkConnectionIndex'] = str(nic.NetworkConnectionIndex)
    #         meta['IpAddressAllocationMode'] = str(nic.IpAddressAllocationMode)

    #         if hasattr(nic, 'IpAddress'):
    #             meta['IpAddress'] = str(nic.IpAddress)

    #         response['msg'][nic_id] = meta

    #     return response

    def return_vm_from_vapp(self):
        vm_name_in_app = self.params.get('vm_name')
        vm_in_vapp = self.vapp.get_vm(vm_name_in_app)
        return vm_in_vapp

    def return_nics(self):
        vm = self.get_vm()
        response = dict()
        response['changed'] = False
        nics = vm.list_nics()
        return nics

    def delete_nic(self):
        vm = self.get_vm()
        vapp = self.params.get('vapp')
        nic_ids = self.params.get('nic_ids')
        vm_name = self.params.get('vm_name')
        response = dict()
        response['changed'] = False

        # VM should be powered off before deleting a nic
        if not vm.is_powered_off():
            msg = "VM {0} is powered on. Cant remove nics in the current state"
            raise OperationNotSupportedException(msg.format(vm_name))

        for nic_id in nic_ids:
            try:
                delete_nic_task = vm.delete_nic(nic_id)
                self.execute_task(delete_nic_task)
                response['changed'] = True
            except InvalidParameterException as error:
                response['msg'] = error.__str__()
            else:
                response['msg'] = 'VM nic(s) has been deleted'
        return response

class VappVMNICstate(VcdAnsibleModule):
    def __init__(self, **kwargs):
        super(VappVMNIC, self).__init__(**kwargs)
        vapp_resource = self.get_resource()
        #vapp_vm_resource = self.get_vm_resource()
        #vapp = self.params.get('vapp')
        self.vapp = VApp(self.client, resource=vapp_resource)
        vapp = self.vapp
        nic_mapping = dict()
        self.nic_mapping = nic_mapping
        new_nic_id = None
        adapter_type = self.params.get('adapter_type')
        #vapp = self.vapp
        #nic_mapping = self.nic_mapping

    def manage_meta(self):
        verification = self.params.get('verification')
        if verification == "meta":
            return self.read_nics()
            #return self

    def manage_operations(self):
        operation = self.params.get('operation')
        if operation == "read":
            return self.read_nics()
        if operation == "update":
            return self.update_nics()
        if operation == "validate":
            return self.validate_nics()
        # if operation == "get_nics_indexes":
        #     return self.get_nics_with_indexes()

    def manage_states(self):
        state = self.params.get('state')
        if state == "validate":
            return self.add_nic()
        if state == "present":
            return self.add_nic()
        # if state == "sumo":
        #     return self.validate_nics()
        # if state == "update":
        #     return self.update_nic()
        # if state == "absent":
        #     return self.delete_nic()
        # if state == "get_nics_indexes":
        #     return self.get_nics_with_indexes()

    def get_nics_with_indexes(self):
        nic_id = self.params.get('nic_id')
        adapter_type = self.params.get('adapter_type')
        ip_allocation_mode = self.params.get('ip_allocation_mode')
        ip_address = self.params.get('ip_address')
        network = self.params.get('network')
        is_connected = self.params.get('is_connected')
        if ip_address is None:
            ip_address = "192.168.233.233"
        response = dict()
        response['changed'] = False
        #nics_read = self.read_nics()
        nics = self.get_vm_nics()
        nics_indexes = [int(nic.NetworkConnectionIndex) for nic in nics.NetworkConnection]
        nics_indexes.sort()
        # if nics_indexes is not None:
        #     for 
        #nics = self.get_vm_nics()
        #nic_indexs = [nic.NetworkConnectionIndex for nic in nics.NetworkConnection]
        # if nic_id not in nic_indexs:
        #     response['warnings'] = 'NIC not found.'
        #     response['msg'] = {
        #     'nic_id': nic_id,
        #     'adapter_type': adapter_type,
        #     'ip_allocation_mode': ip_allocation_mode,
        #     'ip_address': ip_address,
        #     'network': network,
        #     'is_connected': is_connected
        #     }
        #     return response
        # if nic_id in nic_indexs:
        #     response['changed'] = 'NIC ID has been found.'
        #     response['msg'] = {
        #     'nic_id': nic_id,
        #     'adapter_type': adapter_type,
        #     'ip_allocation_mode': ip_allocation_mode,
        #     'ip_address': ip_address,
        #     'network': network,
        #     'is_connected': is_connected
        #     }
        #     return response
        response['warnings'] = 'NIC ID NO CASE'
        return response
        #nic_to_update = nic_indexs.index(nic_id)

    def validate_nics(self):
        vm_name = self.params.get('vm_name')
        nic_id = self.params.get('nic_id')
        nic_state = self.params.get('nic_ids')
        gtntci = self.gtntci
        ip_allocation_mode = self.params.get('ip_allocation_mode')
        ip_address = self.params.get('ip_address')
        network = self.params.get('network')
        is_connected = self.params.get('is_connected')
        response['msg'] = {
            'A new nic has been added to VM:': vm_name,
            'A added nic with ID:': nic_id,
            'Ip allocation model': ip_allocation_mode,
            'Ip address': ip_address,
            'We at end of add_nic method': "add_nic",
            'nic_state:': nic_state,
            'gtntci:': gtntci,
            'is_connected:': is_connected,
            'network:': network
        }
        response['changed'] = True
        return response
        #self.meta = self.read_nics_ng()
        #vapp_resource = self.get_vapp_resource_resource_stateful()
        #self.read_nics()

        # GENERATE RESPONSE
        #read_nics = self.read_nics()
        # FETCH LIST NICS
        #return_nics = self.return_nics()

    def read_nics_ng(self):
        nics = self.get_vm_nics()
        meta = dict()
        if hasattr(nics, 'NetworkConnection'):
            meta['NetworkConnection'] = str(nics.NetworkConnection)
            for nic in nics.NetworkConnection:
                if hasattr(nic, 'NetworkConnectionIndex'):
                    nic_id = str(nic.NetworkConnectionIndex)
                    meta['Network'] = str(nic.get('network'))
                    meta['MACAddress'] = str(nic.MACAddress)
                    meta['IsConnected'] = str(nic.IsConnected)
                    meta['NetworkAdapterType'] = str(nic.NetworkAdapterType)
                    meta['NetworkConnectionIndex'] = str(nic.NetworkConnectionIndex)
                    meta['IpAddressAllocationMode'] = str(nic.IpAddressAllocationMode)
                    if hasattr(nic, 'IpAddress'):
                        meta['IpAddress'] = str(nic.IpAddress)
                    meta['index'] += nic_id
        return meta

    def get_vm_resource(self):
        vapp = self.params.get('vapp')
        vdc = self.params.get('vdc')
        vm_name = self.params.get('vm_name')
        nic_id = self.params.get('nic_id')
        org_resource = Org(self.client, resource=self.client.get_org())
        vdc_resource = VDC(self.client, resource=org_resource.get_vdc(vdc))
        vapp_vm_resource = self.get_vm()
        vapp_resource_href = vdc_resource.get_resource_href(
            name=vapp, entity_type=EntityType.VAPP)
        vapp_resource = self.client.get_resource(vapp_resource_href)
        return vapp_vm_resource

    def get_vapp_resource_resource_stateful(self):
        vapp = self.params.get('vapp')
        vdc = self.params.get('vdc')
        org_resource = Org(self.client, resource=self.client.get_org())
        vdc_resource = VDC(self.client, resource=org_resource.get_vdc(vdc))
        vapp_resource_href = vdc_resource.get_resource_href(name=vapp, entity_type=EntityType.VAPP)
        vapp_resource = self.client.get_resource(vapp_resource_href)
        return vapp_resource

    def get_resource(self):
        vapp = self.params.get('vapp')
        vdc = self.params.get('vdc')
        nic_id = self.params.get('nic_id')
        vm_name = self.params.get('vm_name')
        org_resource = Org(self.client, resource=self.client.get_org())
        vdc_resource = VDC(self.client, resource=org_resource.get_vdc(vdc))
        #vapp_vm_resource = self.get_vm()
        vapp_resource_href = vdc_resource.get_resource_href(
            name=vapp, entity_type=EntityType.VAPP)
        vapp_resource = self.client.get_resource(vapp_resource_href)
        return vapp_resource

    def get_vm(self):
        # vapp = self.params.get('vapp')
        vapp_vm_resource = self.vapp.get_vm(self.params.get('vm_name'))
        return VM(self.client, resource=vapp_vm_resource)

    def get_vm_nics(self):
        vm = self.get_vm()
        return self.client.get_resource(
            vm.resource.get('href') + '/networkConnectionSection')

    def add_nic(self):
        vm = self.get_vm()
        #self.':  = global.': 
        # vapp = self.params.get('vapp')
        vm_name = self.params.get('vm_name')
        nic_id = self.params.get('nic_id')
        network = self.params.get('network')
        ip_address = self.params.get('ip_address')
        ip_allocation_mode = self.params.get('ip_allocation_mode')
        adapter_type = self.params.get('adapter_type')
        is_primary = self.params.get('is_primary')
        is_connected = self.params.get('is_connected')
        response = dict()
        response['changed'] = False
        add_nic_task = vm.add_nic(adapter_type=adapter_type,
                                  is_primary=is_primary,
                                  is_connected=is_connected,
                                  network_name=network,
                                  ip_address_mode=ip_allocation_mode,
                                  ip_address=ip_address)
        self.execute_task(add_nic_task)
        response['msg'] = {
            'A new nic has been added to VM:': vm_name,
            'A added nic with ID:': nic_id,
            'Ip allocation model': ip_allocation_mode,
            'Ip address': ip_address,
            'We at end of add_nic method': "add_nic"
        }
        response['changed'] = True
        return response

    def update_nic(self):
        vm = self.get_vm()
        nic_id = self.params.get('nic_id')
        vapp = self.params.get('vapp')
        vm_name = self.params.get('vm_name')
        network = self.params.get('network')
        ip_address = self.params.get('ip_address')
        ip_allocation_mode = self.params.get('ip_allocation_mode')
        adapter_type = self.params.get('adapter_type')
        is_primary = self.params.get('is_primary')
        is_connected = self.params.get('is_connected')
        response = dict()
        response['changed'] = False

        try:
            update_nic_task = vm.update_nic(network_name=network,
                                            is_connected=is_connected,
                                            is_primary=is_primary,
                                            adapter_type=adapter_type,
                                            ip_address=ip_address,
                                            ip_address_mode=ip_allocation_mode)
            self.execute_task(update_nic_task)
            msg = 'A nic attached with VM {0} has been updated'
            response['msg'] = msg.format(vm_name)
            response['changed'] = True
        except EntityNotFoundException as error:
            response['msg'] = error.__str__()

        return response

    def read_nics(self):
        vm = self.get_vm()
        vm_in_vapp = self.return_vm_from_vapp()
        self.vm_in_vapp = vm_in_vapp
        nitc = self.params.get('nic_id')
        nids = self.params.get('nic_ids')
        rsp = d()
        nltl = list()
        try:
            ncls = vm.list_nics()
        except:
            rsp['changed'] = True
            ncls = ""
            # response['msg'] = 'not able to get any network connection entity because not are was found'
            # return response
        rsp['changed'] = False
        rsp['msg'] = ncls
        ':  = vm.list_nics()
        nap = False
        vncc = None
        for gnic in nids:
            nltl += gnic
        vntci = len(nltl)
        gtntci = len(ncls)
        mms = None

        if vntci == gtntci:
            mms = True
        else:
            mms = False

        if vntci > 0:
            vncc = True
        else:
            vncc = False
        nrcl = []
        if len(ncls) > 0:
            nap = True
            nrcl = len(ncls)
        else:
            nap = False
        self.nap = nap
        self.nrcl = nrcl
        self.vncc = vncc
        self.mms = mms
        self.gtntci = gtntci
        self.vntci = vntci
        self.':  = ': 
        self.ncls = ncls
        self.nltl = nltl
        self.nids = nids
        self.nitc = nitc
        rsp['meta_response'] = {
            'self.nap:': self.nap,
            'self.gtntci:': self.gtntci,
            'vntci': self.vntci,
            'self.': ': self.': ,
            'We at end of add_nic methxod': 'a_meta_response'
        }
        self.rsp = rsp
        self.rsp['changed'] = True
        #response['changed'] = True
        #return response
        return self
        # nics_readed_count = DeepDict(lambda: int(gtntci))
        # return vm, nitc, nrcl, nap, vncc, mms, vntci, gtntci, nltl, ncls, nids, rsp, ': 

    # def index_nic(self):
    #     vapp = self.params.get('vapp')
    #     if nic_id not in self.nic_mapping['vm_name']:
    #         self.nic_mapping['vm_name'].append(nic_id)

    # def read_nics_si(self):
    #     vapp = self.params.get('vapp')
    #     response = defaultdict(dict)
    #     response['changed'] = False

    #     nics = self.get_vm_nics()
    #     for nic in nics.NetworkConnection:
    #         meta = defaultdict(dict)
    #         nic_id = str(nic.NetworkConnectionIndex)
    #         meta['Network'] = str(nic.get('network'))
    #         meta['MACAddress'] = str(nic.MACAddress)
    #         meta['IsConnected'] = str(nic.IsConnected)
    #         meta['NetworkAdapterType'] = str(nic.NetworkAdapterType)
    #         meta['NetworkConnectionIndex'] = str(nic.NetworkConnectionIndex)
    #         meta['IpAddressAllocationMode'] = str(nic.IpAddressAllocationMode)

    #         if hasattr(nic, 'IpAddress'):
    #             meta['IpAddress'] = str(nic.IpAddress)

    #         response['msg'][nic_id] = meta

    #     return response

    # def return_nics_si(self):
    #     response = defaultdict(dict)
    #     response['changed'] = False
    #     vapp = self.params.get('vapp')
    #     nics = self.get_vm_nics()
    #     for nic in nics.NetworkConnection:
    #         meta = defaultdict(dict)
    #         nic_id = str(nic.NetworkConnectionIndex)
    #         if nic_id not in self.nic_mapping['vm_name']:
    #             self.nic_mapping['vm_name'].append(nic_id)
    #         meta['Network'] = str(nic.get('network'))
    #         meta['MACAddress'] = str(nic.MACAddress)
    #         meta['IsConnected'] = str(nic.IsConnected)
    #         meta['NetworkAdapterType'] = str(nic.NetworkAdapterType)
    #         meta['NetworkConnectionIndex'] = str(nic.NetworkConnectionIndex)
    #         meta['IpAddressAllocationMode'] = str(nic.IpAddressAllocationMode)

    #         if hasattr(nic, 'IpAddress'):
    #             meta['IpAddress'] = str(nic.IpAddress)

    #         response['msg'][nic_id] = meta

    #     return response

    def return_vm_from_vapp(self):
        vm_name_in_app = self.params.get('vm_name')
        vm_in_vapp = self.vapp.get_vm(vm_name_in_app)
        return vm_in_vapp

    def return_nics(self):
        vm = self.get_vm()
        response = dict()
        response['changed'] = False
        nics = vm.list_nics()
        return nics

    def delete_nic(self):
        vm = self.get_vm()
        vapp = self.params.get('vapp')
        nic_ids = self.params.get('nic_ids')
        vm_name = self.params.get('vm_name')
        response = dict()
        response['changed'] = False

        # VM should be powered off before deleting a nic
        if not vm.is_powered_off():
            msg = "VM {0} is powered on. Cant remove nics in the current state"
            raise OperationNotSupportedException(msg.format(vm_name))

        for nic_id in nic_ids:
            try:
                delete_nic_task = vm.delete_nic(nic_id)
                self.execute_task(delete_nic_task)
                response['changed'] = True
            except InvalidParameterException as error:
                response['msg'] = error.__str__()
            else:
                response['msg'] = 'VM nic(s) has been deleted'
        return response

class VappVMNIC(VcdAnsibleModule):
    def __init__(self, **kwargs):
        super(VappVMNIC, self).__init__(**kwargs)
        vapp_resource = self.get_resource()
        #vapp_vm_resource = self.get_vm_resource()
        #vapp = self.params.get('vapp')
        self.vapp = VApp(self.client, resource=vapp_resource)
        vapp = self.vapp
        nic_mapping = dict()
        self.nic_mapping = nic_mapping
        new_nic_id = None
        adapter_type = self.params.get('adapter_type')
        #vapp = self.vapp
        #nic_mapping = self.nic_mapping

    def manage_meta(self):
        verification = self.params.get('verification')
        if verification == "meta":
            return self.read_nics()
            #return self

    def manage_operations(self):
        operation = self.params.get('operation')
        if operation == "read":
            return self.read_nics()
        if operation == "update":
            return self.update_nics()
        if operation == "validate":
            return self.validate_nics()
        # if operation == "get_nics_indexes":
        #     return self.get_nics_with_indexes()

    def manage_states(self):
        state = self.params.get('state')
        if state == "validate":
            return self.add_nic()
        if state == "present":
            return self.add_nic()
        # if state == "sumo":
        #     return self.validate_nics()
        # if state == "update":
        #     return self.update_nic()
        # if state == "absent":
        #     return self.delete_nic()
        # if state == "get_nics_indexes":
        #     return self.get_nics_with_indexes()

    def get_nics_with_indexes(self):
        nic_id = self.params.get('nic_id')
        adapter_type = self.params.get('adapter_type')
        ip_allocation_mode = self.params.get('ip_allocation_mode')
        ip_address = self.params.get('ip_address')
        network = self.params.get('network')
        is_connected = self.params.get('is_connected')
        if ip_address is None:
            ip_address = "192.168.233.233"
        response = dict()
        response['changed'] = False
        #nics_read = self.read_nics()
        nics = self.get_vm_nics()
        nics_indexes = [int(nic.NetworkConnectionIndex) for nic in nics.NetworkConnection]
        nics_indexes.sort()
        # if nics_indexes is not None:
        #     for 
        #nics = self.get_vm_nics()
        #nic_indexs = [nic.NetworkConnectionIndex for nic in nics.NetworkConnection]
        # if nic_id not in nic_indexs:
        #     response['warnings'] = 'NIC not found.'
        #     response['msg'] = {
        #     'nic_id': nic_id,
        #     'adapter_type': adapter_type,
        #     'ip_allocation_mode': ip_allocation_mode,
        #     'ip_address': ip_address,
        #     'network': network,
        #     'is_connected': is_connected
        #     }
        #     return response
        # if nic_id in nic_indexs:
        #     response['changed'] = 'NIC ID has been found.'
        #     response['msg'] = {
        #     'nic_id': nic_id,
        #     'adapter_type': adapter_type,
        #     'ip_allocation_mode': ip_allocation_mode,
        #     'ip_address': ip_address,
        #     'network': network,
        #     'is_connected': is_connected
        #     }
        #     return response
        response['warnings'] = 'NIC ID NO CASE'
        return response
        #nic_to_update = nic_indexs.index(nic_id)

    def validate_nics(self):
        vm_name = self.params.get('vm_name')
        nic_id = self.params.get('nic_id')
        nic_state = self.params.get('nic_ids')
        gtntci = self.gtntci
        ip_allocation_mode = self.params.get('ip_allocation_mode')
        ip_address = self.params.get('ip_address')
        network = self.params.get('network')
        is_connected = self.params.get('is_connected')
        response['msg'] = {
            'A new nic has been added to VM:': vm_name,
            'A added nic with ID:': nic_id,
            'Ip allocation model': ip_allocation_mode,
            'Ip address': ip_address,
            'We at end of add_nic method': "add_nic",
            'nic_state:': nic_state,
            'gtntci:': gtntci,
            'is_connected:': is_connected,
            'network:': network
        }
        response['changed'] = True
        return response
        #self.meta = self.read_nics_ng()
        #vapp_resource = self.get_vapp_resource_resource_stateful()
        #self.read_nics()

        # GENERATE RESPONSE
        #read_nics = self.read_nics()
        # FETCH LIST NICS
        #return_nics = self.return_nics()

    def read_nics_ng(self):
        nics = self.get_vm_nics()
        meta = dict()
        if hasattr(nics, 'NetworkConnection'):
            meta['NetworkConnection'] = str(nics.NetworkConnection)
            for nic in nics.NetworkConnection:
                if hasattr(nic, 'NetworkConnectionIndex'):
                    nic_id = str(nic.NetworkConnectionIndex)
                    meta['Network'] = str(nic.get('network'))
                    meta['MACAddress'] = str(nic.MACAddress)
                    meta['IsConnected'] = str(nic.IsConnected)
                    meta['NetworkAdapterType'] = str(nic.NetworkAdapterType)
                    meta['NetworkConnectionIndex'] = str(nic.NetworkConnectionIndex)
                    meta['IpAddressAllocationMode'] = str(nic.IpAddressAllocationMode)
                    if hasattr(nic, 'IpAddress'):
                        meta['IpAddress'] = str(nic.IpAddress)
                    meta['index'] += nic_id
        return meta

    def get_vm_resource(self):
        vapp = self.params.get('vapp')
        vdc = self.params.get('vdc')
        vm_name = self.params.get('vm_name')
        nic_id = self.params.get('nic_id')
        org_resource = Org(self.client, resource=self.client.get_org())
        vdc_resource = VDC(self.client, resource=org_resource.get_vdc(vdc))
        vapp_vm_resource = self.get_vm()
        vapp_resource_href = vdc_resource.get_resource_href(
            name=vapp, entity_type=EntityType.VAPP)
        vapp_resource = self.client.get_resource(vapp_resource_href)
        return vapp_vm_resource

    def get_vapp_resource_resource_stateful(self):
        vapp = self.params.get('vapp')
        vdc = self.params.get('vdc')
        org_resource = Org(self.client, resource=self.client.get_org())
        vdc_resource = VDC(self.client, resource=org_resource.get_vdc(vdc))
        vapp_resource_href = vdc_resource.get_resource_href(name=vapp, entity_type=EntityType.VAPP)
        vapp_resource = self.client.get_resource(vapp_resource_href)
        return vapp_resource

    def get_resource(self):
        vapp = self.params.get('vapp')
        vdc = self.params.get('vdc')
        nic_id = self.params.get('nic_id')
        vm_name = self.params.get('vm_name')
        org_resource = Org(self.client, resource=self.client.get_org())
        vdc_resource = VDC(self.client, resource=org_resource.get_vdc(vdc))
        #vapp_vm_resource = self.get_vm()
        vapp_resource_href = vdc_resource.get_resource_href(
            name=vapp, entity_type=EntityType.VAPP)
        vapp_resource = self.client.get_resource(vapp_resource_href)
        return vapp_resource

    def get_vm(self):
        # vapp = self.params.get('vapp')
        vapp_vm_resource = self.vapp.get_vm(self.params.get('vm_name'))
        return VM(self.client, resource=vapp_vm_resource)

    def get_vm_nics(self):
        vm = self.get_vm()
        return self.client.get_resource(
            vm.resource.get('href') + '/networkConnectionSection')

    def add_nic(self):
        vm = self.get_vm()
        #self.':  = global.': 
        # vapp = self.params.get('vapp')
        vm_name = self.params.get('vm_name')
        nic_id = self.params.get('nic_id')
        network = self.params.get('network')
        ip_address = self.params.get('ip_address')
        ip_allocation_mode = self.params.get('ip_allocation_mode')
        adapter_type = self.params.get('adapter_type')
        is_primary = self.params.get('is_primary')
        is_connected = self.params.get('is_connected')
        response = dict()
        response['changed'] = False
        add_nic_task = vm.add_nic(adapter_type=adapter_type,
                                  is_primary=is_primary,
                                  is_connected=is_connected,
                                  network_name=network,
                                  ip_address_mode=ip_allocation_mode,
                                  ip_address=ip_address)
        self.execute_task(add_nic_task)
        response['msg'] = {
            'A new nic has been added to VM:': vm_name,
            'A added nic with ID:': nic_id,
            'Ip allocation model': ip_allocation_mode,
            'Ip address': ip_address,
            'We at end of add_nic method': "add_nic"
        }
        response['changed'] = True
        return response

    def update_nic(self):
        vm = self.get_vm()
        nic_id = self.params.get('nic_id')
        vapp = self.params.get('vapp')
        vm_name = self.params.get('vm_name')
        network = self.params.get('network')
        ip_address = self.params.get('ip_address')
        ip_allocation_mode = self.params.get('ip_allocation_mode')
        adapter_type = self.params.get('adapter_type')
        is_primary = self.params.get('is_primary')
        is_connected = self.params.get('is_connected')
        response = dict()
        response['changed'] = False

        try:
            update_nic_task = vm.update_nic(network_name=network,
                                            is_connected=is_connected,
                                            is_primary=is_primary,
                                            adapter_type=adapter_type,
                                            ip_address=ip_address,
                                            ip_address_mode=ip_allocation_mode)
            self.execute_task(update_nic_task)
            msg = 'A nic attached with VM {0} has been updated'
            response['msg'] = msg.format(vm_name)
            response['changed'] = True
        except EntityNotFoundException as error:
            response['msg'] = error.__str__()

        return response

    def read_nics(self):
        vm = self.get_vm()
        vm_in_vapp = self.return_vm_from_vapp()
        self.vm_in_vapp = vm_in_vapp
        nitc = self.params.get('nic_id')
        nids = self.params.get('nic_ids')
        rsp = d()
        nltl = list()
        try:
            ncls = vm.list_nics()
        except:
            rsp['changed'] = True
            ncls = ""
            # response['msg'] = 'not able to get any network connection entity because not are was found'
            # return response
        rsp['changed'] = False
        rsp['msg'] = ncls
        ':  = vm.list_nics()
        nap = False
        vncc = None
        for gnic in nids:
            nltl += gnic
        vntci = len(nltl)
        gtntci = len(ncls)
        mms = None

        if vntci == gtntci:
            mms = True
        else:
            mms = False

        if vntci > 0:
            vncc = True
        else:
            vncc = False
        nrcl = []
        if len(ncls) > 0:
            nap = True
            nrcl = len(ncls)
        else:
            nap = False
        self.nap = nap
        self.nrcl = nrcl
        self.vncc = vncc
        self.mms = mms
        self.gtntci = gtntci
        self.vntci = vntci
        self.':  = ': 
        self.ncls = ncls
        self.nltl = nltl
        self.nids = nids
        self.nitc = nitc
        rsp['meta_response'] = {
            'self.nap:': self.nap,
            'self.gtntci:': self.gtntci,
            'vntci': self.vntci,
            'self.': ': self.': ,
            'We at end of add_nic methxod': 'a_meta_response'
        }
        self.rsp = rsp
        self.rsp['changed'] = True
        #response['changed'] = True
        #return response
        return self
        # nics_readed_count = DeepDict(lambda: int(gtntci))
        # return vm, nitc, nrcl, nap, vncc, mms, vntci, gtntci, nltl, ncls, nids, rsp, ': 

    # def index_nic(self):
    #     vapp = self.params.get('vapp')
    #     if nic_id not in self.nic_mapping['vm_name']:
    #         self.nic_mapping['vm_name'].append(nic_id)

    # def read_nics_si(self):
    #     vapp = self.params.get('vapp')
    #     response = defaultdict(dict)
    #     response['changed'] = False

    #     nics = self.get_vm_nics()
    #     for nic in nics.NetworkConnection:
    #         meta = defaultdict(dict)
    #         nic_id = str(nic.NetworkConnectionIndex)
    #         meta['Network'] = str(nic.get('network'))
    #         meta['MACAddress'] = str(nic.MACAddress)
    #         meta['IsConnected'] = str(nic.IsConnected)
    #         meta['NetworkAdapterType'] = str(nic.NetworkAdapterType)
    #         meta['NetworkConnectionIndex'] = str(nic.NetworkConnectionIndex)
    #         meta['IpAddressAllocationMode'] = str(nic.IpAddressAllocationMode)

    #         if hasattr(nic, 'IpAddress'):
    #             meta['IpAddress'] = str(nic.IpAddress)

    #         response['msg'][nic_id] = meta

    #     return response

    # def return_nics_si(self):
    #     response = defaultdict(dict)
    #     response['changed'] = False
    #     vapp = self.params.get('vapp')
    #     nics = self.get_vm_nics()
    #     for nic in nics.NetworkConnection:
    #         meta = defaultdict(dict)
    #         nic_id = str(nic.NetworkConnectionIndex)
    #         if nic_id not in self.nic_mapping['vm_name']:
    #             self.nic_mapping['vm_name'].append(nic_id)
    #         meta['Network'] = str(nic.get('network'))
    #         meta['MACAddress'] = str(nic.MACAddress)
    #         meta['IsConnected'] = str(nic.IsConnected)
    #         meta['NetworkAdapterType'] = str(nic.NetworkAdapterType)
    #         meta['NetworkConnectionIndex'] = str(nic.NetworkConnectionIndex)
    #         meta['IpAddressAllocationMode'] = str(nic.IpAddressAllocationMode)

    #         if hasattr(nic, 'IpAddress'):
    #             meta['IpAddress'] = str(nic.IpAddress)

    #         response['msg'][nic_id] = meta

    #     return response

    def return_vm_from_vapp(self):
        vm_name_in_app = self.params.get('vm_name')
        vm_in_vapp = self.vapp.get_vm(vm_name_in_app)
        return vm_in_vapp

    def return_nics(self):
        vm = self.get_vm()
        response = dict()
        response['changed'] = False
        nics = vm.list_nics()
        return nics

    def delete_nic(self):
        vm = self.get_vm()
        vapp = self.params.get('vapp')
        nic_ids = self.params.get('nic_ids')
        vm_name = self.params.get('vm_name')
        response = dict()
        response['changed'] = False

        # VM should be powered off before deleting a nic
        if not vm.is_powered_off():
            msg = "VM {0} is powered on. Cant remove nics in the current state"
            raise OperationNotSupportedException(msg.format(vm_name))

        for nic_id in nic_ids:
            try:
                delete_nic_task = vm.delete_nic(nic_id)
                self.execute_task(delete_nic_task)
                response['changed'] = True
            except InvalidParameterException as error:
                response['msg'] = error.__str__()
            else:
                response['msg'] = 'VM nic(s) has been deleted'
        return response

def main():
    argument_spec = vapp_vm_nic_argument_spec()
    response = dict(msg=dict(type='str'))
    meta_response = dict(msg=dict(type='str'))
    operation_response = dict(msg=dict(type='str'))
    state_response = dict(msg=dict(type='str'))
    state_module = VappVMNICstate(argument_spec=argument_spec)
    meta_module = VappVMNICmeta(argument_spec=argument_spec)
    operation_module = VappVMNIC(argument_spec=argument_spec)
    module = VappVMNIC(argument_spec=argument_spec)

    try:

        if meta_module.params.get('verification'):
            meta_response = meta_module.manage_meta()
            self.meta_module = meta_response
            meta_response['msg'] = 'Verification for nic(s) has been completed'
            response = merge(response, meta_response)

    except:

        if state_module.params.get('state'):
            state_response = state_module.manage_states()
            state_response['msg'] = 'VM nic(s) has been added because verification has been failed'
            response = merge(response, state_response)

    finally:
        if operation_module.params.get('operation'):
            operation_response = operation_module.manage_operations()
            operation_response['msg'] = 'VM nic(s) has validated has been complete'
            response = merge(response, operation_response)
    module.exit_json(**response)

if __name__ == '__main__':
    main()