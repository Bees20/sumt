{% set check = salt['group.info']('Administrators') %}

{% for appGroup in (pillar['applicationGroups']).split(';') %}

{% set check = salt['group.info']('Administrators') %}

{% if appGroup not in check['members'] %}

add {{ appGroup }} to AdministratorGroup:
  module.run:
    - name: group.adduser
    - m_name: 'Administrators'
    - username: {{ appGroup }}

{% else %}

Validated {{ appGroup }}:
  test.succeed_without_changes

{% endif %}

{% endfor %}


{% if pillar['role'] in ('UUD','URD','UWD','UTD','UDD') %}

{#% set dbGroups = (pillar['sqlInstaller'],pillar['dbaGroup']) | join(';') %#}

{% for dbGroup in (pillar['sqlInstaller'],pillar['dbaGroup']) %}
{% set dbcheck = salt['group.info']('Administrators') %}

{% if dbGroup  not in dbcheck['members'] %}

add {{ dbGroup }} to AdministratorGroup:
  module.run:
    - name: group.adduser
    - m_name: 'Administrators'
    - username: {{ dbGroup }}

{% else %}

Validated {{ dbGroup }}:
  test.succeed_without_changes

{% endif %}
{% endfor %}
{% endif %}

