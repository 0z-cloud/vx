#!/usr/bin/env python

# -*- coding: utf-8 -*-

# (c) 2013, Romeo Theriault <romeot () hawaii.edu>
#
# This file is part of Ansible
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.#
# see examples/playbooks/vsphere_client.yml

# TODO:
# Ability to set CPU/Memory reservations

try:
    import json
except ImportError:
    import simplejson as json

DOCUMENTATION = ''' 
---
module: vsphere_client
short_description: Creates a virtual guest on vsphere.
description:
     - Communicates with vsphere, creating a new virtual guest OS based on
       the specifications you specify to the module.
version_added: "1.1"
options:
  vcenter_vx:
    description:
      - The hostname of the vcenter server the module will connect to, to create the guest.
    required: true
    default: null
    aliases: []
  user:
    description:
      - username of the user to connect to vcenter as.
    required: true
    default: null
  password:
    description:
      - password of the user to connect to vcenter as.
    required: true
    default: null
  ansible_resource_pool:
    description:
      - The name of the ansible_resource_pool to create the VM in.
    required: false
    default: None
  cluster:
    description:
      - The name of the cluster to create the VM in. By default this is derived from the host you tell the module to build the guest on.
    required: false
    default: None 
  datacenter:
    description:
      - The name of the datacenter to create the VM in.
    required: true 
    default: null
  datastore:
    description:
      - The datastore to store the VMs config files in. (Hard-disk locations are specified separately.) 
    required: true
    default: null
  esxi_hostname:
    description:
      - The hostname of the esxi host you want the VM to be created on.
    required: true
    default: null
  power_on:
    description:
      - Whether or not to power on the VM after creation.
    required: false
    default: no
    choices: [yes, no]
  vm_name:
    description:
      - The name you want to call the VM.
    required: true
    default: null
  vm_memory_mb:
    description:
      - How much memory in MB to give the VM.
    required: false
    default: 1024
  vm_num_cpus:
    description:
      - How many vCPUs to give the VM.
    required: false
    default: 1
  vm_scsi:
    description:
      - The type of scsi controller to add to the VM. 
    required: false
    default: "paravirtual"
    choices: [paravirtual, lsi, lsi_sas, bus_logic]
  vm_disk:
    description:
      - A key, value list of disks and their sizes and which datastore to keep it in.
    required: false
    default: null
  vm_nic:
    description:
      - A key, value list of nics, their types and what network to put them on.
    required: false
    default: null
    choices: [vmxnet3, vmxnet2, vmxnet, e1000, e1000e, pcnet32]
  vm_notes:
    description:
      - Any notes that you want to show up in the VMs Annotations field.
    required: false
    default: null
  vm_cdrom:
    description:
      - A path, including datastore, to an ISO you want the CDROM device on the VM to have.
    required: false
    default: null
  vm_extra_config:
    description:
      - A key, value pair of any extra values you want set or changed in the vmx file of the VM. Useful to set advanced options on the VM.
    required: false
    default: null
  guestosid:
    description:
      - A vmware guest needs to have a specific OS identifier set on it during creation. You can find your os guestosid at the following URL:
      http://www.vmware.com/support/developer/vc-sdk/visdk41pubs/ApiReference/vim.vm.GuestOsDescriptor.GuestOsIdentifier.html
    required: true
    default: null
# informational: requirements for nodes
requirements: [ pysphere ]
'''

HAS_PYSPHERE = True
try:
    from pysphere import VIServer, VIProperty, MORTypes
    from pysphere.resources import VimService_services as VI
    from pysphere.vi_task import VITask
    from pysphere import VIException, VIApiException, FaultTypes
except ImportError:
    HAS_PYSPHERE = False


