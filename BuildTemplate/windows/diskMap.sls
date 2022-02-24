diskmap {{ pillar['driveletter'] }}:
  cmd.script:
    - source: salt://files/diskmap.ps1
    - shell: powershell
    - args: >-
        -driveletter "{{ pillar['driveletter'] }}" 
        -drivenum "{{ pillar['drivenum'] }}"
        -drivelabel "{{ pillar['drivelabel'] }}"
    - cwd: C:\
