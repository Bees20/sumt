dotnet4.8:
  '4.8.03761':
    full_name: 'Microsoft .NET Framework 4.8'
    installer: http://LDCSALTREP001/21300/Prerequisites/ndp48-x86-x64-allos-enu.exe
    install_flags: '/q /norestart /log c:\saltlogs\dotnet4.8.log'
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/ndp48-x86-x64-allos-enu.exe
    uninstall_flags: '/uninstall /x86 /x64 /q /norestart'
    msiexec: False
    reboot: False