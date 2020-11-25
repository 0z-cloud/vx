#!/usr/bin/python

# Copyright © 2018 VMware, Inc. All Rights Reserved.
# SPDX-License-Identifier: BSD-2-Clause OR GPL-3.0-only

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'community'
}

DOCUMENTATION = '''
---
module: vcd_get_resources_by_org
short_description: Get Organization Resources's states/operations in vCloud Director
version_added: "2.4"
description:
    - Fetch by vcd_get_resources_by_org's states/operations in vCloud Director Resources

options:
    user:
        description:
            - vCloud Director user name
        required: true
    password:
        description:
            - vCloud Director user password
        required: true
    host:
        description:
            - vCloud Director host address
        required: true
    org:
        description:
            - Organization name on vCloud Director to access
        required: true
    org_name:
        description:
            - Organization name on vCloud Director to access
        required: true
    api_version:
        description:
            - Pyvcloud API version
        required: false
    verify_ssl_certs:
        description:
            - whether to use secure connection to vCloud Director host
        required: bool
    vdc:
        description:
            - The name of the new vdc
        type: str
    vdc_org_name:
        description:
            - The name of organization the new vdc associated with
        type: str
    operation:
        description:
            - operation to perform on vcd_get_resources_by_org (read/list_networks).
            - One of operation/state has to be provided.
        required: true
author:
    Rostisalv Grigoriev - ros@woinc.ru
'''

EXAMPLES = '''
- name: Get vCloud Director Resources by Organization and Virtual Cloud Datacenter
  vcd_get_edge_ip:
    org_name: "AIM"
    org: AIM
    vdc: "AIM_VCD01"
    vdc_org_name: AIM
    host: "vcd.example.com"
    verify_ssl_certs: False
    user: "test-user"
    password: "12345"
    operation: read
  register: output
'''

RETURN = '''
msg: success/failure message corresponding to catalog item state/operation
changed: true if resource has been changed else false
'''
from lxml import etree
from lxml.objectify import StringElement
from ansible.module_utils.vcd import VcdAnsibleModule
import time
import sys
import requests

from pyvcloud.vcd.system import System
from pyvcloud.vcd.exceptions import EntityNotFoundException, BadRequestException,OperationNotSupportedException
from pyvcloud.vcd.platform import Platform
from pyvcloud.vcd.external_network import ExternalNetwork
# from module_utils.basic import AnsibleModule
from pyvcloud.vcd.vdc import VDC
from pyvcloud.vcd.org import Org
from pyvcloud.vcd.vapp import VApp
from pyvcloud.vcd.client import Client
from pyvcloud.vcd.client import QueryResultFormat
from pyvcloud.vcd.gateway import Gateway

from lxml import etree

from pyvcloud.vcd.acl import Acl
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
from pyvcloud.vcd.client import NSMAP
from pyvcloud.vcd.client import QueryResultFormat
from pyvcloud.vcd.client import RelationType
from pyvcloud.vcd.client import ResourceType
from pyvcloud.vcd.client import SIZE_1MB
from pyvcloud.vcd.exceptions import EntityNotFoundException
from pyvcloud.vcd.exceptions import InvalidParameterException
from pyvcloud.vcd.exceptions import MultipleRecordsException
from pyvcloud.vcd.exceptions import OperationNotSupportedException
from pyvcloud.vcd.metadata import Metadata
from pyvcloud.vcd.org import Org
from pyvcloud.vcd.platform import Platform
from pyvcloud.vcd.utils import cidr_to_netmask
from pyvcloud.vcd.utils import get_admin_href
from pyvcloud.vcd.utils import is_admin
from pyvcloud.vcd.utils import netmask_to_cidr_prefix_len
from pyvcloud.vcd.utils import retrieve_compute_policy_id_from_href

VCD_EXTERNAL_NETWORKS_OPERATIONS = ['read', 'list_networks', 'read_and_return']
VAPP_NETWORK_STATES = ['present', 'update', 'absent']
VAPP_NETWORK_OPERATIONS = ['read', 'list_networks', "read_and_return"]

def vapp_network_argument_spec():
    return dict(
        edge_input_to_get=dict(type='str', required=True),
        host=dict(type='str', required=True),
        user=dict(type='str', required=True),
        password=dict(type='str', required=True),
        vdc=dict(type='str', required=True),
        vdc_org_name=dict(type='str', required=True),
        api_version=dict(type='str', required=True),
        org_name=dict(type='str', required=True),
        org=dict(type='str', required=True),
        operation=dict(choices=VAPP_NETWORK_OPERATIONS, required=False),
)

