{% import "./vars.sls" as base %}
{% import "./app.sls" as source %}
{% import "./app2.sls" as source2 %}
{% set install_list= [] %}

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

create log dir:
  file.directory:
    - name: {{ base.dict['LINUX_LOG_DIRECTORY'] }}
    - dir_mode: 755
    - file_mode: 755
    - user: {{base.user}}
    - group: {{base.group}}
    - recurse:
      - mode
      - user
      - group

ensure package directory exists (package/install):
  file.directory:
    - name: {{ base.package_root }}

Create install_root:
  file.directory:
    - name: {{ base.install_root }}
    - makedirs: True

Ensure install root (suite/sumtotal) has correct permissions:
  file.directory:
    - name: {{base.install_root}}
    - user: {{base.user}}
    - group: {{base.group}}
    - dir_mode: 0777
    - file_mode: 0777
    - recurse:
      - user
      - group
      - mode

Copy package to install_root:
  cmd.run:
    - name: cp -rf {{ base.package_root }}/Package/* {{ base.install_root }}

ensure suite dir has correct permissions:
  file.directory:
    - name: {{base.install_root}}
    - user: {{base.user}}
    - group: {{base.group}}
    - dir_mode: 0777
    - file_mode: 0777
    - recurse:
      - user
      - group
      - mode

ensure dsbulk dir has correct permissions:
  file.directory:
    - name: {{base.dsbulk_location}}{{ base.dsbulk_dir }}
    - user: {{base.user}}
    - group: {{base.group}}
    - dir_mode: 0777
    - file_mode: 0777
    - recurse:
      - user
      - group
      - mode

#Add release version to installed list
{% do install_list.append(base.suite_version) %}

{% for app,app_value in source.applications.items() %}

{% if app_value['template'] != "" %}

Update template and copy {{ app }} service file:
  file.managed:
    - name: {{ app_value['servicefile'] }}
    - source: salt://{{base.templates_folder}}/{{ app_value['template'] }}
    - template: jinja
    - user: {{ base.user }}
    - group: {{ base.group }}
    - start: {{ base.install_root }}
    - work_location: {{base.install_root}}
    - dsbulk_location: {{base.dsbulk_location}}{{ base.dsbulk_dir }}

{%endif%}
   
{% for config,config_value in app_value['configs'].items() %}
{% for key,key_details in config_value['keys'].items() %}

update {{ app }}_{{ config }}_{{ key }}:
  file.replace:
    - name: {{base.install_root}}/{{ config_value['_path'] }}
    - pattern: '^.*"{{key_details['_pattern']}}.*'
    - repl: '{{key_details['_spacing']}}"{{key_details['_key']}}": "{{key_details['_value']}}"{{key_details['_ending']}}'

{% endfor %}
{% endfor %}

Load new service files {{ app }}:
  cmd.run:
   - name: systemctl --system daemon-reload

enable {{app}}:
  service.enabled:
    - name: {{app}}

start {{app}}:
  service.running:
    - name: {{app}}

{% endfor %}

{% for app2,app_value2 in source2.applications2.items() %}

{% if app_value2['template'] != "" %}

Update template and copy {{ app2 }} service file:
  file.managed:
    - name: {{ app_value2['servicefile'] }}
    - source: salt://{{base.templates_folder}}/{{ app_value2['template'] }}
    - template: jinja
    - user: {{ base.user }}
    - group: {{ base.group }}
    - start: {{ base.install_root }}
    - work_location: {{base.install_root}}
    - dsbulk_location: {{base.dsbulk_location}}{{ base.dsbulk_dir }}

{%endif%}
   
{% for config2,config_value2 in app_value2['configs'].items() %}
{% for key,key_details in config_value2['keys'].items() %}

update {{ app2 }}_{{ config2 }}_{{ key }}:
  file.replace:
    - name: {{base.install_root}}/{{ config_value2['_path'] }}
    - pattern: '^.*"{{key_details['_pattern']}}.*'
    - repl: '{{key_details['_spacing']}}"{{key_details['_key']}}": "{{key_details['_value']}}"{{key_details['_ending']}}'

{% endfor %}
{% endfor %}

Load new service files {{ app2 }}:
  cmd.run:
   - name: systemctl --system daemon-reload

enable {{app2}}:
  service.enabled:
    - name: {{app2}}

start {{app2}}:
  service.running:
    - name: {{app2}}

{% endfor %}


write installed version to file:
  file.managed:
    - name: {{ base.install_root}}/version.xml
    - source: salt://{{base.templates_folder}}/{{base.versionfile}}
    - template: jinja
    - target: {{install_list|last}}
