{%
set zippath = salt['reg.read_value'](
    'HKEY_LOCAL_MACHINE',
    'Software\\7-Zip',
    'Path64').vdata
%}

check_custom7zip_installed:
  module_and_function: pkg.version
  args:
    - "custom7zip"
  assertion: assertEqual
  expected_return: '19.00.00.0'

check_openjdk_installed:
  module_and_function: pkg.version
  args:
    - "openjdk"
  assertion: assertEqual
  expected_return: '11.0.9.11'

check_sqlsysclrtypes_installed:
  module_and_function: pkg.version
  args:
    - "sqlsysclrtypes"
  assertion: assertEqual
  expected_return: '13.2.5026.0'

check_sharedmanagementobjects_installed:
  module_and_function: pkg.version
  args:
    - "sharedmanagementobjects"
  assertion: assertEqual
  expected_return: '13.2.5026.0'

check_powershelltools_installed:
  module_and_function: pkg.version
  args:
    - "powershelltools"
  assertion: assertEqual
  expected_return: '13.2.5026.0'

check_sqlncli_installed:
  module_and_function: pkg.version
  args:
    - "sqlncli"
  assertion: assertEqual
  expected_return: '13.2.5026.0'

check_msodbcsql_installed:
  module_and_function: pkg.version
  args:
    - "msodbcsql"
  assertion: assertEqual
  expected_return: '13.2.5026.0'

check_mssqlcmdlnutils_installed:
  module_and_function: pkg.version
  args:
    - "mssqlcmdlnutils"
  assertion: assertEqual
  expected_return: '13.2.5026.0'

check_7zip_path:
  module_and_function: win_path.exists
  args:
    - {{ zippath }}
  assertion: assertEqual
  expected-return: True
  output_details: True

check_openjdk_path:
  module_and_function: win_path.get_path
  assertion: assertIn
  expected-return: c:\Program Files\AdoptOpenJDK\jdk-11.0.9.11-hotspot\bin
  output_details: True

check_JAVA_HOME_env_variable:
  module_and_function: environ.item
  args:
    - JAVA_HOME
  assertion: assertEqual
  expected-return: {'JAVA_HOME': 'c:\Program Files\AdoptOpenJDK\jdk-11.0.9.11-hotspot\'}
  output_details: True

