{% set instance = pillar['instance'] %}
{% set repoServer = pillar['repoServer'] %}

Sysmon Install {{ instance }}:
  salt.state:
    - sls:
      - BuildTemplate/windows/Installsysmon
    - tgt: {{ instance }}
    - pillar:
        repoServer: {{ repoServer }}