def add_scsi_controller(module, s, config, devices, type="paravirtual", bus_num=0, disk_ctrl_key=1):
    ### add a scsi controller
    scsi_ctrl_spec = config.new_deviceChange()
    scsi_ctrl_spec.set_element_operation('add')
    
    if type == "lsi":
        # For RHEL5
        scsi_ctrl = VI.ns0.VirtualLsiLogicController_Def("scsi_ctrl").pyclass()
    elif type == "paravirtual":
        # For RHEL6
        scsi_ctrl = VI.ns0.ParaVirtualSCSIController_Def("scsi_ctrl").pyclass()
    elif type == "lsi_sas":
        scsi_ctrl = VI.ns0.VirtualLsiLogicSASController_Def("scsi_ctrl").pyclass()
    elif type == "bus_logic":
        scsi_ctrl = VI.ns0.VirtualBusLogicController_Def("scsi_ctrl").pyclass()
    else:
        s.disconnect()
        module.fail_json(msg="Error adding scsi controller to vm spec. No scsi controller type of: %s" % (type))
    
    scsi_ctrl.set_element_busNumber(bus_num)
    scsi_ctrl.set_element_key(disk_ctrl_key)
    scsi_ctrl.set_element_sharedBus("noSharing")
    scsi_ctrl_spec.set_element_device(scsi_ctrl)
    # Add the scsi controller to the VM spec.
    devices.append(scsi_ctrl_spec)
    return disk_ctrl_key 


def add_disk(module, s, config_target, config, devices, datastore, type="thin", size=200000, disk_ctrl_key=1, disk_number=0, key=0):
    ### add a vmdk disk
    # Verify the datastore exists
    datastore_name, ds = find_datastore(module, s, datastore, config_target)
    # create a new disk - file based - for the vm
    disk_spec = config.new_deviceChange()
    disk_spec.set_element_fileOperation("create")
    disk_spec.set_element_operation("add")
    disk_ctlr = VI.ns0.VirtualDisk_Def("disk_ctlr").pyclass()
    disk_backing = VI.ns0.VirtualDiskFlatVer2BackingInfo_Def("disk_backing").pyclass()
    disk_backing.set_element_fileName(datastore_name)
    disk_backing.set_element_diskMode("persistent")
    if type != "thick":
        disk_backing.set_element_thinProvisioned(1)
    disk_ctlr.set_element_key(key)
    disk_ctlr.set_element_controllerKey(disk_ctrl_key)
    disk_ctlr.set_element_unitNumber(disk_number)
    disk_ctlr.set_element_backing(disk_backing)
    disk_ctlr.set_element_capacityInKB(size)
    disk_spec.set_element_device(disk_ctlr)
    devices.append(disk_spec)


def add_cdrom(module, s, config_target, config, devices, default_devs, type="client", vm_cd_iso_path=None):
    ### Add a cd-rom 
    # Make sure the datastore exists.
    if vm_cd_iso_path:
        iso_location = vm_cd_iso_path.split('/', 1)  
        datastore, ds = find_datastore(module, s, iso_location[0], config_target)
        iso_path = iso_location[1]
    
    # find ide controller
    ide_ctlr = None
    for dev in default_devs:
        if dev.typecode.type[1] == "VirtualIDEController":
            ide_ctlr = dev
    
    # add a cdrom based on a physical device
    if ide_ctlr:
        cd_spec = config.new_deviceChange()
        cd_spec.set_element_operation('add')
        cd_ctrl = VI.ns0.VirtualCdrom_Def("cd_ctrl").pyclass()

        if type == "iso":
            iso = VI.ns0.VirtualCdromIsoBackingInfo_Def("iso").pyclass()
            ds_ref = iso.new_datastore(ds)
            ds_ref.set_attribute_type(ds.get_attribute_type())
            iso.set_element_datastore(ds_ref)
            iso.set_element_fileName("%s %s" % (datastore, iso_path))
            cd_ctrl.set_element_backing(iso)
            cd_ctrl.set_element_key(20)
            cd_ctrl.set_element_controllerKey(ide_ctlr.get_element_key())
            cd_ctrl.set_element_unitNumber(0)
            cd_spec.set_element_device(cd_ctrl)
        elif type == "client":
            client = VI.ns0.VirtualCdromRemoteAtapiBackingInfo_Def("client").pyclass()
            client.set_element_deviceName("")
            cd_ctrl.set_element_backing(client)
            cd_ctrl.set_element_key(20)
            cd_ctrl.set_element_controllerKey(ide_ctlr.get_element_key())
            cd_ctrl.set_element_unitNumber(0)
            cd_spec.set_element_device(cd_ctrl)
        else:
            s.disconnect()
            module.fail_json(msg="Error adding cdrom of type %s to vm spec. cdrom type can either be iso or client" % (type))        

        devices.append(cd_spec)


