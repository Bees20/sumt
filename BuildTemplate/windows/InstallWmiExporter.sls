Refreshdb:
  module.run:
    - name: pkg.refresh_db

InstallWmiExporter:
  module.run:
    - name: pkg.install
    - m_name: wmiexporter
    - kwarg:
        reposerver: {{ pillar['reposerver'] }}
