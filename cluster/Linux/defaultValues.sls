{% import "./Connectionvars.sls" as base %}

{% set Nameservers = salt['cmdb_lib3.getNameservers'](base.connect,pillar['datacenter']) %}

{% set passwd = salt['cmdb_lib3.getresource'](base.connect,'vRATemplate',salt['pillar.get']('user')) %}

{% set baseTemplate = salt['cmdb_lib3.getRoleTemplate'](base.connect,pillar['datacenter'],pillar['clusterrole'],pillar['packageName']) %}

{% set Domain = salt['cmdb_lib3.domain'](base.connect,pillar['datacenter']) %}

{% set vmSize = salt['cmdb_lib3.getMemory'](base.connect,pillar['packageName'],pillar['clusterrole'],pillar['podName']) %}

{% set esxCluster = salt['cmdb_lib3.getesxClusterName'](base.connect,pillar['datacenter'],pillar['environment'],pillar['clusterrole']) %}

{% set Datastore = salt['cmdb_lib3.getDatastore'](base.connect,pillar['datacenter'],pillar['environment'],pillar['clusterrole'],pillar['packageName'],esxCluster) %}

{% set domainpasswd = salt['cmdb_lib3.getresource'](base.connect,salt['pillar.get']('domainuser'),salt['pillar.get']('domainuser')) %}

{% set repoServer = salt['cmdb_lib3.getRepoServer'](base.connect,salt['pillar.get']('datacenter')) %}

{% set SaltMasters = salt['cmdb_lib3.getSaltMasters'](base.connect,pillar['datacenter']) %}
