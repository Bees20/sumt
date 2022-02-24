{% import "./vars.sls" as base %}

{% if base.workflow == 'PROVISION' %}

{% if base.cluster!= '' %}

{% for server in base.clusterservers %}

Install mongoDB on cluster server {{ server }}:
  salt.state:
    - tgt: {{ server }}
    - pillar: {{ dict(pillar) | json}}
    - sls:
      - {{ base.workflow_folder }}/cluster

{% endfor %}

{% elif base.server !='' %}
install mongoDB on server:
  salt.state:
    - tgt: '{{ base.server }}'
    - pillar: {{ dict(pillar) | json}}
    - sls:
      - {{ base.workflow_folder }}/pre-provision
      - {{ base.workflow_folder }}/provision
{% endif %}

{% endif %}

{% if base.workflow == 'BACKUP_TENANT' %}

Backup_umd_db_in_{{ base.clusterservers[0] }}:
  salt.state:
    - tgt: '{{ base.clusterservers[0] }}'
    - pillar: {{ dict(pillar) | json }}
    - sls:
      - {{ base.workflow_folder }}/backup

{% endif %}