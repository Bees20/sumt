Disable Firewall service:
  service.disabled:
    - name: firewalld

Disable Firewalld:
  cmd.run:
    - name: systemctl disable firewalld
    - onfail: 
        - Disable Firewall service

Stop Firewall Service:
  service.dead:
    - name: firewalld

Stop Firewalld:
  cmd.run:
    - name: systemctl stop firewalld
    - onfail:
        - Stop Firewall Service

Disabled:
    selinux.mode

remove-cache:
   file.absent:
      - name: /root/.cache
      - clean: True
