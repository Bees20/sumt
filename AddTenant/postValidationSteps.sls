{% import "./Connectionvars.sls" as base %}

{% set siteKey = salt['addTenant.getsiteKeyfromFQDN'](base.connect,pillar['FQDN']) %}

Run Post Validate Scripts:
  module.run:
    - name: addTenant.postValidationSteps
    - connect: {{ base.connect }}
    - role: {{  salt['pillar.get']('role') }}
    - siteKey: {{ siteKey }}
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10
