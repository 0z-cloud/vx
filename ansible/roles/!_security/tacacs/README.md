TACACS+
========

Setup a TACACS+ server using [`tac_plus`](http://www.shrubbery.net/tac_plus/) from Shrubbery Networks.

You may use local accounts or LDAP for authentication (via PAM). LDAP _does not_ do authorization — that is handled by the `tac_plus.conf`. If using LDAP authentication, make sure to define all the necessary variables described below.

Requirements
------------

You must configure your devices to point at the TACACS+ server. The exact configuration varies greatly between devices and vendors. You'll need to do lots of reading and testing with non-production equipment as it's very easy to lock yourself out of the device when experimenting with AAA configurations.

Open port 49 in the firewall on the host.

Role Variables
--------------

| Name              | Default Value       | Description          |
|-------------------|---------------------|----------------------|
| `tacacs_port` | `49` | Port the TACACS server listens on. |
| `tacacs_users` | `[see defaults.yml]` | User accounts to  be added to `tac_plus.conf` and optionally created on the system. |
| `tacacs_ldap_auth` | `False` | Whether TACACS uses PAM LDAP to authenticate. |
| `tacacs_enable_passwords` | `null` | Host specific enable passwords. |


Example Playbook
-------------------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: tacacs
      roles:
         - tacacs

License
-------

MIT
