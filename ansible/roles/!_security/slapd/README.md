# Ansible Role for OpenLDAP (slapd)

This is an Ansible role that installs OpenLDAP (`slapd`) and performs
a few housekeeping functions such as:

* moving the default data directory location
* setting the `cn=config` administrator password
* building indexes

This role does *not* make any LDAP modifications besides those listed
above.  Use the
[`ansible-ldap-modules` repository](https://github.com/unchained-capital/ansible-ldap-modules)
to do that.

# Requirements

This role relies on the modules defined in the
[`ansible-ldap-modules` repository](https://github.com/unchained-capital/ansible-ldap-modules).
These modules make it possible to interact directly with LDAP servers
from Ansible tasks without having to go through the intermediary of
creating LDIF files.

This role also assumes that the networking environment of the host
defines the LDAP root `dn` (e.g. - `dc=example,dc=com`).  This is
essentially what the OpenLDAP packages assume when they install and
configure `slapd` initially.  Run `hostname -d` on your (intended)
LDAP server -- if you don't want that to be turned into your root
`dn`, then change it first before you use this role.

# Variables

* `slapd_data_dir`: If this value changes, slapd's existing data will
  be moved alongside setting the new directory.  (Default:
  `/var/lib/ldap`).
* `slapd_admin_password`: The admin password (Default: `None`)
* `slapd_set_password`: Should we set the admin password? (Default:
  `true`).  Set `slapd_admin_password` if you set this.
* `slapd_reset_password`: Should we reset the admin password?
  (Default: `false`).  Set `slapd_admin_password` if you set this.
* `slapd_disable_anon_bind`: Do not allow anonymous binds. If you
  enable this, you'll have to create a "service account" or similar
  and distribute its `dn` and password to clients before they can talk
  to the LDAP server. (Default: `false`).
* `slapd_indices`: A list of indices to maintain in the format
  `attribute[,attribute,...] index_type[,index_type,...]`.  For
  example:
```yaml
slapd_indices:
  - "objectClass,uidNumber,gidNumber,sudoUser eq,pres"
  - "ou,cn,mail,surname,givenname,uid,memberUid,nisMapName,nisMapEntry  eq,pres,sub"
```

# Author Information

* Brandon Hudgeons, with lots of assistance from myriad public sources.
* Dhruv Bansal
