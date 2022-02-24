{% import "./Connectionvars.sls" as base %}

Validate SiteKey by FQDN:
  module.run:
    - name: addTenant.getsiteKeyfromFQDN
    - connect: {{ base.connect }}
    - fqdn: {{ pillar["FQDN"] }}
