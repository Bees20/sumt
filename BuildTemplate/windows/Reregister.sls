reSetauthandreregister:
  cmd.run:
    - names:
      - "wuauclt.exe /resetauthorization /detectnow"
      - "wuauclt.exe /reportnow"
      - "UsoClient StartScan"
    - shell: 'powershell'
    - env:
      - ExecutionPolicy: "bypass"

ResetauthandReregister:
  cmd.run:
    - names: 
      - '$updateSession = new-object -com "Microsoft.Update.Session"; $updates=$updateSession.CreateupdateSearcher().Search($criteria).Updates'
    - shell: 'powershell'
    - retry:
        attempts: 3
        until: True
        interval: 100
        splay: 10

