{% set vm = pillar['vm'] %}
{% set role = pillar['role'] %}

{% if role == 'UEC' %}

noexporter:
  cmd.run:
    - name: echo "No role exporter for role UEC"

{% else %}

{% set data = ({"UXD":["9104","mysql_exporter","mysql"],"UMD":["9216","mongod_exporter","mongo"],"DCC":["9121","redis_exporter","redis"],"SCC":["9121","redis_exporter","redis"],"UEB":["9419","rabbitmq_exporter","rabbitmq"],"CSD":["7070","cassandra_exporter","cassandra"],"UKA":["7071","kafka_exporter","kafka"],"HAM":["9356","scc_sentinel_exporter","scc_sentinel"],"UUW":["9182","windows_exporter","windows"],"URW":["9182","windows_exporter","windows"],"URD":["9182","windows_exporter","windows"],"UUD":["9182","windows_exporter","windows"],"UWD":["9182","windows_exporter","windows"],"USA":["9182","windows_exporter","windows"],"USM":["9182","windows_exporter","windows"],"UDD":["9182","windows_exporter","windows"],"UTA":["9182","windows_exporter","windows"],"UTD":["9182","windows_exporter","windows"],"UGM":["9182","windows_exporter","windows"]}) %}

{% set check = [vm, data[role][0]]|join(':') %}
{% set nodenumber = salt.cmd.shell('sudo grep -n '~ data[role][1] ~' /u00/prometheus1/prometheus.yml | cut -d: -f1')|int %}

{% set status = salt["file.contains"]('/u00/prometheus1/prometheus.yml',check) %}

{% if status %}

vm exists {{ vm }}:
  cmd.run:
    - name: echo "{{ vm }} exists under role exporter in yml file."

{% else %}

Add to role {{ vm }}:
  cmd.run:
    - name: |
        sudo sed -i "{{ nodenumber + 2 }} a \            - targets: ['{{ vm }}:{{ data[role][0] }}']" /u00/prometheus1/prometheus.yml
        sudo sed -i '{{ nodenumber + 3 }} a \              labels:' /u00/prometheus1/prometheus.yml
        sudo sed -i '{{ nodenumber + 4 }} a \                instance: {{ vm }}' /u00/prometheus1/prometheus.yml
        sudo sed -i '{{ nodenumber + 5 }} a \                group: {{ data[role][2] }}' /u00/prometheus1/prometheus.yml

{% endif %}

{% endif %}

{% if role == 'HAM' %}

{% set checkvm = [vm, '9355' ]|join(':') %}
{% set nodenum = salt.cmd.shell('sudo grep -n dcc_sentinel_exporter /u00/prometheus1/prometheus.yml | cut -d: -f1')|int %}
{% set status1 = salt["file.contains"]('/u00/prometheus1/prometheus.yml',checkvm) %}

{% if status1 %}
    - name: echo "{{ vm }} exists under role exporter in yml file."

{% else %}

HAM role:
  cmd.run:
    - name: |
        sudo sed -i "{{ nodenum + 2 }} a \            - targets: ['{{ vm }}:9356']" /u00/prometheus1/prometheus.yml
        sudo sed -i '{{ nodenum + 3 }} a \              labels:' /u00/prometheus1/prometheus.yml
        sudo sed -i '{{ nodenum + 4 }} a \                instance: {{ vm }}' /u00/prometheus1/prometheus.yml
        sudo sed -i '{{ nodenum + 5 }} a \                group: dcc_sentinel' /u00/prometheus1/prometheus.yml

{% endif %}

{% endif %}

{% if role == 'UKA' and (salt['pillar.get']('PackageName')|replace('-','')|replace('.','')|int <= 21200252) %}

{% set checkvm = [vm, data['UEB'][0] ]|join(':') %}
{% set nodenum = salt.cmd.shell('sudo grep -n rabbitmq_exporter /u00/prometheus1/prometheus.yml | cut -d: -f1')|int %}
{% set status1 = salt["file.contains"]('/u00/prometheus1/prometheus.yml',checkvm) %}

{% if status1 %}
    - name: echo "{{ vm }} exists under role exporter in yml file."

{% else %}

Rabbitmq in UKA role:
  cmd.run:
    - name: |
        sudo sed -i "{{ nodenum + 2 }} a \            - targets: ['{{ vm }}:{{ data['UEB'][0] }}']" /u00/prometheus1/prometheus.yml
        sudo sed -i '{{ nodenum + 3 }} a \              labels:' /u00/prometheus1/prometheus.yml
        sudo sed -i '{{ nodenum + 4 }} a \                instance: {{ vm }}' /u00/prometheus1/prometheus.yml
        sudo sed -i '{{ nodenum + 5 }} a \                group: {{ data['UEB'][2] }}' /u00/prometheus1/prometheus.yml

{% endif %}

{% endif %}
