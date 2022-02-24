smart host setup:
  cmd.script:
    - source: salt://files/smarthost.ps1
    - shell: powershell
    - args: >-
        -vmName "{{ pillar['vmName'] }}"
        -FQDN "{{ pillar['vmName'] }}.{{ pillar['domain'] }}"
        -smarthost "{{ pillar['smarthost'] }}"
