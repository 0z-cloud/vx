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
    lookup: random_vpn_server_port
    author:
      - Ros aka vortex <support@vortex.com>
    version_added: "2.9.7"
    requirements:
      - No have
    short_description: Generate a random port on lookup in range 30000-49150
    description:
      - Ansible lookup plugin 'random_vpn_server_port' Generate a random Port for VPN Server on lookup that plugin directry
"""

EXAMPLES = """
- name: "Generate a random VPN Server Port on lookup that plugin directry"
  debug:
    msg: "{{ lookup('random_vpn_server_port') }}"
"""

RETURN = """
  _raw:
    description: You can just call lookup
"""

class GenerateVPNServerPort(object):

    def __init__(self, path='ngport'):
        self._cli_path = path

    @property
    def cli_path(self):
        return self._cli_path
        random

    def randomPrivateVPNServerPort(self):
        self._generated_port = "%d%d%d%d%d" % (random.randint(3,4),random.randint(0,9),random.randint(0,1),random.randint(0,5),random.randint(0,9))
        return self._generated_port

    @property
    def rand_subnet(self):
        return self._generated_port

    def _run(self, expected_rc=0):
        p = Popen([self.rand_subnet], stdout=PIPE, stderr=PIPE, stdin=PIPE)
        out, err = p.communicate()
        rc = p.wait()
        if rc != expected_rc:
            raise AnsibleLookupError(err)
        return out, err

class LookupModule(LookupBase):

    def run(self, terms, **kwargs):
        ngport = GenerateVPNServerPort()
        values = []
        values.append(ngport.randomPrivateVPNServerPort())
        return values