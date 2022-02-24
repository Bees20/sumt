{% import "./vars.sls" as base %}


Download and extract percona archive:
  archive.extracted:
    - name: {{base.percona_tmp_path}}
    - source: {{base.percona_archive_url}}
    - enforce_toplevel: False
    - skip_verify: True


Delete potential conflicting packages:
  pkg.removed:
    - pkg_verify: True
    - resolve_capabilities: True
    - pkgs:
      - openssl
      - byobu
  

download pre-requisites:
  pkg.installed:
    - pkg_verify: False
    - sources:
        - byobu: {{base.byobu_rpm}}
        - tmux: {{base.tmux_rpm}}
        - screen: {{base.screen_rpm}}
    - retry:
        attempts: 5
        until: True
        interval: 60
        splay: 10

installing mongo rpms:
  pkg.installed:
    - sources: 
        - percona-server-mongodb-mongos: {{base.percona_tmp_path}}/percona-server-mongodb-mongos-{{base.percona_rpm_version}}
        - percona-server-mongodb-tools:  {{base.percona_tmp_path}}/percona-server-mongodb-tools-{{base.percona_rpm_version}}
        - percona-server-mongodb-shell:  {{base.percona_tmp_path}}/percona-server-mongodb-shell-{{base.percona_rpm_version}}
        - percona-server-mongodb-server: {{base.percona_tmp_path}}/percona-server-mongodb-server-{{base.percona_rpm_version}}

enable mongod:
  service.enabled:
    - name: mongod

start service:
  service.running:
    - name: mongod
