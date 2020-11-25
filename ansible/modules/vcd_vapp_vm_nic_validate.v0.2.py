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


VAPP_VM_NIC_OPERATIONS = ['update', 'read', 'validate', 'get_nics_indexes']
IP_ALLOCATION_MODE = ["DHCP", "POOL", "MANUAL"]
VAPP_VM_NIC_STATES = ['present', 'absent', 'update', 'validate', 'get_nics_indexes']
NETWORK_ADAPTER_TYPE = ['VMXNET', 'VMXNET2', 'VMXNET3', 'E1000', 'E1000E', 'PCNet32']

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


class VappVM(VcdAnsibleModule):
    def __init__(self, **kwargs):
        super(VappVM, self).__init__(**kwargs)
        vapp_resource = self.get_target_resource()
        self.vapp = VApp(self.client, resource=vapp_resource)

    def manage_states(self):
        state = self.params.get('state')
        if state == "present":
            return self.add_vm()

        if state == "absent":
            return self.delete_vm()

        if state == "update":
            return self.update_vm()

    def manage_operations(self):
        operation = self.params.get('operation')
        if operation == "poweron":
            return self.power_on_vm()

        if operation == "poweroff":
            return self.power_off_vm()

        if operation == "reloadvm":
            return self.reload_vm()

        if operation == "deploy":
            return self.deploy_vm()

        if operation == "undeploy":
            return self.undeploy_vm()

        if operation == "list_disks":
            return self.list_disks()

        if operation == "list_nics":
            return self.list_nics()

    def get_source_resource(self):
        source_catalog_name = self.params.get('source_catalog_name')
        source_template_name = self.params.get('source_template_name')
        source_vdc = self.params.get('source_vdc')
        source_vapp = self.params.get('source_vapp')
        org_resource = Org(self.client, resource=self.client.get_org())
        source_vapp_resource = None

        if source_vapp:
            source_vdc_resource = VDC(
                self.client, resource=org_resource.get_vdc(source_vdc))
            source_vapp_resource_href = source_vdc_resource.get_resource_href(
                name=source_vapp, entity_type=EntityType.VAPP)
            source_vapp_resource = self.client.get_resource(
                source_vapp_resource_href)

        if source_catalog_name:
            catalog_item = org_resource.get_catalog_item(
                source_catalog_name, source_template_name)
            source_vapp_resource = self.client.get_resource(
                catalog_item.Entity.get('href'))

        return source_vapp_resource

    def get_target_resource(self):
        target_vapp = self.params.get('target_vapp')
        target_vdc = self.params.get('target_vdc')
        org_resource = Org(self.client, resource=self.client.get_org())
        target_vapp_resource = None

        target_vdc_resource = VDC(
            self.client, resource=org_resource.get_vdc(target_vdc))
        target_vapp_resource = target_vdc_resource.get_vapp(target_vapp)

        return target_vapp_resource

    def get_storage_profile(self, profile_name):
        target_vdc = self.params.get('target_vdc')
        org_resource = Org(self.client, resource=self.client.get_org())
        vdc_resource = VDC(
            self.client, resource=org_resource.get_vdc(target_vdc))

        return vdc_resource.get_storage_profile(profile_name)

    def get_vm(self):
        vapp_vm_resource = self.vapp.get_vm(self.params.get('target_vm_name'))

        return VM(self.client, resource=vapp_vm_resource)

    def add_vm(self):
        params = self.params
        source_vapp_resource = self.get_source_resource()
        target_vm_name = params.get('target_vm_name')
        source_vm_name = params.get('source_vm_name')
        hostname = params.get('hostname')
        vmpassword = params.get('vmpassword')
        vmpassword_auto = params.get('vmpassword_auto')
        vmpassword_reset = params.get('vmpassword_reset')
        network = params.get('network')
        all_eulas_accepted = params.get('all_eulas_accepted')
        power_on = params.get('power_on')
        deploy = params.get('deploy')
        ip_allocation_mode = params.get('ip_allocation_mode')
        cust_script = params.get('cust_script')
        storage_profile = params.get('storage_profile')
        properties = params.get('properties')
        response = dict()
        response['changed'] = False

        try:
            self.get_vm()
        except EntityNotFoundException:
            spec = {
                'source_vm_name': source_vm_name,
                'vapp': source_vapp_resource,
                'target_vm_name': target_vm_name,
                'hostname': hostname,
                'password': vmpassword,
                'password_auto': vmpassword_auto,
                'password_reset': vmpassword_reset,
                'ip_allocation_mode': ip_allocation_mode,
                'network': network,
                'cust_script': cust_script
            }

            spec = {k: v for k, v in spec.items() if v}
            if storage_profile != '':
                spec['storage_profile'] = self.get_storage_profile(
                    storage_profile)
            source_vm = self.vapp.to_sourced_item(spec)

            # Check the source vm if we need to inject OVF properties.
            source_vapp = VApp(self.client, resource=source_vapp_resource)
            vm = source_vapp.get_vm(source_vm_name)
            productsection = vm.find('ovf:ProductSection', NSMAP)
            if productsection is not None:
                for prop in productsection.iterfind('ovf:Property', NSMAP):
                    if properties and prop.get('{' + NSMAP['ovf'] + '}key') in properties:
                        val = prop.find('ovf:Value', NSMAP)
                        if val:
                            prop.remove(val)
                        val = E_OVF.Value()
                        val.set(
                            '{' + NSMAP['ovf'] + '}value', properties[prop.get('{' + NSMAP['ovf'] + '}key')])
                        prop.append(val)
                source_vm.InstantiationParams.append(productsection)
                source_vm.VmGeneralParams.NeedsCustomization = E.NeedsCustomization(
                    'true')

            params = E.RecomposeVAppParams(
                deploy='true' if deploy else 'false', powerOn='true' if power_on else 'false')
            params.append(source_vm)
            if all_eulas_accepted is not None:
                params.append(E.AllEULAsAccepted(all_eulas_accepted))

            add_vms_task = self.client.post_linked_resource(
                self.get_target_resource(), RelationType.RECOMPOSE,
                EntityType.RECOMPOSE_VAPP_PARAMS.value, params)
            self.execute_task(add_vms_task)
            response['msg'] = 'VM {} has been created.'.format(
                target_vm_name)
            response['changed'] = True
        else:
            response['warnings'] = 'VM {} is already present.'.format(
                target_vm_name)

        return response

    def delete_vm(self):
        vm_name = self.params.get('target_vm_name')
        response = dict()
        response['changed'] = False

        try:
            vm = self.get_vm()
        except EntityNotFoundException:
            response['warnings'] = 'VM {} is not present.'.format(vm_name)
        else:
            if not vm.is_powered_off():
                self.undeploy_vm()
            delete_vms_task = self.vapp.delete_vms([vm_name])
            self.execute_task(delete_vms_task)
            response['msg'] = 'VM {} has been deleted.'.format(vm_name)
            response['changed'] = True

        return response

    def update_vm(self):
        vm_name = self.params.get('target_vm_name')
        response = dict()
        response['changed'] = False

        if self.params.get("virtual_cpus"):
            self.update_vm_cpu()
            response['changed'] = True

        if self.params.get("memory"):
            self.update_vm_memory()
            response['changed'] = True

        response['msg'] = 'VM {} has been updated.'.format(vm_name)

        return response

    def update_vm_cpu(self):
        virtual_cpus = self.params.get('virtual_cpus')
        cores_per_socket = self.params.get('cores_per_socket')

        vm = self.get_vm()
        update_cpu_task = vm.modify_cpu(virtual_cpus, cores_per_socket)

        return self.execute_task(update_cpu_task)

    def update_vm_memory(self):
        memory = self.params.get('memory')

        vm = self.get_vm()
        update_memory_task = vm.modify_memory(memory)

        return self.execute_task(update_memory_task)

    def power_on_vm(self):
        vm_name = self.params.get('target_vm_name')
        response = dict()
        response['changed'] = False

        vm = self.get_vm()
        if not vm.is_powered_on():
            self.deploy_vm()
            response['msg'] = 'VM {} has been powered on.'.format(vm_name)
            response['changed'] = True
        else:
            response['warnings'] = 'VM {} is powered on.'.format(vm_name)

        return response

    def power_off_vm(self,):
        vm_name = self.params.get('target_vm_name')
        response = dict()
        response['changed'] = False

        vm = self.get_vm()
        if not vm.is_powered_off():
            self.undeploy_vm()
            response['msg'] = 'VM {} has been powered off.'.format(vm_name)
            response['changed'] = True
        else:
            response['warnings'] = 'VM {} is powered off.'.format(vm_name)

        return response

    def reload_vm(self):
        vm_name = self.params.get('target_vm_name')
        response = dict()
        response['changed'] = False

        vm = self.get_vm()
        vm.reload()
        response['msg'] = 'VM {} has been reloaded.'.format(vm_name)
        response['changed'] = True

        return response

    def deploy_vm(self):
        vm_name = self.params.get('target_vm_name')
        force_customization = self.params.get('force_customization')
        response = dict()
        response['changed'] = False

        vm = self.get_vm()
        if not vm.is_deployed():
            deploy_vm_task = vm.deploy(force_customization=force_customization)
            self.execute_task(deploy_vm_task)
            msg = 'VM {} has been deployed'
            response['msg'] = msg.format(vm_name)
            response['changed'] = True
        else:
            msg = 'VM {} is already deployed'
            response['warnings'] = msg.format(vm_name)

        return response

    def undeploy_vm(self):
        vm_name = self.params.get('target_vm_name')
        response = dict()
        response['changed'] = False

        vm = self.get_vm()
        if not vm.is_deployed():
            undeploy_vm_task = vm.undeploy(action="powerOff")
            self.execute_task(undeploy_vm_task)
            msg = 'VM {} has been undeployed'
            response['msg'] = msg.format(vm_name)
            response['changed'] = True
        else:
            msg = 'VM {} is already undeployed'
            response['warnings'] = msg.format(vm_name)

        return response

    def list_disks(self):
        response = dict()
        response['changed'] = False
        response['msg'] = []

        vm = self.get_vm()
        disks = self.client.get_resource(
            vm.resource.get('href') + '/virtualHardwareSection/disks')

        for disk in disks.Item:
            if disk['{' + NSMAP['rasd'] + '}ResourceType'] == 17:
                response['msg'].append({
                    'id': disk['{' + NSMAP['rasd'] + '}InstanceID'].text,
                    'name': disk['{' + NSMAP['rasd'] + '}ElementName'].text,
                    'description': disk['{' + NSMAP['rasd'] + '}Description'].text,
                    'size': disk['{' + NSMAP['rasd'] + '}HostResource'].get('{' + NSMAP['vcloud'] + '}capacity')
                })

        return response

    def list_nics(self):
        response = dict()
        response['changed'] = False
        response['msg'] = []

        vm = self.get_vm()
        nics = self.client.get_resource(
            vm.resource.get('href') + '/networkConnectionSection')

        for nic in nics.NetworkConnection:
            response['msg'].append({
                'index': nic.NetworkConnectionIndex.text,
                'network': nic.get('network')
            })

        return response

