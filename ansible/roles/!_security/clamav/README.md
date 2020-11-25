* Little info

- > For install on your localhost MAC OS X you must to run

```

ansible-playbook -i inventories/local/ playbook-library/scripts/clamav-all.yml -e HOSTS="localhost" --ask-sudo-pass

```