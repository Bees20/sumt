Copy Repo Files:
  file.copy:
    - name: /var/yum.repos.d/backup
    - source: /etc/yum.repos.d
    - force: True
    - makedirs: True

disable base repo:
  pkgrepo.managed:
    - name: base
    - disabled: True

disable updates repo:
  pkgrepo.managed:
    - name: updates
    - disabled: True

disable extras repo:
  pkgrepo.managed:
    - name: extras
    - disabled: True

disable centosplus repo:
  pkgrepo.managed:
    - name: centosplus
    - disabled: True
{#
Remove Repo files:
  file.directory:
    - name: /etc/yum.repos.d/
    - clean: True

ReRemove Repo Files:
  cmd.run:
    - name: rm -rf /etc/yum.repos.d/

/etc/yum.repos.d:
  file.directory:
    - user: root
    - name: /etc/yum.repos.d
    - group: root
    - mode: 755
#}
LocalRepo:
  pkgrepo.managed:
    - humanname: Local Repo
    - baseurl: http://{{ pillar['repoServer'] }}/
    - gpgcheck: 0
    - enabled: 1

Cleanup:
  cmd.run:
    - name: yum clean all

Install PolicyCoreUtil:
  pkg.installed:
    - pkg_verify: True
    - resolve_capabilities: True
    - pkgs:
      - policycoreutils-python

Disabled:
    selinux.mode

{#
update_pkg:
  pkg.uptodate:
    - refresh: True
#}
