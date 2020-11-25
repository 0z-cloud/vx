#!/usr/bin/python

def fill_path(instance, path):
    if path not in instance["paths"]:
        instance["paths"][path] = "/opt/redis/%s/%s" % (instance["name"], path)
        return True
    return False

def main():
    module = AnsibleModule(
        argument_spec = dict(
            instance = dict(required=False, type="dict", alias="name"),
            default = dict(required=True, type="dict")
        )
    )

    instance = module.params['instance']
    result = module.params['default'].copy()

    if instance is None:
        instance = dict()
    else:
        instance = instance.copy()

    filled = False
    if "port" not in instance:
        instance["port"] = 6379
        filled = True

    if "name" not in instance:
        instance["name"] = "redis_%d" % instance["port"]
        filled = True

    if "paths" not in instance:
        instance["paths"] = dict()
        filled = True

    for path in ["conf", "data", "pid", "logs"]:
        filled = fill_path(instance, path) or filled

    result.update(instance)

    module.exit_json(changed=False, filled=filled, instance=result)

# import module snippets
from ansible.module_utils.basic import *
if __name__ == '__main__':
    main()