# REQUEST FOR COMMENTS VX [1]

## MAKING ISO FOR PACKING ITSELF, OR NEEDED PART ARE IN PLACES WHEREVER WE NEED

- mkisofs -o /tmp/cd.iso /tmp/directory/

  - For packing itself to install at standalone remote systems
    (with ansible vault crypt, or based on fews types of encrypt with splitted key-parts crypto protocol)
  - At bootstraping the Virtualization Layer we can to send the iso's with presonal instance bootstraping plan,
    which contain instance specific configurations.

## Also

    1. Must to generate correct pg_hba.conf for postgres
    2. May be ` docker service ls | grep stage | awk '{print $2}' | xargs -I ID docker service update ID` need in future
    3. Need to investigate paused containers

## INVENTORY CATEGORY TYPE

In basical flows we are have the production, stage, development enviromnents inventory location placements, but in most general cases have a multiple products,
what in result provide a result sets with same production inventory environment location placement,
and as choice with this complicated merging place would to be better implement the {{ ansible_invenotry_category_environment }} - which takes inside value are tripplet.
The object called tripplet variable which contain with appending three values with {{ value1 }}_{{ value2 }}_{{ value3 }} given name format, and in this values we have the

value1: {{ ansible_environment }}
value2: {{ anydata }}
value3: {{ ansible_inventory_signal }}
