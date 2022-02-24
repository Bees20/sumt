{% import "./vars.sls" as base %}
{% if base.cluster!= '' %}

{% for server in base.clusterservers %}

Install DCC on Cluster {{ server }}:
  salt.state:
    - tgt: {{ server }}
    - pillar: {{ dict(pillar) | json }}
    - sls:
      - {{ base.workflow_folder }}/cluster
    - parallel: True

{% endfor %}

{% elif base.server !='' %}
install dcc on server:
  salt.state:
    - tgt: '{{ base.server }}'
    - pillar: {{ dict(pillar) | json }}
    - sls:
      - {{base.version}}/Common/redis/pre-provision
      - {{base.version}}/Common/redis/init
{% endif %}

