{#% set clientfqdns = [["URW","LDC-JS75WIN16-PROD-URW-C0233"],["UUW","LDC-21300232-PROD-UUW-C0603"]] %#}

{% import "./Connectionvars.sls" as base %}

{% set clientfqdns = salt['addTenant.getClientfqdnClusterbyFQDN'](base.connect,pillar['FQDN'])| replace('[[','') | replace(']]','') | replace('],[',':') %}
{% set lbaccount = salt['cmdb_lib3.getLBAccountName'](base.connect,pillar['datacenter']) %}
{% set lb = salt['cmdb_lib3.getlb'](base.connect,pillar['datacenter'],pillar['environment']) %}
{% set lbpassword = salt['cmdb_lib3.getresource'](base.connect,salt['cmdb_lib3.getLBResourceName'](base.connect,pillar['datacenter']),salt['cmdb_lib3.getLBAccountName'](base.connect,pillar['datacenter'])) %}

{#
{% for client in clientfqdns.split(':')%}
data {{ client }}:
  cmd.run:
    - name: echo "{{ (client.split(','))[1] }}"
{% endfor %}
#}

{% for client in clientfqdns.split(':')%}

{% set cluster = (client.split(','))[1] | replace('"','') | replace('-','_') %}

{% set patset = 'ps_'~ cluster ~'_fqdns' %}

bindcsvstopol {{ patset }}:
  module.run:
    - name: netscaler.nspolicypatset_bind
    - p_name: {{ patset }}
    - fqdn: {{ pillar['FQDN'] | lower() }}
    - connection_args: {
        netscaler_host: {{ lb }},
        netscaler_user: "{{ lbaccount }}",
        netscaler_pass: "{{ lbpassword }}",
        netscaler_useSSL: 'False'
      }

{% endfor %}
