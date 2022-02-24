ESET:
  latest:
    full_name: 'ESET'
    installer: 'http://{{ salt['pillar.get']('reposerver') }}/common/PROTECT_Installer_x64_en_US.exe'
    install_flags: '--silent --accepteula --avr-disable'
    msiexec: False
    locale: en_US
    reboot: True
