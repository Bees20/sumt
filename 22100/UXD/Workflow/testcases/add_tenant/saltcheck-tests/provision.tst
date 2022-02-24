{% import "22100/conf.sls" as conf %}

check_mysql_db_exists:
  module_and_function: mysql.db_exists
  args:
    - '{{ conf.UXD_DB }}'
  kwargs: {
    connection_db: 'mysql',
    connection_host: '{{ conf.linux_server }}',
    connection_user: 'root',
    connection_pass: '{{ conf.Linux_password }}'
  }
  assertion: assertTrue
  expected_return: True
  output_details: True

check_mysql_user_exists:
  module_and_function: mysql.user_list
  kwargs: {
    connection_db: '{{ conf.UXD_DB }}',
    connection_host: '{{ conf.linux_server }}',
    connection_user: 'root',
    connection_pass: '{{ conf.Linux_password }}'
  }
  assertion: assertIn
  expected_return: {'User': '{{ conf.UXD_USER }}', 'Host': '%'}
  output_details: True

{#
check_mysql_db_version:
  module_and_function: mysql.query
  args:
    - '{{ conf.UXD_DB }}'
    - "select Version_Number from DBVersion where Version_Number='{{ conf.UXD_Version_Number }}'"
  kwargs: {
    connection_db: '{{ conf.UXD_DB }}',
    connection_host: '{{ conf.linux_server }}',
    connection_user: 'root',
    connection_pass: '{{ conf.Linux_password }}'
  }
  assertion: assertIn
  expected_return: {'rows returned': 1}
  output_details: True
#}