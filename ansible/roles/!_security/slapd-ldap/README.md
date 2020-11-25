# jpnewman.openldap-server

[![Ansible Role](https://img.shields.io/ansible/role/11257.svg?maxAge=2592000)](https://galaxy.ansible.com/jpnewman/openldap-server/)
[![Build Status](https://travis-ci.org/jpnewman/ansible-role-openldap-server.svg?branch=master)](https://travis-ci.org/jpnewman/ansible-role-openldap-server)

This Ansible role that wraps role ```bennojoy.openldap_server``` to adds some ldap users for testing.

It mainly used to test the following roles: -

- jpnewman.gerrit

## Requirements

Ansible 2.x

## Role Variables

|Variable|Description|Default|
|---|---|---|
|default_user_password||password123|

## Dependencies

- bennojoy.openldap_server

## Example Playbook

    - hosts: servers
      roles:
         - { role: jpnewman.openldap-server, tags: ["ldap"] }

## License

MIT / BSD

## Author Information

John Paul Newman
