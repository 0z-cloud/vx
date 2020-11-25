from __future__ import (absolute_import, division, print_function)
from ansible.plugins.lookup import LookupBase
from ansible.errors import AnsibleLookupError
from subprocess import Popen, PIPE
import json
import errno
import random

__metaclass__ = type

ANSIBLE_METADATA = {'metadata_version': '1.2',
                    'status': ['master'],
                    'supported_by': 'community'}

DOCUMENTATION = """
    lookup: random_subnet_facts_get
    author:
      - Ros aka vortex <support@vortex.com>
    version_added: "2.9.7"
    requirements:
      - No have
    short_description: Generate a random subnet on lookup
    description:
      - Ansible lookup plugin 'random_subnet_facts_get' get the default gw and network, mask, etc
"""

EXAMPLES = """
- name: "Generate a random mac-address on lookup that plugin directry"
  debug:
    msg: "{{ lookup('random_subnet_facts_get') }}"
"""

RETURN = """
  _raw:
    description: You can just call lookup
"""



class GenerateSubnet(object):

    def __init__(self, path='ngsubnet'):
        self._cli_path = path

    @property
    def cli_path(self):
        return self._cli_path
        random
    def randomPrivateIPSubnet(self):
        network_type = random.randint(0, 2)
        if network_type == 0:
            self._generated_subnet = "10.%d.%d.%d" % (random.randint(0, 255), random.randint(0, 255), random.randint(0, 0))
        elif network_type == 1:
            self._generated_subnet = "172.%d.%d.%d" % (random.randint(16, 31), random.randint(0, 255), random.randint(0, 0))
        else:
            self._generated_subnet = "192.168.%d.%d" % (random.randint(0,255), random.randint(0,0))
        return self._generated_subnet


    def randomMAC(self):
        mac = [ 0x00, 0x16, 0x3e,
            random.randint(0x00, 0x7f),
            random.randint(0x00, 0xff),
            random.randint(0x00, 0xff) ]
        
        self._generated_mac = ':'.join(map(lambda x: "%02x" % x, mac))
        return self._generated_mac
    #


    @property
    def rand_subnet(self):
        return self._generated_subnet

    def _run(self, expected_rc=0):
        p = Popen([self.rand_subnet], stdout=PIPE, stderr=PIPE, stdin=PIPE)
        out, err = p.communicate()
        rc = p.wait()
        if rc != expected_rc:
            raise AnsibleLookupError(err)
        return out, err

class LookupModule(LookupBase):

    def run(self, terms, **kwargs):
        ngsubnet = GenerateSubnet()
        values = []
        values.append(ngsubnet.randomMAC())
        return values
