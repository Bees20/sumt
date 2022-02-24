asp.netmvc4:
  'MS14-059 (KB2990942)':
    full_name: 'Microsoft ASP.NET MVC 4 Runtime'
    installer: {{ installer }}
    install_flags: '/q /norestart /L {{ log_folder }}\asp.netmvc4.log'
    uninstaller: {{ uninstaller }}
    uninstall_flags: '/uninstall /x86 /x64 /q /norestart'
    msiexec: True
    locale: en_US
    reboot: False
