dotnethosting3.0.1:
  '3.0.1':
    full_name: 'Microsoft .NET Core 3.0.1 - Windows Server Hosting'
    installer: http://LDCSALTREP001/21300/Prerequisites/dotnet-hosting-3.0.1-win.exe
    install_flags: '/install /quiet /norestart /L c:\saltlogs\core3.1.5.log'
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/dotnet-hosting-3.0.1-win.exe
    uninstall_flags: '/uninstall /x86 /x64 /q /norestart'
    msiexec: False
    reboot: False
