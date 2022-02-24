{% import "./Connectionvars.sls" as base %}

{% set clientname = (pillar['FQDN'].split('.')[0])|lower %}


{% if pillar['environment'] != 'PROD' %}

{% set clientname = [clientname,pillar['environment']|lower]|join('.') %}
{% set zonename = [pillar['FQDN'].split('.')[2],pillar['FQDN'].split('.')[3]]|join('.') %}

{% else %}

{% set zonename = [pillar['FQDN'].split('.')[1],pillar['FQDN'].split('.')[2]]|join('.') %}

{% endif %}

{% if pillar['datacenter'] in ('LDC','GSL') %}
{% set dnsip = salt['cmdb_lib3.getDNS'](base.connect,pillar['datacenter']) %}
{% else %}
{% set dnsip = salt['cmdb_lib3.getDNS'](base.connect,'CMH') %}
{% endif %}

{% set publicCSName = (salt['cmdb_lib3.getpublicCSName'](base.connect,pillar['datacenter'],pillar['environment']).split('_')[1],'.')|join('') %}


Add Client DNS Record:
  ddns.present:
    - name: "{{ clientname }}"
    - zone: "{{ zonename }}"
    - ttl: 3600
    - data: "{{ publicCSName }}"
    - nameserver: "{{ dnsip }}"
    - rdtype: 'CNAME'
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10
