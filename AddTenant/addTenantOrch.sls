Validate Sitekey By FQDN:
  salt.runner:
    - name: state.orch
    - mods: AddTenant.validateFqdn
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Validate DB File:
  salt.runner:
    - name: state.orch
    - mods: AddTenant.validateBackupFileOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Delete Config Keys:
  salt.runner:
    - name: state.orch
    - mods: AddTenant.deleteConfigKeys
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Associate Cluster to CMDB for Tenant:
  salt.runner:
    - name: state.orch
    - mods: AddTenant.addTenantClusterAssociation
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Bind Client FQDN clusters:
  salt.runner:
    - name: state.orch
    - mods: AddTenant.bindClientfqdnCluster
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Add Client FQDN to DNS:
  salt.runner:
    - name: state.orch
    - mods: AddTenant.addclienttoDNS
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Create Isilon Share:
  salt.runner:
    - name: state.orch
    - mods: AddTenant.createIsilonShareOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Add CongigKeys to CMDB:
  salt.runner:
    - name: state.orch
    - mods: AddTenant.addConfigKeysToCMDB
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Add Role Tenant:
  salt.runner:
    - name: state.orch
    - mods: AddTenant.addRoleTenant
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Add Tenant Remove POD Reservation:
  salt.runner:
    - name: state.orch
    - mods: AddTenant.removePODReservation
    - pillar: {{ dict(pillar) | json }}

Add Client to CDN Orch:
  salt.runner:
    - name: state.orch
    - mods: AddTenant.addClientToCdn
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

{#
Add Tenant to Matomo:
  salt.runner:
    - name: state.orch
    - mods: AddTenant.matomoOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True
#}
