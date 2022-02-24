IISLogFileRotation:
  cmd.script:
    - source: salt://files/iisLogPurgeInit.ps1
    - shell: powershell
    - runas: '{{ pillar['domainAdminUser'] }}'
    - password: '{{ pillar['domainAdminPass'] }}'
