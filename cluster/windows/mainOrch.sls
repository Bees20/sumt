Provision Template:
  salt.runner:
    - name: state.orch
    - mods: cluster/windows/BuildTemplateOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Add Clusters to CMDB:
  salt.runner:
    - name: state.orch
    - mods: cluster/windows/addClustertoCMDB
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Delete minion keys if exists:
  salt.runner:
    - name: state.orch
    - mods: cluster/windows/DeleteKeyOrch
    - pillar: {{ dict(pillar) | json }}

Provision Cluster Servers:
  salt.runner:
    - name: state.orch
    - mods: cluster/windows/ProvisionOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Restart Salt Minion:
  salt.runner:
    - name: state.orch
    - mods: cluster/windows/RestartminionOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Add VM to CMDB:
  salt.runner:
    - name: state.orch
    - mods: cluster/windows/addvmCMDBorch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Accept Cluster Server keys:
  salt.runner:
    - name: state.orch
    - mods: cluster/windows/AcceptKeyOrch
    - pillar: {{ dict(pillar) | json }}

Modify Minion Config:
  salt.runner:
    - name: state.orch
    - mods: cluster/windows/modifyConf
    - pillar: {{ dict(pillar) | json }}

Set the Timezone:
  salt.runner:
    - name: state.orch
    - mods: cluster/windows/SetTimezoneOrch
    - pillar: {{ dict(pillar) | json }}

Create DNS record:
  salt.runner:
    - name: state.orch
    - mods: cluster/windows/addDNSrecordOrch
    - pillar: {{ dict(pillar) | json }}

Join Domain:
  salt.runner:
    - name: state.orch
    - mods: cluster/windows/DomainOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Install and Configure Splunk:
  salt.runner:
    - name: state.orch
    - mods: cluster/windows/InstallSplunkOrch
    - pillar: {{ dict(pillar) | json }}

Install and Configure Scom:
  salt.runner:
    - name: state.orch
    - mods: cluster/windows/InstallScomOrch
    - pillar: {{ dict(pillar) | json }}

Install ESET:
  salt.runner:
    - name: state.orch
    - mods: cluster/windows/InstallEsetOrch
    - pillar: {{ dict(pillar) | json }}

Add servers to prometheus:
  salt.runner:
    - name: state.orch
    - mods: cluster/Common/prometheusOrch
    - pillar: {{ dict(pillar) | json }}

Symlink Creation:
  salt.runner:
    - name: state.orch
    - mods: cluster/windows/SymlinkOrch
    - pillar: {{ dict(pillar) | json }}

Cluster LB Configuration:
  salt.runner:
    - name: state.orch
    - mods: cluster/Common/lb/clusterlbOrch
    - pillar: {{ dict(pillar) | json }}

Cluster Client LB Configuration:
  salt.runner:
    - name: state.orch
    - mods: cluster/Common/lb/clientlbOrch
    - pillar: {{ dict(pillar) | json }}

Add server to LoadBalancer:
  salt.runner:
    - name: state.orch
    - mods: cluster/Common/lb/addservertolbOrch
    - pillar: {{ dict(pillar) | json }}

Add Config Key to CMDB:
  salt.runner:
    - name: state.orch
    - mods: cluster/windows/addConfigKeys
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Create User in Active Directory:
  salt.runner:
    - name: state.orch
    - mods: cluster/windows/AdduserOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Post Build Configuration:
  salt.runner:
    - name: state.orch
    - mods: cluster/windows/ConfigureRole
    - pillar: {{ dict(pillar) | json }}

Install UDA Roles:
  salt.runner:
    - name: state.orch
    - mods: cluster/windows/UDAConfigRole
    - pillar: {{ dict(pillar) | json }}

Configure IIS Log Settings:
  salt.runner:
    - name: state.orch
    - mods: cluster/windows/IISLogFileConfigOrch
    - pillar: {{ dict(pillar) | json }}

Smart Host Settings:
  salt.runner:
    - name: state.orch
    - mods: cluster/windows/SmartHostOrch
    - pillar: {{ dict(pillar) | json }}

