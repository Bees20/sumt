add DNS Record:
  cmd.script:
    - source: salt://files/addDNS.ps1
    - shell: powershell
    - args: >-
        -name "{{ pillar['name'] }}"
        -zone "{{ pillar['zone'] }}"
        -ipaddress "{{ pillar['ipaddress'] }}"
        -dnsip "{{ pillar['dnsip'] }}"
    - runas: {{ salt['pillar.get']('domainuser') }}
    - password: {{ pillar['password'] }}

