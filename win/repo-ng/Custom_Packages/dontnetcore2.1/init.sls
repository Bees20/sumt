core2.1:
  '2.1.2.26629':
    full_name: 'Microsoft .NET Core Runtime - 2.1.2 (x64)'
    installer: http://LDCSALTREP001/21300/Prerequisites/dotnet-runtime-2.1.2-win-x64.exe
    install_flags: '/q /norestart /L c:\saltlogs\core2.1.log'
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/dotnet-runtime-2.1.2-win-x64.exe
    uninstall_flags: '/uninstall /x86 /x64 /q /norestart'
    msiexec: False
    locale: en_US
    reboot: False
