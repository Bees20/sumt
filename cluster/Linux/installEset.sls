{% set repo = pillar['repoServer'] %}

Get_ESET_PROTECTAgentInstaller:
  file.managed:
    - name: /var/PROTECTAgentInstaller.sh
    - source: http://{{ repo }}/common/PROTECTAgentInstaller.sh
    - skip_verify: True
    - mode: '775'
    - if_missing: /var/PROTECTAgentInstaller.sh

Install_ESET:
  cmd.run:
    - name: sudo /var/PROTECTAgentInstaller.sh

Install Kernel Devel:
  pkg.installed:
    - name: kernel-devel
    - enable: True
    - skip_verify: True
    - sources:
      - kernel-devel: http://{{ repo }}/common/kernel-devel-3.10.0-1160.el7.x86_64.rpm

Get_ESETFS_binaries:
  file.managed:
    - name: /var/efs.x86_64.bin
    - source: http://{{repo}}/common/efs.x86_64.bin
    - mode: '775'
    - if_missing: /var/efs.x86_64.bin
    - skip_verify: True

Install_ESETFS:
  cmd.run:
    - name: sudo /var/efs.x86_64.bin  -y -f -g
