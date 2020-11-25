#!/usr/bin/python


DOCUMENTATION = '''
---
module: vcd_nat_fw
short_description: Update Nat/FW in vcloud
'''

EXAMPLES = '''
- name: Add nat rule
  vcd_nat_fw:
    vcloud_url: 'https://vcloud-url-goes-here.somecompany.com'
    username: 'vcloud_admin'
    passwd: 'vcloud_passwd'
    ruletype: 'DNAT'
    iface: 'vm-blah-blah-blah'
    ifaceguid: '57fe4def-5328-4e27-91aa-b73700bffaa1'
    origip: 172.16.0.6
    origport: any
    transip: 192.168.2.0/24
    transport: any
    proto: tcp    
'''

from ansible.module_utils.basic import *
import xml.etree.ElementTree as ET
import requests
import time

def do_work(data):
    vc_url = data["vcloud_url"]
    vc_usr = data["username"]
    vc_pwd = data["passwd"]
    vc_gw_name = data['gw_name']
    ruletype = data['ruletype']
    nattype = data['nattype']
    iface = data['iface']
    ifaceguid = data['ifaceguid']
    origip = data['origip']
    origport = data['origport']
    transip = data['transip']
    transport = data['transport']
    proto = data['proto']

    headers = {
        "Accept": "application/*+xml;version=1.5",
        "User-Agent": "Mozilla/5.0"
    }

    if vc_url.endswith('/'):
        vc_url = vc_url[:-1]

    r = requests.post(vc_url + "/api/sessions", auth=(vc_usr, vc_pwd), headers=headers)

    if r.status_code == 200:
        headers['x-vcloud-authorization'] = r.headers['x-vcloud-authorization']
        headers['Accept'] = 'application/*+xml;version=5.1'

        r = requests.get(vc_url + '/api/query?type=edgeGateway', auth=(vc_usr, vc_pwd), headers=headers)

        if r.status_code == 200:
            tree = ET.fromstring(r.content)
            # Get all gateways
            gw_list = tree.findall('{http://www.vmware.com/vcloud/v1.5}EdgeGatewayRecord')
            gw_href = ''

            for gw in gw_list:
                if gw.attrib['name'] == vc_gw_name:
                    gw_href = gw.attrib['href']

            # GET https://vcloud/api/admin/edgeGateway/guid
            r = requests.get(gw_href, auth=(vc_usr, vc_pwd), headers=headers)
            if r.status_code == 200:
                tree = ET.fromstring(r.content)
                cfgtop = tree.findall('{http://www.vmware.com/vcloud/v1.5}Configuration')[0]
                servicecfg = cfgtop.findall('{http://www.vmware.com/vcloud/v1.5}EdgeGatewayServiceConfiguration')[0]
                natservice = servicecfg.findall('{http://www.vmware.com/vcloud/v1.5}NatService')[0]
                fwservice = servicecfg.findall('{http://www.vmware.com/vcloud/v1.5}FirewallService')[0]

                if ruletype == 'NAT':
                # NatRule
                    newrule = ET.Element('NatRule')

                    newruletype = ET.SubElement(newrule, 'RuleType')
                    newruletype.text = nattype
                    newenabled = ET.SubElement(newrule, 'IsEnabled')
                    newenabled.text = 'true'
                    newid = ET.SubElement(newrule, 'Id')
                    newid.text = ''
                    newgwnatrule = ET.SubElement(newrule, 'GatewayNatRule')
                    newiface = ET.SubElement(newgwnatrule, 'Interface')
                    newiface.attrib['href'] = 'https://vcloud-/api/admin/network/' + ifaceguid
                    newiface.attrib['name'] = iface
                    newiface.attrib['type'] = 'application/vnd.vmware.admin.network+xml'
                    neworigip = ET.SubElement(newgwnatrule, 'OriginalIp')
                    neworigip.text = origip
                    neworigport = ET.SubElement(newgwnatrule, 'OriginalPort')
                    neworigport.text = origport
                    newtransip = ET.SubElement(newgwnatrule, 'TranslatedIp')
                    newtransip.text = transip
                    newtransport = ET.SubElement(newgwnatrule, 'TranslatedPort')
                    newtransport.text = transport
          
                    natservice.append(newrule)
                    
                    #ET.dump(natservice)

                    headers["Content-Type"] = 'application/vnd.vmware.admin.edgeGatewayServiceConfiguration+xml'
                   
                    r = requests.post(gw_href + '/action/configureServices', auth=(vc_usr, vc_pwd), headers=headers)


                elif ruletype == 'FW':
                    pass



def main():
    fields = {
        "vcloud_url": {"required": True, "type": "str"},
        "username": {"required": True, "type": "str"},
        "passwd": {"required": True, "type": "str"},
        "iface": {"required": True, "type": "str"},
        "ifaceguid": {"required": True, "type": "str"},
        "origip": {"required": True, "type": "str"},
        "origport": {"required": True, "type": "str"},
        "transip": {"required": True, "type": "str"},
        "transport": {"required": True, "type": "str"},
        "proto": {"required": True, "type": "str"},
        "ruletype": {
            "default": "SNAT",
            "choices": ['SNAT', 'DNAT'],
            "type": 'str'
        },
    }

    choice_map = {
        "yes": check_vm_block,
        "no": do_work,
    }

    module = AnsibleModule(argument_spec=fields)
    is_error, has_changed, result = do_work(module.params)

    if not is_error:
        module.exit_json(changed=has_changed, meta=result)
    else:
        module.fail_json(msg="Error checking vm state", meta=result)

if __name__ == '__main__':
    main()