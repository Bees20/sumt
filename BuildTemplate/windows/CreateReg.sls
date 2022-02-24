{% set wsusserver = pillar['wsusserver'] %}

Remove SusClientidValidation:
  reg.key_absent:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SusClientIdValidation

Remove SusClientId:
  reg.key_absent:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SusClientId

TargetGroup:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate
    - vname: TargetGroup
    - vdata: WSUS
    - vtype: REG_SZ

TargetGroupEnabled:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate
    - vname: TargetGroupEnabled
    - vdata: 1
    - vtype: REG_DWORD

WUServer:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate
    - vname: WUServer
    - vdata: http://{{ wsusserver }}
    - vtype: REG_SZ

WUServerServer:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate
    - vname: WUServerStatus
    - vdata: http://{{ wsusserver }}
    - vtype: REG_SZ

WUServerSatus:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate
    - vname: WUStatusServer
    - vdata: http://{{ wsusserver }}
    - vtype: REG_SZ

AUOptions:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
    - vname: AUOptions
    - vdata: 2
    - vtype: REG_DWORD

AUPowerManagement:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
    - vname: AUPowerManagement
    - vdata: 1
    - vtype: REG_DWORD

AutoInstallMinorUpdates:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
    - vname: AutoInstallMinorUpdates
    - vdata: 1
    - vtype: REG_DWORD

DetectionFrequency:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
    - vname: DetectionFrequency
    - vdata: 1
    - vtype: REG_DWORD

DetectionFrequencyEnabled:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
    - vname: DetectionFrequencyEnabled
    - vdata: 1
    - vtype: REG_DWORD

EnableFeaturedSoftware:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
    - vname: EnableFeaturedSoftware
    - vdata: 1
    - vtype: REG_DWORD

NoAUAsDefaultShutdownOption:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
    - vname: NoAUAsDefaultShutdownOption
    - vdata: 1
    - vtype: REG_DWORD

NoAUShutdownOption:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
    - vname: NoAUShutdownOption
    - vdata: 1
    - vtype: REG_DWORD

NoAutoUpdate:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
    - vname: NoAutoUpdate
    - vdata: 0
    - vtype: REG_DWORD

RebootRelaunchTimeout:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
    - vname: RebootRelaunchTimeout
    - vdata: 10
    - vtype: REG_DWORD

RebootRelaunchTimeoutEnabled:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
    - vname: RebootRelaunchTimeoutEnabled
    - vdata: 1
    - vtype: REG_DWORD

RebootWarningTimeout:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
    - vname: RebootWarningTimeout
    - vdata: 10
    - vtype: REG_DWORD

RebootWarningTimeoutEnabled:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
    - vname: RebootWarningTimeoutEnabled
    - vdata: 1
    - vtype: REG_DWORD

ScheduledInstallDay:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
    - vname: ScheduledInstallDay
    - vdata: 4
    - vtype: REG_DWORD

ScheduledInstallTime:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
    - vname: ScheduledInstallTime
    - vdata: 22
    - vtype: REG_DWORD

UseWUServer:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
    - vname: UseWUServer
    - vdata: 1
    - vtype: REG_DWORD
{#
systemreboot:
  module.run:
    - name: system.reboot
    - timeout: 1
    - in_seconds: True
#}
