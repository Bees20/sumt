{% import "./vars.sls" as base %}
{% if base.cluster!= "" %}

{% for server in base.clusterservers %}

Install kafka on cluster server {{ server }}:
  salt.state:
    - tgt: {{ server }}
    - pillar: {{ dict(pillar) | json }}
    - sls:
      - {{ base.workflow_folder }}/cluster

{% endfor %}

Install kafka-topics on cluster server {{ base.majorserver }}:
  salt.state:
    - tgt: {{ base.majorserver }}
    - pillar: {{ dict(pillar) | json }}
    - sls:
      - {{ base.workflow_folder }}/topics

{% elif base.server !="" %}
install kafka on server:
  salt.state:
    - tgt: '{{ base.server }}'
    - pillar: {{ dict(pillar) | json }}
    - sls:
      - {{ base.workflow_folder }}/pre-provision
      - {{ base.workflow_folder }}/provision
{% endif %}

