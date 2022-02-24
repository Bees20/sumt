{%
set zippath = salt['reg.read_value'](
    'HKEY_LOCAL_MACHINE',
    'Software\\7-Zip',
    'Path64').vdata
%}

check_dotnet4.8_regkey:
  module_and_function: reg.key_exists
  args:
    - HKLM 
    - SOFTWARE\Microsoft\Net Framework Setup\NDP\v4\Client
  assertion: assertEqual
  expected-return: True
  output_details: True

check_custom7zip_installed:
  module_and_function: pkg.version
  args:
    - "custom7zip"
  assertion: assertEqual
  expected_return: '19.00.00.0'

check_nodejs10.18.1_installed:
  module_and_function: pkg.version
  args:
    - "nodejs10.18.1"
  assertion: assertEqual
  expected_return: '10.18.1'

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

check_7zip_path:
  module_and_function: win_path.exists
  args:
    - {{ zippath }}
  assertion: assertEqual
  expected-return: True
  output_details: True

check_.pm2_folder_exists:
  module_and_function: file.directory_exists
  args:
    - c:\pm2\.pm2
  assertion: assertEqual
  expected-return: 'True'
  output_details: True

check_npm_folder_exists:
  module_and_function: file.directory_exists
  args:
    - c:\pm2\npm
  assertion: assertEqual
  expected-return: 'True'
  output_details: True

check_npm-cache_folder_exists:
  module_and_function: file.directory_exists
  args:
    - c:\pm2\npm-cache
  assertion: assertEqual
  expected-return: 'True'
  output_details: True

check_pm2_path:
  module_and_function: win_path.get_path
  assertion: assertIn
  expected-return: c:\pm2\NPM
  output_details: True

check_PM2_HOME_env_variable:
  module_and_function: environ.item
  args:
    - PM2_HOME
  assertion: assertEqual
  expected-return: {'PM2_HOME': 'c:\pm2\.pm2'}
  output_details: True

check_PM2_SERVICE_PM2_DIR_env_variable:
  module_and_function: environ.item
  args:
    - PM2_SERVICE_PM2_DIR
  assertion: assertEqual
  expected-return: {'PM2_SERVICE_PM2_DIR': 'c:\pm2\NPM\node_modules\pm2\index.js'}
  output_details: True

check_SET_PM2_HOME_env_variable:
  module_and_function: environ.item
  args:
    - SET_PM2_HOME
  assertion: assertEqual
  expected-return: {'SET_PM2_HOME': 'true'}
  output_details: True

check_SET_PM2_SERVICE_PM2_DIR_env_variable:
  module_and_function: environ.item
  args:
    - SET_PM2_SERVICE_PM2_DIR
  assertion: assertEqual
  expected-return: {'SET_PM2_SERVICE_PM2_DIR': 'true'}
  output_details: True

check_SET_PM2_SERVICE_SCRIPTS_env_variable:
  module_and_function: environ.item
  args:
    - SET_PM2_SERVICE_SCRIPTS
  assertion: assertEqual
  expected-return: {'SET_PM2_SERVICE_SCRIPTS': 'true'}
  output_details: True

check_PM2_running:
  module_and_function: service.status
  args:
   - pm2.exe
  assertion: assertTrue
  output_details: True