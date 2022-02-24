iisurlrewrite:
  '2.1':
    full_name: 'IIS URL Rewrite Module 2'
    installer: http://LDCSALTREP001/21300/Prerequisites/rewrite_amd64_en-US.msi
    install_flags: '/qn /norestart /L c:\saltlogs\iisurlrewrite.log'
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/rewrite_amd64_en-US.msi
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False

