
Refreshdb:
  module.run:
    - name: pkg.refresh_db

InstallScom:
  module.run:
    - name: pkg.install
    - m_name: scom
    - kwarg:
        reposerver: {{ pillar['reposerver'] }}
        managementServer: {{ pillar['managementServer'] }}
        domain: {{ pillar['domain'] }}

StartScomService:
  module.run:
    - name: service.start
    - m_name: HealthService
    - require: 
      - InstallScom
