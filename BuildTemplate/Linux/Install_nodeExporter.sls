{% set repoServer = pillar['repoServer'] %}

node_exporter:
  user.present:
    - fullname: node_exporter
    - shell: /bin/false


extract_node_exporter:
  archive.extracted:
    - name: /tmp/
    - source: http://{{ repoServer }}/prometheus/node_exporter-0.15.2.linux-amd64.tar.gz
    - user: node_exporter
    - group: node_exporter
    - mode: '755'
    - skip_verify: True
    - if_missing: /tmp/node_exporter-0.15.2.linux-amd64.tar.gz

copy__files:
  file.managed:
    - name: /usr/local/sbin/node_exporter
    - source: /tmp/node_exporter-0.15.2.linux-amd64/node_exporter
    - mode: 0755

/etc/sysconfig/node_exporter:
  file.append:
    - text: |
        OPTIONS="--collector.textfile.directory /var/lib/node_exporter/textfile_collector"

/var/lib/node_exporter/textfile_collector:
  file.directory:
    - makedirs: True

{% if salt['file.file_exists' ]('/etc/systemd/system/node_exporter.service') %}
Remove NodeExporter servicefile:
  module.run:
    - name: file.remove
    - path: /etc/systemd/system/node_exporter.service
{% endif %}

/etc/systemd/system/node_exporter.service:
  file.append:
    - text: |
        [Unit]
        Description=Node Exporter
        After=network-online.target

        [Service]
        User=node_exporter
        Group=node_exporter
        Type=simple
        EnvironmentFile=/etc/sysconfig/node_exporter
        ExecStart=/usr/local/sbin/node_exporter $OPTIONS

        [Install]
        WantedBy=multi-user.target


Enable node_exporter service:
  service.enabled:
    - name: node_exporter.service

start node_exporter Service:
  service.running:
    - name: node_exporter.service