class VappVMNIC(VcdAnsibleModule):
    def __init__(self, **kwargs):
        super(VappVMNIC, self).__init__(**kwargs)
        vapp_resource = self.get_resource()
        #vapp_vm_resource = self.get_vm_resource()
        #vapp = self.params.get('vapp')
        self.vapp = VApp(self.client, resource=vapp_resource)
        nic_mapping = dict()
        self.nic_mapping = nic_mapping
        new_nic_id = None
        adapter_type = self.params.get('adapter_type')
        #vapp = self.vapp
        #nic_mapping = self.nic_mapping

    def manage_operations(self):
        operation = self.params.get('operation')
        if operation == "read":
            return self.read_nics()
        if operation == "update":
            return self.update_nics()
        if operation == "validate":
            return self.validate_nics()
        if operation == "get_nics_indexes":
            return self.get_nics_with_indexes()

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

    def get_vm_nics(self):
        vm = self.get_vm()
        network_connection_section = self.client.get_resource(vm.resource.get('href') + '/networkConnectionSection')
        if 
        return self.client.get_resource(
            vm.resource.get('href') + '/networkConnectionSection')

    def get_vm_nics_list(self):
        vm = self.get_vm()
        response = dict()
        response['changed'] = False
        response['msg'] = vm.list_nics()
        return response

    def get_vm(self):
        vapp_vm_resource = self.vapp.get_vm(self.vm_name))
        return VM(self.client, resource=vapp_vm_resource)

    def get_nics_with_indexes(self):
        vm = self.get_vm()
        adapter_type = self.params.get('adapter_type')
        nic_id = self.params.get('nic_id')
        network = self.params.get('network')
        ip_address = self.params.get('ip_address')
        ip_allocation_mode = self.params.get('ip_allocation_mode')
        is_connected = self.params.get('is_connected')
        vm_name = self.params.get('vm_name')
        #uri = vm.resource.get('href') + '/networkConnectionSection'

        response = defaultdict(dict)
        response['changed'] = False

        self.vm_name = vm_name

        nic_id = self.params.get('nic_id')
        ip_address = self.params.get('ip_address')
        network = self.params.get('network')
        # if ip_address is None:
        #     ip_address = "192.168.233.233"
        vm_list_nics_fetched = vm.list_nics()
        response = dict()
        response['changed'] = False
        response['nic_id'] = {
            'nic_id': nic_id
        }
        response['vm_list_nics_fetched'] = {
            'vm_list_nics_fetched': vm_list_nics_fetched
        }

        return response

        #nics = self.read_nics()
        #nics_read = self.read_nics()
        #nics = self.get_vm_nics()
        #nics_indexes = [int(nic.NetworkConnectionIndex) for nic in nics.NetworkConnection]
        #nics_indexes.sort()
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
        # response['warnings'] = 'NIC ID NO CASE'

        #nic_to_update = nic_indexs.index(nic_id)

    def validate_nics(self):
        vapp_resource = self.get_vapp_resource_resource_stateful()
        self.read_nics()
        # GENERATE RESPONSE
        #read_nics = self.read_nics()
        # FETCH LIST NICS
        #return_nics = self.return_nics()

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

    # def get_vm_nics(self):
    #     vm = self.get_vm()
    #     return self.client.get_resource(
    #         vm.resource.get('href') + '/networkConnectionSection')

    def add_nic(self):
        vm = self.get_vm()
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
        response['msg'] = 'A new nic has been added to VM {0}'.format(vm_name)
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

        return response

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
    module = VappVMNIC(argument_spec=argument_spec, supports_check_mode=True)
    try:
        if module.check_mode:
            response = dict()
            response['changed'] = False
            response['msg'] = "skipped, running in check mode"
            response['skipped'] = True
        elif module.params.get('state'):
            response = module.manage_states()
        elif module.params.get('operation'):
            response = module.manage_operations()
        else:
            raise Exception('Please provide state/operation for resource')

    except Exception as error:
        response['msg'] = error
        module.fail_json(**response)
    else:
        module.exit_json(**response)


if __name__ == '__main__':
    main()