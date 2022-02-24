Refreshdb:
  module.run:
    - name: pkg.refresh_db


InstallSplunk:
  module.run:
    - name: pkg.install
    - m_name: splunk
    - kwarg:
        reposerver: {{ pillar['reposerver'] }}
        splunkInstaller: {{ pillar['splunkInstaller'] }}
        deploymentserver: {{ pillar['deploymentserver'] }}

StartSplunkService:
  module.run:
    - name: service.start
    - m_name: SplunkForwarder
    - require: 
      - InstallSplunk
