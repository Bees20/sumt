{% set reposerver = pillar['reposerver'] %}

{% if not salt['user.info']('kafka') %}

kafka:
  user.present:
    - fullname: kafka
    - shell: /bin/false

{% endif %}
{#
get jmx jar and yml file:
  file.managed:
    - source: http://{{ reposerver }}/prometheus/kafka.tar.gz
    - name: /opt/exporter/kafka.tar.gz
    - skip_verify: True
    - user: kafka
    - group: kafka
    - mode: 0755
    - makedirs: True
#}

extract_kakfka_exporter:
  archive.extracted:
    - name: /opt/exporter/
    - source:  http://{{ reposerver }}/prometheus/kafka.tar.gz
    - skip_verify: True
    - user: kafka
    - group: kafka
    - mode: '755'
    - makedirs: True

get jmx jar file:
  file.managed:
    - source: /opt/exporter/kafka/jmx_prometheus_javaagent-0.12.0.jar
    - names: 
      - /opt/exporter/jmx_prometheus_javaagent-0.12.0.jar:
        - source: /opt/exporter/kafka/jmx_prometheus_javaagent-0.12.0.jar
      - /opt/exporter/kafka-2_0_0.yml:
        - source: /opt/exporter/kafka/kafka-2_0_0.yml
    - skip_verify: True
    - user: kafka
    - group: kafka
    - mode: 0755
    - makedirs: True

Delete tar files:
  file.absent:
    - name: /opt/exporter/kafka.tar.gz
{#
Delete kafka folder:
  file.absent:
    - name: /opt/exporter/kafka
#}
