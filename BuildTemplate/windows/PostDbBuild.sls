
{% set sqllist = salt['file.find']("C:\Temp\DB_TemplateScripts", type='f', name='*.sql') %}




{% for script in sqllist %}

Run CO SQl scripts {{ script }}:
  cmd.run:
    - name: sqlcmd.exe -S "{{ pillar['instance'] }}" -U "sa" -P "{{ pillar['sa_pass'] }}" -d "master" -i "{{ script }}" -v smtp="{{ pillar['SMTP'] }}" login="{{ pillar['domain_user'] }}" backuplocation="{{ pillar['backupLocation'] }}" SRVR="$(ESCAPE_SQUOTE(SRVR))" SQLLOGDIR="$(ESCAPE_SQUOTE(SQLLOGDIR))" JOBID="$(ESCAPE_SQUOTE(JOBID))" STEPID="$(ESCAPE_SQUOTE(STEPID))" STRTDT="$(ESCAPE_SQUOTE(STRTDT))" STRTTM="$(ESCAPE_SQUOTE(STRTTM))" WMI="$(ESCAPE_SQUOTE(WMI(TextData)))" INST="$(ESCAPE_SQUOTE(INST))"

{% endfor %}
