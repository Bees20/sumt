
{% set redispass = pillar['redispass'] %}

{% set server = pillar['server'] %}

/opt/redis_exporter/config:
  file.replace:
    - pattern: '(REDIS_PASSWORD)=\w+'
    - repl: 'REDIS_PASSWORD={{ redispass }}'


updatehostname:
  file.replace:
    - name: '/opt/redis_exporter/config'
    - pattern: 'REDIS_ADDR=\W+\w+\S+'
    - repl: "REDIS_ADDR='redis://{{ server }}:6379'"

redis_exporter:
  module.run:
    - name: service.restart
    - m_name: redis_exporter
