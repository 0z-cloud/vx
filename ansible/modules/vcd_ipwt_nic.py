# !/usr/bin/python


from collections import defaultdict
from ansible.module_utils.vcd import VcdAnsibleModule
from pyvcloud.vcd.client import E
from pyvcloud.vcd.client import EntityType
from pyvcloud.vcd.exceptions import EntityNotFoundException
from pyvcloud.vcd.org import Org
from pyvcloud.vcd.vapp import VApp
from pyvcloud.vcd.vdc import VDC
from pyvcloud.vcd.vm import VM

VAPP_VM_NIC_STATES = ['present', 'absent']
VAPP_VM_NIC_OPERATIONS = ['update', 'read']
NETWORK_ADAPTER_TYPE = ['VMXNET', 'VMXNET2', 'VMXNET3', 'E1000', 'E1000E', 'PCNet32']

def vapp_vm_nic_argument_spec():
    return dict(
        vm_name=dict(type='str', required=True),
        vapp=dict(type='str', required=True),
        vdc=dict(type='str', required=True),
        nic_id=dict(type='int', required=False),
        nic_ids=dict(type='list', required=False),
        ip_allocation_mode=dict(type='str', required=False, default='DHCP'),
        is_connected=dict(type='bool', required=False, default=False),
        ip_address=dict(type='str', required=False, default=''),
        network=dict(type='str', required=False),
        adapter_type=dict(choices=NETWORK_ADAPTER_TYPE, required=True),
        state=dict(choices=VAPP_VM_NIC_STATES, required=False),
        operation=dict(choices=VAPP_VM_NIC_OPERATIONS, required=False),
    )

