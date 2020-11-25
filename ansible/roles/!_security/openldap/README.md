Ansible Role: OpenLDAP Server (slapd)
=====================================

Provisions [OpenLDAP](https://www.openldap.org/) server (slapd) on Debian/Ubuntu

Role Variables
--------------
| Variable              | Required | Default                                     | Description                                                                 |
| --------------------- | -------- | ------------------------------------------- | --------------------------------------------------------------------------- |
| slapd_root_password   | yes      |                                             | Administrator Password                                                      |
| slapd_domain          | no       | `hostvars[inventory_hostname].ansible_fqdn` | The DNS domain name is used to construct the base DN of the LDAP directory. |
| slapd_organization    | no       | "My Organization"                           | Title of the organization used as base DN                                   |

Examples
--------

### Slapd with MDB backend without TLS
```yaml
- role: gronke.ldap
    slapd_root_password: "correct horse battery staple"
    slapd_domain: "example.com"
```

ToDo
----

- Encryption Support
- Test on other Operating Systems (Ubuntu, CentOS, BSD, ...)
