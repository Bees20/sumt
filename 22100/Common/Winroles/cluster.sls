{% import "./vars.sls" as commonbase %}
{% set hostname = salt['grains.get']('host', '') %}

Run Powershell Script {{ commonbase.temp_folder }}\{{ commonbase.cluster }}_{{ hostname }}_{{ commonbase.role }}.ps1:
  cmd.script:
    - source: 'salt://{{ commonbase.scripts_folder }}/{{ commonbase.cluster }}_{{ hostname }}_{{ commonbase.role }}.ps1'
    - shell: powershell
    - cwd: "C:\\Windows\\System32\\WindowsPowerShell\\v1.0"
