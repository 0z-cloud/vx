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
module: vcd_v_network
short_description: Ansible Module to manage (create/delete) Networks in vApps in vCloud Director.
version_added: "2.4"
description:
    - "Ansible Module to manage (create/delete) Networks in vApps."
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
    network:
        description:
            - Network name
        required: true
    vapp:
        description:
            - vApp name
        required: true
    vdc:
        description:
            - VDC name
        required: true
    fence_mode:
        description:
            - Network fence mode
        required: false
    parent_network:
        description:
            - VDC parent network to connect to
        required: false
    ip_scope:
        description:
            - IP scope when no parent_network is defined
    state:
        description:
            - state of network ('present'/'absent').
        required: true
author:
    - mtaneja@vmware.com
'''

EXAMPLES = '''
- name: Read vNetwork with out message
  vcd_v_network:
    user: ""
    password: ""
    host: ""
    org: ""
    api_version: ""
    verify_ssl_certs: true
    network: ""
    vapp: ""
    vdc: ""
    fence_mode: ""
    parent_network:
    ip_scope: ""
    state: "read"

- name: Test with a message
  vcd_v_network:
    user: terraform
    password: abcd
    host: csa.sandbox.org
    org: Terraform
    api_version: 30
    verify_ssl_certs: False
    network = "uplink"
    vapp = "vapp1"
    vdc = "vdc1"
    state = "present"
