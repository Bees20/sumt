{% import "./Connectionvars.sls" as base %}

{% if pillar['overrideUUDbak'] == true %}

{% set clusterName = pillar['clusterDict']["UUD"] %}
{% set UUDServer = salt['cmdb_lib3.getClusterServerList'](base.connect,clusterName) %}
{% set filePath = pillar['backupLocation'] %}

validateUUDBakFile {{ UUDServer }}:
  salt.state:
    - sls:
      - AddTenant.validateBackupFile
    - tgt: {{ UUDServer[0] }}
    - pillar:
        filePath: {{ filePath }}
    - retry:
        attempts: 3
        until: True
        interval: 45
        splay: 10
    - queue: True

{% else %}

Check UUD Backup File Path:
  cmd.run:
    - name: echo "overrideUUDBak flag is set to false"

{% endif %}
