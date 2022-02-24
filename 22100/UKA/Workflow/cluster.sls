
{% import "./vars.sls" as base %}

{% set trialset = salt['network.ipaddrs']( ) %}
{% set val= trialset | replace("['", "") %}
{% set ip_addr= val| replace("']", "") %}

kill kafka:
  service.dead:
    - name: kafka

kill schema-registry:
  service.dead:
    - name: confluent-schema-registry
updateschemaregistryservicefile:
  file.replace:
    - name: /lib/systemd/system/confluent-schema-registry.service
    - pattern: 'After=network.target confluent-kafka.target'
    - repl: 'After=kafka.service'
update broker ID values:
  file.replace:
    - name: {{base.kafka_config_path}}
    - pattern: '^(broker.id=)(.*)$'
    - repl: 'broker.id={{ range(1, 1000) | random }}'
update the listener values:
  file.replace:
    - name: {{base.kafka_config_path}}
    - pattern: '^(#?listeners=)(.*)$'
    - repl: listeners=PLAINTEXT://{{ip_addr}}:{{base.kafka_port}}

update the advertised listener values:
  file.replace:
    - name: {{base.kafka_config_path}}
    - pattern: '^(#?advertised.listeners=)(.*)$'
    - repl: advertised.listeners=PLAINTEXT://{{ip_addr}}:{{base.kafka_port}}
update the zookeepertimeout values:
  file.replace:
    - name: {{base.kafka_config_path}}
    - pattern: '^(#?zookeeper.connection.timeout.ms=)(.*)$'
    - repl: zookeeper.connection.timeout.ms=60000

update the autotopiccreationtofale:
  file.append:
    - name: {{base.kafka_config_path}}
    - text: auto.create.topics.enable=false

update zk ip configs:
  file.replace:
    - name: {{base.kafka_config_path}}
    - pattern: '^(zookeeper.connect=)(.*)$'
    - repl: zookeeper.connect={{base.zookeeper_ip_string}}

update log directory path:
  file.replace:
    - name: {{base.kafka_config_path}}
    - pattern: '^(log.dirs=)(.*)$'
    - repl: 'log.dirs={{base.log_path}}'

update the schema:
  file.replace:
    - name: {{base.schema_registry_path}}/schema-registry.properties
    - pattern: '^(#?kafkastore.bootstrap.servers=)(.*)$'
    - repl: kafkastore.bootstrap.servers=PLAINTEXT://{{base.kafka_ip_string}}

Append host.name in schema:
  file.append:
    - name: {{base.schema_registry_path}}/schema-registry.properties
    - text: host.name={{ip_addr}}

comment unneeded kafkastore connection url:
  file.replace:
    - name: {{base.schema_registry_path}}/schema-registry.properties
    - pattern: 'kafkastore.connection.url=localhost:2181'
    - repl: "#kafkastore.connection.url=localhost:2181"

Load in new service files:
  cmd.run:
   - name: systemctl --system daemon-reload

enable kafka:
  service.enabled:
    - name: kafka

start kafka:
  service.running:
    - name: kafka

start schema-registry:
  service.running:
    - name: confluent-schema-registry


