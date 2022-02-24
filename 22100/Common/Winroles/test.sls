{% set user = 'deployteam' %}
{% set domain = 'devlab' %}
{% set passwd= 'D3pl0y@15#' %}
{% set share= '\\\\devflsr\\Package_Share\\PACKAGES\\21.3.0.0-747' %}


/opt/Install/21.3.0.0-747:
  file.directory:
    - makedirs: True
    - mode: 0755

/srv/packages/21.3.0.0-747:
  file.directory:
    - makedirs: True
    - mode: 0755

Install cifs-utils:
  pkg.installed: 
    - name: cifs-utils

Mount:
  cmd.run:
    - name: mount -t cifs -o username={{ user }},dom={{ domain }},password={{ passwd }} '{{ share }}' /srv/packages/21.3.0.0-747
    - require:
      - pkg: Install cifs-utils

copy_files:
  file.copy:
    - name: /opt/Install/21.3.0.0-747/UEC.zip
    - source: /srv/packages/21.3.0.0-747/UEC.zip
    - mode: 0755
    - makedirs: True
    - preserve: True
    - subdir: True
    - force: True
    - require:
      - cmd: Mount

unmount:
  mount.unmounted:
    - name: /srv/packages/21.3.0.0-747
    - require:
      - file: copy_files

