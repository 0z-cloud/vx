# REQUEST FOR COMMENTS VX [1]

## MAKING ISO FOR PACKING ITSELF, OR NEEDED PART ARE IN PLACES WHEREVER WE NEED

- mkisofs -o /tmp/cd.iso /tmp/directory/

  - For packing itself to install at standalone remote systems
    (with ansible vault crypt, or based on few types of encrypting with split key-parts crypto protocol)
  - At bootstrapping the Virtualization Layer we can send the iso's with a personal instance bootstrapping plan,
    which contains instance-specific configurations.

## Also

    1. Must generate correct pg_hba.conf for Postgres
    2. May be ` docker service ls | grep stage | awk '{print $2}' | xargs -I ID docker service update ID` need in future
    3. Need to investigate paused containers

## INVENTORY CATEGORY TYPE

In basic flows, we have the production, stage, development environments inventory location placements, but in most general cases have multiple products,
what in result provide a result sets with same production inventory environment location placement,
and as a choice with this complicated merging place would to better implement the {{ ansible_invenotry_category_environment }} - which takes inside value are triplet.
The object called triplet variable which contains with appending three values with {{ value1 }}_{{ value2 }}_{{ value3 }} given name format, and in this values, we have the

value1: {{ ansible_environment }}
value2: {{ anydata }}
value3: {{ ansible_inventory_signal }}
