custom7zip:
  '19.00.00.0':
    full_name: '7-Zip 19.00 (x64 edition)'
    installer: {{ installer }}
    install_flags: '/qn ALLUSERS=1 /norestart /L {{ log_folder }}\custom7zip.log'
    uninstaller: {{ uninstaller }}
    uninstall_flags: '/qn /norestart'
    msiexec: True
    locale: en_US
    reboot: False
