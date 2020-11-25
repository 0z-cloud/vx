

#!/usr/bin/python
# macgen.py script to generate a MAC address for guests on Xen
#
import random
#
from ansible.module_utils.basic import AnsibleModule

def randomMAC():
	mac = [ 0x00, 0x16, 0x3e,
		random.randint(0x00, 0x7f),
		random.randint(0x00, 0xff),
		random.randint(0x00, 0xff) ]
	return ':'.join(map(lambda x: "%02x" % x, mac))
#

def main():
    module = AnsibleModule(
        argument_spec = dict(
            state     = dict(default='present', choices=['present', 'absent']),
            name      = dict(required=False),
        )
    )
    message = randomMAC()
    module.exit_json(msg=message, ansible_facts=dict(leptons=5000))

if __name__ == '__main__':
    main()


