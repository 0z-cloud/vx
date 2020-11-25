
ANSIBLE_METADATA = {
    'metadata_version': '1.4',
    'status': ['preview'],
    'supported_by': 'community'
}
DOCUMENTATION = '''
---
module: vcd_vapp_vm_nic_read
short_description: Read VM NIC's IP in vCloud Director
version_added: "2.9.9"
description:
    - Read VM NIC's IP in vCloud Director
options:
    org:
        description:
            - Organization name on vCloud Director to access
        required: false
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
    network:
        description:
            - VApp network name
        required: false
    ip_allocation_mode:
        description:
            - IP allocation mode (DHCP, POOL or MANUAL)
        required: false
    ip_connected:
        description:
            - Indicates connection physic state of NIC
            - Possible states of nic connection is True/False.
        required: true
    nic_id:
        description:
            - You can select one from range [0-9]
            - Module checks the provided NIC index id with gathered list of presented NICs
        required: true
    nic_ids:
        description:
            - List of NIC IDs
        required: false
    is_primary:
        description:
            - Indicates NIC are a primary VM interface or no.
            - Possible values are [0/1]
        required: true
    adapter_type:
        description:
            - Adapter type (VMXNET3, E1000E, ...)
        required: true
    state:
        description:
            - Target state of NIC (present/update/absent).
            - One from state or operation has to be provided.
            - Default value for one-call work - "present"
        required: true
    operation:
        description:
            - Operation to perform for nic.
            - One from state or operation has to be provided.
            - Default value for one-call work - "validate"
        required: true
    verification:
        description:
            - Verification on nic.
            - Verification must to be provided.
            - Possible keys are currently usage - "meta"
        required: true
    ip_address:
        description:
            - NIC IP address (required for MANUAL IP allocation mode)
        required: false
author:
    - rsgrigoriev@local.cloud.eve.vortice.eden
'''
EXAMPLES = '''
- name: '[ethX] Create NIC and Attach NIC with ID to NICs Specs by Network in vCloud vApp Zone'
  vcd_vapp_vm_nic_read:
    org: "SupriMeOraginzation"
    user: "zero_zen_time_admin"
    password: "af09012h0ri2tghjvj"
    host: "vcloud-director.example.com"
    vm_name: "any-instance-01"
    vapp: "product-environment-datacenter-location"
    vdc: "SupriMeOraginzation_VDataCenter_03"
    network: "vZone_Sector_Network_Exchange_product_routed_environment_datacenter"
    ip_allocation_mode: "DHCP"
    is_connected: True
    nic_id: "1"
    nic_ids: 
      - "1"
      - "0"
    is_primary: 0
    adapter_type: "E1000"
    state: "present"
    verification: "meta"
    operation: "validate"
'''

RETURN = '''
msg: success/failure message corresponding to nic state
changed: true if resource has been changed else false
'''

