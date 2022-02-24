Shutdown Template VM:
  salt.runner:
    - name: cloud.action
    - func: stop
    - instance: {{ pillar['instance'] }}
    - retry:
        attempts: 5
        until: True
        interval: 60
        splay: 10


Convert to template:
  salt.runner:
    - name: cloud.action
    - func: convert_to_template
    - instance: {{ pillar['instance'] }}
    - retry:
        attempts: 5
        until: True
        interval: 60
        splay: 10


{#
Convert to Template:
  cmd.run:
    - name: salt-cloud -a convert_to_template {{ pillar['instance'] }} -y

#}
