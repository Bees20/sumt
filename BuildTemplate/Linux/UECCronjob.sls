{% set reposerver = pillar['reposerver'] %}
{% set packageName =  pillar['packageName'] %}

servicestatus:
  file.managed:
    - name: /opt/services_status.sh
    - source: http://{{ reposerver }}/common/UEC/{{ packageName }}/services_status.sh
    - skip_verify: True
    - mode: '755'
    - if_missing: /opt/services_status.sh

checkuecservices:
  cron.present:
    - name: /opt/services_status.sh > /opt/services_status.log
    - user: root
    - minute: '*/10'
    - hour: '*'
    - daymonth: '*'
    - month: '*'
    - dayweek: '*'
