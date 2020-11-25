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

from collections import defaultdict
from copy import deepcopy
from lxml import etree
from pyvcloud.vcd.vm import VM
from pyvcloud.vcd.org import Org
from pyvcloud.vcd.vdc import VDC
from pyvcloud.vcd.client import E
from pyvcloud.vcd.vapp import VApp
from pyvcloud.vcd.client import NSMAP
from pyvcloud.vcd.client import E_RASD
from pyvcloud.vcd.client import EntityType
from pyvcloud.vcd.exceptions import EntityNotFoundException
from pyvcloud.vcd.exceptions import OperationNotSupportedException
from pyvcloud.vcd.exceptions import EntityNotFoundException, InvalidParameterException
from ansible.module_utils.vcd import VcdAnsibleModule


VAPP_VM_NIC_OPERATIONS = ["update", "read", "validate", "get_nics_indexes"]
IP_ALLOCATION_MODE = ["DHCP", "POOL", "MANUAL"]
VAPP_VM_NIC_STATES = ["read", "present", "absent", "update", "validate", "get_nics_indexes"]
NETWORK_ADAPTER_TYPE = ["VMXNET", "VMXNET2", "VMXNET3", "E1000", "E1000E", "PCNet32"]

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
        operation=dict(choices=VAPP_VM_NIC_OPERATIONS, required=True)
    )

def vapp_vm_argument_spec():
    return dict(
        target_vm_name=dict(type='str', required=True),
        target_vapp=dict(type='str', required=True),
        target_vdc=dict(type='str', required=True),
        source_vdc=dict(type='str', required=False),
        source_vapp=dict(type='str', required=False),
        source_catalog_name=dict(type='str', required=False),
        source_template_name=dict(type='str', required=False),
        source_vm_name=dict(type='str', required=False),
        hostname=dict(type='str', required=False),
        vmpassword=dict(type='str', required=False),
        vmpassword_auto=dict(type='bool', required=False),
        vmpassword_reset=dict(type='bool', required=False),
        cust_script=dict(type='str', required=False, default=''),
        network=dict(type='str', required=False),
        storage_profile=dict(type='str', required=False, default=''),
        ip_allocation_mode=dict(type='str', required=False, default='DHCP'),
        virtual_cpus=dict(type='int', required=False),
        cores_per_socket=dict(type='int', required=False, default=None),
        memory=dict(type='int', required=False),
        deploy=dict(type='bool', required=False, default=True),
        power_on=dict(type='bool', required=False, default=True),
        all_eulas_accepted=dict(type='bool', required=False, default=None),
        properties=dict(type='dict', required=False),
        state=dict(choices=VAPP_VM_STATES, required=False),
        operation=dict(choices=VAPP_VM_OPERATIONS, required=False),
        adapter_type=dict(choices=NETWORK_ADAPTER_TYPE, required=False),
        force_customization=dict(type='bool', required=False, default=False)
    )

