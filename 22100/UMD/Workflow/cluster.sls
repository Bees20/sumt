{% import "./vars.sls" as base %}

{% set trialset = salt['network.ipaddrs']( ) %}
{% set val= trialset | replace("['", "") %}
{% set ip_addr= val| replace("']", "") %}

create mongo user:
  mongodb_user.present:
  - name: {{base.umd_user}}
  - passwd: {{base.umd_password}}
  - database: admin
  - roles:
      - root

enable mongo authorization:
  file.append:
    - name: '/etc/mongod.conf'
    - require:
      - mongodb_user: create mongo user
    - text: |
        security:
          authorization: enabled

{#
remove ip binding:
  cmd.run:
    - name: sudo sed -i '/\s\sbindIp.*/d' /etc/mongod.conf
#}

update ipaddress in configs:
  file.replace:
    - name: '/etc/mongod.conf'
    - pattern: '(#?bindIp:)(.*)$'
    - repl: 'bindIp: 127.0.0.1, {{ip_addr}}'

restart mongd:
  cmd.run:
    - name: sudo systemctl restart mongod

