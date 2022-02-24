Unjoin domain:
  cmd.script:
    - source: salt://files/unjoinSystem.ps1
    - shell: powershell
    - args: >-
        -username "{{ pillar['domainuser'] }}"
        -password "{{ pillar['domainpwd'] }}"
        -domain "{{ pillar['domain'] }}"
    - cwd: C:\\Temp

systemreboot:
  module.run:
    - name: system.reboot
    - timeout: 1
    - in_seconds: True
