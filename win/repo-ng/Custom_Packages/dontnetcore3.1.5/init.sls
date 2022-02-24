core3.1.5:
  '3.1.5':
    full_name: 'Microsoft .NET Core Runtime - 3.1.5 (x64)'
    installer: http://LDCSALTREP001/21300/Prerequisites/dotnet-runtime-3.1.5-win-x64.exe
    install_flags: '/install /quiet /norestart /L c:\saltlogs\core3.1.5.log'
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/dotnet-runtime-3.1.5-win-x64.exe
    uninstall_flags: '/uninstall /x86 /x64 /q /norestart'
    msiexec: False
    reboot: False
