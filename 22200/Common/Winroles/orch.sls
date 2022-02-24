{% import "./vars.sls" as commonbase %}

{% if commonbase.cluster!= '' and commonbase.associated_cluster != '' and commonbase.workflow == 'PROVISION' %}

Generate cluster powershell for {{ commonbase.role }}:
  salt.runner:
    - name: state.orch
    - pillar: {{ pillar | json }}
    - mods:
      - {{ commonbase.parentfolder }}/Common/Winroles/generateps

{% for server in commonbase.clusterservers %}


{% if commonbase.role == 'URD' or commonbase.role == 'UDD' or commonbase.role == 'UUD' or commonbase.role == 'UTD' or commonbase.role == 'UWD' %}

Pre-Provision cluster for {{ commonbase.role }}_{{ server }}:
  salt.state:
    - tgt: '{{ server }}'
    - pillar: {{ pillar | json }}
    - sls:
      - {{ commonbase.parentfolder }}/Common/Winroles/vars
      - {{ commonbase.parentfolder }}/Common/Winroles/pre-dbcluster
    - queue: true


{% endif %}

{% if commonbase.role == 'USA' %}

Provision cluster for {{ commonbase.role }}_{{ server }}:
  salt.state:
    - tgt: '{{ server }}'
    - pillar: {{ pillar | json }}
    - sls:
      - {{ commonbase.parentfolder }}/Common/Winroles/vars
      - {{ commonbase.parentfolder }}/Common/Winroles/cluster
    - timeout: 2000
    - queue: true

{% else %}

Provision cluster for {{ commonbase.role }}_{{ server }}:
  salt.state:
    - tgt: '{{ server }}'
    - pillar: {{ pillar | json }}
    - sls:
      - {{ commonbase.parentfolder }}/Common/Winroles/vars
      - {{ commonbase.parentfolder }}/Common/Winroles/cluster
    - parallel: True
    - timeout: 2000
    - queue: true

{% endif %}
{% endfor %}

{% elif commonbase.workflow == 'ADD_TENANT' %}

Generate addtenant powershell for {{ commonbase.role }}:
  salt.runner:
    - name: state.orch
    - pillar: {{ pillar | json }}
    - mods:
      - {{ commonbase.parentfolder }}/Common/Winroles/addtenantps


Provision addtenant for {{ commonbase.role }}_{{ commonbase.dict["EXECUTE_FROM"] }}:
  salt.state:
    - tgt: '{{ commonbase.dict["EXECUTE_FROM"] }}'
    - pillar: {{ pillar | json }}
    - sls:
      - {{ commonbase.parentfolder }}/Common/Winroles/vars
      - {{ commonbase.parentfolder }}/Common/Winroles/addtenant
    - queue: true

{% elif commonbase.server !='' and commonbase.workflow == 'PROVISION' %}

Run {{ commonbase.role }} pre-provision for {{ commonbase.server }}:
  salt.runner:
    - name: state.orch
    - mods:
      - {{ commonbase.parentfolder }}/Common/Winroles/pre-provision
    - pillar: {{ pillar | json }}

Create default directories for {{ commonbase.role }} on {{ commonbase.server }}:
  salt.state:
    - tgt: '{{ commonbase.server }}'
    - pillar: {{ pillar | json }}
    - sls:
      - {{ commonbase.parentfolder }}/Common/Winroles/vars
      - {{ commonbase.parentfolder }}/Common/Winroles/createdirectories
    - queue: true
    - require:
      - salt: Run {{ commonbase.role }} pre-provision for {{ commonbase.server }}

Install {{ commonbase.role }} provision on {{ commonbase.server }}:
  salt.state:
    - tgt: '{{ commonbase.server }}'
    - pillar: {{ pillar | json }}
    - sls:
      - {{ commonbase.parentfolder }}/Common/Winroles/vars
      - {{ commonbase.workflow_folder }}/provision
    - queue: true
    - require:
      - salt: Create default directories for {{ commonbase.role }} on {{ commonbase.server }}

Install {{ commonbase.role }} post-provision on {{ commonbase.server }}:
  salt.state:
    - tgt: '{{ commonbase.server }}'
    - pillar: {{ pillar | json }}
    - sls:
      - {{ commonbase.parentfolder }}/Common/Winroles/post-provision
    - queue: true
    - require:
      - salt: Install {{ commonbase.role }} provision on {{ commonbase.server }}

Reboot Minion {{ commonbase.server }}:
  salt.function:
    - name: system.reboot
    - tgt: {{ commonbase.server }}
    - kwarg:
        timeout: 1
        in_seconds: True
    - require:
      - salt: Install {{ commonbase.role }} post-provision on {{ commonbase.server }}

Wait_for_minion Reboot {{ commonbase.server }}:
  salt.wait_for_event:
    - name: salt/minion/*/start
    - id_list:
      - {{ commonbase.server }}
    - timeout: 900
    - require:
      - salt: Reboot Minion {{ commonbase.server }}

{% if commonbase.role == 'URD' or commonbase.role == 'UDD' or commonbase.role == 'UUD' or commonbase.role == 'UTD' or commonbase.role == 'UWD' or commonbase.role == 'UGM' %}

Install {{ commonbase.role }} db-postreboot on {{ commonbase.server }}:
  salt.state:
    - tgt: '{{ commonbase.server }}'
    - pillar: {{ pillar | json }}
    - sls:
      - {{ commonbase.parentfolder }}/Common/Winroles/dbpostreboot
    - queue: true
    - require:
      - salt: Wait_for_minion Reboot {{ commonbase.server }}


{% endif %}
{% endif %}


