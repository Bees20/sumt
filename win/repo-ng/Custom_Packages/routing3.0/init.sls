routing3.0:
  '3.0':
    full_name: 'Microsoft Application Request Routing 3.0'
    installer: http://LDCSALTREP001/21300/Prerequisites/requestRouter_amd64.msi
    install_flags: 'ACCEPTEULA=1 /qn /norestart /L c:\saltlogs\routing3.0.log'
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/requestRouter_amd64.msi
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False
