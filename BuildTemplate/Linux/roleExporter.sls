{% set role = pillar['role'] %}
{% set reposerver = pillar['repoServer'] %}
{% set server = pillar['instance'] %}
{% set packageName =  pillar['packageName'] %}

{% if role == 'UKA' %}

{{ role }}roleexporter:
  salt.state:
    - sls:
      - BuildTemplate/Linux/kafkaExporter
      - BuildTemplate/Linux/rabbitmqExporter
      - BuildTemplate/Linux/UKACronjob
    - tgt: {{ server }}
    - pillar:
        reposerver: {{ reposerver }}

{% elif ((role == 'SCC') or (role == 'DCC')) %}

{{ role }}roleexporter:
  salt.state:
    - sls:
      - BuildTemplate/Linux/redisExporter
    - tgt: {{ server }}
    - pillar:
        reposerver: {{ reposerver }}

{% elif role == 'CSD' %}

{{ role }}roleexporter:
  salt.state:
    - sls:
      - BuildTemplate/Linux/cassandraExporter
    - tgt: {{ server }}
    - pillar:
        reposerver: {{ reposerver }}

{% elif role == 'HAM' %}

{{ role }}roleexporter:
  salt.state:
    - sls:
      - BuildTemplate/Linux/redisSentinelExporter
    - tgt: {{ server }}
    - pillar:
        reposerver: {{ reposerver }}

{% elif role == 'UXD' %}

{{ role }}roleexporter:
  salt.state:
    - sls:
      - BuildTemplate/Linux/mysqldExporter
    - tgt: {{ server }}
    - pillar:
        reposerver: {{ reposerver }}
        password: "{{ pillar['password'] }}"

{% elif role == 'UMD' %}

{{ role }}roleexporter:
  salt.state:
    - sls:
      - BuildTemplate/Linux/mongodbExporter
    - tgt: {{ server }}
    - pillar:
        reposerver: {{ reposerver }}
        password: "{{ pillar['password'] }}"

{% elif role == 'UEB' %}

{{ role }}roleexporter:
  salt.state:
    - sls:
      - BuildTemplate/Linux/rabbitmqExporter
    - tgt: {{ server }}
    - pillar:
        reposerver: {{ reposerver }}

{% elif role == 'UEC' %}

{{ role }}roleexporter:
  salt.state:
    - sls:
      - BuildTemplate/Linux/UECCronjob
    - tgt: {{ server }}
    - pillar:
        reposerver: {{ reposerver }}
        packageName: {{ packageName }}
{% endif %}

