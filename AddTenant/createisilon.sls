{#
create dir:
  module.run:
    - name: file.mkdir
    - path: "\\\\ldcufsp001n001\\UDASHARE\\subbu"
    - owner: svc_saltstack
    - reset: True
    - grant_perms: {'Everyone': {'perms': 'full_control'}}    
       

symlink creation:
  file.symlink:
    - name: "\\\\cotestdev.local\\udashare\\DEV\\subbu"
    - target: "\\\\ldcufsp001n001\\UDASHARE\\subbu"
    - makedirs: True
#}


Create Isilonshare:
  cmd.script:
    - source: salt://files/createIsilonShare.ps1
    - shell: powershell
    - args: >-
        -sitekey "{{ pillar['sitekey'] }}"
        -isilonshare "{{ pillar['isilonShare'] }}"
    - cwd: C:\


Add Tenant share to DFS:
  cmd.script:
    - source: salt://files/addTenanttoDFS.ps1
    - shell: powershell
    - args: >-
        -sitekey "{{ pillar['sitekey'] }}"
        -naspath "{{ pillar['isilonShare'] }}"
        -share "{{ pillar['udaShare'] }}"
    - cwd: C:\

Create IsilonUF2share:
  cmd.script:
    - source: salt://files/createIsilonShare.ps1
    - shell: powershell
    - args: >-
        -sitekey "{{ pillar['sitekey'] }}"
        -isilonshare "{{ pillar['isilonuf2'] }}"
    - cwd: C:\


Add Tenant UF2 share to DFS:
  cmd.script:
    - source: salt://files/addTenanttoDFS.ps1
    - shell: powershell
    - args: >-
        -sitekey "{{ pillar['sitekey'] }}"
        -naspath "{{ pillar['isilonuf2'] }}"
        -share "{{ pillar['shareuf2'] }}"
    - cwd: C:\
