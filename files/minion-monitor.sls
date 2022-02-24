###  Set up bash script to check minions and restart if they are failed
###  v1.0 2/2/21 - Brian Reasoner - Initial

{% if 'CentOS Linux-7' in grains['osfinger'] %}
{% if 'mas' not in grains['host'] %}
{% if grains['host'].startswith('sal')%}
{% set script = 'check-service.dev.sh' %}
{% else %}
{% set script = 'check-service.sh' %}
{% endif %}

### CREATE SCRIPT
Setup new script:
  file.managed:
    - name: /etc/salt/minion.d/check-service.sh
    - source: http://ldcsaltrep001.cotestdev.local/files/{{ script }}
    - skip_verify: True
    - user: root
    - group: root
    - mode: 755


### ADD CRON JOB TO RUN SCRIPT EVERY 5 MINUTES
Add cron job for service check:
  cron.present:
    - identifier: MINION_SVC_CHECK_CRON
    - name: /etc/salt/minion.d/check-service.sh
    - user: root
    - minute: '5'
    - hour: '*'
    - daymonth: '*'
    - month: '*'
    - dayweek: '*'
    - comment: 'Check minion service, restart if stopped'

{% endif %}
{% endif %}