{% set adminuser = salt['pillar.get']('adminuser') %}
{% set adminpwd = salt['pillar.get']('adminpwd') %}
removeminion:
  cmd.script:
    - source: salt://files/RemoveMinion.ps1
    - shell: powershell
    - cwd: "C:\\Temp"
    - runas: {{ adminuser }}
    - password: "{{ adminpwd }}"
    - bg: True
