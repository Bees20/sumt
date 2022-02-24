custompython3:
  '3.7.2':
    full_name: 'Python 3.7.2 (64-bit)'
    installer: http://LDCSALTREP001/21300/Prerequisites/python-3.7.2-amd64.exe
    install_flags: '/qn /s /norestart /passive PrependPath=1 InstallAllUsers=1 /log c:\saltlogs\custompython3.log'
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/python-3.7.2-amd64.exe
    uninstall_flags: '/quiet /uninstall'
    msiexec: False
    locale: en_US
    reboot: False
