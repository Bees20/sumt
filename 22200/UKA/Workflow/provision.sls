
{% import "./vars.sls" as base %}

create kafka user:
  user.present:
    - name: {{base.kafka_user}}

Create Kafka Group:
  group.present:
    - name: {{ base.kafka_group}}
    - gid: 7648
    - system: True
    - addusers:
      - {{base.kafka_user}}
    - require:
      - user: create kafka user

{% for directory in base.directories %}

create {{directory}} for:
  file.directory:
    - name: {{directory}}
    - makedirs: True

{% endfor %}

download kafka install file:
  file.managed:
    - name: {{base.kafka_download_path}}/{{base.kafka_download_file}}
    - source: {{base.kafka_download_url}}
    - skip_verify: True

download confluent-common:
  file.managed:
    - name: {{base.kafka_download_path}}/confluent-common-{{base.confluent_full_version}}.noarch.rpm
    - source: {{base.confluent_common_url}}
    - skip_verify: True

download confluent-rest-utils file:
  file.managed:
    - name: {{base.kafka_download_path}}/confluent-rest-utils-{{base.confluent_full_version}}.noarch.rpm
    - source: {{base.confluent_rest_utils_url}}
    - skip_verify: True

download confluent-schema-registry file:
  file.managed:
    - name: {{base.kafka_download_path}}/confluent-schema-registry-{{base.confluent_full_version}}.noarch.rpm
    - source: {{base.confluent_schema_registry_url}}
    - skip_verify: True


extract kafka zip file:
  archive.extracted:
    - name: {{base.kafka_path}}
    - source: {{base.kafka_download_path}}/{{base.kafka_download_file}}
    - enforce_toplevel: False
    - watch:
      - file: download kafka install file

ensure_copy_kafka_service_file:
  file.managed:
    - name: '/lib/systemd/system/kafka.service'
    - source: salt://{{ base.templates_folder}}/{{base.kafka_service_file}}
    - template: jinja
    - user: {{ base.kafka_user }}
    - group: {{ base.kafka_group }}
    - kafka_install_path: {{base.kafka_install_path}}

 
assign kafka permissions:
  file.directory:
    - name: {{base.kafka_path}}
    - user: {{base.kafka_user}}
    - group: {{base.kafka_group}}
    - dir_mode: 0777
    - file_mode: 0777
    - recurse:
      - user
      - group
      - mode
    - watch:
      - file: ensure_copy_kafka_service_file

assign kafka permissions on {{base.log_path}}:
  file.directory:
    - name: {{base.log_path}}
    - user: {{base.kafka_user}}
    - group: {{base.kafka_group}}
    - dir_mode: 0777
    - file_mode: 0777
    - recurse:
      - user
      - group
      - mode

Reload in new service:
  cmd.run:
    - name: systemctl --system daemon-reload
    - watch:
      - file: ensure_copy_kafka_service_file

install rabbit prereqs:
  pkg.installed:
    - pkgs:
      - dkms
      - make
      - bzip2
      - perl
      - kernel-headers

yum clean:
  cmd.run:
    - name: yum clean all

Set SELinux boolean for nis:
  selinux.boolean:
    - name: nis_enabled
    - value: 1
    - persist: True

yum clean dists:
  cmd.run:
   - name: yum clean all

installing confluent rpms:
  pkg.installed:
    - sources: 
        - confluent-common: {{base.kafka_download_path}}/confluent-common-{{base.confluent_full_version}}.noarch.rpm
        - confluent-rest-utils:  {{base.kafka_download_path}}/confluent-rest-utils-{{base.confluent_full_version}}.noarch.rpm
        - confluent-schema-registry:  {{base.kafka_download_path}}/confluent-schema-registry-{{base.confluent_full_version}}.noarch.rpm

enable schema:
  service.enabled:
    - name: confluent-schema-registry

#start schema:
 # service.running:
  #  - name: confluent-schema-registry

{% set disable = ["packages-microsoft-com-prod.repo"] %}

{% for repo in disable %}

/etc/yum.repos.d/{{ repo }}:
  file.replace:
    - pattern: 'enabled=1'
    - repl: 'enabled=0'

{% endfor %}

Remove yum repo backup files:
  cmd.run:
    - name: rm -f /etc/yum.repos.d/*.bak
