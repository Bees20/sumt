# -*- coding: utf-8 -*-
'''
:Module to provide connectivity to the CMDB
:depends:   - FreeTDS
            - pymssql Python module
'''

# Import python libs
from __future__ import absolute_import, print_function, unicode_literals
from json import JSONEncoder, loads
from datetime import datetime

#import salt.ext.six as six
import sys
import logging
import uuid
import re
import subprocess
import platform
#import salt.utils.args
import threading
import time
import copy
import cmdb_orchTracking
import pmp_resource
import oriondb_IPAM
import SaltCommon
try:
    import pymssql
    HAS_ALL_IMPORTS = True
except ImportError:
    HAS_ALL_IMPORTS = False
    print('Import Failed')

log = logging.getLogger(__name__)

__virtualname__ = 'cmdb_lib3'

def __virtual__():
    '''
    Only load if import successful
    '''
    if HAS_ALL_IMPORTS:
        return __virtualname__
    else:
        return False, 'The cmdb_lib3 module cannot be loaded: dependent package(s) unavailable.'

def cleanupIPAddresses(connect):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.cleanupIPAddresses()

def cleanupIpamNodes(connect,datacenter):
    cleanupIpamClass = cmdb_orchTracking.SaltJob(connect)
    return cleanupIpamClass.cleanupIpamNodes(datacenter)

def tracking(CC,status,server):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    data = trackingClass.tracking(CC,status,server)
    return data

def groupInsert(SaltJobId,groupName,sequence):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    data = trackingClass.groupInsert(SaltJobId,groupName,sequence)
    return data

def VMtoGroupInsert(SaltJobId,vmGroupId,vmId):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    data = trackingClass.VMtoGroupInsert(SaltJobId,vmGroupId,vmId)
    return data

def insertVMStatus(SaltJobId,vmId,netscalerStatus,prometheusStatus):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    data = trackingClass.insertVMStatus(SaltJobId,vmId,netscalerStatus, prometheusStatus)
    return data

def updateVMnetscalerStatus(connect,netscalerStatus,vmId,SaltJobId):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    data = trackingClass.updateVMnetscalerStatus(netscalerStatus,vmId,SaltJobId)
    return data

def callOrchPath(version, role, action):
    p= packageInfo.packageInfo()
    data = p.getOrchPath(version, role, action)
    return data

def callSaltConfigKeys(connect,config_key, vm_tier):
    p= packageInfo.packageInfo()
    data = p.getSaltConfigKeys(config_key, vm_tier)
    return data

