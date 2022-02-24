{% set rabbitmqpass = pillar['rabbitmqpass'] %}

/opt/rabbitmq_exporter/config:
  file.replace:
    - pattern: 'RABBIT_PASSWORD=\W+\w+\W+'
    - repl: "RABBIT_PASSWORD='{{ rabbitmqpass }}'"

rabbitmq_exporter:
  module.run:
    - name: service.restart
    - m_name: rabbitmq_exporter
