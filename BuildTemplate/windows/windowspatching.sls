{% set instance = pillar['instance'] %}
{% set wsusserver = pillar['wsusserver'] %}


Create Registry {{ instance }}:
  salt.state:
    - sls:
      - BuildTemplate/windows/CreateReg
    - tgt: {{ instance }}
    - pillar:
        wsusserver: {{ wsusserver }}

{#
wait_for_minion Reboot {{ instance }}:
  salt.wait_for_event:
    - name: salt/minion/*/start
    - id_list:
      - '{{ instance }}' 
    - timeout: 2000

Detectandregister {{ instance }}:
  salt.state:
    - sls:
      - BuildTemplate/windows/Register
    - tgt: {{ instance }}

wait_on_minion Reboot {{ instance }}:
  salt.wait_for_event:
    - name: salt/minion/*/start
    - id_list:
      - '{{ instance }}'
    - timeout: 2000

Add to WsusGroup {{ instance }}:
  salt.state:
    - sls:
      - BuildTemplate/windows/AddToWsusGroup
    - tgt: {{ wsusserver.split('.')[0] }}
    - pillar:
        instance: {{ instance }}
        wsusserver: {{ wsusserver.split(':')[0] }}
        port: {{ wsusserver.split(':')[1] }}
    - queue: True


Reregister {{ instance }}:
  salt.state:
    - sls:
      - BuildTemplate/windows/Reregister
    - tgt: {{ instance }}
    - timeout: 2000

PushPatches {{ instance }}:
  salt.state:
    - sls:
      - BuildTemplate/windows/PushPatches
    - tgt: {{ instance }}
    - timeout: 2000

{% for i in range(0,5) %}

Patching {{ i }} on {{ instance }}:
  salt.state:
    - sls:
      - BuildTemplate/windows/Patch
    - tgt: {{ instance }}
    - pillar:
        instance: {{ instance }}
    - timeout: 6000

Reboot_minion {{ i }} on {{ instance }}:
  salt.function:
    - name: system.reboot
    - tgt: {{ instance }}
    - kwarg:
        timeout: 1
        in_seconds: True
    - onlyif:
      - salt {{ instance }} system.get_pending_reboot | grep True

wait_for_minion Reboot {{ i }} {{ instance }}:
  salt.wait_for_event:
    - name: salt/minion/*/start
    - id_list:
      - '{{ instance }}'
    - timeout: 6000
    - onchanges:
      - salt: Reboot_minion {{ i }} on {{ instance }}

{% endfor %}
#}
