{% import "./vars.sls" as base %}

{% set backuplocation = "/opt/" %}
{% set uxddbname = base.dict["UXD_TENANT_DB_NAME"] %}
{% set uxddbfilename =  backuplocation + uxddbname + ".sql"%} 
{% set tenantname = base.dict["TENANT_KEY"]|lower %}
{% set tenanturl = base.dict["TENANT_FQDN"] %}
{% set share= base.dict["BACKUP_LOCATION"] %}


{% set user = base.dict["user"] %}
{% set domain = base.dict["domain"] %}
{% set passwd= base.dict["password"] %}

Creating_folder_for_mount:
  file.directory:
    - name: /opt/Backup_tenant/{{base.sourcetenantkey}}
    - makedirs: True
    - mode: 0755

Install_cifs-utils:
  pkg.installed: 
    - name: cifs-utils

Creating_mount_for_backuplocation:
  cmd.run:
    - name: mount -t cifs -o username={{ user }},dom={{ domain }},password={{ passwd }} '{{ share }}' /opt/Backup_tenant/{{base.sourcetenantkey}}
    - require:
      - pkg: Install_cifs-utils

Restore_UXD_DB_{{ tenantname }} :
  cmd.script:
    - name: salt://{{ base.parentfolder }}/UXD/Templates/restore.sh
    - args: {{base.dict["UXD_DB_INSTANCE"]}} {{base.dict["UXD_ADMIN_USER"]}} {{base.dict["UXD_ADMIN_PASSWORD"]}} {{uxddbname}} /opt/Backup_tenant/{{base.sourcetenantkey}}/{{base.sourcetenantkey|lower}}/UXD/*.sql
    - cwd: {{ backuplocation }}

Replace values in uxd_post_restore_script.sql for {{ tenantname }}:
  file.managed:
    - name: /opt/uxd_post_restore_script_{{ base.sourcetenantkey }}.sql
    - source: salt://{{ base.parentfolder }}/UXD/Templates/uxd_post_restore_script.sql
    - makedirs: True
    - replace: True
    - template: jinja
    - Prod_URL: {{ base.sourcetenantfqdn  }}
    - Stage_URL: {{ tenanturl }}
    - Prod_Site_key: {{ base.sourcetenantkey|upper }}
    - Stage_Site_Key: {{ tenantname|upper }}

Execute_post_restore_for_uxd_DB_{{ tenantname }} :
  cmd.script:
    - name: salt://{{ base.parentfolder }}/UXD/Templates/restore.sh
    - args: {{base.dict["UXD_DB_INSTANCE"]}} {{base.dict["UXD_ADMIN_USER"]}} {{base.dict["UXD_ADMIN_PASSWORD"]}} {{uxddbname}} /opt/uxd_post_restore_script_{{ base.sourcetenantkey }}.sql
    - cwd: {{ backuplocation }}


unmount_backuplocation:
  mount.unmounted:
    - name: /opt/Backup_tenant/{{base.sourcetenantkey}}

