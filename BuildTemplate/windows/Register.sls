
Stopservice:
  module.run:
    - name: service.stop
    - m_name: wuauserv
    - order: 1
    - retry:
        attempts: 5
        until: True
        interval: 60
        splay: 10

Removedir:
  module.run:
    - name: file.remove
    - path: "c:\\windows\\SoftwareDistribution"
    - force: True
    - order: 2
    - retry:
        attempts: 5
        until: True
        interval: 60
        splay: 10

Remove SusClientidValidation:
  reg.key_absent:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SusClientIdValidation

Remove SusClientId:
  reg.key_absent:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SusClientId

Startservice:
  module.run:
    - name: service.start
    - m_name: wuauserv
    - order: 3
    - retry:
        attempts: 5
        until: True
        interval: 60
        splay: 10


resetauthandreregister:
  cmd.run:
    - names:
      - "wuauclt.exe /resetauthorization /detectnow"
      - "(New-Object -ComObject Microsoft.Update.AutoUpdate).DetectNow()"
      - "wuauclt.exe /reportnow"
      - "UsoClient StartScan"
    - shell: 'powershell'

disable_firewallprofiles:
  win_firewall.disabled:
    - names: 
      - domainprofile
      - publicprofile
      - privateprofile

GPO Update:
  cmd.run:
    - name: 'GPUPDATE /force'
    - shell: 'powershell'
    - retry:
        attempts: 5
        until: True
        interval: 100
        splay: 10
{#
ResetauthandReregister:
  cmd.run:
    - names:
      - '$updateSession = new-object -com "Microsoft.Update.Session"; $updates=$updateSession.CreateupdateSearcher().Search($criteria).Updates'
    - shell: 'powershell'
    - env: 
      - ExecutionPolicy: "bypass"
    - retry:
        attempts: 7
        until: True
        interval: 100
        splay: 10
#}

sleepingtoreflect:
  module.run:
    - name: test.sleep
    - length: 300

systemreboot:
  module.run:
    - name: system.reboot
    - timeout: 20
    - in_seconds: True
    - order: last
