{% import "./vars.sls" as base %}

{% if base.workflow == 'PROVISION' %}

{% if base.cluster != '' %}

{% for server in base.clusterservers %}

Install mysql on cluster server {{ server }}:
  salt.state:
    - tgt: {{ server }}
    - pillar: {{ dict(pillar) | json }}
    - sls:
      - {{ base.workflow_folder }}/cluster

{% endfor %}

{% elif base.server !='' %}
install mysql on server:
  salt.state:
    - tgt: '{{ base.server }}'
    - pillar: {{ dict(pillar) | json }}
    - sls:
      - {{ base.workflow_folder }}/pre-provision
      - {{ base.workflow_folder }}/provision
{% endif %}
{% endif %}

{% if base.tenant != '' and base.workflow == 'ADD_TENANT' %}

Run Add Tenant for {{ base.role }}:
  salt.runner:
    - name: state.orch
    - pillar: {{ pillar | json }}
    - mods:
      - {{ base.parentfolder }}/Common/Winroles/orch

{% endif %}
