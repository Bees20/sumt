
Stopservice:
  module.run:
    - name: service.stop
    - m_name: wuauserv
    - force: True
    - order: 1
   
Removedir:
  module.run:
    - name: file.remove
    - path: "c:\\windows\\SoftwareDistribution"
    - force: True
    - require:
      - Stopservice
    - order: 2

Startservice:
  module.run:
    - name: service.start
    - m_name: wuauserv
    - force: True
    - order: 3

reregister:
  cmd.run:
    - names:
      - 'wuauclt /detectnow'
      - "(New-Object -ComObject Microsoft.Update.AutoUpdate).DetectNow()"
      - 'wuauclt /reportnow'
      - "c:\\windows\\system32\\UsoClient.exe startscan"
    - shell: 'powershell'

sleepingtosyncpatches:
  module.run:
    - name: test.sleep
    - length: 300
