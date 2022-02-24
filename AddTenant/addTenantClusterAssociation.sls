{% import "./Connectionvars.sls" as base %}

Associate Clusters to CMDB for the Tenant:
  module.run:
    - name: addTenant.AddTenant_Association
    - connect: {{ base.connect }}
    - fqdn: {{ pillar['FQDN'] }}
    - AR: {{ pillar['AR'] }}
    - clusterDict: {{ dict(pillar['clusterDict']) | json }}
    - datacenter: {{ pillar['datacenter'] }}
    - environment: {{ pillar['environment'] }}
    - packageName: {{ pillar['packageName'] }}
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10
