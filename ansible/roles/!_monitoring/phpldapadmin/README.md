phpLDAPAdmin ANsible Role
=========================

Installs phpLDAPAdmin.  Does not install a webserver or a full PHP
environment (though PHP LDAP extensions are installed).

Requirements
------------

Not much is needed to make this role work -- it just clones the
phpLDAPAdmin code base to disk and templates out a configuration file.

If you intend to actually use phpLDAPAdmin, you'll need a webserver
capable of serving PHP web applications and point it at the files this
role produces.

Role Variables
--------------

See `defaults/main.yml`.


Dependencies
------------

None.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: phpldapadmin, pla_server_name: my-ldap-server, pla_server_host: 123.123.123.123 }

License
-------

Apache