def add_nic(module, s, nfmor, config, devices, nic_type="vmxnet3", network_name="VM Network", network_type="standard"):
    ### add a NIC 
    # Different network card types are: "VirtualE1000", "VirtualE1000e","VirtualPCNet32", "VirtualVmxnet", "VirtualNmxnet2", "VirtualVmxnet3"
    nic_spec = config.new_deviceChange()
    nic_spec.set_element_operation("add")

    if nic_type == "e1000":
        nic_ctlr = VI.ns0.VirtualE1000_Def("nic_ctlr").pyclass()
    elif nic_type == "e1000e":
        nic_ctlr = VI.ns0.VirtualE1000e_Def("nic_ctlr").pyclass()
    elif nic_type == "pcnet32":
        nic_ctlr = VI.ns0.VirtualPCNet32_Def("nic_ctlr").pyclass()
    elif nic_type == "vmxnet":
        nic_ctlr = VI.ns0.VirtualVmxnet_Def("nic_ctlr").pyclass()
    elif nic_type == "vmxnet2":
        nic_ctlr = VI.ns0.VirtualVmxnet2_Def("nic_ctlr").pyclass()
    elif nic_type == "vmxnet3":
        nic_ctlr = VI.ns0.VirtualVmxnet3_Def("nic_ctlr").pyclass()
    else:
        s.disconnect()
        module.fail_json(msg="Error adding nic to vm spec. No nic type of: %s" % (nic_type))        

    if network_type == "standard":
        nic_backing = VI.ns0.VirtualEthernetCardNetworkBackingInfo_Def("nic_backing").pyclass()
        nic_backing.set_element_deviceName(network_name)
    elif network_type == "dvs":
        # Get the portgroup key
        portgroupKey = find_portgroup_key(module, s, nfmor, network_name)
        # Get the dvswitch uuid
        dvswitch_uuid = find_dvswitch_uuid(module, s, nfmor, portgroupKey)

        nic_backing_port = VI.ns0.DistributedVirtualSwitchPortConnection_Def("nic_backing_port").pyclass()
        nic_backing_port.set_element_switchUuid(dvswitch_uuid)
        nic_backing_port.set_element_portgroupKey(portgroupKey)

        nic_backing = VI.ns0.VirtualEthernetCardDistributedVirtualPortBackingInfo_Def("nic_backing").pyclass()
        nic_backing.set_element_port(nic_backing_port)
    else:
        s.disconnect()
        module.fail_json(msg="Error adding nic backing to vm spec. No network type of: %s" % (network_type))

        
    nic_ctlr.set_element_addressType("generated")
    nic_ctlr.set_element_backing(nic_backing)
    nic_ctlr.set_element_key(4)
    nic_spec.set_element_device(nic_ctlr)
    devices.append(nic_spec)


def find_datastore(module, s, datastore, config_target):
    # Verify the datastore exists and put it in brackets if it does.
    ds = None
    for d in config_target.Datastore:
        if (d.Datastore.Accessible and
        (datastore and d.Datastore.Name == datastore)
        or (not datastore)):
            ds = d.Datastore.Datastore
            datastore = d.Datastore.Name
            break
    if not ds:
        s.disconnect()
        module.fail_json(msg="Datastore: %s does not appear to exist" % (datastore))

    datastore_name = "[%s]" % datastore
    return datastore_name, ds


def find_portgroup_key(module, s, nfmor, network_name):
    # Find a portgroups key given the portgroup name.

    # Grab all the distributed virtual portgroup's names and key's.
    dvpg_mors = s._retrieve_properties_traversal(property_names=['name','key'],
                                    from_node=nfmor, obj_type='DistributedVirtualPortgroup')

    # Get the correct portgroup managed object.
    dvpg_mor = None
    for dvpg in dvpg_mors:
        if dvpg_mor:
            break
        for p in dvpg.PropSet:
            if p.Name == "name" and p.Val == network_name:
                dvpg_mor = dvpg
            if dvpg_mor:
                break
    
    # If dvpg_mor is empty we didn't find the named portgroup.
    if dvpg_mor == None:
        s.disconnect()
        module.fail_json(msg="Could not find the distributed virtual portgroup named %s" % network_name)
    
    # Get the portgroup key
    portgroupKey = None
    for p in dvpg_mor.PropSet:
        if p.Name == "key":
            portgroupKey = p.Val

    return portgroupKey

