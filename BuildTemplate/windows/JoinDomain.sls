
Join domain:
  system.join_domain:
    - name: {{ salt['pillar.get']('domain') }}
    - username: {{ salt['pillar.get']('domainuser') }}
    - password: {{ salt['pillar.get']('domainpwd') }}
    - restart: False

systemreboot:
  module.run:
    - name: system.reboot
    - timeout: 1
    - in_seconds: True