class VappVMNIC(VcdAnsibleModule):
    def __init__(self, **kwargs):
        super(VappVMNIC, self).__init__(**kwargs)
        vapp_resource = self.get_resource()
        self.vapp = VApp(self.client, resource=vapp_resource)

    def create_list_with_present_nics(self):
        response = dict()
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

    def manage_states(self):
        returned_nics_list = self.create_list_with_present_nics()
        
        state = self.params.get('state')
        if state == "present":
            present_nic = self.custom_add_nic()
            return self.add_update_nic()

        if state == "absent":
            return self.delete_nic()

    def manage_operations(self):
        operation = self.params.get('operation')
        if operation == "update":
            network = self.params.get('network')
            if network:
                return self.add_update_nic("update")
            else:
                return self.update_nic()

            # update_nic = self.custom_add_nic()
            # self.update_nic = update_nic
            return self.update_nic()
            # if network:
            #     return self.add_update_nic("update")
            # else:
            #     return self.update_nic()
            # if network:
            #     return self.add_update_nic("update")
            # else:
            #     return self.update_nic()

        if operation == "read":
            return self.read_nics()

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
        return self.client.get_resource(vm.resource.get('href') + '/networkConnectionSection')

    def manage_nics_list(self):
        nic_id = self.params.get('nic_id')
        nic_ids = self.params.get('nic_ids')
        nics = self.get_vm_nics()
        
        if 'NetworkConnection' not in dir(nics):
            nic = self.add_nic()
            self.nic = nic
            return self.nic
        
        #nics.get('NetworkConnection')
        #if hasattr(nics,"NetworkConnection")
        # 
        # if nics is None:
        #     self.custom_add_nic()

    def custom_add_nic(self):
        vm = self.get_vm()
        vm_name = self.params.get('vm_name')
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

    # noinspection DuplicatedCode
    def add_update_nic(self, op = "add"):
        '''
            Used to add a nic (default)
            or to modify an existing one (op = "update") if network change is needed
            
            Error - More than 10 Nics are not permissible in vCD
        '''
        vm = self.get_vm()
        vm_name = self.params.get('vm_name')
        nic_id = self.params.get('nic_id')
        network = self.params.get('network')
        ip_address = self.params.get('ip_address')
        ip_allocation_mode = self.params.get('ip_allocation_mode')
        uri = vm.resource.get('href') + '/networkConnectionSection'
        response = defaultdict(dict)
        new_nic_id = None
        note = 'added'
        # nics = self.get_vm_nics()
        # if nics is None:
        #     self.add_nic()
        nic_found = False
        vm = self.get_vm()
        '''
        # ДЛЯ ИНДУСА STATE WITH FINDED DIFFERENT
        # nics_indexes = [int(nic.NetworkConnectionIndex) for nic in nics.NetworkConnection]
        # nic_indexs = [nic.NetworkConnectionIndex for nic in nics.NetworkConnection]
        '''
        nics_indexes = []
        nics = self.get_vm_nics()
        response['changed'] = False
        nics_zalupa = self.get_vm_nics()
        zalupa_index = [nic.NetworkConnectionIndex for nic in nics_zalupa.NetworkConnection]
        
        if "NetworkConnection" in nics:
            
            for nic_interface in nics.NetworkConnection:
                nic_id = int(nic_interface.NetworkConnectionIndex)
                nics_indexes += nic_id

            nics_indexes.sort()
            response['nics_indexes'] = {
                'NICs index is is already present': nics_indexes, 
            }
            
            for nic in nics.NetworkConnection:
                if nic.NetworkConnectionIndex == nic_id:
                    nic_found = True
                    if op == "add":
                        '''
                        # presend nic, when operation add, dont do anythins'''
                        response['msg'] = 'NIC is already present.'
                        return response
                    else:
                        '''
                        # update nic, when operation not are add, go validate'''
                        response['msg'] = 'NIC is present and updated.'
                        note = 'updated'

                if not nic_found and op == "update":
                    response['msg'] = 'Update nic: add NIC because his not found.'

                    if ip_allocation_mode in ('DHCP', 'POOL'):
                        nic = E.NetworkConnection(
                        E.NetworkConnectionIndex(nic_id),
                        E.IsConnected(True),
                        E.IpAddressAllocationMode(ip_allocation_mode),
                        network=network)
                    else:
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
        '''
                    #return response
                
        # else:
        #     if nic_id is None:
        #         for index, nic_index in enumerate(nics_indexes):
        #             new_nic_id = nic_index + 1
        #             if index != nic_index:
        #                 new_nic_id = index
        #                 break
        #         nic_id = new_nic_id
        #     else
        #     nics.NetworkConnection.addnext(nic)
        #     self.execute_task(add_nic_task)
        # else:
        #add_nic_task = self.client.put_resource(uri, nics, EntityType.NETWORK_CONNECTION_SECTION.value)
        #self.execute_task(add_nic_task)'''
        
        response['msg'] = {
            'vApp VM NIC:': note,
            'nic_id': nic_id,
            'ip_allocation_mode': ip_allocation_mode,
            'ip_address': ip_address,
            'network': network,
            'we at here yopta': 'really fucking shit'
        }
        response['changed'] = True
        return response

    def nics_enumerate(self):

        nics = self.get_vm_nics()

        if nics is None:
            self.custom_add_nic()
        nics = self.get_vm_nics()
        nics_indexes = [int(nic.NetworkConnectionIndex) for nic in nics.NetworkConnection]
        nics_indexes.sort()
        for index, nic_index in enumerate(nics_indexes):
            new_nic_id = nic_index + 1
            if index != nic_index:
                new_nic_id = index
                break

    def add_nic(self):
        '''
            Error - More than 10 Nics are not permissible in vCD
        '''
        vm = self.get_vm()
        vm_name = self.params.get('vm_name')
        network = self.params.get('network')
        ip_address = self.params.get('ip_address')
        ip_allocation_mode = self.params.get('ip_allocation_mode')
        uri = vm.resource.get('href') + '/networkConnectionSection'
        response = defaultdict(dict)
        response['changed'] = False
        new_nic_id = None

        nics = self.get_vm_nics()
        if nics is None:
            self.custom_add_nic()
        nics = self.get_vm_nics()
        nics_indexes = [int(nic.NetworkConnectionIndex) for nic in nics.NetworkConnection]
        nics_indexes.sort()
        for index, nic_index in enumerate(nics_indexes):
            new_nic_id = nic_index + 1
            if index != nic_index:
                new_nic_id = index
                break

        if ip_allocation_mode not in ('DHCP', 'POOL', 'MANUAL'):
            raise Exception('IpAllocationMode should be one of DHCP/POOL/MANUAL')

        if ip_allocation_mode in ('DHCP', 'POOL'):
            nic = E.NetworkConnection(
                E.NetworkConnectionIndex(new_nic_id),
                E.IsConnected(True),
                E.IpAddressAllocationMode(ip_allocation_mode),
                network=network)
        else:
            if not ip_address:
                raise Exception('IpAddress is missing.')
            nic = E.NetworkConnection(
                E.NetworkConnectionIndex(new_nic_id),
                E.IpAddress(ip_address),
                E.IsConnected(True),
                E.IpAddressAllocationMode(ip_allocation_mode),
                network=network)

        nics.NetworkConnection.addnext(nic)
        add_nic_task = self.client.put_resource(uri, nics, EntityType.NETWORK_CONNECTION_SECTION.value)
        self.execute_task(add_nic_task)
        response['msg'] = {
            'nic_id': new_nic_id, 
            'ip_allocation_mode': ip_allocation_mode,
            'ip_address': ip_address,
            'we_at_here': 'add_nic we_at_here'
        }
        response['changed'] = True

        return response

    def update_nic(self):
        '''
            Following update scenarios are covered
            1. IP allocation mode change: DHCP, POOL, MANUAL
            2. Update IP address in MANUAL mode
            
            If network change is needed, add_update_nic is used
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
            nics.NetworkConnection[nic_to_update].network = network
            response['changed'] = True

        if ip_allocation_mode:
            allocation_mode_element = E.IpAddressAllocationMode(ip_allocation_mode)
            nics.NetworkConnection[nic_to_update].IpAddressAllocationMode = allocation_mode_element
            response['changed'] = True

        if ip_address:
            nics.NetworkConnection[nic_to_update].IpAddress = E.IpAddress(ip_address)
            response['changed'] = True

        if response['changed']:
            update_nic_task = self.client.put_resource(uri, nics, EntityType.NETWORK_CONNECTION_SECTION.value)
            self.execute_task(update_nic_task)
            response['msg'] = 'update_nid: vApp VM nic has been updated.'

        return response

    def read_nics(self):
        vm = self.get_vm()
        response = defaultdict(dict)
        response['changed'] = False

        nics = self.get_vm_nics()
        for nic in nics.NetworkConnection:
            meta = defaultdict(dict)
            nic_id = str(nic.NetworkConnectionIndex)
            meta['MACAddress'] = str(nic.MACAddress)
            meta['IsConnected'] = str(nic.IsConnected)
            meta['NetworkAdapterType'] = str(nic.NetworkAdapterType)
            meta['NetworkConnectionIndex'] = str(nic.NetworkConnectionIndex)
            meta['IpAddressAllocationMode'] = str(nic.IpAddressAllocationMode)
            meta['we at here 2'] = '2222222'

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
    # org = "AIM"
    # user = "cloud_robot_man_admin"
    # password = "supersonic777cloud666"
    # host = "https://vcd.local.cloud.eve.vortice.eden/tenant/aim/"
    # vm_name = "oz-router-01"
    # vapp = "vZone_Sector_Network_Exchange_matreshka_zone_production_dc911rs"
    # vdc = "lf-vx-z1e-vcd"
    # network = "vZone_Sector_Network_Exchange_matreshka_routed_production_dc911rs"
    # ip_allocation_mode = "DHCP"
    # is_connected = True
    # verify_ssl_certs = True
    # api_version = '31.0'
    # nic_id = "1"
    # nic_ids = ["1", "0"]
    # adapter_type = "E1000"
    # state = "present"
    # operation = "update"
    argument_spec = vapp_vm_nic_argument_spec()
    response = dict(
        msg=dict(type='str')
    )
    module = VappVMNIC(argument_spec=argument_spec, supports_check_mode=True)

    try:

        if module.params.get('state'):
            response = module.manage_states()
        # if module.params.get('operation'):
        #     response = module.manage_operations()
        else:
            raise Exception('One of the state/operation should be provided.')

    except Exception as error:
        response['msg'] = error
        module.fail_json(**response)

    module.exit_json(**response)

if __name__ == '__main__':
    main()
