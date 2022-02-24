iisurlrewrite:
  '2.1':
    full_name: 'IIS URL Rewrite Module 2'
    installer: {{ installer }}
    install_flags: '/qn /norestart /L {{ log_folder }}\iisurlrewrite.log'
    uninstaller: {{ uninstaller }}
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False

