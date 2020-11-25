#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
VMware Inventory Script
=======================
'''
# import logging
# import time
# import os.path
# import subprocess
import os
import sys
import json

import ConfigParser
import optparse
import atexit

from pyVim.connect import SmartConnect, Disconnect
from pyVmomi import vim, vmodl


def _get_si():
    '''
    Authenticate with vCenter server and return service instance object.
    '''

    config = ConfigParser.SafeConfigParser()
    if os.environ.get('VMWARE_INI', ''):
        config_files = [os.environ['VMWARE_INI']]
    else:
        config_files =  [os.path.abspath(sys.argv[0]).rstrip('.py') + '.ini', 'vmware.ini']
    for config_file in config_files:
        if os.path.exists(config_file):
            config.read(config_file)
            break

    # (if set), otherwise from INI file.
    auth_host = os.environ.get('VMWARE_HOST')
    if not auth_host and config.has_option('auth', 'host'):
        auth_host = config.get('auth', 'host')
    auth_user = os.environ.get('VMWARE_USER')
    if not auth_user and config.has_option('auth', 'user'):
        auth_user = config.get('auth', 'user')
    auth_password = os.environ.get('VMWARE_PASSWORD')
    if not auth_password and config.has_option('auth', 'password'):
        auth_password = config.get('auth', 'password')
    # protocol = 'https'
    # port = 443


    try:
        si = SmartConnect(host=auth_host,
                          user=auth_user,
                          pwd=auth_password)
                          #,port=int(auth.port))
    except IOError, e:
        pass

    #
    # except Exception as exc:
    #     if isinstance(exc, vim.fault.HostConnectFault) and '[SSL: CERTIFICATE_VERIFY_FAILED]' in exc.msg:
    #         try:
    #             import ssl
    #             default_context = ssl._create_default_https_context
    #             ssl._create_default_https_context = ssl._create_unverified_context
    #             si = SmartConnect(
    #                 host=auth.host,
    #                 user=auth.user,
    #                 pwd=auth.password,
    #                 protocol=protocol,
    #                 port=port
    #             )
    #             ssl._create_default_https_context = default_context
    #         except Exception as exc:
    #             err_msg = exc.msg if hasattr(exc, 'msg') else 'Could not connect to the specified vCenter server. Please check the debug log for more information'
    #             raise Exception(err_msg)
    #     else:
    #         err_msg = exc.msg if hasattr(exc, 'msg') else 'Could not connect to the specified vCenter server. Please check the debug log for more information'
    #         raise Exception(err_msg)

    atexit.register(Disconnect, si)

    return si


def _get_inv():
    '''
    Return the inventory.
    '''
    si = _get_si()
    return si.RetrieveContent()


def _get_content(obj_type, property_list=None):
    # Get service instance object
    si = _get_si()

    # Refer to http://pubs.vmware.com/vsphere-50/index.jsp?topic=%2Fcom.vmware.wssdk.pg.doc_50%2FPG_Ch5_PropertyCollector.7.6.html for more information.

    # Create an object view
    obj_view = si.content.viewManager.CreateContainerView(si.content.rootFolder, [obj_type], True)

    # Create traversal spec to determine the path for collection
    traversal_spec = vmodl.query.PropertyCollector.TraversalSpec(
        name='traverseEntities',
        path='view',
        skip=False,
        type=vim.view.ContainerView
    )

    # Create property spec to determine properties to be retrieved
    property_spec = vmodl.query.PropertyCollector.PropertySpec(
        type=obj_type,
        all=True if not property_list else False,
        pathSet=property_list
    )

    # Create object spec to navigate content
    obj_spec = vmodl.query.PropertyCollector.ObjectSpec(
        obj=obj_view,
        skip=True,
        selectSet=[traversal_spec]
    )

    # Create a filter spec and specify object, property spec in it
    filter_spec = vmodl.query.PropertyCollector.FilterSpec(
        objectSet=[obj_spec],
        propSet=[property_spec],
        reportMissingObjectsInResults=False
    )

    # Retrieve the contents
    content = si.content.propertyCollector.RetrieveContents([filter_spec])

    # Destroy the object view
    obj_view.Destroy()

    return content

def _get_mors_with_properties(obj_type, property_list=None):
    '''
    Returns list containing properties and managed object references for the managed object
    '''
    # Get all the content
    content = _get_content(obj_type, property_list)

    object_list = []
    for object in content:
        properties = {}
        for property in object.propSet:
            properties[property.name] = property.val
            properties['object'] = object.obj
        object_list.append(properties)

    return object_list


def _get_mor_by_property(obj_type, property_value, property_name='name'):
    '''
    Returns the first managed object reference having the specified property value
    '''
    # Get list of all managed object references with specified property
    object_list = _get_mors_with_properties(obj_type, [property_name])

    for object in object_list:
        if object[property_name] == property_value:
            return object['object']

    return None

def test_vcenter_connection(kwargs=None, call=None):
    '''
    Test if the connection can be made to the vCenter
    '''

    try:
        # Get the service instance object
        si = _get_si()
    except Exception as exc:
        return 'failed to connect: {0}'.format(exc)

    return 'connection successful'


def list_nodes_min(kwargs=None, call=None):
    '''
    Return a list of all VMs and templates that are on the specified provider, with no details
    '''

    ret = {}
    vm_properties = ["name"]

    vm_list = _get_mors_with_properties(vim.VirtualMachine, vm_properties)

    for vm in vm_list:
        ret[vm["name"]] = True

    return ret


def main():
    parser = optparse.OptionParser()
    parser.add_option('--list', action='store_true', dest='list',
                      default=False, help='Output inventory groups and hosts')
    parser.add_option('--host', dest='host', default=None, metavar='HOST',
                      help='Output variables only for the given hostname')
    # Additional options for use when running the script standalone, but never
    # used by Ansible.
    parser.add_option('--pretty', action='store_true', dest='pretty',
                      default=False, help='Output nicely-formatted JSON')
    parser.add_option('--include-host-systems', action='store_true',
                      dest='include_host_systems', default=False,
                      help='Include host systems in addition to VMs')
    parser.add_option('--no-meta-hostvars', action='store_false',
                      dest='meta_hostvars', default=True,
                      help='Exclude [\'_meta\'][\'hostvars\'] with --list')
    options, args = parser.parse_args()
    #
    # if options.include_host_systems:
    #     vmware_inventory = VMwareInventory(guests_only=False)
    # else:
    #     vmware_inventory = VMwareInventory()
    # if options.host is not None:
    #     inventory = vmware_inventory.get_host(options.host)
    # else:
    #     inventory = vmware_inventory.vmodl.(options.meta_hostvars)

    inventory = list_nodes_min()
    
    json_kwargs = {}
    if options.pretty:
        json_kwargs.update({'indent': 4, 'sort_keys': True})
    json.dump(inventory, sys.stdout, **json_kwargs)


if __name__ == '__main__':
    main()
