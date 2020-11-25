# Copyright © 2018 VMware, Inc. All Rights Reserved.
# SPDX-License-Identifier: BSD-2-Clause OR GPL-3.0-only

#!/usr/bin/python

ANSIBLE_METADATA = {'metadata_version': '1.1',
                    'status': ['preview'],
                    'supported_by': 'community'}

DOCUMENTATION = '''
module: vcd_link_net_edge
short_description: Manage VDC Network's states/operations in vCloud Director
version_added: "2.7"
description:
    -  GET EDGE INFO ABOUT Network's states/operations in vCloud Director
author:
    - Rost  <ros@noexists.com>
options:
    user:
        description:
            - vCloud Director user name
        type: str
    password:
        description:
            - vCloud Director user password
        type: str
    host:
        description:
            - vCloud Director host address
        type: str
    org:
        description:
            - Organization name on vCloud Director to access i.e. System.
        type: str
    org_name:
        description:
            - Name of the organization the network belongs to.
        type: str
    api_version:
        description:
            - Pyvcloud API version, required as float i.e 31 => 31.0
        type: float
    verify_ssl_certs:
        description:
            - Whether to use secure connection to vCloud Director host.
        type: bool
    vdc_name:
        description:
            - The name of the vdc where EDGE is going to be readed.
        required: true
        type: str
    vdc_org_name:
        description:
            - The name of ORG in vdc where EDGE is going to be readed.
        required: true
        type: str
    description:
        description:
            - The description of the edge gateway
        type: str
    edge_name:
        description:
            - The name of the new gateway.
        type: str
        required: true
    operation:
        description:
            - Oeration to get edge from vcd (read).
            - One of operation/state has to be provided.
        required: true
'''

EXAMPLES = '''
- name: Get EDGE Info
  vcd_link_net_edge:
    user: "{{ anycloud_adapter_api_user }}"
    password: "{{ anycloud_adapter_api_password }}"
    host: "{{ anycloud_adapter_api_url_endpoint | default(anycloud_defaults_api_url_endpoint) }}"
    org: "{{ anycloud_defaults_virtual_organization | default(anycloud_adapter_virtual_organization) }}"
    org_name: "{{ anycloud_defaults_virtual_organization }}"
    api_version: 31.0
    verify_ssl_certs: true
    vdc_name: "{{ anycloud_defaults_virtual_organization }}"
    vdc_org_name: "{{ anycloud_defaults_virtual_organization }}"
    description: "{{ ansible_datacenter }}"
    edge_name: "{{ anycloud_result_edge_router }}"
    operation: read
'''


RETURN = '''
msg: success/failure message corresponding to vdc state/operation
changed: true if resource has been changed else false
'''

from ansible.module_utils.vcd import VcdAnsibleModule
from lxml import etree
from ipaddress import ip_network
from pyvcloud.vcd.gateway import Gateway
from pyvcloud.vcd.org import Org
from pyvcloud.vcd.vdc import VDC
from pyvcloud.vcd.client import E
from pyvcloud.vcd.vapp import VApp
from pyvcloud.vcd.gateway_services import GatewayServices
from pyvcloud.vcd.gateway import Gateway
from pyvcloud.vcd.nat_rule import NatRule

from pyvcloud.vcd.utils import netmask_to_cidr_prefix_len
from pyvcloud.vcd.client import NSMAP
from pyvcloud.vcd.client import E_OVF
from pyvcloud.vcd.client import FenceMode
from pyvcloud.vcd.client import EntityType
from pyvcloud.vcd.client import RelationType
from pyvcloud.vcd.client import ApiVersion
from pyvcloud.vcd.client import E
from pyvcloud.vcd.client import E_OVF
from pyvcloud.vcd.client import EdgeGatewayType

from pyvcloud.vcd.client import EntityType
from pyvcloud.vcd.client import FenceMode
from pyvcloud.vcd.client import find_link
from pyvcloud.vcd.client import GatewayBackingConfigType
from pyvcloud.vcd.client import LogicalNetworkLinkType
from pyvcloud.vcd.client import MetadataDomain
from pyvcloud.vcd.client import MetadataValueType
from pyvcloud.vcd.client import MetadataVisibility
from pyvcloud.vcd.client import QueryResultFormat
from pyvcloud.vcd.client import ResourceType
from pyvcloud.vcd.client import SIZE_1MB
from ansible.module_utils.vcd import VcdAnsibleModule
from pyvcloud.vcd.exceptions import EntityNotFoundException, OperationNotSupportedException
from pyvcloud.vcd.exceptions import EntityNotFoundException
from pyvcloud.vcd.exceptions import InvalidParameterException
from pyvcloud.vcd.exceptions import MultipleRecordsException
from pyvcloud.vcd.exceptions import OperationNotSupportedException
# from pyvcloud.vcd.exceptions import Multipl

VAPP_NETWORK_OPERATIONS = ['read']


def org_vdc_network_argument_spec():
    return dict(
        host=dict(type='str', required=True),
        user=dict(type='str', required=True),
        password=dict(type='str', required=True),
        api_version=dict(type='str', required=True),
        vdc_name=dict(type='str', required=True),
        org_name=dict(type='str', required=True),
        vdc_org_name=dict(type='str', required=True),
        edge_name=dict(type='str', required=True),
        description=dict(type='str', required=False, default=None),
        operation=dict(choices=VAPP_NETWORK_OPERATIONS, required=True),
    )


class EdgeInCatalogWhole(VcdAnsibleModule):
    def __init__(self, **kwargs):
        super(EdgeInCatalogWhole, self).__init__(**kwargs)
        self.host = self.params.get('host')
        self.host = self.params.get('host')

        self.user = self.params.get('user')
        self.password = self.params.get('password')
        self.api_version = self.params.get('api_version')
        self.vdc_name = self.params.get('vdc_name')
        self.org_name = self.params.get('org_name')
        self.edge_name = self.params.get('edge_name')
        logged_in_org = self.client.get_org_by_name(self.org_name)
        self.org = Org(self.client, resource=logged_in_org)
        #org_resource = self.client.get_org_by_name(self.org_name)
        #self.org = Org(self.client, resource=org_resource)
        vdc_resource = self.org.get_vdc(self.vdc_name)
        self.vdc = VDC(self.client, name=self.vdc_name, resource=vdc_resource)

    def manage_states(self):
        operation = self.params.get('operation')
        if operation == "read":
            return self.get_edge_information()

    def get_edge_information(self):
        operation = self.params.get('operation')

        if operation:
            return self.run_get_edge_information()

        raise ValueError("Operation type is must be read, now is missing")

    def run_get_edge_information(self):
        response = dict()
        response['changed'] = False
        edge_name = self.params.get('edge_name')
        description = self.params.get('description')

        try:
            self.vdc.get_direct_orgvdc_network(edge_name)
        except EntityNotFoundException:
            msg = 'EDGE INFO Cannot be found for {0} '
            response['msg'] = error.__str__(msg)
            response['changed'] = True
        else:
            msg = 'EDGE INFO Network {0} is already present'
            response['warnings'] = msg.format(edge_name)

        return response

def main():
    argument_spec = org_vdc_network_argument_spec()
    response = dict(msg=dict(type='str'))
    module = EdgeInCatalogWhole(
        argument_spec=argument_spec, supports_check_mode=True)
    try:
        if not module.params.get('operation'):
            raise Exception('Please provide the operation for the resource.')

        response = module.manage_states()

    except Exception as error:
        response['msg'] = error.__str__()
        module.fail_json(**response)

    module.exit_json(**response)


if __name__ == '__main__':
    main()