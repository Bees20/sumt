Modify minion Logonas Service:
  module.run:
    - name: service.modify
    - m_name: "salt-minion"
    - account_name: "LocalSystem"
