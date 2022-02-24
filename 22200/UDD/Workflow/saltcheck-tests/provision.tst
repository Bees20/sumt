check_mssql_default_fill_factor:
  module_and_function: mssql.tsql_query
  args:
    - "EXEC sp_configure @configname='fill factor (%)';"
  kwargs : {
    server: 'CISWINDOWS',
    port: '1433',
    user: 'sa',
    password: 'titan#12',
    database: 'master'
  }
  assertion: assertEqual
  expected_return: [['fill factor (%)', 0, 100, 80, 80]]
  output_details: True