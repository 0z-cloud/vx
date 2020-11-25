# Global Templates Source Root

## Product Contract Types


  - root: "{{ root_path_get_by_pwd }}"
  - ansible: "{{ root }}/ansible"
  - ansible_group_vars: "{{ ansible }}/group_vars"

### INVENTORIES
  - inventories: "{{ ansible }}/inventories"
  - short: "{{ ansible_product }}/{{ ansible_environment }}/"
  - 0z-cloud: "{{ inventories }}/0z-cloud"
  - vortex-py: "{{ inventories }}/vortex-py"
  - group_templates: "{{ inventories }}/group_templates"
  - global: "{{ inventories }}/global"
  - inventories_products: "{{ inventories }}/products"


### GLOBAL
  - _meta_self_search_: "{{ global }}/_meta_self_search_"
  - oz_router: "{{ global }}/oz_router"
  - vortex: "{{ global }}/vortex"

### MICS
  - full: "products/types/!_{{ ansible_cloud_type  }}/{{ ansible_product }}/{{ ansible_environment }}/"
  - ansible_group_vars_short: "{{ ansible_group_vars }}/{{ short }"}
  - ansible_short: "{{ ansible }}/{{ short }}"
  - ansible_full: "{{ ansible }}/{{ full }}"
  - zero: ""

### AGNOSTIC OBJECTS FOR ANYTHING, 'CLASSIC BOOTSTRAP', 'TERAFORMA-STYLE', 

### ######## SOURCE PLACEMENT
  - inventories_products_full: "{{ inventories }/{{ full }}"

### ######## TARGET PLACEMENT
  - inventories_products_short: "{{ inventories_products }}/{{ short }}"



  * Can be contain specific instance groups by variable which place products ```{{ ansible_product }}``` by default small product contract,
