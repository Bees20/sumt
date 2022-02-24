Accept_Minion_Key {{ salt['pillar.get']('instance') }}:
  salt.wheel:
    - name: key.delete
    - match: {{ salt['pillar.get']('instance') }}
