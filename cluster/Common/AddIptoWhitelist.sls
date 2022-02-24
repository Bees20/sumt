{% if salt['file.get_diff'](pillar['whitelistPath'],pillar['whitelistbackupPath']) %}

always-fails:
  test.fail_without_changes:
    - name: Files are not identical

{% else %}

Add Ip to whitelist {{ pillar['IP'] }}:
  file.append:
    - name: {{ pillar['whitelistPath'] }}
    - text:
        - "{{ pillar['IP'] }}"

Validate IP in WhiteList:
  module.run:
    - name: file.search
    - path: {{ pillar['whitelistPath'] }}
    - pattern: "{{ pillar['IP'] }}"

{% endif %}