def find_dvswitch_uuid(module, s, nfmor, portgroupKey):
    # Find a dvswitch's uuid given a portgroup key.
    # Function searches all dvswitches in the datacenter to find the switch that has the portgroup key.

    # Grab the dvswitch uuid and portgroup properties
    dvswitch_mors = s._retrieve_properties_traversal(property_names=['uuid','portgroup'],
                                        from_node=nfmor, obj_type='DistributedVirtualSwitch')
    
    dvswitch_mor = None
    # Get the dvswitches managed object
    for dvswitch in dvswitch_mors:
        if dvswitch_mor:
            break
        for p in dvswitch.PropSet:
            if p.Name == "portgroup":
                pg_mors = p.Val.ManagedObjectReference
                for pg_mor in pg_mors:
                    if dvswitch_mor:
                        break
                    key_mor = s._get_object_properties(pg_mor, property_names=['key'])
                    for key in key_mor.PropSet:
                        if key.Val == portgroupKey:
                            dvswitch_mor = dvswitch
    
    # Get the switches uuid
    dvswitch_uuid = None
    for p in dvswitch_mor.PropSet:
        if p.Name == "uuid":
            dvswitch_uuid = p.Val

    return dvswitch_uuid



def main():
    module = AnsibleModule(
        argument_spec = dict(
            vcenter_vx     = dict(required=True, type='str'),
            user                 = dict(required=True, type='str'),
            password             = dict(required=True, type='str'),
            ansible_resource_pool        = dict(required=False, default=None, type='str'),
            cluster              = dict(required=False, default=None, type='str'),
            datacenter           = dict(required=True, type='str'),
            datastore            = dict(required=True, type='str'),
            esxi_hostname        = dict(required=True, type='str'),
            power_on             = dict(required=False, default='no', type='bool'),
            vm_name              = dict(required=True, type='str'),
            vm_memory_mb         = dict(required=False, default=1024),
            vm_num_cpus          = dict(required=False, default=1),
            vm_scsi              = dict(required=False, default="paravirtual", type='str'),
            vm_disk              = dict(required=False, default=None, type='dict'),
            vm_nic               = dict(required=False, default=None, type='dict'),
            vm_notes             = dict(required=False, default=None, type='str'),
            vm_cdrom             = dict(required=False, default=None, type='dict'),
            vm_extra_config      = dict(required=False, default=None, type='dict'),
            guestosid            = dict(required=True, type='str'),
        ),
        supports_check_mode = False,
        required_together = [ ['ansible_resource_pool','cluster'] ],
    )

    if not HAS_PYSPHERE:
        module.fail_json(msg="pysphere is not installed")

    vcenter_vx  = module.params['vcenter_vx']
    user = module.params['user']
    password = module.params['password']
    ansible_resource_pool = module.params['ansible_resource_pool']
    cluster_name = module.params['cluster']
    datacenter = module.params['datacenter']
    datastore = module.params['datastore']
    esxi_hostname = module.params['esxi_hostname']
    power_on = module.params['power_on']
    vm_name = module.params['vm_name']
    vm_memory_mb = int(module.params['vm_memory_mb'])
    vm_num_cpus = int(module.params['vm_num_cpus'])
    vm_scsi = module.params['vm_scsi']
    vm_disk = module.params['vm_disk']
    vm_nic = module.params['vm_nic']
    vm_notes = module.params['vm_notes']
    vm_cdrom = module.params['vm_cdrom']
    vm_extra_config = module.params['vm_extra_config']
    guestosid = module.params['guestosid']


    # CONNECT TO THE SERVER
    s = VIServer()
    try:
        s.connect(vcenter_vx, user, password)
    except VIApiException, err:
        module.fail_json(msg="Cannot connect to %s: %s" % (vcenter_vx, err))
    

    # Check if the VM exists before continuing    
    try:
	vm = None
        vm = s.get_vm_by_name(vm_name)
    except:
	# VM doesn't exist, lets continue and create it.
	pass

    if vm:
        # If the vm already exists, lets get some info from it, pass back the vm's facts and then exit.
        s.disconnect()
        module.exit_json(changed=False, vcenter=vcenter_vx, datacenter=datacenter, datastore=datastore, esxi_hostname=esxi_hostname, vm_name=vm_name, vm_memory_mb=vm_memory_mb, vm_num_cpus=vm_num_cpus, guestosid=guestosid, vm_disk=vm_disk, vm_nic=vm_nic)

    # GET INITIAL PROPERTIES AND OBJECTS

    # Datacenter managed object reference
    dcmor = [k for k,v in s.get_datacenters().items() if v==datacenter][0]

    if dcmor == None:
        s.disconnect()    
        module.fail_json(msg="Cannot find datacenter named: %s" % datacenter)    

    dcprops = VIProperty(s, dcmor)
    
    # hostFolder managed reference
    hfmor = dcprops.hostFolder._obj
    
    # virtualmachineFolder managed object reference
    vmfmor = dcprops.vmFolder._obj

    # networkFolder managed object reference
    nfmor = dcprops.networkFolder._obj 

    # Grab the computerResource name and host properties
    crmors = s._retrieve_properties_traversal(property_names=['name','host'],
                                        from_node=hfmor, obj_type='ComputeResource')
    
    # Grab the host managed object reference of the esxi_hostname
    try:
        hostmor = [k for k,v in s.get_hosts().items() if v==esxi_hostname][0]
    except IndexError, e:
        s.disconnect()
        module.fail_json(msg="Cannot find esx host named: %s" % esxi_hostname)    
        

    # Grab the computerResource managed object reference of the host we are creating the VM on.
    crmor = None
    for cr in crmors:
        if crmor:
            break
        for p in cr.PropSet:
            if p.Name == "host":
                for h in p.Val.get_element_ManagedObjectReference():
                    if h == hostmor:
                        crmor = cr.Obj
                        break
                if crmor:
                    break
    crprops = VIProperty(s, crmor)
    
    # Get resource pool managed reference
    # Requires that a cluster name be specified. 
    if ansible_resource_pool:
        try:
            cluster = [k for k,v in s.get_clusters().items() if v==cluster_name][0]
        except IndexError, e:
            s.disconnect()
            module.fail_json(msg="Cannot find Cluster named: %s" % cluster_name)    
            
        try:
            rpmor = [k for k,v in s.get_ansible_resource_pools(from_mor=cluster).items()
                 if v == ansible_resource_pool][0]
        except IndexError, e:
            s.disconnect()
            module.fail_json(msg="Cannot find Resource Pool named: %s" % ansible_resource_pool)    
            
    else:
        rpmor = crprops.resourcePool._obj
    
    # CREATE VM CONFIGURATION
    # get config target
    request = VI.QueryConfigTargetRequestMsg()
    _this = request.new__this(crprops.environmentBrowser._obj)
    _this.set_attribute_type(crprops.environmentBrowser._obj.get_attribute_type ())
    request.set_element__this(_this)
    h = request.new_host(hostmor)
    h.set_attribute_type(hostmor.get_attribute_type())
    request.set_element_host(h)
    config_target = s._proxy.QueryConfigTarget(request)._returnval
    
    # get default devices
    request = VI.QueryConfigOptionRequestMsg()
    _this = request.new__this(crprops.environmentBrowser._obj)
    _this.set_attribute_type(crprops.environmentBrowser._obj.get_attribute_type ())
    request.set_element__this(_this)
    h = request.new_host(hostmor)
    h.set_attribute_type(hostmor.get_attribute_type())
    request.set_element_host(h)
    config_option = s._proxy.QueryConfigOption(request)._returnval
    default_devs = config_option.DefaultDevice
    
    # add parameters to the create vm task
    create_vm_request = VI.CreateVM_TaskRequestMsg()
    config = create_vm_request.new_config()
    vmfiles = config.new_files()
    datastore_name, ds = find_datastore(module, s, datastore, config_target)
    vmfiles.set_element_vmPathName(datastore_name)
    config.set_element_files(vmfiles)
    config.set_element_name(vm_name)
    if vm_notes != None:
        config.set_element_annotation(vm_notes)
    config.set_element_memoryMB(vm_memory_mb)
    config.set_element_numCPUs(vm_num_cpus)
    config.set_element_guestId(guestosid)
    devices = []
    
    # Attach all the hardware we want to the VM spec.
    # Add a scsi controller to the VM spec.
    disk_ctrl_key = add_scsi_controller(module, s, config, devices, vm_scsi)
    if vm_disk:
        disk_num = 0
        disk_key = 0
        for disk in sorted(vm_disk.iterkeys()):
            try:
                datastore = vm_disk[disk]['datastore']
            except KeyError:
                s.disconnect()
                module.fail_json(msg="Error on %s definition. datastore needs to be specified." % disk) 
            try:
                disksize = vm_disk[disk]['size_gb']
                # Convert the disk size to kiloboytes
                disksize = disksize * 1024 * 1024 
            except KeyError:
                s.disconnect()
                module.fail_json(msg="Error on %s definition. size needs to be specified." % disk) 
            try:
                disktype = vm_disk[disk]['type']
            except KeyError:
                s.disconnect()
                module.fail_json(msg="Error on %s definition. type needs to be specified." % disk) 
            # Add the disk  to the VM spec.
            add_disk(module, s, config_target, config, devices, datastore, disktype, disksize, disk_ctrl_key, disk_num, disk_key)
            disk_num = disk_num + 1
            disk_key = disk_key + 1
    if vm_cdrom:
        cdrom_iso_path = None
        cdrom_type = None
        try:
            cdrom_type = vm_cdrom['type']
        except KeyError:
            s.disconnect()
            module.fail_json(msg="Error on %s definition. cdrom type needs to be specified." % vm_cdrom) 
        if cdrom_type == 'iso':
            try:
                cdrom_iso_path = vm_cdrom['iso_path']
            except KeyError:
                s.disconnect()
                module.fail_json(msg="Error on %s definition. cdrom iso_path needs to be specified." % vm_cdrom) 
        # Add a CD-ROM device to the VM.
        add_cdrom(module, s, config_target, config, devices, default_devs, cdrom_type, cdrom_iso_path)
    if vm_nic:
        dvswitch = None
	for nic in sorted(vm_nic.iterkeys()):
            try:
                nictype = vm_nic[nic]['type']
            except KeyError:
                s.disconnect() 
                module.fail_json(msg="Error on %s definition. type needs to be specified." % nic) 
            try:
                network = vm_nic[nic]['network']
            except KeyError:
                s.disconnect()
                module.fail_json(msg="Error on %s definition. network needs to be specified." % nic) 
            try:
                network_type = vm_nic[nic]['network_type']
            except KeyError:
                s.disconnect()
                module.fail_json(msg="Error on %s definition. network_type needs to be specified." % nic) 
            # Add the nic to the VM spec.
            add_nic(module, s, nfmor, config, devices, nictype, network, network_type)
    
    
    config.set_element_deviceChange(devices)
    create_vm_request.set_element_config(config)
    folder_mor = create_vm_request.new__this(vmfmor)
    folder_mor.set_attribute_type(vmfmor.get_attribute_type())
    create_vm_request.set_element__this(folder_mor)
    rp_mor = create_vm_request.new_pool(rpmor)
    rp_mor.set_attribute_type(rpmor.get_attribute_type())
    create_vm_request.set_element_pool(rp_mor)
    host_mor = create_vm_request.new_host(hostmor)
    host_mor.set_attribute_type(hostmor.get_attribute_type())
    create_vm_request.set_element_host(host_mor)
    
    # CREATE THE VM
    taskmor = s._proxy.CreateVM_Task(create_vm_request)._returnval
    task = VITask(taskmor, s)
    task.wait_for_state([task.STATE_SUCCESS, task.STATE_ERROR])
    if task.get_state() == task.STATE_ERROR:
        s.disconnect()
        module.fail_json(msg="Error creating vm: %s" % task.get_error_message())
    else:
	vm = None
	if vm_extra_config or power_on:
        	vm = s.get_vm_by_name(vm_name)    

        # VM was created. If there is any extra config options specified, set them here , disconnect from vcenter, then exit.
        if vm_extra_config:
            vm.set_extra_config(vm_extra_config)
        # Power on the VM if it was requested
        if power_on:
            vm.power_on(sync_run=False) 

        s.disconnect()
        module.exit_json(changed=True, vcenter=vcenter_vx, datacenter=datacenter, datastore=datastore, esxi_hostname=esxi_hostname, vm_name=vm_name, vm_memory_mb=vm_memory_mb, vm_num_cpus=vm_num_cpus, guestosid=guestosid, vm_disk=vm_disk, vm_nic=vm_nic)

# this is magic, see lib/ansible/module_common.py
#<<INCLUDE_ANSIBLE_MODULE_COMMON>>
main()
