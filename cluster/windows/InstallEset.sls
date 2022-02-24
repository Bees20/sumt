InstallEset:
  module.run:
    - name: pkg.install
    - m_name: ESET
    - kwarg:
        reposerver: {{ pillar['reposerver'] }}
