Disable Firewall service:
  service.disabled:
    - name: firewalld
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10

Stop Firewall Service:
  service.dead:
    - name: firewalld
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10
