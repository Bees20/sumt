
Add Tenant to Matomo:
  cmd.script:
    - source: salt://files/matomo.ps1
    - shell: powershell
    - args: >-
        -cmdbServer "{{ pillar['cmdbServer'] }}"
        -cmdbDBName "{{ pillar['cmdbDBName'] }}"
        -cmdbAdminUser "{{ pillar['cmdbAdminUser'] }}"
        -cmdbAminPassword "{{ pillar['cmdbAminPassword'] }}"
        -vmtierCode "{{ pillar['vmtierCode'] }}"
        -packageName "{{ pillar['packageName'] }}"
        -tenantList "{{ pillar['tenantList'] }}"
    - cwd: C:\
