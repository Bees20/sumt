sharedmanagementobjects:
  '13.0.5026.0':
    full_name: 'Microsoft SQL Server 2016 Management Objects  (x64)'
    installer: http://LDCSALTREP001/21300/Prerequisites/SharedManagementObjects.msi
    install_flags: '/qn /norestart /L c:\saltlogs\sharedmanagementobjects.log'
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/SharedManagementObjects.msi
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False
