connector8.0.13:
  '8.0.13':
    full_name: 'MySQL Connector Net 8.0.13'
    installer: http://LDCSALTREP001/21300/Prerequisites/mysql-connector-net-8.0.13.msi
    install_flags: '/qn /norestart /L c:\saltlogs\connector8.0.13.log'
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/mysql-connector-net-8.0.13.msi
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False
