{% set instance = pillar['instance'] %}
{% set repoServer = pillar['repoServer'] %}

Eset Install {{ instance }}:
  salt.state:
    - sls:
      - BuildTemplate/windows/InstallEset
    - tgt: {{ instance }}
    - pillar: 
        repoServer: {{ repoServer }}

