custom7zip:
  '19.00.00.0':
    full_name: '7-Zip 19.00 (x64 edition)'
    installer: http://LDCSALTREP001/21300/Prerequisites/7z1900-x64.msi
    install_flags: '/qn ALLUSERS=1 /norestart /L c:\saltlogs\custom7zip.log'
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/7z1900-x64.msi
    uninstall_flags: '/qn /norestart'
    msiexec: True
    locale: en_US
    reboot: False
