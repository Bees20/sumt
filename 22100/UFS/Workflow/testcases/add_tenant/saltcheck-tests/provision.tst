{% import "22100/conf.sls" as conf %}

check_ufs_folder_exists:
  module_and_function: file.mkdir
  args:
    - '{{ conf.UFS_TENANT_SHARE_LOCATION }}'
    - 'Everyone'
    - "{'Users': {'perms': 'Full control'}}"
  assertion: assertEqual
  expected_return: True
  output_details: True

check_ufs_folder_exists2:
  module_and_function: file.mkdir
  args:
    - '{{ conf.UFSV2_TENANT_SHARE_LOCATION }}'
    - 'Everyone'
    - "{'Users': {'perms': 'Full control'}}"
  assertion: assertEqual
  expected_return: True
  output_details: True