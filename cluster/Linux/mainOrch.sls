Provision Template:
  salt.runner:
    - name: state.orch
    - mods: cluster/Linux/BuildTemplateOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Add Clusters to CMDB:
  salt.runner:
    - name: state.orch
    - mods: cluster/Linux/addClustertoCMDB
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Delete minion keys if exists:
  salt.runner:
    - name: state.orch
    - mods: cluster/Linux/DeleteKeyOrch
    - pillar: {{ dict(pillar) | json }}

Provision Cluster Servers:
  salt.runner:
    - name: state.orch
    - mods: cluster/Linux/ProvisionOrch1
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Add VM to CMDB:
  salt.runner:
    - name: state.orch
    - mods: cluster/Linux/addvmCMDBorch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Accept Cluster Server keys:
  salt.runner:
    - name: state.orch
    - mods: cluster/Linux/AcceptKeyOrch
    - pillar: {{ dict(pillar) | json }}

Create DNS record:
  salt.runner:
    - name: state.orch
    - mods: cluster/Linux/addDNSrecordOrch
    - pillar: {{ dict(pillar) | json }}

Join Domain:
  salt.runner:
    - name: state.orch
    - mods: cluster/Linux/DomainOrch2
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Set Admin Password:
  salt.runner:
    - name: state.orch
    - mods: cluster/Linux/ChangepasswdOrch3
    - pillar: {{ dict(pillar) | json }}

Create Service Account:
  salt.runner:
    - name: state.orch
    - mods: cluster/Linux/addResourceOrch4
    - pillar: {{ dict(pillar) | json }}

Configure NTP:
  salt.runner:
    - name: state.orch
    - mods: cluster/Linux/ConfigureNTPOrch5
    - pillar: {{ dict(pillar) | json }}

Configure Syslog:
  salt.runner:
    - name: state.orch
    - mods: cluster/Linux/ConfigureSysLogOrch
    - pillar: {{ dict(pillar) | json }}

Install ESET security:
  salt.runner:
    - name: state.orch
    - mods: cluster/Linux/installEsetOrch
    - pillar: {{ dict(pillar) | json }}

Install and Configure Splunk:
  salt.runner:
    - name: state.orch
    - mods: cluster/Linux/InstallSplunkOrch6
    - pillar: {{ dict(pillar) | json }}

Cluster LB Configuration:
  salt.runner:
    - name: state.orch
    - mods: cluster/Linux/clusterlbOrch
    - pillar: {{ dict(pillar) | json }}

Cluster Client LB Configuration:
  salt.runner:
    - name: state.orch
    - mods: cluster/Linux/clientlbOrch
    - pillar: {{ dict(pillar) | json }}

Add server to LoadBalancer:
  salt.runner:
    - name: state.orch
    - mods: cluster/Linux/addservertolbOrch
    - pillar: {{ dict(pillar) | json }}

Add Config Key to CMDB:
  salt.runner:
    - name: state.orch
    - mods: cluster/Linux/addConfigKeys
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Add servers to prometheus:
  salt.runner:
    - name: state.orch
    - mods: cluster/Linux/prometheusOrch
    - pillar: {{ dict(pillar) | json }}
{#
Add IP to WhiteList:
  salt.runner:
    - name: state.orch
    - mods: cluster/Common/AddIptoWhitelistOrch
    - pillar: {{ dict(pillar) | json }}
#}
Post Build Configuration:
  salt.runner:
    - name: state.orch
    - mods: cluster/Linux/ConfigureRole
    - pillar: {{ dict(pillar) | json }}

Remove IP from WhiteList:
  salt.runner:
    - name: state.orch
    - mods: cluster/Common/RemoveIpfromWhitelistOrch
    - pillar: {{ dict(pillar) | json }}
