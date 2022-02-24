
{% set domainpasswd = salt['pillar.get']('domainpasswd') %}

{% set server = pillar['instance'] %}

{% set serverIP = salt.cmd.run('salt '~ server ~' grains.item fqdn_ip4').splitlines() | last | replace("-", "") | trim%}

Remove Minion:
  cmd.run:
    - name: sshpass -p "{{ domainpasswd }}" ssh -q -o StrictHostKeyChecking=no {{ salt['pillar.get']('domainuser') }}@{{ serverIP }} 'sudo systemctl stop salt-minion; sleep 7;sudo yum -y remove salt*'

Remove Config:
  cmd.run:
    - name: sshpass -p "{{ domainpasswd }}" ssh -q -o StrictHostKeyChecking=no {{ salt['pillar.get']('domainuser') }}@{{ serverIP }} 'sudo rm -rf /etc/salt/;sleep 10'
