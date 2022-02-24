{% import "./vars.sls" as commonbase %}

{%
set zippath = salt['reg.read_value'](
    'HKEY_LOCAL_MACHINE',
    'Software\\7-Zip',
    'Path64').vdata
%}

Add 7zip Path to Environment Variables :
  win_path.exists:
    - name: {{ zippath }}

{% if commonbase.role == 'URW' %}

Download iso file:
  file.managed:
    - name: {{ commonbase.temp_folder }}\SSDT_14.0.61021.0_EN.iso
    - source: {{ commonbase.dict['ssdt14.0'] }}
    - skip_verify: True

Unzip iso file:
  cmd.run:
    - name: Set-Alias sz '{{ zippath }}7z.exe' ; sz x '{{ commonbase.temp_folder }}\SSDT_14.0.61021.0_EN.iso' -o'{{ commonbase.temp_folder }}\SSDT\' -y
    - shell: powershell
    - require:
      - file: Download iso file
      - win_path: Add 7zip Path to Environment Variables

Install ssdt Package:
  pkg.installed:
    - pkgs:
      - ssdt14.0
    - require:
      - cmd: Unzip iso file
    - refresh_db: True

{% endif %}

{% for regis in commonbase.EnableCiphersHashesKeyExchangeAlgorithms %}

{% set reg = 'HKLM\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\'~ regis ~'' %}

Enable {{reg}}:
  reg.present:
    - name: '{{reg}}'
    - vname: Enabled
    - vdata: 4294967295
    - vtype: REG_DWORD
{% endfor %}

{% for regis in commonbase.DisableCiphersHashesKeyExchangeAlgorithms %}

{% set reg = 'HKLM\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\'~ regis ~'' %}

Disable {{reg}}:
  reg.present:
    - name: '{{reg}}'
    - vname: Enabled
    - vdata: 0
    - vtype: REG_DWORD
{% endfor %}

{% for reg in commonbase.Disabled_protocols %}
Disable {{reg}} in server:
  reg.present:
    - name: HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\{{reg}}\Server
    - vname: Enabled
    - vdata: 0
    - vtype: REG_DWORD

Disable {{reg}} in client:
  reg.present:
    - name: HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\{{reg}}\Client
    - vname: Enabled
    - vdata: 0
    - vtype: REG_DWORD

EnableByDefault {{reg}} in server:
  reg.present:
    - name: HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\{{reg}}\Server
    - vname: DisabledByDefault 
    - vdata: 1
    - vtype: REG_DWORD

EnableByDefault {{reg}} in client:
  reg.present:
    - name: HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\{{reg}}\Client
    - vname: DisabledByDefault
    - vdata: 1
    - vtype: REG_DWORD
{% endfor %}

{#{% for reg in commonbase.Enabled_protocols %}#}
Enable {{commonbase.Enabled_protocols}} in server:
  reg.present:
    - name: HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\{{commonbase.Enabled_protocols}}\Server
    - vname: Enabled
    - vdata: 1
    - vtype: REG_DWORD

Enable {{commonbase.Enabled_protocols}} in client:
  reg.present:
    - name: HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\{{commonbase.Enabled_protocols}}\Client
    - vname: Enabled
    - vdata: 1
    - vtype: REG_DWORD

DisableByDefault {{commonbase.Enabled_protocols}} in server:
  reg.present:
    - name: HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\{{commonbase.Enabled_protocols}}\Server
    - vname: DisabledByDefault 
    - vdata: 0
    - vtype: REG_DWORD

DisableByDefault {{commonbase.Enabled_protocols}} in client:
  reg.present:
    - name: HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\{{commonbase.Enabled_protocols}}\Client
    - vname: DisabledByDefault
    - vdata: 0
    - vtype: REG_DWORD
{#{% endfor %}#}
