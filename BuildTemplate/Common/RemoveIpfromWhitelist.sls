{#
remove_lines:
  file.replace:
    - name: D:\iplist.txt
    - pattern: "0.0.0.0"
    - repl: ""

Remove IP from the Whitelist {{ pillar['IP'] }}:
  file.line:
    - name: {{ pillar['whitelistPath'] }}
    - mode: delete
    - content: {{ pillar['IP'] }}
#}

Remove IP from the Whitelist {{ pillar['IP'] }}:
  cmd.script:
    - source: salt://files/RemoveStringinFile.ps1
    - shell: powershell
    - args: >-
        -path "{{ pillar['whitelistPath'] }}"
        -ip "{{ pillar['IP'] }}"
