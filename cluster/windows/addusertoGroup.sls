
{% set subdomain = (pillar['domain']).split('.')[0] | upper %}

{% set ADuser = [subdomain,"\\",pillar['svcuser']] | join %}

{% for group in ["Administrators","IIS_IUSRS"] %}

{% set check = salt['group.info'](group) %}

{% if ADuser not in check['members'] %}

add user to group {{ group }}:
  module.run:
    - name: group.adduser
    - m_name: {{ group }}
    - username: {{ pillar['svcuser'] }}

{% else %}

Validated {{ group }}:
  test.succeed_without_changes

{% endif %}

{% endfor %}

Set {{ pillar['svcuser'] }} as log on as service:
  lgpo.set:
    - computer_policy:
        Log on as a service: {{ pillar['svcuser'] }}
