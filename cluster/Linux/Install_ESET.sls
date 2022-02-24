{% set eset_config = pillar['eset_dict'] %}
{% set eset_pass = pillar['eset_pass'] %}
{% set repo = pillar['repoServer'] %}


Get_ESET_binaries:
  file.managed:
    - name: /var/agent_linux_x86_64.sh
    - source: http://{{ repo }}/common/agent_linux_x86_64.sh
    - source_hash: 2944cfeb3bbb38c0e533666255f212ff
    - mode: '775'
    - if_missing: /var/agent_linux_x86_64.sh

Install_ESET:
  cmd.run:
    - name: sudo /var/agent_linux_x86_64.sh --skip-license --hostname={{ eset_config['CO_ESET_SERVER'] }} --port={{ eset_config['CO_ESET_PORT'] }} --webconsole-user={{ eset_config['CO_ESET_WEBCONSOLE_ACCOUNTNAME'] }} --webconsole-password={{ eset_pass }} --webconsole-port={{ eset_config['CO_ESET_WEBCONSOLE_PORT'] }} --cert-auto-confirm
