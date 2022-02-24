{% import "./vars.sls" as base %}

set up MS repo:
  pkgrepo.managed:
    - name: packages-microsoft-com-prod
    - baseurl: {{ base.ms_baseurl }}
    - gpgkey: {{ base.ms_gpgkey }}
    - gpgcheck: 1
    - enabled: 0

delete potential conflicting packages:
  pkg.removed:
    - pkg_verify: True
    - resolve_capabilities: True
    - pkgs:
      - unixODBC-utf16
      - unixODBC-utf16-devel

install unixODBC:
  pkg.installed:
    - sources:
      - unixODBC: {{ base.unixODBC }}
      - unixODBC-devel: {{ base.unixODBC_devel }}

install packages:
  pkg.installed:
    - pkg_verify: True
    - resolve_capabilities: True
    - pkgs: #required for python
      - python-devel
      - epel-release
      - gcc-c++
# required for rabbitmq
      - policycoreutils-python

install selinux tools:
  pkg.installed:
    - pkgs: #required for python
      - selinux-policy-targeted

download mssql_tools install file:
  file.managed:
    - name: {{base.kafka_download_path}}/{{base.mssql_tools_rpm}}
    - source: {{base.mssql_tools_url}}
    - skip_verify: True

download msodbcsql install file:
  file.managed:
    - name: {{base.kafka_download_path}}/{{base.msodbcsql_rpm}}
    - source: {{base.msodbcsql_url}}
    - skip_verify: True

download python2_pip install file:
  file.managed:
    - name: {{base.kafka_download_path}}/{{base.python2_pip_rpm}}
    - source: {{base.python2_pip_url}}
    - skip_verify: True

download python_setuptools install file:
  file.managed:
    - name: {{base.kafka_download_path}}/{{base.python_setuptools_rpm}}
    - source: {{base.python_setuptools_url}}
    - skip_verify: True

installing python2_pip python_setuptools rpms:
  pkg.installed:
    - sources: 
        - python2-pip:  {{base.kafka_download_path}}/{{base.python2_pip_rpm}}
        - python-setuptools: {{base.kafka_download_path}}/{{base.python_setuptools_rpm}}
    - require:
      - file: download python2_pip install file
      - file: download python_setuptools install file

installing mssql-tools msodbcsql:
  cmd.run:
    - name: |
        ACCEPT_EULA=Y rpm -i {{base.msodbcsql_rpm}}
        ACCEPT_EULA=Y rpm -i {{base.mssql_tools_rpm}}
    - cwd: {{base.kafka_download_path}}
    - require:
      - file: download mssql_tools install file
      - file: download msodbcsql install file

install java and update MS tools Path:
  cmd.run:
    - reload_modules: true
    - name: |
        yum install -y java
        export PATH="$PATH:/opt/mssql-tools/bin" >> ~/.bash_profile
        export PATH="$PATH:/opt/mssql-tools/bin" >> ~/.bashrc
        source ~/.bashrc

download futures install file:
  file.managed:
    - name: {{base.kafka_download_path}}/{{base.futures_file}}
    - source: {{base.futures}}
    - skip_verify: True

download enum install file:
  file.managed:
    - name: {{base.kafka_download_path}}/{{base.enum_file}}
    - source: {{base.enum}}
    - skip_verify: True

download confluent_kafka install file:
  file.managed:
    - name: {{base.kafka_download_path}}/{{base.confluent_kafka_file}}
    - source: {{base.confluent_kafka}}
    - skip_verify: True

download pymysql install file:
  file.managed:
    - name: {{base.kafka_download_path}}/{{base.pymysql_file}}
    - source: {{base.pymysql_url}}
    - skip_verify: True

extract pymysql zip file:
  archive.extracted:
    - name: {{base.kafka_download_path}}
    - source: {{base.kafka_download_path}}/{{base.pymysql_file}}
    - enforce_toplevel: False
    - watch:
      - file: download pymysql install file

install pymysql:
  cmd.run:
    - name: python3 setup.py install
    - cwd: {{base.kafka_download_path}}/{{base.pymysql}}
    - require:
      - archive: extract pymysql zip file

install futures:
  cmd.run:
    - name: pip install {{base.futures_file}} -f ./ --no-index --no-deps
    - cwd: {{base.kafka_download_path}}
    - require:
      - file: download futures install file

install enum:
  cmd.run:
    - name: pip install {{base.enum_file}} -f ./ --no-index --no-deps
    - cwd: {{base.kafka_download_path}}
    - require:
      - file: download enum install file

install confluent_kafka:
  cmd.run:
    - name: pip install {{base.confluent_kafka_file}} -f ./ --no-index --no-deps
    - cwd: {{base.kafka_download_path}}
    - require:
      - file: download confluent_kafka install file
