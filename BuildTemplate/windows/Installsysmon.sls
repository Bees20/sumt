Refreshdb:
  module.run:
    - name: pkg.refresh_db

copy__file:
  file.managed:
    - name: c:\Temp\sysmon-config.xml
    - source: http://{{ pillar['reposerver'] }}/common/sysmon-config.xml
    - skip_verify: True
    - makedirs: True

InstallSysmon:
  module.run:
    - name: pkg.install
    - m_name: sysmon
    - kwarg:
        reposerver: {{ pillar['reposerver'] }}
