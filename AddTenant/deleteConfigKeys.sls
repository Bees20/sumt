{% import "./Connectionvars.sls" as base %}

Delete Config Keys from CMDB:
  module.run:
    - name: addTenant.deleteCONFIGURATION_KEY_TO_CUSTOMER_ENVIRONMENT
    - connect: {{ base.connect }}
    - clientFQDN: {{  salt['pillar.get']('FQDN') }}
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10
