{% set instance = pillar['instance'] %}
Reregister:
  cmd.run:
    - names:
      - 'wuauclt /detectnow'
      - "(New-Object -ComObject Microsoft.Update.AutoUpdate).DetectNow()"
      - 'wuauclt /reportnow'
      - "c:\\windows\\system32\\UsoClient.exe startscan"
    - shell: 'powershell'


{% if salt['win_wua.list']() == 'Nothing to return' %}

no-updates:
  test.succeed_without_changes:
    - name: {{ grains.id }} has no updates available

{% else %}

{% set winwua = salt['win_wua.list']() %}

{% for kbuid in winwua %}
{% set kbdata = winwua[kbuid] %}

Reregister {{kbdata.KBs[0]}}:
  cmd.run:
    - names:
      - "(New-Object -ComObject Microsoft.Update.AutoUpdate).DetectNow()"
    - shell: 'powershell'


Download_update {{kbdata.KBs[0]}}:
  module.run:
    - name: win_wua.download
    - m_names: {{kbdata.KBs[0]}}

Install_update {{kbdata.KBs[0]}}:
  module.run:
    - name: win_wua.install
    - m_names: {{kbdata.KBs[0]}}
    - require:
      - Download_update {{kbdata.KBs[0]}}

Reboot_minion {{kbdata.KBs[0]}}:
  salt.function:
    - name: system.reboot
    - tgt: '{{ instance }}'



wait_for_minion Reboot {{kbdata.KBs[0]}}:
  salt.wait_for_event:
    - name: salt/minion/*/start
    - id_list:
      - '{{ instance }}'
    - require:
      - salt: Reboot_minion
{% endfor %}


{% endif %}


sleepingtoApplypatches:
  module.run:
    - name: test.sleep
    - length: 300

Install_updates:
  module.run:
    - name: win_wua.list
    - download: True
    - install: True
    - online: False
    - retry:
        attempts: 5
        until: True
        interval: 60
        splay: 10

