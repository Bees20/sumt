wmiexporter:
  latest:
    full_name: 'wmiexporter'
    installer: 'http://{{ salt['pillar.get']('reposerver') }}/common/wmi_exporter.msi'
    install_flags: 'ENABLED_COLLECTORS=cpu,cs,iis,logical_disk,net,os,service,system,textfile /qn /norestart'
    msiexec: True
    reboot: False
