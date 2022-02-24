dotnethosting2.0.0:
  '2.0.0':
    full_name: 'Microsoft .NET Core 2.0.0 - Windows Server Hosting'
    installer: http://LDCSALTREP001/21300/Prerequisites/DotNetCore.2.0.0-WindowsHosting.exe
    install_flags: '/install /quiet /norestart /L c:\saltlogs\core3.1.5.log'
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/DotNetCore.2.0.0-WindowsHosting.exe
    uninstall_flags: '/uninstall /x86 /x64 /q /norestart'
    msiexec: False
    reboot: False
