{% import "./Connectionvars.sls" as base %}

{% set adminpasswd = salt['pillar.get']('adminpasswd') %}

{% set resource = salt['pillar.get']('server') %}

{% set user = salt['pillar.get']('user') %}

{% if grains['os'] == 'RedHat' or grains['os'] == 'Fedora' or grains['os'] == 'CentOS'%}

{% set RESOURCETYPE = 'Linux' %}

{% elif grains['os'] == 'Windows' %}

{% set RESOURCETYPE = 'Windows' %}

{% else %}

{% set RESOURCETYPE = 'Other' %}

{% endif %}


{#% set result = salt['cmdb_lib3.addPMPResource'](base.connect,user,adminpasswd,resource,RESOURCETYPE) %#}


Add pmp resource:
  module.run:
    - name: cmdb_lib3.addPMPResource
    - connect: {{ base.connect }}
    - account: {{ user }}
    - passwd: {{ adminpasswd }}
    - resource: {{ resource }}
    - RESOURCETYPE: {{ RESOURCETYPE }}