def SetStatus(connect,ServerIP,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.reserveIP(ServerIP,datacenter)

def getMemory(connect,version,role,podName=None):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getCPU_COUNT(version,role,podName)

def domain(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getDomain(datacenter)

def gateway(connect,Port_Group):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.defaultGateway(Port_Group)

def subnet_mask(connect,Port_Group):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.subnet_mask(Port_Group)

def getPassword(connect,source):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getpassword(source)

def getresource(connect,resource,account):
    pmpClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    return pmpClass.PMP_resource(resource,account)

def ipSublist(connect,clusterrole,datacenter,environment):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    data = trackingClass.ipSublist(clusterrole,datacenter,environment)
    return data

def getlb (connect,datacenter,environment):
    loadbalancer = cmdb_orchTracking.SaltJob(connect)
    lb = loadbalancer.getLoadBalancer(datacenter,environment)
    return lb

def dictinfo (connect,clustername,packagename):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    data = trackingClass.lbDict(clustername,packagename)
    return data

def isLoadBalanced(connect,fqdn,packagename,clusterrole):
    loadbalanced = cmdb_orchTracking.SaltJob(connect)
    islb = loadbalanced.isLoadBalanced(fqdn,packagename,clusterrole)
    return islb

def zoneForVIP(connect,datacenter,environment):
    getZone = cmdb_orchTracking.SaltJob(connect)
    zone = getZone.getDNSZoneForVip (datacenter,environment)
    return zone

def getDNS(connect,datacenter):
    dns = cmdb_orchTracking.SaltJob(connect)
    dns1 = dns.getPrimaryDNS (datacenter)
    return dns1

def getDatastore(connect,datacenter,environment,clusterrole,packagename,esxcluster):
    ds = cmdb_orchTracking.SaltJob(connect)
    return ds.Datastore(datacenter,environment,clusterrole,packagename,esxcluster)

def win_getDatastore(connect,datacenter,environment,clusterrole,packagename,esxcluster):
    ds = cmdb_orchTracking.SaltJob(connect)
    return ds.win_Datastore(datacenter,environment,clusterrole,packagename,esxcluster)

def getRTdatastore(connect,datacenter,environment,clusterrole,packagename,esxcluster):
    ds = cmdb_orchTracking.SaltJob(connect)
    return ds.RTdatastore(datacenter,environment,clusterrole,packagename,esxcluster)

def get_winDrive(connect,datacenter,environment,clusterrole,packagename,esxcluster):
    ds = cmdb_orchTracking.SaltJob(connect)
    return ds.get_winDrive(datacenter,environment,clusterrole,packagename,esxcluster)

def get_Drivemap(connect,datacenter,environment,clusterrole,packagename,esxcluster):
    ds = cmdb_orchTracking.SaltJob(connect)
    return ds.get_Drivemap(datacenter,environment,clusterrole,packagename,esxcluster)

def AddorUpdateServer(connect,Vmname,clusterrole,packagename,patch,workflowname,Status):
    ds = cmdb_orchTracking.SaltJob(connect)
    updatevm = ds.AddorUpdateServerVersion (Vmname,clusterrole,packagename,patch,workflowname,Status)
    return updatevm

def prometheusvm(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    data = trackingClass.getPrometheusserver(datacenter)
    return data

def addClusterinfo(connect,clusterName,associateClusterName,isDedicated,isValidated,podClusterCode,udaPackage):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    data = trackingClass.addNewClusterinfo(clusterName,associateClusterName,isDedicated,isValidated,podClusterCode,udaPackage)
    return data

def getSaltMasters(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getSaltMasters(datacenter)

def getSaltClusterID(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getSaltClusterID(datacenter)

def buildServerlist(connect,ClusterName,numOfServers,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getservername(ClusterName,numOfServers,datacenter)

def getIP(connect,networkname,datacenter,numOfServers,**args):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.FindIp(networkname,datacenter,numOfServers,**args)

def getNameservers(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.Nameservers(datacenter)

def ClusterServerExists(connect,ClusterName):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.checkServerExists(ClusterName)

def getesxClusterName(connect,datacenter,environment,clusterrole):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.esxClusterName(datacenter,environment,clusterrole)

def getDatastore(connect,datacenter,environment,clusterrole,packagename,esxcluster):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.Datastore(datacenter,environment,clusterrole,packagename,esxcluster)

def addVMinfo(connect,vmName,vmIP,uuid,os,clusterrole,Environment,ClusterName,fqdn):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.UUID(vmName,vmIP,uuid,os,clusterrole,Environment,ClusterName,fqdn)

def addPMPResource(connect,account,passwd,resource,RESOURCETYPE):
    trackingClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    return trackingClass.add_resource(account,passwd,resource,RESOURCETYPE)

def getClusterServerList(connect,ClusterName):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getServers(ClusterName)

def getDVS_switch(connect,Port_Group):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getDVS_switch(Port_Group)

def getClusterServerIP(connect,ClusterName):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getcmdb_clusterVmIps(ClusterName)

def GetSplunk(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.Splunk(datacenter)

def DCC_CONFIGKEYS(connect,ClusterName):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.DCC_CONFIGKEYS(ClusterName)

def SCC_CONFIGKEYS(connect,ClusterName):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.SCC_CONFIGKEYS(ClusterName)

def HAM_CONFIGKEYS(connect,ClusterName):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.HAM_CONFIGKEYS(ClusterName)

def UKA_CONFIGKEYS(connect,ClusterName):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.UKA_CONFIGKEYS(ClusterName)

def CSD_CONFIGKEYS(connect,ClusterName):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.CSD_CONFIGKEYS(ClusterName)

def UEC_CONFIGKEYS(connect,ClusterName):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.UEC_CONFIGKEYS(ClusterName)

def UXD_CONFIGKEYS(connect,ClusterName):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.UXD_CONFIGKEYS(ClusterName)

def UMD_CONFIGKEYS(connect,ClusterName):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.UMD_CONFIGKEYS(ClusterName)

def UWD_CONFIGKEYS(connect,ClusterName,packagename):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.UWD_CONFIGKEYS(ClusterName,packagename)

def URW_CONFIGKEYS(connect,ClusterName,packagename):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.URW_CONFIGKEYS(ClusterName,packagename)

def USA_CONFIGKEYS(connect,ClusterName,packagename):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.USA_CONFIGKEYS(ClusterName,packagename)

def UGM_CONFIGKEYS(connect,ClusterName,packagename):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.UGM_CONFIGKEYS(ClusterName,packagename)

def UUW_CONFIGKEYS(connect,ClusterName,packagename):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.UUW_CONFIGKEYS(ClusterName,packagename)

def UTA_CONFIGKEYS(connect,ClusterName,packagename):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.UTA_CONFIGKEYS(ClusterName,packagename)

def USM_CONFIGKEYS(connect,ClusterName,packagename):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.USM_CONFIGKEYS(ClusterName,packagename)

def UUD_CONFIGKEYS(connect,ClusterName,packagename):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.UUD_CONFIGKEYS(ClusterName,packagename)

def UTD_CONFIGKEYS(connect,ClusterName,packagename):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.UTD_CONFIGKEYS(ClusterName,packagename)

def URD_CONFIGKEYS(connect,ClusterName,packagename):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.URD_CONFIGKEYS(ClusterName,packagename)

def UDD_CONFIGKEYS(connect,ClusterName,packagename):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.UDD_CONFIGKEYS(ClusterName,packagename)

def getBenchmarkID(connect,version,vm_type,role_version):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getBenchmarkID(version,vm_type,role_version)

def getCheckID(connect,version,vm_type,role_version):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getCheckID(version,vm_type,role_version)

def getVariables(connect,version,vm_type,role_version):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getVariables(version,vm_type,role_version)

def get_syslog_server(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.SYSLOG_SERVER(datacenter)

def get_ntp_server(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.NTP_SERVER(datacenter)

def get_eset_config(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.ESET_CONFIG(datacenter)

def getRepoServer(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.repoServer(datacenter)

def getWsusServer(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.WsusServer(datacenter)

def getscomManagementServer(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.scomManagementServer(datacenter)

def getsplunkDeploymentServer(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.splunkDeploymentServer(datacenter)

def getsplunkWindowsInstaller(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.splunkWindowsInstaller(datacenter)

def getBaseTemplate(connect,datacenter,clusterrole,packageName):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getBaseTemplate(datacenter,clusterrole,packageName)

def getRoleTemplate(connect,datacenter,clusterrole,packageName):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getRoleTemplate(datacenter,clusterrole,packageName)

def getRoleversion(connect,packageName,clusterrole):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getRoleversion(packageName,clusterrole)

def getSubnet(connect,Port_Group):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getSubnet(Port_Group)

def getassociatedcluster(connect,cluster):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getassociatedcluster(cluster)

def getPackageLocation(connect,datacenter,package):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getPackageLocation(datacenter,package)

def get_install_params(connect,query,packageName,clusterrole,datacenter,sqlaccount,udacresource,saltaccount):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.get_install_params(query,packageName,clusterrole,datacenter,sqlaccount,udacresource,saltaccount)

def getVMdata(connect,cluster):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getVMdata(cluster)

def getVLAN(connect,ipaddress):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getVLAN(ipaddress)

def UpdateVMdata(connect,uuid,os,fqdn,vmName,ClusterName,PowerState):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.UpdateVMdata(uuid,os,fqdn,vmName,ClusterName,PowerState)

def get_assoclusterVmIps(connect,cluster):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.get_assoclusterVmIps(cluster)

def setlock(connect,lockname,maxage):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.setLock(lockname,maxage)

def deletelock(connect,lockname):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.deleteLock(lockname)

def getprerequisiteurls(connect,packagename,clusterrole,datacenter,sqladmin,saltaccount):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getprerequisiteurls(packagename,clusterrole,datacenter,sqladmin,saltaccount)

def insertRoleTemplate(connect,role,package,datacenter,templateName,templateDescription):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.insertRoleTemplate(role,package,datacenter,templateName,templateDescription)

def getRoleTemplateName(connect,datacenter,role,roleVersion,package):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getRoleTemplateName(datacenter,role,roleVersion,package)

def getRoleTemplateNamev1(connect,datacenter,roles,package):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getRoleTemplateNamev1(datacenter,roles,package)

def getConfigInfo(connect,ClusterName):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.get_ConfigInfo(ClusterName)

def islinux(connect,ClusterRole):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.isLinux(ClusterRole)

def getdata(connect,result,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getdata(result,datacenter)

def restartminion(host,user,password):
    status = SaltCommon.Restartsaltminion(host,user,password)
    return status

def getSmartHost(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getSmartHost(datacenter)

def getTimeZone(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getTimeZone(datacenter)

def getPackageShare(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getPackageShare(datacenter)

def getTenantShare(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getTenantShare(datacenter)

def getLBResourceName(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getLBResourceName(datacenter)

def getLBAccountName(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getLBAccountName(datacenter)

def getWindowsResourceName(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getWindowsResourceName(datacenter)

def getWindowsAccountName(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getWindowsAccountName(datacenter)

def getSvcAccountOU(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getSvcAccountOU(datacenter)

def getInstancevars(connect,packageName,clusterrole,datacenter,environment,domainuser,numOfServers,**args):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getInstancevars(packageName,clusterrole,datacenter,environment,domainuser,numOfServers,**args)

def getwindowsDB(connect,packageName):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getwindowsDB(packageName)

def getConfigValueByKey(connect,datacenter,key):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getConfigValueByKey(datacenter,key)

def getClientFqdnClustersbyFqdn(connect,fqdn):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getClientFqdnClustersbyFqdn(fqdn)

def getroleexecutionorder(connect):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getroleexecutionorder()

def getClusterbysiteKeyandRole(connect,sitekey,role):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getClusterbysiteKeyandRole(sitekey,role)

def getClientfqdnClusterbyFQDN(connect,fqdn):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getClientfqdnClusterbyFQDN(fqdn)

def getpublicCSName(connect,datacenter,environment):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getpublicCSName(datacenter,environment)

def getUDASHare(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getUDASHare(datacenter)

def getvdomandfirewall(connect,datacenter):
    trackingClass = cmdb_orchTracking.SaltJob(connect)
    return trackingClass.getvdomandfirewall(datacenter)
