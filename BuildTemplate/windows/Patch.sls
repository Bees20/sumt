
Install_updates:
  module.run:
    - name: win_wua.list
    - download: True
    - install: True
    - online: False
    - retry:
        attempts: 5
        until: True
        interval: 60
        splay: 10
