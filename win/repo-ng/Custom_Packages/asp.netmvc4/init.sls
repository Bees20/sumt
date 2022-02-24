asp.netmvc4:
  'MS14-059 (KB2990942)':
    full_name: 'Microsoft ASP.NET MVC 4 Runtime'
    installer: http://LDCSALTREP001/21300/Prerequisites/AspNetMVC4.msi
    install_flags: '/q /norestart /L c:\saltlogs\asp.netmvc4.log'
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/AspNetMVC4.msi
    uninstall_flags: '/uninstall /x86 /x64 /q /norestart'
    msiexec: True
    locale: en_US
    reboot: False