class VcdResource(VcdAnsibleModule):
    def __init__(self, **kwargs):
        super(VcdResource, self).__init__(**kwargs)
        edge_input_to_get = self.params.get('edge_input_to_get')
        operation = self.params.get('operation')
        vdc = self.params.get('vdc')
        org_name = self.params.get('org_name')
        org = self.params.get('org')
        name = self.params.get('name')
        host = self.params.get('host')
        user = self.params.get('user')
        password = self.params.get('password')
        vdc_org_name = self.params.get('vdc_org_name')
        self.edge_input_to_get = edge_input_to_get
        self.operation = operation
        self.vdc = vdc
        self.org_name = org_name
        self.org = org
        self.name = name
        self.host = host
        self.user = user
        self.password = password
        self.vdc_org_name = vdc_org_name
         
    def get_vdc_org_resource(self):
        if self.params.get(self.vdc_org_name):
            return self.client.get_org_by_name(self.params.get(self.vdc_org_name))
        return self.client.get_org()

    def manage_operations(self):
        operation = self.params.get('operation')
        if operation == "read":
            return self.getVcdResourcesByOrg()
        if operation == "list_networks":
            return self.list_external_networks()
        if operation == "read_and_return":
            return self.read_and_return()

    def read_and_return(self):
        response = dict()
        response_data = dict()
        vdc_resources = dict()
        copy_result = dict()
        vdc_resources = self.get_vdc_org_resource()
        self.vdc_resources = vdc_resources
        self.org = Org(self.client, resource=self.client.get_org())
        platform = Platform(self.org.client)
        self.platform = platform
        vdc_name = self.vdc_org_name
        vdc_response = VDC(self.client, name=self.vdc, resource=(self.org.get_vdc(self.vdc)))
        result = vdc_response.list_edge_gateways()
        for ko in result:
            copy_result.update(ko)
        self.copy_result = copy_result
        #networks_result_xml = str()
        networks_result_xml = vdc_response.get_gateway(self.edge_input_to_get)
        response_data = vdc_response.list_edge_gateways()
        for m in response_data:
                edge_href = m['href']
                self.edge_href = edge_href
        for e in result:
                del e['href']
        #result_n_gateway = Gateway(self.edge_input_to_get,self.edge_href,resource=(self.org.get_vdc(self.vdc)))
        #response['networks_result_xml'] = networks_result_xml
        response['edge-gw-info'] = result_n_gateway
        response['edge-gw-href'] = edge_href
        response['edge-gw-copy'] = response_data
        response['edge-gw-name'] = self.edge_input_to_get
        response['edge-gw'] = result
        self.vdc_response = vdc_response
        # vdc_resource = self.org.get_vdc(self.org)
        # self.vdc = VDC(self.client, name=self.vdc, resource=vdc_resource)
        # vdc = self.vdc
        response['changed'] = True
        return response

        # vdc_request_rexource_result_orgvdc = self.vdc_response.list_orgvdc_direct_networks()
        # vdc_request_orgvdc_routed_networks = self.vdc_response.list_orgvdc_routed_networks()
        # vdc_request_orgvdc_network_resources = self.vdc_response.list_orgvdc_network_resources()

        # routed_networks_list = []

        # get_access_settings_result = dict()

        # get_access_settings_result = self.vdc_response.get_access_settings()

        # self.vdc_request_rexource_result_orgvdc = vdc_request_rexource_result_orgvdc
        # self.vdc_request_orgvdc_routed_networks = vdc_request_orgvdc_routed_networks
        # self.vdc_request_orgvdc_network_resources = vdc_request_orgvdc_network_resources

        # for routed_network in vdc_response.list_orgvdc_routed_networks:
        #     routed_networks_list = routed_networks_list.append(routed_network)


        # # vdc_resource = self.org.get_vdc(self.vdc)
        # self.vdc = VDC(self.client, name=self.vdc, resource=vdc_resource)
        # vdc_call = Org(self.client.getvdc(self.params.get_vdc_org_resource(self.vdc_org_name)))
        # # response['msg'] = "VDC Details: {} ".format(platform)
        # # response['msg'] = "Platform Details: {} ".format(vdc_name)
        # # response['msg'] = "VDC Resources: {} ".format(vdc_resources)
        # response['networks'] = list()
        
        # for key_of_network in get_access_settings_result.keys():
        #     return response['networks'].append(key_of_network)

        # #response['networks'] = get_access_settings_result.keys()
        # response['msg'] = " API Host: {0}\n  \
        #                     Organization: {1}\n \
        #                     Username: {2}\n    \
        #                     Password: {3}\n    \
        #                     Message out by Platform : {4}\n \
        #                     Datacenter: {5}\n    \
        #                     Organization Resource: {6}\n    \
        #                     Organization Response: {7}\n \
        #                     Operation Type: {8}\n    \
        #                     VDC Organization name: {9}\n   \
        #                     Virtual Organization:    {10}\n  \
        #                     ".format(self.host, self.org_name, self.user, self.password, self.platform, self.vdc, self.vdc_resources, self.vdc_response, self.operation, self.vdc_org_name, self.org)

        # # response['msg'] = " API Host: {0}\n  \
        #                     Organization: {1}\n \
        #                     Username: {2}\n    \
        #                     Password: {3}\n    \
        #                     Message out by Platform : {4}\n \
        #                     Datacenter: {5}\n    \
        #                     Organization Resource: {6}\n    \
        #                     Organization Response: {7}\n \
        #                     Operation Type: {8}\n    \
        #                     VDC Organization name: {9}\n   \
        #                     Virtual Organization:    {10}\n  \
        #                     Some Networks:     {11}\n  \
        #                     Routed Networks:     {12}\n  \
        #                     Resources in Networks:     {12}\n  \
        #                     ".format(self.host, self.org_name, self.user, self.password, self.platform, self.vdc, self.vdc_resources, self.vdc_response, self.operation, self.vdc_org_name, self.org, self.vdc_request_rexource_result_orgvdc, self.vdc_request_orgvdc_routed_networks, self.vdc_request_orgvdc_network_resources)


        # response['msg'].append("API Host: {0}\n    Organization: {1}\n \
        #                                             Username: {2}\n    Password: {3}\n    Message out by platform : {4}\n \
        #                                             Name: {5}\n    Organization Resource: {6}\n    Organization Response: {7}\n \
        #                                             Datacenter: {8}\n    Platform: {9}\n   Organization Separated Name Full:    {10}\n    VDC Resource:    {11}\n \
        #                      ").format(self.host, self.org, self.user, self.password, self.platform, self.org, self.org_name, self.vdc_org_name, self.vdc, platform)

        # logged_in_org = self.client.get_org()
        #self.org = Org(self.client, resource=logged_in_org)
        # vdc = Org(self.client.get.vdc(self.params.get(self.vdc_org_name)))
        # self.vdc = VDC(self.client, href=vdc.client.get('href'))
        # vdc_resources = Org(self.org).client.get.vcd_get_resources_by_org(self.vdc)
        # org_name = self.params.get('org_name')
        # response = dict()
        # org_details = dict()
        # response['changed'] = False
        # resource = self.client.get_org_by_name(org_name)
        # org = Org(self.client, resource=resource)
        # org_admin_resource = org.client.get_resource(org.href_admin)
        # org_details['org_name'] = org_name
        # org_details['full_name'] = str(org_admin_resource['FullName'])
        # org_details['is_enabled'] = str(org_admin_resource['IsEnabled'])
        # response['msg'] = "Org Details: {} ".format(org_details)
        # response['msg'] = "Org Name: {} ".format(org_name)
        # response['msg'] = "VDC: {} ".format(vdc)
        # response['msg'] = "VDC Resources: {} ".format(vdc_resources)
        # response['msg'] = "Main Resource: {} ".format(resource)

    def list_external_networks(self):
        response = dict()
        response['msg'] = list()
        response['changed'] = False
        response['msg'] = "test"
        return response

    def getVcdResourcesByOrg(self):
        response = dict()
        response['org'] = str()
        response['user'] = str()
        response['password'] = str()
        response['host'] = str()
        response['msg'] = list()
        response['changed'] = dict()
        # response['name'] = str()
        response['org_resource'] = str()
        response['org_response'] = dict()
        response['vdc_resource'] = dict()
        response['vdc'] = str()
        response['platform'] = dict()
        response['org_name'] = str()
        response['msg_test'] = "test"

        api_version = self.params.get('api_version')
        platform = self.platform
        vdc_org_name = self.params.get('org_name')
        vdc = self.params.get('vdc')
        org_name = self.params.get('org_name')
        org = self.params.get('org')
        # name = self.params.get('name')
        host = self.params.get('host')
        user = self.params.get('user')
        password = self.params.get('password')
        operation = self.params.get('operation')
        response['msg'].append("API Host: {0}".format(self.host))
        # response['msg'].append("API Host: {0}\n    Organization: {1}\n \
        #                                             Username: {2}\n    Password: {3}\n    Message out by platform : {4}\n \
        #                                             Name: {5}\n    Organization Resource: {6}\n    Organization Response: {7}\n \
        #                                             Datacenter: {8}\n    Platform: {9}\n   Organization Separated Name Full:    {10}\n    VDC Resource:    {11}\n \
        #                      ").format(self.host, self.org, self.user, self.password, self.platform, self.org, self.org_name, self.vdc_org_name, self.vdc, platform)

        return response

def main():

    argument_spec = vapp_network_argument_spec()
    response = dict(msg=dict(type='str'))
    module = VcdResource(argument_spec=argument_spec, supports_check_mode=True)

    # return response

    try:
        if module.params.get('state'):
            response = module.manage_states()
        elif module.params.get('operation'):
            response = module.manage_operations()
        else:
            raise Exception('Please provide the state for the resource')

        module.exit_json(**response)

    except Exception as error:
        response['msg'] = error
        module.fail_json(**response)

    
if __name__ == '__main__':
    main()

