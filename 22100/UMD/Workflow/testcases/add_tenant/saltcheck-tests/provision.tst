{% import "22100/conf.sls" as conf %}

check_mongo_service_running:
  module_and_function: service.status
  args:
    - mongod
  assertion: assertTrue

check_port_is_open:
  module_and_function: firewalld.list_ports
  args:
    - public
  assertion: assertIn
  expected_return: 27017/tcp

check_mongodb_db_list:
  module_and_function: mongodb.db_list
  kwargs: {
    user: 'admin',
    password: '{{ conf.Linux_password }}',
    host: 'localhost',
    port: 27017
  }
  assertion: assertIn
  expected_return: '{{ conf.UMD_DB }}'
  output_details: True

check_mongodb_user_exists:
  module_and_function: mongodb.user_list
  kwargs: {
    user: 'admin',
    password: '{{ conf.Linux_password }}',
    host: 'localhost',
    database: '{{ conf.UMD_DB }}',
    port: 27017
  }
  assertion: assertEqual
  expected_return: [{'user': '{{ conf.UMD_USER }}', 'roles': [{'role': 'read', 'db': '{{ conf.UMD_DB }}'}, {'role': 'readWrite', 'db': '{{ conf.UMD_DB }}'}]}]
  output_details: True
  
check_mongodb_collections_BadgeDefinition:
  module_and_function: mongodb.find
  args:
    - 'BadgeDefinition'
    - {"name": "On Time, Every Time"}
  kwargs: {
    user: '{{ conf.UMD_USER }}',
    password: '{{ conf.UMD_password }}',
    host: 'localhost',
    database: '{{ conf.UMD_DB }}',
    port: 27017
  }
  assertion: assertNotEmpty
  expected_return: True
  output_details: True

check_mongodb_collections_CategoryField:
  module_and_function: mongodb.find
  args:
    - 'CategoryField'
    - {"name": "Name"}
  kwargs: {
    user: '{{ conf.UMD_USER }}',
    password: '{{ conf.UMD_password }}',
    host: 'localhost',
    database: '{{ conf.UMD_DB }}',
    port: 27017
  }
  assertion: assertNotEmpty
  expected_return: True
  output_details: True

check_mongodb_collections_LevelDefinition:
  module_and_function: mongodb.find
  args:
    - 'LevelDefinition'
    - {"name": "Novice"}
  kwargs: {
    user: '{{ conf.UMD_USER }}',
    password: '{{ conf.UMD_password }}',
    host: 'localhost',
    database: '{{ conf.UMD_DB }}',
    port: 27017
  }
  assertion: assertNotEmpty
  expected_return: True
  output_details: True

check_mongodb_collections_Ruleset:
  module_and_function: mongodb.find
  args:
    - 'Ruleset'
    - {"name": "Default"}
  kwargs: {
    user: '{{ conf.UMD_USER }}',
    password: '{{ conf.UMD_password }}',
    host: 'localhost',
    database: '{{ conf.UMD_DB }}',
    port: 27017
  }
  assertion: assertNotEmpty
  expected_return: True
  output_details: True