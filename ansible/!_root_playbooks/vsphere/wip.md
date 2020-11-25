# vars yaml
esxi_advanced_options:
  'DCUI.Access': 'root'
  'Mem.ShareForceSalting': 2
  'Security.AccountLockFailures': 3
  'Security.AccountUnlockTime': 900
  'Security.PasswordQualityControl': 'retry=3 min=disabled,disabled,disabled,14,14'
  'UserVars.DcuiTimeOut': 1200
  'UserVars.ESXiShellInteractiveTimeOut': 1800
  'UserVars.ESXiShellTimeOut': 1800

# task 

- name: 'Set ESXi advanced options'
  connection: 'local'
  vmware_host_config_manager:
   hostname: '{{ ansible_host }}'
   username: '{{ ansible_vcenter_username }}'
   password: '{{ ansible_vcenter_password }}'
   cluster_name: '{{ cluster_name }}'
   validate_certs: '{{ validate_certs }}'
   options:
     '{{ esxi_advanced_options }}'
