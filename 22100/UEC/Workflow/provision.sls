{% import "./vars.sls" as base %}
{% set patch_path = '/tmp/' + base.suite_version + '/Patches/' %}
{% set patch_list = salt['file.find'](patch_path, type= 'f', print= 'name') %}
{% set mylist= [] %}
{% set newlist= [] %}

create a user:
  user.present:
    - name: {{base.user}}

Create group:
  group.present:
    - name: {{ base.group}}
    - system: True
    - addusers:
      - {{base.user}}
    - require:
      - user: create a user

extract dsbulk:
  archive.extracted:
    - source: {{ base.dict['dsbulk-1.8.0'] }}
    - skip_verify: true
    - name: {{base.dsbulk_location}}

install dsbulk:
  cmd.run:
    - reload_modules: true
    - name: |
        export PATH="$PATH:{{base.dsbulk_location}}{{ base.dsbulk_dir }}/bin"
        source ~/.bashrc

appending to bashrc:
  file.append:
    - name: ~/.bashrc
    - text:
      - export PATH="$PATH:{{base.dsbulk_location}}{{ base.dsbulk_dir }}/bin"
    - require:
      - cmd: install dsbulk

source bashrc:
  cmd.run:
    - name: source ~/.bashrc
    - require:
      - file: appending to bashrc

/opt/mount/install/{{ base.release_version }}:
  file.directory:
    - makedirs: True
    - mode: 0755

/opt/install/{{ base.release_version }}/UEC:
  file.directory:
    - makedirs: True
    - mode: 0755

Install cifs-utils:
  pkg.installed: 
    - name: cifs-utils

Mount:
  cmd.run:
    - name: mount -t cifs -o username={{ base.duser }},dom={{ base.domain }},password={{ base.passwd }} "{{ base.share }}" /opt/mount/install/{{ base.release_version }}
    - require:
      - pkg: Install cifs-utils

copy_files:
  file.copy:
    - name: /opt/install/{{ base.release_version }}/UEC.zip
    - source: /opt/mount/install/{{ base.release_version }}/UEC.zip
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
    - source: /opt/install/{{ base.release_version }}/UEC.zip
    - skip_verify: true
    - name: {{base.package_root}}
    - archive_format: zip
    - enforce_toplevel: False
    - user: {{base.user}}
    - group: {{base.group}}
