{% import "./Connectionvars.sls" as base %}

{% set cluster = pillar['clusterDict']["UFS"].split('-') %}

{% set isilonfoldername = [cluster[0],cluster[3],cluster[2][0],cluster[4][1:5]]| join('') %}

{% set shareinfo = salt['cmdb_lib3.getUDASHare'](base.connect,pillar['datacenter']) %}

{% set isilonUF2 = salt['cmdb_lib3.getConfigValueByKey'](base.connect,pillar['datacenter'],'UFSV2_ROOT_FOLDER')| replace('\\','\\\\') %}

{% set shareUF2 = salt['cmdb_lib3.getConfigValueByKey'](base.connect,pillar['datacenter'],'UFSV2_SHARE_LOCATION') | replace('\\','\\\\') %}

{% set utilserver = salt['cmdb_lib3.getdata'](base.connect,"VRO_UTILITY_SERVER",pillar['datacenter']) %}

{% set siteKey = salt['addTenant.getsiteKeyfromFQDN'](base.connect,pillar['FQDN']) %}


Create Share for Tenant {{ siteKey }}:
  salt.state:
    - sls:
      - AddTenant.createisilon
    - tgt: {{ utilserver }}
    - pillar:
        sitekey: "{{ siteKey }}"
        isilonShare: "{{ ((salt['cmdb_lib3.getUDASHare'](base.connect,pillar['datacenter']))[0][0] | replace('\\','\\\\'),isilonfoldername) | join('\\\\') }}"
        udaShare: "{{ ((salt['cmdb_lib3.getUDASHare'](base.connect,pillar['datacenter']))[0][1] | replace('\\','\\\\'),pillar['environment'],siteKey) | join('\\\\') }}"
        isilonuf2: "{{ (isilonUF2,isilonfoldername)| join('\\\\')}}"
        shareuf2: "{{ (shareUF2,pillar['environment'],siteKey) | join('\\\\') }}"


