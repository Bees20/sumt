{% import "./Connectionvars.sls" as base %}


{% set siteKey = salt['addTenant.getsiteKeyfromFQDN'](base.connect,pillar['FQDN']) %}

{% set uuwserver = salt['addTenant.getcmdb_clusterFirstvm'](base.connect,pillar['clusterDict']['UUW']) %}

{% set CMDB_Password = salt['cmdb_lib3.getresource'](base.connect,salt['pillar.get']('udacresource').split('.')[0],base.connect['CMDB_user']) %}

{% set Domain = salt['cmdb_lib3.domain'](base.connect,salt['pillar.get']('datacenter')) %}

{#% set cmdb_Server = base.connect['CMDB_server'] + "." + Domain %#}

Add  Tenant {{ siteKey }} to Matomo:
  salt.state:
    - sls:
      - AddTenant.matomoOrch
    - tgt: {{ uuwserver }}
    - pillar:
        tenantList: "{{ siteKey }}"
        cmdbServer: "{{ salt['pillar.get']('udacresource') }}"
        cmdbDBName: "{{ base.connect['CMDB_DB_Name'] }}"
        cmdbAdminUser: "{{ base.connect['CMDB_user'] }}"
        cmdbAminPassword: "{{ CMDB_Password }}"
        vmtierCode: {{ salt['pillar.get']('environment') }}
        packageName: {{ salt['pillar.get']('packageName') }}