class VappVMNIC(VcdAnsibleModule):
    def __init__(self, **kwargs):
        super(VappVMNIC, self).__init__(**kwargs)
        vapp_resource = self.get_resource()
        vapp = VApp(self.client, resource=vapp_resource)

    def manage_states(self):
        state = self.params.get('state')
        if state == "validate":
            return self.add_nic()

        if state == "present":
            return self.add_nic()

        if state == "update":
            return self.update_nic()

        if state == "absent":
            return self.delete_nic()

        if state == "get_nics_indexes":
            return self.get_nics_with_indexes()

        if state == "read":
            return self.read_nics()

    def manage_operations(self):
        operation = self.params.get('operation')

        if operation == "read":
            return self.read_nics()

        if operation == "update":
            return self.update_nics()

        if operation == "validatei":
            return self.validate_nics()

        if operation == "get_nics_indexes":
            return self.get_nics_with_indexes()

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

    def get_resource(self):
        vapp = self.params.get('vapp')
        vdc = self.params.get('vdc')
        org_resource = Org(self.client, resource=self.client.get_org())
        vdc_resource = VDC(self.client, resource=org_resource.get_vdc(vdc))
        vapp_resource_href = vdc_resource.get_resource_href(name=vapp, entity_type=EntityType.VAPP)
        vapp_resource = self.client.get_resource(vapp_resource_href)

        return vapp_resource

    def get_vm(self):
        vapp_vm_resource = self.vapp.get_vm(self.params.get('vm_name'))

        return VM(self.client, resource=vapp_vm_resource)

    def get_vm_nics(self):
        vm = self.get_vm()

        return self.client.get_resource(
            vm.resource.get('href') + '/networkConnectionSection')

    def validate_nics(self):
        nics = self.return_nics()
        response['msg'] = 'A new nic has been added to VM {vm_name}, NICs list: {nics}'
        response['changed'] = True
        return response
        #nics = self.read_nics()
        #return meta_index

    def get_vapp_resource_resource_stateful(self):
        vapp = self.params.get('vapp')
        vdc = self.params.get('vdc')
        org_resource = Org(self.client, resource=self.client.get_org())
        vdc_resource = VDC(self.client, resource=org_resource.get_vdc(vdc))
        vapp_resource_href = vdc_resource.get_resource_href(name=vapp, entity_type=EntityType.VAPP)
        vapp_resource = self.client.get_resource(vapp_resource_href)
        return vapp_resource

    def get_vm_nics(self):
        vm = self.get_vm()
        return self.client.get_resource(vm.resource.get('href') + '/networkConnectionSection')

    def get_vm_by_resource(self):
        vapp_vm_resource = self.vapp.get_vm(self.params.get('vm_name'))
        return VM(self.client, resource=vapp_vm_resource)
    
    def get_vm_nics(self):
        vm = self.get_vm()
        return self.client.get_resource(vm.resource.get('href') + '/networkConnectionSection')

    def add_nic(self):
        vm = self.get_vm()
        self.vm = vm
        # vapp = self.params.get('vapp'),
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
        nics = self.vm.list_nics()
        #nics = self.get_vm_nics()
        # nics_indexes = [int(nic.NetworkConnectionIndex) for nic in nics.NetworkConnection]
        # nics_indexes.sort()

        # for nic in nics.NetworkConnection:
        #     if nic.NetworkConnectionIndex == nic_id:
        #         response['warnings'] = 'NIC {} is already present on VM {}'.format(
        #             nic_id, vm_name)
        #         return response

        add_nic_task = vm.add_nic(adapter_type=adapter_type,
                                  is_primary=is_primary,
                                  is_connected=is_connected,
                                  index=nic_id,
                                  network_name=network,
                                  ip_address_mode=ip_allocation_mode,
                                  ip_address=ip_address)
        self.execute_task(add_nic_task)
        response['msg'] = 'A new nic has been added to VM {0}, NICs list: {1}'.format(vm_name,str(nics))
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
        response = dict()
        response['changed'] = False
        response['msg'] = vm.list_nics()
        return response

    def index_nic(self):
        vapp = self.params.get('vapp')
        if nic_id not in self.nic_mapping['vm_name']:
            self.nic_mapping['vm_name'].append(nic_id)

    def read_nics_si(self):
        vapp = self.params.get('vapp')
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

    def return_nics_si(self):
        response = defaultdict(dict)
        response['changed'] = False
        vapp = self.params.get('vapp')
        nics = self.get_vm_nics()
        for nic in nics.NetworkConnection:
            meta = defaultdict(dict)
            nic_id = str(nic.NetworkConnectionIndex)
            if nic_id not in self.nic_mapping['vm_name']:
                self.nic_mapping['vm_name'].append(nic_id)
            meta['Network'] = str(nic.get('network'))
            meta['MACAddress'] = str(nic.MACAddress)
            meta['IsConnected'] = str(nic.IsConnected)
            meta['NetworkAdapterType'] = str(nic.NetworkAdapterType)
            meta['NetworkConnectionIndex'] = str(nic.NetworkConnectionIndex)
            meta['IpAddressAllocationMode'] = str(nic.IpAddressAllocationMode)

            if hasattr(nic, 'IpAddress'):
                meta['IpAddress'] = str(nic.IpAddress)

            response['msg'][nic_id] = meta

        # return response

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
    response = dict(
        msg=dict(type='str')
    )
    read_response = dict(
        msg=dict(type='str')
    )
    validate_response = dict(
        msg=dict(type='str')
    )
    module = VappVMNIC(argument_spec=argument_spec, supports_check_mode=True)
    try:
        if module.params.get('state'):
            read_response = module.manage_states()
        elif module.params.get('operation'):
            validate_response = module.manage_operations()
        # if module.check_mode:
        #     response['changed'] = False
        #     response['msg'] = "skipped, running in check mode"
        #     response['skipped'] = True
        # if module.params.get('state'):
        #     read_response = module.manage_states()
        # elif module.params.get('read'):
        #     read_response = module.manage_states()
        #     if module.params.get('operation'):
        #         validate_response = module.manage_operations()
        else:
            raise Exception('Please provide state/operation for resource')
    response = read_response.update(validate_response)
    except Exception as error:
        response['msg'] = error
        module.fail_json(**response)
    else:
        module.exit_json(**response)


if __name__ == '__main__':
    main()