{% import "./Connectionvars.sls" as base %}

{% set siteKey = salt['addTenant.getsiteKeyfromFQDN'](base.connect,pillar['FQDN']) %}

Remove POD Reservation:
  module.run:
    - name: addTenant.removePODReservation
    - connect: {{ base.connect }}
    - siteKey: {{ siteKey }}
    - environment: {{  salt['pillar.get']('environment') }}
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10
