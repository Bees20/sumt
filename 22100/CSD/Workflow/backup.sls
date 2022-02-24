{% import "./vars.sls" as base %}

{% set backuplocation = '/opt/' %}
{% set csddbname = base.dict["CSD_DB_NAME"]|lower %}
{% set tenantname = base.dict["TENANT_KEY"]|lower %}
{% set share= base.dict["BACKUP_LOCATION"] %}

{% set user = base.dict["user"] %}
{% set domain = base.dict["domain"] %}
{% set passwd= base.dict["password"] %}

CSD_DB_Backup_for_{{ csddbname }} :
  cmd.script:
    - name: salt://{{ base.parentfolder }}/CSD/Templates/backup.sh
    - args: {{csddbname}} {{tenantname}}
    - cwd: {{ backuplocation }}

/opt/Backup_tenant/{{tenantname}}:
  file.directory:
    - makedirs: True
    - mode: 0755

Install cifs-utils:
  pkg.installed: 
    - name: cifs-utils

Mount:
  cmd.run:
    - name: mount -t cifs -o username={{ user }},dom={{ domain }},password={{ passwd }} '{{ share }}' /opt/Backup_tenant/{{tenantname}}
    - require:
      - pkg: Install cifs-utils

/opt/Backup_tenant/{{tenantname}}/{{tenantname}}/CSD:
  file.directory:
    - makedirs: True
    - mode: 0755

copy_files:
 file.copy:
  - name: /opt/Backup_tenant/{{tenantname}}/{{tenantname}}/CSD
  - source: /backup
  - force: True
  - makedirs: True

unmount:
  mount.unmounted:
    - name: /opt/Backup_tenant/{{tenantname}}
    - require:
      - file: copy_files










