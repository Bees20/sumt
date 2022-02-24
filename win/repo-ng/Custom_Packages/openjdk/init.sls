openjdk:
  '11.0.9.11':
    full_name: 'AdoptOpenJDK JDK with Hotspot 11.0.9.11 (x64)'
    installer: http://LDCSALTREP001/21300/Prerequisites/OpenJDK11U-jdk_x64_windows_hotspot_11.0.9_11.msi
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/OpenJDK11U-jdk_x64_windows_hotspot_11.0.9_11.msi
    install_flags: ' INSTALLLEVEL=3 /quiet /norestart /L c:\saltlogs\OpenJDK.log'
    uninstall_flags: '/qn /norestart '
    msiexec: True
    locale: en_US
    reboot: False
