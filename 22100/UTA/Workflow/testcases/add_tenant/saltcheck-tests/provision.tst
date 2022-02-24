{% import "22100/conf.sls" as conf %}

check_mssql_db_exists:
  module_and_function: mssql.db_list
  kwargs : {
    server: '{{ conf.server }}',
    port: '{{ conf.port }}',
    user: '{{ conf.user }}',
    password: '{{ conf.password }}',
    database: 'master'
  }
  assertion: assertIn
  expected_return: '{{ conf.UTA_DB }}'
  output_details: True

check_mssql_user_exists:
  module_and_function: mssql.user_list
  kwargs : {
    server: '{{ conf.server }}',
    port: '{{ conf.port }}',
    user: '{{ conf.user }}',
    password: '{{ conf.password }}',
    database: '{{ conf.UTA_DB }}'
  }
  assertion: assertIn
  expected_return: '{{ conf.UTA_USER }}'
  output_details: True

check_mssql_role_privilages:
  module_and_function: mssql.tsql_query
  args:
    - "SELECT Login_Name = ul.[name],DB_Role = rolp.[name] FROM sys.database_role_members mmbr,sys.database_principals rolp,sys.database_principals mmbrp,sys.server_principals ul WHERE Upper (mmbrp.[type]) IN ( 'S', 'U', 'G' ) AND Upper (mmbrp.[name]) NOT IN ('SYS','INFORMATION_SCHEMA') AND rolp.[principal_id] = mmbr.[role_principal_id] AND mmbrp.[principal_id] = mmbr.[member_principal_id] AND ul.[sid] = mmbrp.[sid] AND rolp.[name] LIKE '%'"
  kwargs : {
    server: '{{ conf.server }}',
    port: '{{ conf.port }}',
    user: '{{ conf.user }}',
    password: '{{ conf.password }}',
    database: '{{ conf.UTA_DB }}'
  }
  assertion: assertEqual
  expected_return: [['{{ conf.UTA_USER }}', 'db_owner']]
  output_details: True

check_mssql_QRTZ_TRIGGERS:
  module_and_function: mssql.tsql_query
  args:
    - "select distinct 1 from QRTZ_TRIGGERS where TRIGGER_GROUP='AC20_INT_TEST'"
  kwargs : {
    server: '{{ conf.server }}',
    port: '{{ conf.port }}',
    user: '{{ conf.user }}',
    password: '{{ conf.password }}',
    database: '{{ conf.UTA_DB }}'
  }
  assertion: assertEqual
  expected_return: [[1]]
  output_details: True