Delete Template Server keys:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/DeleteKeyOrch
    - pillar: {{ dict(pillar) | json }}

Provision RoleTemplate Servers:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/Template
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Accept RoleTemplate Server keys:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/AcceptKeyOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True
{#
Add IP to WhiteList:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Common/AddIptoWhitelistOrch
    - pillar: {{ dict(pillar) | json }}
#}
Validate Python version:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/validateOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Run Base Setup:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/baseTemplateSetupOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Update Patches:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/PatchingOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Install system packages:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/InstallutilsOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Configure Node Exporter:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/NodeExporterOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Grant Sudoers:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/SudoersOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Apply CIS Controls:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/SecopsOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

System Reboots:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/RebootMinionOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Re-apply CIS policies:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/RunAssessmentOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Configure system Services:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/setFirewallOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Install Role Prerequisites:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/InstallPrerequisitesOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Remove IP from WhiteList:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Common/RemoveIpfromWhitelistOrch
    - pillar: {{ dict(pillar) | json }}

Configure Role Exporter:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/roleExporterOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Unjoin from domain:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/LeaveDomainOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Remove Salt Configuration:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/RemoveMinionOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Convert VM to Template:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/ConverttoTemplateOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Insert Role Template into CMDB:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/InsertRoleTemplate
    - pillar: {{ dict(pillar) | json }}

