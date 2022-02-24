salt://files/JoinDomain.ps1:
  cmd.script:
    - shell: powershell
    - env:
      - ExecutionPolicy: "bypass"
    - retry:
        attempts: 5
        until: True
        interval: 60
        splay: 10
