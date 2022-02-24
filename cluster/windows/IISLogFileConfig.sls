{% set trueClientIP = salt['cmd.shell']('C:\\Windows\\system32\\inetsrv\\appcmd.exe list config Sumtotal -section:system.applicationHost/sites | findstr True-Client-IP') %}

{% set cdnIP = salt['cmd.shell']('C:\\Windows\\system32\\inetsrv\\appcmd.exe list config Sumtotal -section:system.applicationHost/sites | findstr CDN-IP') %}

{% set sumTotalSession = salt['cmd.shell']('C:\\Windows\\system32\\inetsrv\\appcmd.exe list config Sumtotal -section:system.applicationHost/sites | findstr SumTotalSession') %}

IIS Enable Logging:
  cmd.run:
    - name: appcmd.exe set config -section:system.applicationHost/sites /[name='Sumtotal'].logFile.enabled:"True" /commit:apphost
    - cwd: C:\Windows\system32\inetsrv

IIS Logging Format:
  cmd.run:
    - name: appcmd.exe set config -section:system.applicationHost/sites /[name='Sumtotal'].logFile.logFormat:"W3C" /commit:apphost
    - cwd: C:\Windows\system32\inetsrv

IIS Log Folder:
  cmd.run:
    - name: appcmd.exe set config -section:system.applicationHost/sites /[name='Sumtotal'].logFile.directory:"D:\LogFiles" /commit:apphost
    - cwd: C:\Windows\system32\inetsrv

{% if trueClientIP == '' %}
IIS TrueClientIP CustomField:
  cmd.run:
    - name: appcmd.exe set config -section:system.applicationHost/sites /+"[name='Sumtotal'].logFile.customFields.[logFieldName='True-Client-IP',sourceName='True-Client-IP',sourceType='RequestHeader']" 
    - cwd: C:\Windows\system32\inetsrv
{% endif %}

{% if cdnIP == '' %}
IIS CDN-IP CustomField:
  cmd.run:
    - name: appcmd.exe set config -section:system.applicationHost/sites /+"[name='Sumtotal'].logFile.customFields.[logFieldName='CDN-IP',sourceName='CDN-IP',sourceType='RequestHeader']" 
    - cwd: C:\Windows\system32\inetsrv
{% endif %}

{% if sumTotalSession == '' %}
IIS SumTotalSession CustomField:
  cmd.run:
    - name: appcmd.exe set config -section:system.applicationHost/sites /+"[name='Sumtotal'].logFile.customFields.[logFieldName='SumTotalSession',sourceName='SumTotalSession',sourceType='RequestHeader']" 
    - cwd: C:\Windows\system32\inetsrv
{% endif %}

IIS Logging Fields:
  cmd.run:
    - name: appcmd.exe set config /section:sites /[name='Sumtotal'].logFile.logExtFileFlags:"BytesRecv,BytesSent,ClientIP,ComputerName,Date,Host,HttpStatus,HttpSubStatus,Method,Referer,ServerIP,ServerPort,Time,TimeTaken,UriQuery,UriStem,UserAgent,UserName,Win32Status" /commit:apphost
    - cwd: C:\Windows\system32\inetsrv
