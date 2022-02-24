vcredist2019:
  '14.28.29325.2':
    full_name: 'Microsoft Visual C++ 2015-2019 Redistributable (x64) - 14.28.29913'
    installer: http://LDCSALTREP001/21300/Prerequisites/VC_redist.x64.exe
    install_flags: '/q /norestart /L c:\saltlogs\vcredist2019.log'
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/VC_redist.x64.exe
    uninstall_flags: '/uninstall /x64 /q'
    msiexec: False
    reboot: False

