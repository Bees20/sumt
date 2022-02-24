wse3.0:
  '3.0':
    full_name: 'Microsoft WSE 3.0'
    installer: http://LDCSALTREP001/21300/Prerequisites/Microsoft%20WSE%203.0.msi
    install_flags: ' /qn /norestart /L c:\saltlogs\wse3.0.log'
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/Microsoft%20WSE%203.0.msi
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False

