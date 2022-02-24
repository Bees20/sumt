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
    - name: {{base.cassandra_download_path}}/{{base.mssql_tools_rpm}}
    - source: {{base.mssql_tools_url}}
    - skip_verify: True

download msodbcsql install file:
  file.managed:
    - name: {{base.cassandra_download_path}}/{{base.msodbcsql_rpm}}
    - source: {{base.msodbcsql_url}}
    - skip_verify: True

download python2_pip install file:
  file.managed:
    - name: {{base.cassandra_download_path}}/{{base.python2_pip_rpm}}
    - source: {{base.python2_pip_url}}
    - skip_verify: True

download python_setuptools install file:
  file.managed:
    - name: {{base.cassandra_download_path}}/{{base.python_setuptools_rpm}}
    - source: {{base.python_setuptools_url}}
    - skip_verify: True

download python3_pip install file:
  file.managed:
    - name: {{base.cassandra_download_path}}/{{base.python3_pip_rpm}}
    - source: {{base.python3_pip_url}}
    - skip_verify: True

installing python2_pip python3_pip python_setuptools rpms:
  pkg.installed:
    - sources: 
        - python2-pip: {{base.cassandra_download_path}}/{{base.python2_pip_rpm}}
        - python-setuptools: {{base.cassandra_download_path}}/{{base.python_setuptools_rpm}}
        - python3-pip: {{base.cassandra_download_path}}/{{base.python3_pip_rpm}}
    - require:
      - file: download python2_pip install file
      - file: download python_setuptools install file
      - file: download python3_pip install file

installing mssql-tools msodbcsql:
  cmd.run:
    - name: |
        ACCEPT_EULA=Y rpm -i {{base.msodbcsql_rpm}}
        ACCEPT_EULA=Y rpm -i {{base.mssql_tools_rpm}}
    - cwd: {{base.cassandra_download_path}}
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

download pymysql install file:
  file.managed:
    - name: {{base.cassandra_download_path}}/{{base.pymysql_file}}
    - source: {{base.pymysql_url}}
    - skip_verify: True

extract pymysql zip file:
  archive.extracted:
    - name: {{base.cassandra_download_path}}
    - source: {{base.cassandra_download_path}}/{{base.pymysql_file}}
    - enforce_toplevel: False
    - watch:
      - file: download pymysql install file

install pymysql:
  cmd.run:
    - name: python3 setup.py install
    - cwd: {{base.cassandra_download_path}}/{{base.pymysql}}
    - require:
      - archive: extract pymysql zip file

download cassandra_driver install file:
  file.managed:
    - name: {{base.cassandra_download_path}}/{{base.cassandra_driver_file}}
    - source: {{base.cassandra_driver}}
    - skip_verify: True

download geomet install file:
  file.managed:
    - name: {{base.cassandra_download_path}}/{{base.geomet_file}}
    - source: {{base.geomet}}
    - skip_verify: True

download six install file:
  file.managed:
    - name: {{base.cassandra_download_path}}/{{base.six_file}}
    - source: {{base.six}}
    - skip_verify: True

download click install file:
  file.managed:
    - name: {{base.cassandra_download_path}}/{{base.click_file}}
    - source: {{base.click}}
    - skip_verify: True

download importlib_metadata install file:
  file.managed:
    - name: {{base.cassandra_download_path}}/{{base.importlib_metadata_file}}
    - source: {{base.importlib_metadata}}
    - skip_verify: True

download typing_extensions install file:
  file.managed:
    - name: {{base.cassandra_download_path}}/{{base.typing_extensions_file}}
    - source: {{base.typing_extensions}}
    - skip_verify: True

download zipp install file:
  file.managed:
    - name: {{base.cassandra_download_path}}/{{base.zipp_file}}
    - source: {{base.zipp}}
    - skip_verify: True

install cassandra_driver:
  cmd.run:
    - name: pip3 install {{base.cassandra_driver_file}} -f ./ --no-index --no-deps
    - cwd: {{base.cassandra_download_path}}
    - require:
      - file: download cassandra_driver install file

install geomet:
  cmd.run:
    - name: pip3 install {{base.geomet_file}} -f ./ --no-index --no-deps
    - cwd: {{base.cassandra_download_path}}
    - require:
      - file: download geomet install file

install six:
  cmd.run:
    - name: pip3 install {{base.six_file}} -f ./ --no-index --no-deps
    - cwd: {{base.cassandra_download_path}}
    - require:
      - file: download six install file

install click:
  cmd.run:
    - name: pip3 install {{base.click_file}} -f ./ --no-index --no-deps
    - cwd: {{base.cassandra_download_path}}
    - require:
      - file: download click install file

install importlib_metadata:
  cmd.run:
    - name: pip3 install {{base.importlib_metadata_file}} -f ./ --no-index --no-deps
    - cwd: {{base.cassandra_download_path}}
    - require:
      - file: download importlib_metadata install file

install typing_extensions:
  cmd.run:
    - name: pip3 install {{base.typing_extensions_file}} -f ./ --no-index --no-deps
    - cwd: {{base.cassandra_download_path}}
    - require:
      - file: download typing_extensions install file

install zipp:
  cmd.run:
    - name: pip3 install {{base.zipp_file}} -f ./ --no-index --no-deps
    - cwd: {{base.cassandra_download_path}}
    - require:
      - file: download zipp install file



