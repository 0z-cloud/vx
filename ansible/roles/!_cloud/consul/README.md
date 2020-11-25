## Consul Service Role
This section about work and monitoring works Consul Server's Agent's & Consul Client Agent's

### Possible commands on Server Agent

- > to monitoring process of the server agent use:

`consul monitor -rpc-addr {{ server_node_name }}:8400`

Example: `consul monitor -rpc-addr consul1.woinc.work:8400`

- > for monitoring members you can use:

`consul members -rpc-addr {{ server_node_name }}:8400`

Example: `consul members -rpc-addr consul1.woinc.work:8400`

### Web interface

You can access to Main Consul Web Interface After Install:

https://consul.woinc.work

:heavy_minus_sign: Access possible only from Office Hosts

### Windows hosts

- > You can insstall that package manualy or use role in roles/windows/os-install

- > Playbook currently support install Consul Agent service for Windows Hosts

- > Consul Agent Service installed by Ansible `` win_nssm `` sub-module

- > Necessary for that, you need to be have installed via chocolately package:

```

  win_chocolatey:
    name: "nssm"
    state: present

```