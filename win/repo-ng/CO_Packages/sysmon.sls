sysmon:
  latest:
    full_name: 'sysmon'
    installer: 'http://{{ salt['pillar.get']('reposerver') }}/common/Sysmon64.exe'
    install_flags: '-accepteula -i c:\Temp\sysmon-config.xml'
    uninstaller: 'c:\windows\sysmon64'
    uninstaller_flags: '-u'
    msiexec: False
    reboot: False

