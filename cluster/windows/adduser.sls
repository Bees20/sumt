{#
{% if (pillar['domain']).split('.')[0]|upper == 'COPCI' %}
{% set groupname = 'svc_accounts_uda_pci' %}
{% else %}
{% set groupname = 'svc_accounts_uda' %}
{% endif %}

{% set domain = (pillar['domain']).split('.')[0] %}
{% set subdomain = (pillar['domain']).split('.')[1] %}

add user:
  cmd.script:
    - source: salt://files/adduser.ps1
    - shell: powershell
    - args: >-
        -username "{{ pillar['username'] }}"
        -password "{{ pillar['password'] }}"
        -domain "{{ domain }}"
        -subdomain "{{ subdomain }}"
        -groupname "{{ groupname }}"
    - runas: {{ salt['pillar.get']('domainuser') }}
    - password: {{ pillar['domainpwd'] }}
#}


{% set oupath = (pillar['svcOU']).split(';')[0] %}
{% set identity = (pillar['svcOU']).split(';')[1] %}

add user:
  cmd.script:
    - source: salt://files/adduser.ps1
    - shell: powershell
    - args: >-
        -username "{{ pillar['username'] }}"
        -password "{{ pillar['password'] }}"
        -domain "{{ pillar['domain'] }}"
        -oupath "{{ oupath }}"
        -identity "{{ identity }}"
    - runas: {{ salt['pillar.get']('domainuser') }}
    - password: {{ pillar['domainpwd'] }}

