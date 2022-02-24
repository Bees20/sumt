Accept_Minion_Key {{ salt['pillar.get']('instance') }}:
  salt.wheel:
    - name: key.accept
    - match: {{ salt['pillar.get']('instance') }}
