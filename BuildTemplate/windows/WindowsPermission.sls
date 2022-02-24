Set Drive Permissions:
  cmd.run:
    - name: |
        icacls.exe d:\ /remove:g "Authenticated Users"
        icacls.exe d:\ /grant:r "Authenticated Users":(OI)(CI)(RX)


{% if pillar['clusterrole'] in pillar['DBroles'] %}

Drive Permissions for DB roles:
  cmd.run:
    - name: |
        icacls.exe n:\ /remove:g "Authenticated Users"
        icacls.exe n:\ /grant:r "Authenticated Users":(OI)(CI)(RX)

{% endif %}

Modify minion Logonas Service to local:
  module.run:
    - name: service.modify
    - m_name: "salt-minion"
    - account_name: "LocalSystem"
