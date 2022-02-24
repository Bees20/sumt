{% import "22200/conf.sls" as conf %}

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
  expected_return: '{{ conf.UWD_DB }}'
  output_details: True

check_mssql_user_exists:
  module_and_function: mssql.user_list
  kwargs : {
    server: '{{ conf.server }}',
    port: '{{ conf.port }}',
    user: '{{ conf.user }}',
    password: '{{ conf.password }}',
    database: '{{ conf.UWD_DB }}'
  }
  assertion: assertIn
  expected_return: '{{ conf.UWD_USER }}'
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
    database: '{{ conf.UWD_DB }}'
  }
  assertion: assertEqual
  expected_return: [['{{ conf.user }}', 'db_owner'], ['{{ conf.UWD_USER }}', 'db_owner'], ['{{ conf.UWD_JASPERSOFT_USER }}', 'db_owner']]
  output_details: True

check_mssql_JASPER_user_exists:
  module_and_function: mssql.user_list
  kwargs : {
    server: '{{ conf.server }}',
    port: '{{ conf.port }}',
    user: '{{ conf.user }}',
    password: '{{ conf.password }}',
    database: '{{ conf.UWD_DB }}'
  }
  assertion: assertIn
  expected_return: '{{ conf.UWD_JASPERSOFT_USER }}'
  output_details: True

check_UWD_DW:
  module_and_function: mssql.tsql_query
  args:
    - "select 1 from VersionComponent A JOIn Version B on a.VersionId=b.Id where b.VersionDescription='{{ conf.Version_Number }}' and a.ComponentName ='DW' and A.Status=1"
  kwargs : {
    server: '{{ conf.server }}',
    port: '{{ conf.port }}',
    user: '{{ conf.user }}',
    password: '{{ conf.password }}',
    database: '{{ conf.UWD_DB }}'
  }
  assertion: assertEqual
  expected_return: [[1]]
  output_details: True

check_UWD_Replication:
  module_and_function: mssql.tsql_query
  args:
    - "select 1 from VersionComponent A JOIn Version B on a.VersionId=b.Id where b.VersionDescription='{{ conf.Version_Number }}' and a.ComponentName ='replication' and A.Status=1"
  kwargs : {
    server: '{{ conf.server }}',
    port: '{{ conf.port }}',
    user: '{{ conf.user }}',
    password: '{{ conf.password }}',
    database: '{{ conf.UWD_DB }}'
  }
  assertion: assertEqual
  expected_return: [[1]]
  output_details: True

check_UWD_ETL:
  module_and_function: mssql.tsql_query
  args:
    - "select 1 from VersionComponent A JOIn Version B on a.VersionId=b.Id where b.VersionDescription='{{ conf.Version_Number }}' and a.ComponentName ='ETL' and A.Status=1"
  kwargs : {
    server: '{{ conf.server }}',
    port: '{{ conf.port }}',
    user: '{{ conf.user }}',
    password: '{{ conf.password }}',
    database: '{{ conf.UWD_DB }}'
  }
  assertion: assertEqual
  expected_return: [[1]]
  output_details: True

check_UWD_scripts:
  module_and_function: mssql.tsql_query
  args:
    - "select 1 from VersionComponent A JOIn Version B on a.VersionId=b.Id where b.VersionDescription='{{ conf.Version_Number }}' and a.ComponentName ='scripts' and A.Status=1"
  kwargs : {
    server: '{{ conf.server }}',
    port: '{{ conf.port }}',
    user: '{{ conf.user }}',
    password: '{{ conf.password }}',
    database: '{{ conf.UWD_DB }}'
  }
  assertion: assertEqual
  expected_return: [[1]]
  output_details: True

check_UWD_Jasper:
  module_and_function: mssql.tsql_query
  args:
    - "select 1 from VersionComponent A JOIn Version B on a.VersionId=b.Id where b.VersionDescription='{{ conf.Version_Number }}' and a.ComponentName ='Jasper' and A.Status=1"
  kwargs : {
    server: '{{ conf.server }}',
    port: '{{ conf.port }}',
    user: '{{ conf.user }}',
    password: '{{ conf.password }}',
    database: '{{ conf.UWD_DB }}'
  }
  assertion: assertEqual
  expected_return: [[1]]
  output_details: True

check_UWD_Jasper_Version:
  module_and_function: mssql.tsql_query
  args:
    - "select 1 from Version where VersionDescription='{{ conf.Version_Number }}' and Status=1"
  kwargs : {
    server: '{{ conf.server }}',
    port: '{{ conf.port }}',
    user: '{{ conf.user }}',
    password: '{{ conf.password }}',
    database: '{{ conf.UWD_DB }}'
  }
  assertion: assertEqual
  expected_return: [[1]]
  output_details: True