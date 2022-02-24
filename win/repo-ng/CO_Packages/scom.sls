scom:
  latest:
    full_name: 'InstallScom'
    installer: 'http://{{ salt['pillar.get']('reposerver') }}/common/MOMAgent.msi'
    install_flags: '/qn USE_SETTINGS_FROM_AD=0 MANAGEMENT_GROUP=SCOM2016POC MANAGEMENT_SERVER_DNS={{ salt['pillar.get']('managementServer') }}.{{ salt['pillar.get']('domain') }} MANAGEMENT_SERVER_AD_NAME={{ salt['pillar.get']('managementServer') }}.{{ salt['pillar.get']('domain') }} ACTIONS_USE_COMPUTER_ACCOUNT=1 USE_MANUALLY_SPECIFIED_SETTINGS=1 AcceptEndUserLicenseAgreement=1 NOAPM=1'
    msiexec: True
    reboot: False
