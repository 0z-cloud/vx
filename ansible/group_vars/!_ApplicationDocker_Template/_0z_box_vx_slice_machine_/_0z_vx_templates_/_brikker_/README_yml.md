# --------------------------------------------
# template ansible module test.j2 RUN 
# --------------------------------------------
# --------------------------------------------
- template:
    src: test.j2 # <------------------------------|
    dest: test # --------------------------------|*|--.                                # |
                                              # * |    \
# --------------------------------------------  * |    |
# $ echo 'with the templates'                   * |    |
# --------------------------------------------  * |    | 
# $ cat test.j2 ----------------------------------/    | 
# --------------------------------------------         |
# --------------------------------------------         |
{% extends 'main.j2' %}   # <---------------------|    |
{% block test %}                                # |    |
value = custom value in test.j2                 # |    | 
{% endblock %}                                  # |    |
                                                # |    |
# --------------------------------------------  # |    |
# $ cat main.j2 ----------------------------------/    |
# --------------------------------------------  #      |
#################################################      |
value1 = 123                                    #      |
{% block test %} # ----------------------------------------------------------\_/ 
value = default value in main.j2                #      |
{% endblock %}                                  #      |
value3 = 789                                    #      |
#################################################      |
# --------------------------------------------  #      |
# RESULT                                             # |
# --------------------------------------------       # |
# --------------------------------------------       # |
# $ cat test                                         # |
# --------------------------------------------       # |
# --------------------------------------------              # |
#                                                         # | |
value1 = 123                                            # | | | 
value = custom value in test.j2                       #'| ''| |
value3 = 789                                        #''imiq'' |
                                                  #''|i0'.\\ ''
# --------------------------------------------..////||[]    ''  ''
# SECOND TYPE OF RE BLOKKING A TEMPLATE BIRKS ######||p      \\ ''/
# --------------------------------------------======================

- name: Copy config
  template:
    src: "{{ item }}"
    dest: "{{ conf_file_path }}"
  with_items:
    - "main.conf.j2"
    - "test.conf.j2"
    - "example.conf.j2"
    - "abcd.conf.j2"

- template:
    src: main2.j2
    dest: test
- blockinfile:
    marker: "# {mark} ANSIBLE MANAGED BLOCK {{ item }}"
    path: test
    block: "{{ lookup('template', item) }}"
  loop:
    - test.conf.j2
    - example.conf.j2
# with the templates

# $ cat main2.j2
value1 = 123

# BEGIN ANSIBLE MANAGED BLOCK test.conf.j2
value_test = default value in main2.j2
# END ANSIBLE MANAGED BLOCK test.conf.j2

# BEGIN ANSIBLE MANAGED BLOCK example.conf.j2
value_example = default value in main2.j2
# END ANSIBLE MANAGED BLOCK example.conf.j2

value3 = 789

# $ cat test.conf.j2
value_test = custom value in test.conf.j2

# $ cat example.conf.j2
value_example = custom value in example.conf.j2
# give

# $ cat test 
value1 = 123

# BEGIN ANSIBLE MANAGED BLOCK test.conf.j2
value_test = custom value in test.conf.j2
# END ANSIBLE MANAGED BLOCK test.conf.j2

# BEGIN ANSIBLE MANAGED BLOCK example.conf.j2
value_example = custom value in example.conf.j2
# END ANSIBLE MANAGED BLOCK example.conf.j2

value3 = 789
