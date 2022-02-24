{% set instance = pillar['instance'] %}
{% set repoServer = pillar['repoServer'] %}

Install WmiExporter {{ instance }}:
  salt.state:
    - sls:
      - BuildTemplate/windows/InstallWmiExporter
    - tgt: {{ instance }}
    - pillar:
        repoServer: {{ repoServer }}
