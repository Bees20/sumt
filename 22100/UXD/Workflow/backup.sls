{% import "./vars.sls" as base %}

{% set backuplocation = "/opt/" %}
{% set uxddbname = base.dict["UXD_TENANT_DB_NAME"] %}
{% set uxddbfilename =  backuplocation + uxddbname + ".sql"%} 
{% set tenantname = base.dict["TENANT_KEY"]|lower %}

{% set user = base.dict["user"] %}
{% set domain = base.dict["domain"] %}
{% set passwd= base.dict["password"] %}
{% set share= base.dict["BACKUP_LOCATION"] %}


UXD_DB_Backup_for_{{ uxddbname }}:
  cmd.script:
    - name: salt://{{ base.parentfolder }}/UXD/Templates/backup.sh
    - args: {{base.dict["UXD_DB_INSTANCE"]}} {{base.dict["UXD_ADMIN_USER"]}} {{base.dict["UXD_ADMIN_PASSWORD"]}} {{uxddbname}} {{uxddbfilename}}
    - cwd: {{ backuplocation }}

Creating_folder_for_mount:
  file.directory:
    - name: /opt/Backup_tenant/{{tenantname}}
    - makedirs: True
    - mode: 0755

Install_cifs-utils:
  pkg.installed: 
    - name: cifs-utils

Creating_mount_for_backuplocation:
  cmd.run:
    - name: mount -t cifs -o username={{ user }},dom={{ domain }},password={{ passwd }} '{{ share }}' /opt/Backup_tenant/{{tenantname}}
    - require:
      - pkg: Install_cifs-utils

Creating_folder_in_backuplocation:
  file.directory:
    - name: /opt/Backup_tenant/{{tenantname}}/{{tenantname}}/UXD
    - makedirs: True
    - mode: 0755

Copy_files_from_server_to_backuplocation:
 file.copy:
  - name: /opt/Backup_tenant/{{tenantname}}/{{tenantname}}/UXD/{{uxddbname}}.sql
  - source: {{uxddbfilename}}
  - force: True
  - preserve: True

unmount_backuplocation:
  mount.unmounted:
    - name: /opt/Backup_tenant/{{tenantname}}
    - require:
      - file: Copy_files_from_server_to_backuplocation

