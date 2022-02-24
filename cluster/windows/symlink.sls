{#
{{ pillar['tenantShare'] }} symlink:
  file.symlink:
    - name: {{ pillar['tenantShare'] }}
    - target: \\{{ pillar['domain'] }}\UDASHARE\{{ pillar['environment'] }}
    - makedirs: True

{{ pillar['packageShare'] }} symlink:
  file.symlink:
    - name: {{ pillar['packageShare'] }}
    - target: \\{{ pillar['domain'] }}\UDASHARE\{{ pillar['datacenter'] }}-packages
    - makedirs: True

#}
{% if not salt['file.directory_exists' ]('D:\\tenantShares') %}
symlink:
  cmd.run:
    - name: 'mklink /d "d:\tenantShares" "\\{{ pillar['domain'] }}\UDASHARE\{{ pillar['environment'] }}"'

{% else %}

Validated:
  test.succeed_without_changes
{% endif %}

{% if not salt['file.directory_exists' ]('D:\\udaPackages') %}

PackageShare symlink:
  cmd.run:
    - name: 'mklink /d "d:\udaPackages" "\\{{ pillar['domain'] }}\UDASHARE\{{ pillar['datacenter'] }}-packages"'

{% else %}

Validated udapackages:
  test.succeed_without_changes
{% endif %}

