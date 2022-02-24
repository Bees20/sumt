{% import "./Connectionvars.sls" as base %}

{% set siteKey = salt['addTenant.getsiteKeyfromFQDN'](base.connect,pillar['FQDN']) %}

{% if pillar['overrideUUDbak'] %}

Add Config Keys into CMDB:
  module.run:
    - name: addTenant.addTenantUpdateConfigValues
    - connect: {{ base.connect }}
    - fqdn: {{  pillar['FQDN'] }}
    - siteKey: {{ siteKey }}
    - AR: {{  pillar['AR'] }}
    - packageName: {{  pillar['packageName'] }}
    - AUDIT_ENABLED: {{  pillar['audit'] }}
    - environment: {{ pillar['environment'] }}
    - datacenter: {{ pillar['datacenter'] }}
    - UUD_RESTORE_TENANT_BAK: {{ pillar['backupLocation'] }}
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10

{% else %}

Add Config Keys into CMDB:
  module.run:
    - name: addTenant.addTenantUpdateConfigValues
    - connect: {{ base.connect }}
    - fqdn: {{  pillar['FQDN'] }}
    - siteKey: {{ siteKey }}
    - AR: {{  pillar['AR'] }}
    - packageName: {{  pillar['packageName'] }}
    - AUDIT_ENABLED: {{  pillar['audit'] }}
    - environment: {{ pillar['environment'] }}
    - datacenter: {{ pillar['datacenter'] }}
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10

{% endif %}
