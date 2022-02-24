{% import "./Connectionvars.sls" as base %}

{% set hostAddress = "api.edgecast.com" %}
{% set accountName = "C18F" %}

Add Client To CDN:
  module.run:
    - name: addTenant.addCustomerToCDN
    - connect: {{ base.connect }}
    - fqdn: {{ salt['pillar.get']('FQDN') }}
    - environment: {{  salt['pillar.get']('environment') }}
    - datacenter: {{  salt['pillar.get']('datacenter') }}
    - cdnHostAddress: {{ hostAddress }}
    - cdnAcountName: {{ accountName }}
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10

