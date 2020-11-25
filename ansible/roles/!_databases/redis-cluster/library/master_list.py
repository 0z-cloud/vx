#!/usr/bin/python

def main():
    module = AnsibleModule(
        argument_spec = dict(
            map = dict(required=False, type="list", alias="name")
        )
    )

    cluster_map = module.params['map']
    if cluster_map is None:
        cluster_map = []

    result = " ".join(map(lambda x: "%s %d" % (x["host"], x["port"]), cluster_map))

    module.exit_json(changed=False, masters=result)

# import module snippets
from ansible.module_utils.basic import *
if __name__ == '__main__':
    main()