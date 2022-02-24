{% import "./vars.sls" as commonbase %}

{% for key, value in commonbase.dict.items() %}
{% if key[:1] == "_" %}

create {{ key[1:] }} for:
  file.directory:
    - name: {{ commonbase.custom_package_folder }}/{{ key[1:] }}
    - user: root
    - group: root
    - dir_mode: 777
    - file_mode: 777
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

copy {{ key[1:] }} url:
  file.managed:
    - name: {{ commonbase.custom_package_folder }}/{{ key[1:] }}/init.sls
    - source: {{ commonbase.install_package_folder }}/{{ key[1:] }}/init.sls
    - template: jinja
    - installer: {{ value }}
    - uninstaller: {{ value }}
    - log_folder: {{ commonbase.log_folder }}

{%endif%}
{%endfor%}

{% if commonbase.role == 'URW' %}

create ssdt package:
  file.directory:
    - name: {{ commonbase.custom_package_folder }}/ssdt14.0
    - user: root
    - group: root
    - dir_mode: 777
    - file_mode: 777
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

copy ssdt url:
  file.managed:
    - name: {{ commonbase.custom_package_folder }}/ssdt14.0/init.sls
    - source: {{ commonbase.install_package_folder }}/ssdt14.0/init.sls
    - template: jinja
    - installer: {{ commonbase.temp_folder }}
    - uninstaller: {{ commonbase.temp_folder }}
    - log_folder: {{ commonbase.log_folder }}

{% endif %}

refresh winrepo:
  cmd.run:
    - name: salt '{{ commonbase.server }}' pkg.refresh_db
    - runas: root
    - retry:
        interval: 30
        attempts: 3
