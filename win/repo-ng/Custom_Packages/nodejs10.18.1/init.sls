nodejs10.18.1:
  '10.18.1':
    full_name: 'Node.js'
    installer: http://LDCSALTREP001/21300/Prerequisites/node-v10.18.1-x64.msi
    install_flags: '/qn /norestart /L c:\saltlogs\nodejs10.18.1.log'
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/node-v10.18.1-x64.msi
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False