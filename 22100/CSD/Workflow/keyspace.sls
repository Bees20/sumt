{% import "./vars.sls" as base %}
{% set trialset = salt['network.ipaddrs']( ) %}
{% set val= trialset | replace("['", "") %}
{% set ip_addr= val| replace("']", "") %}


update the authorizer values:
  file.replace:
    - name: {{base.cassandra_dir}}/conf/cassandra.yaml
    - pattern: '^(#?authorizer)(.*)$'
    - repl: 'authorizer: CassandraAuthorizer'


update the authenticator values:
  file.replace:
    - name: {{base.cassandra_dir}}/conf/cassandra.yaml
    - pattern: '^(#?authenticator)(.*)$'
    - repl: 'authenticator: PasswordAuthenticator'



first restart cassandra:
  service.running:
    - name: cassandra
    - watch:
      - file: update the authenticator values

