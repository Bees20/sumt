{% set datetime = (salt["system.get_system_time"]().split(' ')[0]).replace(':','').replace(' ','') %}

Backup Existing IP whiltelist {{ datetime }}:
  file.copy:
    - name: {{ pillar['whitelistbackupPath'] }}_{{ datetime }}
    - source: {{ pillar['whitelistPath'] }}
    - makedirs: True

Backup Existing List {{ datetime }}:
  file.managed:
    - name: {{ pillar['whitelistbackupPath'] }}
    - source: {{ pillar['whitelistPath'] }}
    - keep_source: True
    - replace: True
    - makedirs: True
