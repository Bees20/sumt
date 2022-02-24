Delete BuildTemplate Server keys:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/windows/DeleteKeyOrch
    - pillar: {{ dict(pillar) | json }}

Provision BuildTemplate Servers:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/windows/Template
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Restart Salt Minion:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/windows/RestartMinionOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Accept BuildTemplate Server keys:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/windows/AcceptKeyOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Set TimeZone:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/windows/SetTimeZone
    - pillar: {{ dict(pillar) | json }}

Modify Minion Config:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/windows/modifyConf
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Join Domain:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/windows/DomainOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Patching:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/windows/PatchingOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

DiskMap:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/windows/DiskmapOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Install Sysmon:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/windows/InstallSysmonOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Install WmiExporter:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/windows/InstallWMIOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Apply Secops Policies:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/windows/SecopsOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Install Role Prerequisites:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/windows/InstallRoleOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Configre DB Role Template:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/windows/PostDbBuildOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Remove insecure windows permission:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/windows/WindowsPermissionOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Unjoin from Domain:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/windows/UnjoinDomainOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Uninstall salt:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/windows/RemoveMinionOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Convert vm to Template:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/windows/ConvertToTemplateOrch
    - pillar: {{ dict(pillar) | json }}
    - failhard: True

Insert Role Template to CMDB:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/windows/InsertTemplateOrch
    - pillar: {{ dict(pillar) | json }}
