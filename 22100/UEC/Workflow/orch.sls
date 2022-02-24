{% import "./vars.sls" as base %}
{% if base.cluster != '' %}

{% for server in base.clusterservers %}

Install UEC on Cluster server {{ server }}:
  salt.state:
    - tgt: {{ server }}
    - pillar: {{ dict(pillar) | json }}
    - sls:
      - {{ base.workflow_folder }}/cluster

{% endfor %}

{% elif base.server !='' %}
install UEC on server:
  salt.state:
    - tgt: '{{ base.server }}'
    - pillar: {{ dict(pillar) | json }}
    - sls:
      - {{ base.workflow_folder }}/pre-provision
      - {{ base.workflow_folder }}/provision
{% endif %}