from ansible.module_utils.vcd import VM
from pyvcloud.vcd.org import Org
from pyvcloud.vcd.vdc import VDC
from pyvcloud.vcd.vapp import VApp
from pyvcloud.vcd.client import EntityType
from ansible.module_utils.vcd import VcdAnsibleModule
from pyvcloud.vcd.exceptions import OperationNotSupportedException
from pyvcloud.vcd.exceptions import EntityNotFoundException, InvalidParameterException
from pyvcloud.vcd.client import EntityType
VAPP_VM_NIC_OPERATIONS = ['update', 'read', 'validate', 'get_nics_indexes']
IP_ALLOCATION_MODE = ["DHCP", "POOL", "MANUAL"]
VAPP_VM_NIC_STATES = ['read', 'present', 'absent', 'update', 'validate', 'get_nics_indexes']
NETWORK_ADAPTER_TYPE = ['VMXNET', 'VMXNET2', 'VMXNET3', 'E1000', 'E1000E', 'PCNet32']
METATYPE_STATES = ['meta', 'present', 'absent', 'update', 'validate', 'get_nics_indexes']
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
class VappVMNIC(VcdAnsibleModule):
    def __init__(self, **kwargs):
        super(VappVMNIC, self).__init__(**kwargs)
        vapp_resource = self.get_resource()
        self.vapp = VApp(self.client, resource=vapp_resource)
        vapp = self.vapp
        nic_mapping = dict()
        self.nic_mapping = nic_mapping
        adapter_type = self.params.get('adapter_type')
    def manage_meta(self):
        verification = self.params.get('verification')
        if verification == "meta":
            self = self.read_nics()
            return self
    def manage_states(self):
        state = self.params.get('state')
        nic_id = self.params.get('nic_id')
        response = dict()
        list_with_current_indexes_of_nics = []
        already_in_nics_list = self.ncls
        if len(already_in_nics_list) == 0:
            if state == "validate":
                response = self.add_nic_ng()
            if state == "present":
                response = self.add_nic_ng()
        else:
            nics = self.get_vm_nics()
            nics_indexes = [int(nic.NetworkConnectionIndex) for nic in nics.NetworkConnection]
            if nic_id not in nics_indexes:
                response = self.add_nic_ng()
            else:
                response = self.update_nic_ng()
        self.response = response
        return response
    def manage_operations(self):
        operation = self.params.get('operation')
        if operation == "read":
            return self.read_nics()
        if operation == "update":
            return self.update_nic()
        if operation == "validate":
            return self.validate_nics()
    def validate_nics(self):
        vm_name = self.params.get('vm_name')
        nic_id = self.nitc
        nic_state = self.nids
        ncls = self.ncls
        mms = self.mms
        nap = self.nap
        vncc = self.vncc
        gtntci = self.gtntci
        ip_allocation_mode = self.params.get('ip_allocation_mode')
        ip_address = self.params.get('ip_address')
        network = self.params.get('network')
        is_connected = self.params.get('is_connected')
        vm_updated = self.get_vm()
        ncls_updated = vm_updated.list_nics()
        gtntci_updated = len(ncls_updated)
        self.return_self_rsp_custom()
        self.response['changed'] = False
        return self.response
    def get_resource(self):
        vapp = self.params.get('vapp')
        vdc = self.params.get('vdc')
        nic_id = self.params.get('nic_id')
        vm_name = self.params.get('vm_name')
        org_resource = Org(self.client, resource=self.client.get_org())
        vdc_resource = VDC(self.client, resource=org_resource.get_vdc(vdc))
        vapp_resource_href = vdc_resource.get_resource_href(
            name=vapp, entity_type=EntityType.VAPP)
        vapp_resource = self.client.get_resource(vapp_resource_href)
        return vapp_resource
    def get_vm(self):
        vapp_vm_resource = self.vapp.get_vm(self.params.get('vm_name'))
        return VM(self.client, resource=vapp_vm_resource)
    def get_vm_nics(self):
        vm = self.get_vm()
        return self.client.get_resource(
            vm.resource.get('href') + '/networkConnectionSection')
    def return_self_rsp_custom(self):
        self.response.update(self.rsp)
        return self
    def return_vm_from_vapp(self):
        vm_name_in_app = self.params.get('vm_name')
        vm_in_vapp = self.vapp.get_vm(vm_name_in_app)
        return vm_in_vapp
    def read_nics(self):
        vm = self.get_vm()
        vm_in_vapp = self.return_vm_from_vapp()
        self.vm_in_vapp = vm_in_vapp
        nitc = self.params.get('nic_id')
        nids = self.params.get('nic_ids')
        primary_index = int()
        self.primary_index = primary_index
        rsp = dict()
        nltl = list()
        try:
            ncls = vm.list_nics()
        except:
            response_add_returned = self.add_nic_ng()
            ncls = vm.list_nics()
            self.ncls = ncls
            self.response_add_returned = response_add_returned
            self.rsp['changed'] = True
        rsp['changed'] = False
        all_nics_list = vm.list_nics()
        for dict_item in all_nics_list:
            if dict_item['index'] == str(nitc):
                try: 
                    rsp['vm_ip_address'] = dict_item['ip_address']
                except:
                    rsp['vm_ip_address'] = 'Zero'
        etnrcl = None
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
        self.nids = nids
        self.etnrcl = etnrcl
        self.ncls = ncls
        self.nltl = nltl
        self.rsp = rsp
        self.nids = nids
        self.nitc = nitc
        self.response = response
        self.rsp = rsp
        return self
    def update_nic_ng(self):
        vm = self.get_vm()
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
        add_nic_task = vm.update_nic(adapter_type=adapter_type,
                                  nic_id=nic_id,
                                  is_primary=is_primary,
                                  is_connected=is_connected,
                                  network_name=network,
                                  ip_address_mode=ip_allocation_mode,
                                  ip_address=ip_address
                                  )
        self.execute_task(add_nic_task)
        response['changed'] = True
        return response
    def add_nic_ng(self):
        vm = self.get_vm()
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
                                  ip_address=ip_address
                                  )
        self.execute_task(add_nic_task)
        response['z_add_nic_ng'] = {
            '[0 ADD] A new nic has been added to VM:': vm_name,
            '[0 ADD] A added nic with ID:': nic_id,
            '[0 ADD] Ip allocation model': ip_allocation_mode,
            '[0 ADD] Ip address': ip_address,
            '[0 ADD] We at end of add_nic method': "add_nic",
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
                                            nic_id=nic_id,
                                            is_connected=is_connected,
                                            is_primary=is_primary,
                                            ip_address=ip_address,
                                            ip_address_mode=ip_allocation_mode,
                                            adapter_type=adapter_type)
            self.execute_task(update_nic_task)
            msg = 'A nic attached with VM {0} has been updated'
            response['msg'] = msg.format(vm_name)
            response['changed'] = True
        except EntityNotFoundException as error:
            response['msg'] = error.__str__()
        return response
def main():
    global response
    global networks_check
    argument_spec = vapp_vm_nic_argument_spec()
    response = dict(msg=dict(type='str'))
    networks_check = bool()
    module = VappVMNIC(argument_spec=argument_spec, supports_check_mode=True)
    if module.params.get('verification'):
        response = module.manage_meta()
    if module.params.get('state'):
        response = module.manage_states()
    if module.params.get('operation'):
        response = module.manage_operations()
    module.exit_json(**response)
if __name__ == '__main__':
    main()