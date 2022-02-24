splunk:
  latest:
    full_name: 'splunk'
    installer: 'http://{{ salt['pillar.get']('reposerver') }}/common/{{ salt['pillar.get']('splunkInstaller') }}'
    install_flags: 'DEPLOYMENT_SERVER="{{ salt['pillar.get']('deploymentserver') }}" SPLUNKUSERNAME=admin SPLUNKPASSWORD=changeme LAUNCHSPLUNK=0 AGREETOLICENSE=yes /quiet'
    msiexec: True
    reboot: False
