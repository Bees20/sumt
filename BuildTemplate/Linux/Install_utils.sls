install_packages:
  pkg.installed:
    - pkg_verify: True
    - resolve_capabilities: True
    - pkgs:
      - psacct
      - samba-common
      - cifs-utils
      - samba-common-tools
      - openldap-clients
      - policycoreutils-devel
      - ntp
      - realmd
      - yum-utils
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10
