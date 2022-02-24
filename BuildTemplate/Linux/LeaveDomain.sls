Install_Realm_Package:
  pkg.installed:
    - pkg_verify: True
    - resolve_capabilities: True
    - pkgs:
      - realmd

Leave Domain:
  cmd.run:
    - name: echo '{{ pillar['domainpasswd'] }}' | sudo realm leave --user={{ pillar['domainuser'] }} {{ pillar['Domain'] }}

