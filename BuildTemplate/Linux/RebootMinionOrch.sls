{% import "./Connectionvars.sls" as base %}

{% set instances = salt['cmdb_lib3.getRoleTemplateNamev1'](base.connect,pillar['datacenter'],pillar['clusterroles'],pillar['packageName']) %}


reboot_minion:
  salt.function:
    - name: system.reboot
    - tgt: [{% for value in instances %}{{ [value['instance'],',']|join }}{% endfor %}]
    - tgt_type: list
    - check_cmd:
      - /bin/true
    - timeout: 1

Wait_for_minion Reboot:
  salt.wait_for_event:
    - name: salt/minion/*/start
    - timeout: 1000
    - id_list:{% for value in instances %}
      - {{ value['instance'] }}{% endfor %}
    - require:
      - salt: reboot_minion    

