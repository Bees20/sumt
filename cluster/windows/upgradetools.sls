UpgradeTools:
  salt.runner:
    - name: cloud.action
    - func: upgrade_tools
    - instance: {{ pillar['instance'] }}
    - retry:
        attempts: 5
        until: True
        interval: 60
        splay: 10
