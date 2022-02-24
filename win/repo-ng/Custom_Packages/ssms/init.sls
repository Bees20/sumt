ssms:
  '18.7.1':
    full_name: 'Microsoft SQL Server Management Studio - 18.7.1'
    installer: http://LDCSALTREP001/21300/Prerequisites/SSMS-Setup-ENU.exe
    install_flags: '/quiet /norestart /log c:\saltlogs\ssms.log'
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/SSMS-Setup-ENU.exe
    uninstall_flags: '/uninstall /x86 /x64 /q /norestart'
    msiexec: False
    reboot: False