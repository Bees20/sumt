{% import "./vars.sls" as base %}

{% set trialset = salt['network.ipaddrs']( ) %}
{% set val= trialset | replace("['", "") %}
{% set ip_addr= val| replace("']", "") %}

wait for minute:
  cmd.run:
    - name: sleep 180

/opt/mount/install/{{ base.release_version }}:
  file.directory:
    - makedirs: True
    - mode: 0755

/opt/install/{{ base.release_version }}/UKA:
  file.directory:
    - makedirs: True
    - mode: 0755

Install cifs-utils:
  pkg.installed: 
    - name: cifs-utils

Mount:
  cmd.run:
    - name: mount -t cifs -o username={{ base.user }},dom={{ base.domain }},password={{ base.passwd }} "{{ base.share }}" /opt/mount/install/{{ base.release_version }}
    - require:
      - pkg: Install cifs-utils

copy_files:
  file.copy:
    - name: /opt/install/{{ base.release_version }}/UKA.zip
    - source: /opt/mount/install/{{ base.release_version }}/UKA.zip
    - mode: 0755
    - makedirs: True
    - preserve: True
    - subdir: True
    - force: True
    - require:
      - cmd: Mount

unmount:
  mount.unmounted:
    - name: /opt/mount/install/{{ base.release_version }}
    - require:
      - file: copy_files

extract main install folder to {{base.suite_version}} package root:
  archive.extracted:
    - source: /opt/install/{{ base.release_version }}/UKA.zip
    - skip_verify: true
    - name: {{base.package_root}}
    - archive_format: zip
    - enforce_toplevel: False
    - user: {{base.kafka_user}}
    - group: {{base.kafka_group}}

copytopicsscript:
  file.managed:
    - name: /opt/installtopics.sh
    - source: salt://{{base.templates_folder}}/install_service.sh
    - template: jinja
    - UKASERVERNODES: {{base.kafka_ip_string}}
    - suiteversion: {{base.suite_version}}
    - packageroot: /opt/install/
    - mode: 777

runinstalltopicsscript:
  cmd.script:
    - name: /opt/installtopics.sh
