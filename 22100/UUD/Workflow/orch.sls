{% import "./../../Common/Winroles/vars.sls" as commonbase %}

Run Orchestration for {{ commonbase.role }}:
  salt.runner:
    - name: state.orch
    - pillar: {{ pillar | json }}
    - mods:
      - {{ commonbase.parentfolder }}/Common/Winroles/orch