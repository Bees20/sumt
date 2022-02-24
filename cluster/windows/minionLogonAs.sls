{% set subdomain =  salt['pillar.get']('domain').split('.')[0]  %}

{% set domainupper = subdomain | upper %}

{% set saltuser = [domainupper,"\\",pillar['domainuser']] | join %}

{% set check = salt['group.info']('Administrators') %}

{% if saltuser not in check['members'] %}

Add user to admin group:
  module.run:
    - name: group.adduser
    - m_name: Administrators
    - username: {{ saltuser }}

{% else %}

Validated:
  test.succeed_without_changes

{% endif %}

Set {{ salt['pillar.get']('domainuser') }} as log on as service:
  lgpo.set:
    - computer_policy:
        Log on as a service: {{ saltuser }}

Modify minion Logonas Service:
  module.run:
    - name: service.modify
    - m_name: "salt-minion"
    - start_delayed: True
    - account_name: "{{ salt['pillar.get']('domainuser') }}@{{ salt['pillar.get']('domain') }}"
    - account_password: "{{ salt['pillar.get']('domainpasswd') }}"

Restart service:
  module.run:
    - name: service.restart
    - m_name: salt-minion
{#
Wait For Minion:
  module.run:
    - name: test.sleep
    - length: 30
#}