'''

RETURN = '''
msg: success/failure message corresponding to vapp network state
changed: true if resource has been changed else false
'''

from lxml import etree
from ipaddress import ip_network
from pyvcloud.vcd.org import Org
from pyvcloud.vcd.vdc import VDC
from pyvcloud.vcd.client import E
from pyvcloud.vcd.vapp import VApp
from pyvcloud.vcd.client import NSMAP
from pyvcloud.vcd.client import E_OVF
from pyvcloud.vcd.client import FenceMode
from pyvcloud.vcd.client import EntityType
from pyvcloud.vcd.client import RelationType
from ansible.module_utils.vcd import VcdAnsibleModule
from pyvcloud.vcd.exceptions import EntityNotFoundException, OperationNotSupportedException

VAPP_VM_STATES = ['present', 'absent', 'read']
VAPP_VM_OPERATIONS = ['poweron', 'poweroff', 'deploy', 'undeploy', 'list_vms', 'list_networks']
VM_STATUSES = {'3': 'SUSPENDED', '4': 'POWERED_ON', '8': 'POWERED_OFF'}
VAPP_NETWORK_STATES = ['present', 'update', 'absent', 'read']
VAPP_NETWORK_OPERATIONS = ['read']

def vapp_argument_spec():
    return dict(
        vapp_name=dict(type='str', required=True),
        template_name=dict(type='str', required=False),
        catalog_name=dict(type='str', required=False),
        vdc=dict(type='str', required=True),
        description=dict(type='str', required=False, default=None),
        network=dict(type='str', required=False, default=None),
        fence_mode=dict(
            type='str', required=False, default=FenceMode.BRIDGED.value),
        ip_allocation_mode=dict(type='str', required=False, default="dhcp"),
        deploy=dict(type='bool', required=False, default=True),
        power_on=dict(type='bool', required=False, default=True),
        accept_all_eulas=dict(type='bool', required=False, default=False),
        memory=dict(type='int', required=False, default=None),
        cpu=dict(type='int', required=False, default=None),
        disk_size=dict(type='int', required=False, default=None),
        vmpassword=dict(type='str', required=False, default=None),
        cust_script=dict(type='str', required=False, default=None),
        vm_name=dict(type='str', required=False, default=None),
        hostname=dict(type='str', required=False, default=None),
        ip_address=dict(type='str', required=False, default=None),
        storage_profile=dict(type='str', required=False, default=None),
        network_adapter_type=dict(type='str', required=False, default=None),
        force=dict(type='bool', required=False, default=False),
        state=dict(choices=VAPP_VM_STATES, required=False),
        operation=dict(choices=VAPP_VM_OPERATIONS, required=False),
    )

def vapp_merge_argument_spec():
    return dict(
        vapp_name=dict(type='str', required=True),
        template_name=dict(type='str', required=False),
        catalog_name=dict(type='str', required=False),
        vdc=dict(type='str', required=True),
        description=dict(type='str', required=False, default=None),
        network=dict(type='str', required=False, default=None),
        fence_mode=dict(type='str', required=False, default=FenceMode.BRIDGED.value),
        ip_allocation_mode=dict(type='str', required=False, default="dhcp"),
        deploy=dict(type='bool', required=False, default=True),
        power_on=dict(type='bool', required=False, default=True),
        accept_all_eulas=dict(type='bool', required=False, default=False),
        memory=dict(type='int', required=False, default=None),
        cpu=dict(type='int', required=False, default=None),
        disk_size=dict(type='int', required=False, default=None),
        vmpassword=dict(type='str', required=False, default=None),
        cust_script=dict(type='str', required=False, default=None),
        vm_name=dict(type='str', required=False, default=None),
        hostname=dict(type='str', required=False, default=None),
        ip_address=dict(type='str', required=False, default=None),
        parent_network=dict(type='str', required=False, default=None),
        storage_profile=dict(type='str', required=False, default=None),
        network_adapter_type=dict(type='str', required=False, default=None),
        force=dict(type='bool', required=False, default=False),
        state=dict(choices=VAPP_VM_STATES, required=False),
        ip_scope=dict(type='str', required=False, default=None),
        operation=dict(choices=VAPP_VM_OPERATIONS, required=False),
    )

def vapp_network_argument_spec():
    return dict(
        network=dict(type='str', required=True),
        vapp=dict(type='str', required=True),
        vdc=dict(type='str', required=True),
        fence_mode=dict(type='str', required=False, default=FenceMode.BRIDGED.value),
        parent_network=dict(type='str', required=False, default=None),
        ip_scope=dict(type='str', required=False, default=None),
        state=dict(choices=VAPP_NETWORK_STATES, required=True),
    )

class VappNetwork(VcdAnsibleModule):
    def __init__(self, **kwargs):
        super(VappNetwork, self).__init__(**kwargs)
        vapp_resource = self.get_resource()
        self.vapp = VApp(self.client, resource=vapp_resource)

    def manage_states(self):
        state = self.params.get('state')
        if state == "present":
            return self.add_network()
        if state == "absent":
            return self.delete_network()
        if state == "update":
            return self.update_network()
        if state == "read":
            return self.read_network()

    def get_resource(self):
        vapp = self.params.get('vapp')
        vdc = self.params.get('vdc')
        org_resource = Org(self.client, resource=self.client.get_org())
        vdc_resource = VDC(self.client, resource=org_resource.get_vdc(vdc))
        vapp_resource_href = vdc_resource.get_resource_href(name=vapp, entity_type=EntityType.VAPP)
        vapp_resource = self.client.get_resource(vapp_resource_href)
        return vapp_resource

    def get_org_resource(self):
        vapp = self.params.get('vapp')
        vdc = self.params.get('vdc')
        org_resource = Org(self.client, resource=self.client.get_org())
        vdc_resource = VDC(self.client, resource=org_resource.get_vdc(vdc))
        vapp_resource_href = vdc_resource.get_resource_href(name=vapp, entity_type=EntityType.VAPP)
        vapp_resource = self.client.get_resource(vapp_resource_href)
        return org_resource

    def get_vdc_resource(self):
        vapp = self.params.get('vapp')
        vdc = self.params.get('vdc')
        org_resource = Org(self.client, resource=self.client.get_org())
        vdc_resource = VDC(self.client, resource=org_resource.get_vdc(vdc))
        vapp_resource_href = vdc_resource.get_resource_href(name=vapp, entity_type=EntityType.VAPP)
        vapp_resource = self.client.get_resource(vapp_resource_href)
        return vdc_resource

    def get_network(self):
        network_name = self.params.get('network')
        networks = self.vapp.get_all_networks()
        for network in networks:
            if network.get('{'+NSMAP['ovf']+'}name') == network_name:
                return network
        raise EntityNotFoundException('Can\'t find the specified vApp network')

    def read_network(self):
        network_name = self.params.get('network')
        network_object = []
        network_object = self.get_network(network_name)
        vapp = self.params.get('vapp')
        vdc = self.params.get('vdc')
        finded_network = {}
        org_resource = self.get_org_resource()
        vdc_resource = self.get_vdc_resource()
        vapp_resource = self.get_resource()
        vnet_resource = self.get_network(self.NetworkConfig)
        return network_object

    def update_network(self):
        network_name = self.n
        vapp = self.params.get('vapp')
        vdc = self.params.get('vdc')
        finded_network = {}
        org_resource = self.get_org_resource()
        vdc_resource = self.get_vdc_resource()
        vapp_resource = self.get_resource()
        vnet_resource = self.get_network(self)

        #self.get_vdc_resource.network_config_section
        # for network in networks:
        #     if network.get('{'+NSMAP['ovf']+'}name') == network_name:
        #         net_entity = self.get_network(network_name)     
                           
        # raise EntityNotFoundException('Can\'t find the specified vApp network')
        #self.get_vdc_resource.network_config_section
        # for network in networks:
        #     if network.get('{'+NSMAP['ovf']+'}name') == network_name:
        #         net_entity = self.get_network(network_name)     
                           
        # raise EntityNotFoundException('Can\'t find the specified vApp network')
    def delete_network(self):
        network_name = self.params.get('network')
        response = dict()
        response['changed'] = False

        try:
            self.get_network()
        except EntityNotFoundException:
            response['warnings'] = 'Vapp Network {} is not present.'.format(network_name)
        else:
            network_config_section = self.vapp.resource.NetworkConfigSection
            for network_config in network_config_section.NetworkConfig:
                if network_config.get('networkName') == network_name:
                    network_config_section.remove(network_config)
            delete_network_task = self.client.put_linked_resource(
                self.vapp.resource.NetworkConfigSection, RelationType.EDIT,
                EntityType.NETWORK_CONFIG_SECTION.value,
                network_config_section)
            self.execute_task(delete_network_task)
            response['msg'] = 'Vapp Network {} has been deleted.'.format(network_name)
            response['changed'] = True

        return response

    def add_network(self):
        network_name = self.params.get('network')
        fence_mode = self.params.get('fence_mode')
        parent_network = self.params.get('parent_network')
        ip_scope = self.params.get('ip_scope')

        response = dict()
        response['changed'] = False

        try:
            self.get_network()
        except EntityNotFoundException:
            network_config_section = self.vapp.resource.NetworkConfigSection
            config = E.Configuration()
            if parent_network:
                vdc = self.params.get('vdc')
                org_resource = Org(self.client, resource=self.client.get_org())
                vdc_resource = VDC(self.client, resource=org_resource.get_vdc(vdc))
                orgvdc_networks = vdc_resource.list_orgvdc_network_resources(parent_network)
                parent = next((network for network in orgvdc_networks if network.get('name') == parent_network), None)
                if parent:
                    config.append(E.ParentNetwork(href=parent.get('href')))
                else:
                    raise EntityNotFoundException('Parent network \'%s\' does not exist'.format(parent_network))
            elif ip_scope:
                scope = E.IpScope(
                    E.IsInherited('false'),
                    E.Gateway(str(ip_network(ip_scope, strict=False).network_address+1)),
                    E.Netmask(str(ip_network(ip_scope, strict=False).netmask)))
                config.append(E.IpScopes(scope))
            else:
                raise VappNetworkCreateError('Either parent_network or ip_scope must be set')
            config.append(E.FenceMode(fence_mode))

            network_config = E.NetworkConfig(config, networkName=network_name)
            network_config_section.append(network_config)

            add_network_task = self.client.put_linked_resource(
                self.vapp.resource.NetworkConfigSection, RelationType.EDIT,
                EntityType.NETWORK_CONFIG_SECTION.value,
                network_config_section)
            self.execute_task(add_network_task)
            response['msg'] = 'Vapp Network {} has been added'.format(network_name)
            response['changed'] = True
        else:
            response['warnings'] = 'Vapp Network {} is already present.'.format(network_name)

        return response

class Vapp(VcdAnsibleModule):
    def __init__(self, **kwargs):
        super(Vapp, self).__init__(**kwargs)
        logged_in_org = self.client.get_org()
        self.org = Org(self.client, resource=logged_in_org)
        vdc_resource = self.org.get_vdc(self.params.get('vdc'))
        self.vdc = VDC(self.client, href=vdc_resource.get('href'))

    def manage_states(self):
        state = self.params.get('state')
        if state == "present":
            return self.create()

        if state == "absent":
            return self.delete()

    def manage_operations(self):
        state = self.params.get('operation')
        if state == "poweron":
            return self.power_on()

        if state == "poweroff":
            return self.power_off()

        if state == "deploy":
            return self.deploy()

        if state == "undeploy":
            return self.undeploy()

        if state == "list_vms":
            return self.list_vms()

        if state == "list_networks":
            return self.list_networks()

    def get_vapp(self):
        vapp_name = self.params.get('vapp_name')
        vapp_resource = self.vdc.get_vapp(vapp_name)

        return VApp(self.client, name=vapp_name, resource=vapp_resource)

    def instantiate(self):
        params = self.params
        vapp_name = params.get('vapp_name')
        catalog_name = params.get('catalog_name')
        template_name = params.get('template_name')
        description = params.get('description')
        network = params.get('network')
        fence_mode = params.get('fence_mode')
        ip_allocation_mode = params.get('ip_allocation_mode')
        deploy = params.get('deploy')
        power_on = params.get('power_on')
        accept_all_eulas = params.get('accept_all_eulas')
        memory = params.get('memory')
        cpu = params.get('cpu')
        disk_size = params.get('disk_size')
        vmpassword = params.get('vmpassword')
        cust_script = params.get('cust_script')
        vm_name = params.get('vm_name')
        hostname = params.get('hostname')
        ip_address = params.get('ip_address')
        storage_profile = params.get('storage_profile')
        network_adapter_type = params.get('network_adapter_type')
        response = dict()
        response['changed'] = False

        try:
            self.vdc.get_vapp(vapp_name)
        except EntityNotFoundException:
            create_vapp_task = self.vdc.instantiate_vapp(
                name=vapp_name,
                catalog=catalog_name,
                template=template_name,
                description=description,
                network=network,
                fence_mode=fence_mode,
                ip_allocation_mode=ip_allocation_mode,
                deploy=deploy,
                power_on=power_on,
                accept_all_eulas=accept_all_eulas,
                memory=memory,
                cpu=cpu,
                disk_size=disk_size,
                password=vmpassword,
                cust_script=cust_script,
                vm_name=vm_name,
                hostname=hostname,
                ip_address=ip_address,
                storage_profile=storage_profile,
                network_adapter_type=network_adapter_type)
            self.execute_task(create_vapp_task.Tasks.Task[0])
            msg = 'Vapp {} has been created'
            response['msg'] = msg.format(vapp_name)
            response['changed'] = True
        else:
            msg = "Vapp {} is already present"
            response['warnings'] = msg.format(vapp_name)

        return response

    def create(self):
        params = self.params
        catalog_name = params.get('catalog_name')

        # vapp initialization if catalog has been provided
        if catalog_name:
            return self.instantiate()

        vapp_name = params.get('vapp_name')
        description = params.get('description')
        network = params.get('network')
        fence_mode = params.get('fence_mode')
        accept_all_eulas = params.get('accept_all_eulas')
        response = dict()
        response['changed'] = False

        try:
            self.vdc.get_vapp(vapp_name)
        except EntityNotFoundException:
            create_vapp_task = self.vdc.create_vapp(
                name=vapp_name,
                description=description,
                network=network,
                fence_mode=fence_mode,
                accept_all_eulas=accept_all_eulas)
            self.execute_task(create_vapp_task.Tasks.Task[0])
            msg = 'Vapp {} has been created'
            response['msg'] = msg.format(vapp_name)
            response['changed'] = True
        else:
            msg = "Vapp {} is already present"
            response['warnings'] = msg.format(vapp_name)

        return response

    def delete(self):
        vapp_name = self.params.get('vapp_name')
        force = self.params.get('force')
        response = dict()
        response['changed'] = False

        try:
            self.vdc.get_vapp(vapp_name)
        except EntityNotFoundException:
            response['warnings'] = "Vapp {} is not present.".format(vapp_name)
        else:
            delete_vapp_task = self.vdc.delete_vapp(
                name=vapp_name, force=force)
            self.execute_task(delete_vapp_task)
            response['msg'] = 'Vapp {} has been deleted.'.format(vapp_name)
            response['changed'] = True

        return response

    def power_on(self):
        vapp_name = self.params.get('vapp_name')
        response = dict()
        response['changed'] = False

        vapp = self.get_vapp()

        if vapp.is_powered_on():
            msg = 'Vapp {} is already powered on'
            response['warnings'] = msg.format(vapp_name)
            return response

        try:
            vapp_resource = self.vdc.get_vapp(vapp_name)
            vapp = VApp(self.client, name=vapp_name, resource=vapp_resource)
            power_on_vapp_task = vapp.power_on()
            self.execute_task(power_on_vapp_task)
            msg = 'Vapp {} has been powered on'
            response['msg'] = msg.format(vapp_name)
            response['changed'] = True
        except OperationNotSupportedException:
            msg = 'Operation is not supported. You may have no VM(s) in {}'
            response['warnings'] = msg.format(vapp_name)

        return response

    def power_off(self):
        vapp_name = self.params.get('vapp_name')
        response = dict()
        response['changed'] = False

        vapp = self.get_vapp()

        if vapp.is_powered_off():
            msg = 'Vapp {} is already powered off'
            response['warnings'] = msg.format(vapp_name)
            return response

        try:
            vapp_resource = self.vdc.get_vapp(vapp_name)
            vapp = VApp(self.client, name=vapp_name, resource=vapp_resource)
            power_off_vapp_task = vapp.power_off()
            self.execute_task(power_off_vapp_task)
            msg = 'Vapp {} has been powered off'
            response['msg'] = msg.format(vapp_name)
            response['changed'] = True
        except OperationNotSupportedException:
            msg = 'Operation is not supported. You may have no VM(s) in {}'
            response['warnings'] = msg.format(vapp_name)

        return response

    def deploy(self):
        vapp_name = self.params.get('vapp_name')
        response = dict()
        response['changed'] = False

        vapp = self.get_vapp()

        if vapp.is_deployed():
            msg = 'Vapp {} is already deployed'
            response['warnings'] = msg.format(vapp_name)
            return response

        vapp_resource = self.vdc.get_vapp(vapp_name)
        vapp = VApp(self.client, name=vapp_name, resource=vapp_resource)
        deploy_vapp_task = vapp.deploy()
        self.execute_task(deploy_vapp_task)
        msg = 'Vapp {} has been deployed'
        response['msg'] = msg.format(vapp_name)
        response['changed'] = True

        return response

    def undeploy(self):
        vapp_name = self.params.get('vapp_name')
        response = dict()
        response['changed'] = False

        vapp = self.get_vapp()

        if not vapp.is_deployed():
            msg = 'Vapp {} is already undeployed'
            response['warnings'] = msg.format(vapp_name)
            return response

        vapp_resource = self.vdc.get_vapp(vapp_name)
        vapp = VApp(self.client, name=vapp_name, resource=vapp_resource)
        undeploy_vapp_task = vapp.undeploy(action="powerOff")
        self.execute_task(undeploy_vapp_task)
        response['msg'] = 'Vapp {} has been undeployed.'.format(vapp_name)
        response['changed'] = True

        return response

    def list_vms(self):
        vapp = self.get_vapp()
        response = dict()
        response['msg'] = list()

        for vm in vapp.get_all_vms():
            try:
                ip = vapp.get_primary_ip(vm.get('name'))
            except Exception:
                ip = None
            finally:
                vm_details = {"name": vm.get('name'),
                              "status": VM_STATUSES[vm.get('status')],
                              "deployed": vm.get('deployed') == 'true',
                              "ip_address": ip
                              }

                response['msg'].append(vm_details)

        return response

    def list_networks(self):
        vapp = self.get_vapp()
        response = dict()

        networks = vapp.get_all_networks()
        response['msg'] = [network.get(
            '{' + NSMAP['ovf'] + '}name') for network in networks]

        return response


def main():
    argument_network_spec = vapp_network_argument_spec()
    argument_merge_spec = vapp_merge_argument_spec()
    argument_vapp_spec = vapp_argument_spec()

    response = dict(
        msg=dict(type='str')
    )
    module_network = VappNetwork(argument_spec=vapp_network_argument_spec, supports_check_mode=True)
    #module_merge = VappNetwork(argument_spec=argument_spec, supports_check_mode=True)
    module_vapp = VappNetwork(argument_spec=vapp_argument_spec, supports_check_mode=True)
    module = (module_network, module_vapp)
    try:
        if not module.params.get('state'):
            raise Exception('Please provide the state for the resource.')

        response = module.manage_states()
        module.exit_json(**response)

    except Exception as error:
        response['msg'] = error
        module.fail_json(**response)


if __name__ == '__main__':
    main()