{% set infodict = salt['pillar.get']('Info') %}

/opt/mongodb_exporter/config:
  file.managed:
    - contents: ''

updatepassword:
  file.append:
    - name: '/opt/mongodb_exporter/config'
    - text: 
        - OPTIONS=mongodb://'{{ infodict['UMD_ADMIN_USER'] }}:{{ infodict['UMD_ADMIN_PASSWORD'] }}'@localhost:{{ infodict['UMD_DB_PORT'] }}

mongodb_exporter:
  module.run:
    - name: service.restart
    - m_name: mongodb_exporter
