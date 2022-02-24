{% set instance = pillar['instance'] %}
{% set wsusserver = pillar['wsusserver'] %}
{% set port = pillar['port'] %}

Adding server to Group {{ instance }}:
  cmd.run:
    - name: 'Get-WsusServer -Name "{{ wsusserver }}" -portnumber "{{ port }}" | Get-WsusComputer -NameIncludes "{{ instance }}" | Add-WsusComputer -TargetGroupName "wsus"'
    - shell: 'powershell'
    - retry:
        attempts: 10
        until: True
        interval: 60
        splay: 10

