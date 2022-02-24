{% import "./vars.sls" as base %}

{% set backuplocation = '/opt/' %}
{% set umddbname = base.dict["UMD_TENANT_DB_NAME"]|lower %}
{% set tenantname = base.dict["TENANT_KEY"]|lower %}
{% set share= base.dict["BACKUP_LOCATION"] %}

{% set user = base.dict["user"] %}
{% set domain = base.dict["domain"] %}
{% set passwd= base.dict["password"] %}

UMD_DB_Backup_for_{{ base.dict["UMD_TENANT_DB_NAME"] }} :
  cmd.script:
    - name: salt://{{ base.parentfolder }}/UMD/Templates/backup.sh
    - args: {{base.dict["UMD_DB_INSTANCE"]}} {{base.dict["UMD_ADMIN_USER"]}} {{base.dict["UMD_ADMIN_PASSWORD"]}} {{base.dict["UMD_TENANT_DB_NAME"]}} {{backuplocation}} {{base.dict["UMD_DB_PORT"]}}
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

/opt/Backup_tenant/{{tenantname}}/{{tenantname}}/UMD:
  file.directory:
    - makedirs: True
    - mode: 0755

copy_files:
 file.copy:
  - name: /opt/Backup_tenant/{{tenantname}}/{{tenantname}}/UMD
  - source: {{ backuplocation }}{{ base.dict["UMD_TENANT_DB_NAME"] }}
  - force: True
  - makedirs: True

unmount:
  mount.unmounted:
    - name: /opt/Backup_tenant/{{tenantname}}
    - require:
      - file: copy_files













