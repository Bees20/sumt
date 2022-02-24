{% set vm = pillar['vm'] %}
{% if pillar['OS'] == 'Windows' %}

Validated:
  test.succeed_without_changes

{% else %}
{% set role = pillar['role'] %}
{% set port = '9100' %}
{% set check = [vm, port]|join(':') %}
{% set nodenumber = salt['cmd.shell']('sudo grep -n  node_exporter /u00/prometheus1/prometheus.yml | cut -d: -f1')|int %}
{% set group = ({"UKA":"kafka","UXD": "mysql","HAM":"sentinal","UMD":"mongo","UEB":"rabbitmq","DCC":"redis","SCC":"redis","UEC":"webhooks","CSD":"cassandra","UUW":"windows","URW":"windows","URD":"windows","UUD":"windows","UWD":"windows","USA":"windows","USM":"windows","UDD":"windows","UTA":"windows","UTD":"windows","UGM":"windows"}) %}

{% set status = salt["file.contains"]('/u00/prometheus1/prometheus.yml',check) %}
{% if status %}
vm exists in node:
  cmd.run:
    - name: echo "{{ vm }} exists under node exporter in yml file."

{% else %}

Add to nodeexporter:
  cmd.run:
    - name: |
        sudo sed -i "{{ nodenumber + 15 }} a \            - targets: ['{{ vm }}:{{ port }}']" /u00/prometheus1/prometheus.yml
        sudo sed -i '{{ nodenumber + 16 }} a \              labels:' /u00/prometheus1/prometheus.yml
        sudo sed -i '{{ nodenumber + 17 }} a \                instance: {{ vm }}' /u00/prometheus1/prometheus.yml
        sudo sed -i '{{ nodenumber + 18 }} a \                group: {{ group[role] }}' /u00/prometheus1/prometheus.yml

{% endif %}
{% endif %}
