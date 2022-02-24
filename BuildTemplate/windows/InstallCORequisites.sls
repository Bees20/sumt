{% set repoServer = pillar['repoServer'] %}
{% set instance = pillar['instance'] %}

{#
Installing CO Prerequisties:
   salt.parallel_runners:
     - runners:
         Installing_Eset:
           - name: state.orchestrate
           - kwarg:
               mods: ESET
               pillar:
                 repoServer: {{ repoServer }}
                 instance: {{ instance }}
         Installing_Sysmon:
           - name: state.orchestrate
           - kwarg:
               mods: Sysmon
               pillar:
                 repoServer: {{ repoServer }}
                 instance: {{ instance }}
         Installing_WmiExporter:
           - name: state.orchestrate
           - kwarg:
               mods: WmiExporter
               pillar:
                 repoServer: {{ repoServer }}
                 instance: {{ instance }}

#}
Eset Install {{ instance }}:
  salt.state:
    - sls:
      - InstallEset
    - tgt: {{ instance }}
    - pillar:
        repoServer: {{ repoServer }}


Sysmon Install {{ instance }}:
  salt.state:
    - sls:
      - Installsysmon
    - tgt: {{ instance }}
    - pillar:
        repoServer: {{ repoServer }}

Install WmiExporter {{ instance }}:
  salt.state:
    - sls:
      - InstallWmiExporter
    - tgt: {{ instance }}
    - pillar:
        repoServer: {{ repoServer }}
