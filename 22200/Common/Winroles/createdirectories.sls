{% import "./vars.sls" as commonbase %}

# Create log folder
Create_logfolder:
  file.directory:
    - name: {{ commonbase.log_folder }}
    - makedirs: True

Create_tempfolder:
  file.directory:
    - name: {{ commonbase.temp_folder }}
    - makedirs: True

{% if commonbase.role == 'UUD' or commonbase.role == 'UDD' or commonbase.role == 'UTD' or commonbase.role == 'URD' or commonbase.role == 'UWD'%}

{% for dir in commonbase.sqldirectories %}
create {{dir}} with  correct permissions:
  file.directory:
    - name: {{ dir }}
    - makedirs: true
    - recurse:

{% endfor %}

{% endif %}


