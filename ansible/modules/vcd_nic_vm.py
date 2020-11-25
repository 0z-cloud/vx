# !/usr/bin/python

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'community'
}

DOCUMENTATION = '''
---
module: vcd_ipwt_nic
short_description: Ansible Module to manage consolidate NIC or NICs in vApp VM in vCloud Director.
version_added: "2.9.6"
description:
    - "Ansible Module to manage consolidate NIC or NICs in vApp VM."

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
  vcd_ipwt_nic:
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


from collections import defaultdict
from copy import deepcopy
from lxml import etree
from pyvcloud.vcd.client import EntityType
from pyvcloud.vcd.exceptions import EntityNotFoundException
from pyvcloud.vcd.vm import VM
from pyvcloud.vcd.org import Org
from pyvcloud.vcd.vdc import VDC
from pyvcloud.vcd.client import E
from pyvcloud.vcd.vapp import VApp
from pyvcloud.vcd.client import E_RASD
from pyvcloud.vcd.client import NSMAP
from pyvcloud.vcd.client import EntityType
from ansible.module_utils.vcd import VcdAnsibleModule
from pyvcloud.vcd.exceptions import EntityNotFoundException, OperationNotSupportedException, InvalidParameterException

VAPP_VM_NIC_STATES = ['present', 'absent', 'update']
VAPP_VM_NIC_OPERATIONS = ['update', 'read', 'validate']
NETWORK_ADAPTER_TYPE = ['VMXNET', 'VMXNET2', 'VMXNET3', 'E1000', 'E1000E', 'PCNet32']
IP_ALLOCATION_MODE = ["DHCP", "POOL", "MANUAL"]

def vapp_vm_nic_argument_spec():
    """Allocate arguments specifications"""
    return dict(
        vm_name=dict(type='str', required=True),
        vapp=dict(type='str', required=True),
        vdc=dict(type='str', required=True),
        nic_id=dict(type='int', required=False),
        nic_ids=dict(type='list', required=False),
        ip_allocation_mode=dict(choices=IP_ALLOCATION_MODE, required=False, default='DHCP'),
        ip_address=dict(type='str', required=False),
        is_connected=dict(type='bool', required=False, default=True),
        network=dict(type='str', required=False),
        adapter_type=dict(choices=NETWORK_ADAPTER_TYPE, required=False),
        state=dict(choices=VAPP_VM_NIC_STATES, required=False),
        operation=dict(choices=VAPP_VM_NIC_OPERATIONS, required=False),
    )

class VappVMNIC(VcdAnsibleModule):
    def __init__(self, **kwargs):
        super(VappVMNIC, self).__init__(**kwargs)
        vapp_resource = self.get_resource()
        self.vapp = VApp(self.client, resource=vapp_resource)
        self.nic_mapping = defaultdict(list)

    def manage_states(self):
        state = self.params.get('state')
        if state == "present":
            return self.add_update_nic()

        if state == "absent":
            return self.delete_nic()

    def manage_operations(self):
        operation = self.params.get('operation')
        if operation == "update":
            return self.add_update_nic()

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
        #self.vm = vm
        return self.client.get_resource(vm.resource.get('href') + '/networkConnectionSection')

    # def manage_nics_list(self):
    #     nic_id = self.params.get('nic_id')
    #     nic_ids = self.params.get('nic_ids')
    #     nics = self.get_vm_nics()
    #     if 'NetworkConnection' not in dir(nics):
    #         nic = self.add_nic()
    #         self.nic = nic
    #         return self.nic
        #nics.get('NetworkConnection')
        #if hasattr(nics,"NetworkConnection")
        # 
        # if nics is None:
        #     self.custom_add_nic()

    # def custom_add_nic(self):
    #     vm = self.get_vm()
    #     vm_name = self.params.get('vm_name')
    #     network = self.params.get('network')
    #     ip_address = self.params.get('ip_address')
    #     ip_allocation_mode = self.params.get('ip_allocation_mode')
    #     adapter_type = self.params.get('adapter_type')
    #     is_primary = self.params.get('is_primary')
    #     is_connected = self.params.get('is_connected')
    #     response = dict()
    #     response['changed'] = False

    #     add_nic_task = vm.add_nic(adapter_type=adapter_type,
    #                               is_primary=is_primary,
    #                               is_connected=is_connected,
    #                               network_name=network,
    #                               ip_address_mode=ip_allocation_mode,
    #                               ip_address=ip_address)
    #     self.execute_task(add_nic_task)
    #     response['msg'] = 'A new nic has been added to VM {0}'.format(vm_name)
    #     response['changed'] = True

    #     return response

    # noinspection DuplicatedCode
    def add_update_nic(self):
        vm = self.get_vm()
        vm_name = self.params.get('vm_name')
        network = self.params.get('network')
        nic_id = self.params.get('nic_id')
        ip_address = self.params.get('ip_address')
        is_connected = self.params.get('is_connected')
        ip_allocation_mode = self.params.get('ip_allocation_mode')
        adapter_type = self.params.get('adapter_type')
        uri = vm.resource.get('href') + '/networkConnectionSection'
        response = defaultdict(dict)
        response['changed'] = False
        new_nic_id = None
        nics = self.get_vm_nics()
        nics_indexes = [int(nic.NetworkConnectionIndex) for nic in nics.NetworkConnection]
        nics_indexes.sort()
        note = 'added'
        # nics = self.get_vm_nics()
        # if nics is None:
        #     self.add_nic()
        #nic_found = False
        #vm = []
        #vm = self.get_vm()
        # '''
        # # ДЛЯ ИНДУСА STATE WITH FINDED DIFFERENT
        # # nics_indexes = [int(nic.NetworkConnectionIndex) for nic in nics.NetworkConnection]
        # # nic_indexs = [nic.NetworkConnectionIndex for nic in nics.NetworkConnection]
        # '''
        # nics_indexes = []
        # ip_allocation_mode_state = []
        # note_response_check_operation = []
        # found_in_nics_state = []
        first_state = []
        # nics_to_print = []
        # nic_to_update = []
        response_nics_indexes = []
        # nic = []
        # nics = self.get_vm_nics()
        for nic in nics.NetworkConnection:
            if nic.NetworkConnectionIndex == nic_id:
                response['warnings'] = 'NIC {} is already present on VM {}'.format(
                    nic_id, vm_name)
                return response
        ###### > DOUBLE_COMMENT_BLOCK_START
        if "NetworkConnection" in nics:
            first_state = 'NetworkConnection in nics index check true'
            for nic_interface in nics.NetworkConnection:
                nic_id = int(nic_interface.NetworkConnectionIndex)
                nics_indexes += nic_id
            nics_indexes.sort()
            response_nics_indexes = { 'NICs index is is already present': nics_indexes }
            for nic in nics.NetworkConnection:
                if nic.NetworkConnectionIndex == nic_id:
                    nic_found = True
                    if op == "add":
                        '''
                        # presend nic, when operation add, dont do anythins'''
                        note_response_check_operation = 'NIC is already present.'
                        note = 'add'
                        '''#return response'''
                    else:
                        '''
                        # update nic, when operation not are add, go validate'''
                        note_response_check_operation = 'NIC is present and updated.'
                        note = 'updated'

                if not nic_found and op == "update":
                    found_in_nics_state = 'Update nic: add NIC because his not found.'
                    '''
                    # response['msg'] = 'Update nic: add NIC because his not found.'
                    '''
                    if ip_allocation_mode in ('DHCP', 'POOL'):
                        ip_allocation_mode_state = { 'ip_allocation_mode': ip_allocation_mode }
                        nic = E.NetworkConnection(
                        E.NetworkConnectionIndex(nic_id),
                        E.IsConnected(True),
                        E.IpAddressAllocationMode(ip_allocation_mode),
                        network=network)
                    else:
                        ip_allocation_mode_state = { 'ip_allocation_mode': ip_allocation_mode }
                        if not ip_address:
                            raise Exception('IpAddress is missing.')
                        nic = E.NetworkConnection(
                        E.NetworkConnectionIndex(nic_id),
                        E.IpAddress(ip_address),
                        E.IsConnected(True),
                        E.IpAddressAllocationMode(ip_allocation_mode),
                        network=network)

                    nics.NetworkConnection.addnext(nic)
                    add_nic_task = self.client.put_resource(uri, nics, EntityType.NETWORK_CONNECTION_SECTION.value)
                    self.execute_task(add_nic_task)

        nics.NetworkConnection.addnext(nic)
        add_nic_task = self.client.put_resource(uri, nics, EntityType.NETWORK_CONNECTION_SECTION.value)
        self.execute_task(add_nic_task)
        response['msg'] = {
            'vApp VM NIC:': note,
            'nic_id': nic_id,
            'ip_allocation_mode': ip_allocation_mode,
            'ip_address': ip_address,
            'is_connected': is_connected,
            'network': network,
            'ip_allocation_mode_state': ip_allocation_mode_state,
            'note network operation check return result': note_response_check_operation,
            'found first check': found_in_nics_state,
            'first_state': first_state,
            'nics_to_print': nics_to_print,
            'new_nic_id': new_nic_id,
            'response_nics_indexes': response_nics_indexes,
            'vm': vm,
            'vm_name': vm_name,
            # 'nic_to_update': nic_to_update,
            'adapter_type': adapter_type
        }
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