{% set connect = {} %}
{% do connect.update({'CMDB_server':pillar['CMDB_server']}) %}
{% do connect.update({'CMDB_user':pillar['CMDB_user']}) %}
{% do connect.update({'CMDB_DB_Name':pillar['CMDB_DB_Name']}) %}
{% do connect.update({'pmpToken':pillar['pmpToken']}) %}
{% do connect.update({'pmpHost':pillar['pmpHost']}) %}
