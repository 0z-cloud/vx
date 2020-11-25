## PostgreSQL PowerDNS Service Role
This section about work clouds from scracth or how it happened with us

### Possible commands extra-vars in playbook role

- > To completely remove all databases of your cloud,
- > You need just only add extra variable ``clean_all_databases`` to the run pipeline:

``
ansible-playbook -i inventories/develop/ cloud_playbooks/powerdns-master.yml \
    --extra-vars="clean_all_databases=true"
      
``