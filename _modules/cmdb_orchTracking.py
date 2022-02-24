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
# from 192.cmdb_lib import Foo1

#import salt.ext.six as six
import sys
import logging
import uuid
#import salt.utils.args
import threading
import time
import re
import platform
import copy
import random
import string
import pmp_resource
import oriondb_IPAM
import subprocess
import dns.query
import dns.zone
from xml.dom import minidom
from ipaddress import IPv4Network
import netscaler


try:
    import pymssql
    HAS_ALL_IMPORTS = True
except ImportError:
    HAS_ALL_IMPORTS = False
    print('Import Failed')

log = logging.getLogger(__name__)

__virtualname__ = 'cmdb_orchTracking'

def __virtual__():
    '''
    Only load if import successful
    '''
    if HAS_ALL_IMPORTS:
        return __virtualname__
    else:
        return False, 'The cmdb_orchTracking module cannot be loaded: dependent package(s) unavailable.'

class SaltJob:

    def __init__(self,connect):
        self.PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
        CMDB_Passwd = self.PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
        self.conn = pymssql.connect(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
        self.cursor = self.conn.cursor()
	
    def tracking(self,CC,status,server):
        self.query= "INSERT INTO SALT_JOB(JID,CC,REQUESTED_BY,START_DATE,END_DATE,STATE,ENTITY) VALUES ('" + str(uuid.uuid1()) + "',%s,'installer',getDate(),NULL,%s,%s)"
        self.cursor.execute(self.query,((CC),(status),(server)))
        self.conn.commit()
        self.cursor.execute("SELECT MAX(ID) FROM SALT_JOB")
        row = self.cursor.fetchone()
        id = row[0] 
	#self.conn.close
        return id

    def groupInsert(self,SaltJobId,groupName,sequence):
        self.query= "INSERT INTO SALT_JOB_VM_GROUP(NAME,SALT_JOB_ID,SEQUENCE,START_TIME,END_TIME) VALUES (%s,%s,%s,getDate(),NULL)"
        self.cursor.execute(self.query,((groupName),(SaltJobId),(sequence)))
        self.conn.commit()
        self.cursor.execute("SELECT MAX(ID) FROM SALT_JOB_VM_GROUP")
        row = self.cursor.fetchone()
        id = row[0] 
	#self.conn.close
        return id

    def VMtoGroupInsert(self,SaltJobId,vmGroupId,vmId):
        self.cursor.execute("INSERT INTO SALT_JOB_TO_VM(SALT_JOB_ID,SALT_JOB_VM_GROUP_ID,VM_ID) VALUES (" + str(SaltJobId) + "," + str(vmGroupId) + "," + str(vmId) + ")")
        self.conn.commit()
        self.cursor.execute("SELECT MAX(ID) FROM SALT_JOB_TO_VM")
        row = self.cursor.fetchone()
        id = row[0] 
	#self.conn.close
        return id

    def insertVMStatus(self,SaltJobId,vmId,netscalerStatus,prometheusStatus):
        self.cursor.execute("INSERT INTO SALT_JOB_VM_STATE(SALT_JOB_ID,VM_ID, INITIAL_NETSCALER_STATE, CURRENT_NETSCALER_STATE, INITIAL_PROMETHEUS_STATE, CURRENT_PROMETHEUS_STATE) VALUES (" + str(SaltJobId) + "," + str(vmId) + ",'" + netscalerStatus + "','" + netscalerStatus + "','" + prometheusStatus + "','" + prometheusStatus + "')")
        self.conn.commit()
        self.cursor.execute("SELECT MAX(ID) FROM SALT_JOB_TO_VM")
        row = self.cursor.fetchone()
        id = row[0] 
	#self.conn.close
        return id
    def updateVMnetscalerStatus(self,netscalerStatus,vmId,SaltJobId):
        self.query= ("UPDATE SALT_JOB_VM_STATE SET CURRENT_NETSCALER_STATE=%s WHERE VM_ID=%s AND SALT_JOB_ID=%s")
        self.cursor.execute(self.query,((netscalerStatus),(vmId),(SaltJobId)))
        self.conn.commit()
        self.cursor.execute("SELECT MAX(ID) FROM SALT_JOB_VM_STATE")
        row = self.cursor.fetchone()
        id = row[0]
        #self.conn.close
        return id

#These are my functions
    def ipSublist(self,clusterrole,datacenter,environment,session=None):
        #subnetwork = []
        if (clusterrole == "VIP"):
          description = "VIP"
        elif (clusterrole[2] == "D"):
          description = "DB"
        else:
          description = "WEB"
        self.query= ("SELECT IP_S.SUBNET AS SUBNET,IP_S.DIST_PORT_GROUP AS PORTGRP FROM IP_SUBNET IP_S INNER JOIN IP_SUBNET_TO_VM_TIER IP_STVT ON IP_STVT.IP_SUBNET_ID=IP_S.ID INNER JOIN VM_TIER VMTI ON IP_STVT.VM_TIER_ID=VMTI.ID INNER JOIN DATACENTER D ON D.ID = IP_S.DATACENTER_ID WHERE IP_S.DESCRIPTION='" + str(description) + "' AND D.CODE='" + str(datacenter) + "' AND VMTI.CODE='" + str(environment) + "'")
        self.cursor.execute(self.query,((description),(datacenter),(environment)))
        networkname = self.cursor.fetchall()
        network = [i for i in networkname]
        if session:
          return network
        self.conn.close()
        return network


    def getpublicdomain (self,datacenter,environment):
        self.query = ("SELECT DOMAIN AS RESULT FROM CERTIFICATE C INNER JOIN VM_TIER VMTI ON VMTI.ID=C.VM_TIER_ID INNER JOIN DATACENTER D ON D.ID=C.DATACENTER_ID WHERE D.CODE = %s AND VMTI.CODE= %s");
        self.cursor.execute(self.query,(datacenter,environment))
        d = self.cursor.fetchone()
        return d[0]

    def getlbmaintainanceserver (self,datacenter,environment):
        self.query = ("SELECT LB.MAINTENANCE_SERVER AS RESULT FROM LOAD_BALANCE LB INNER JOIN DATACENTER D ON LB.DATACENTER_ID=D.ID INNER JOIN VM_TIER VMT ON VMT.ID= LB.VM_TIER_ID WHERE D.CODE=%s AND VMT.CODE=%s AND VMT.IS_UDA='TRUE'");
        self.cursor.execute(self.query,(datacenter,environment))
        lbmaintainanceserver = self.cursor.fetchone()
        return lbmaintainanceserver[0]

    def gethealthCheckResponse (self,clusterversion,clusterrole):
        self.query = ("SELECT PR.HEALTH_CHECK_RESPONSE AS RESULT FROM PACKAGE_ROLE PR INNER JOIN ROLE_VERSION RV ON PR.ROLE_VERSION_ID=RV.ID INNER JOIN VM_TYPE VMT ON PR.VM_TYPE_ID=VMT.ID AND RV.NAME=%s AND VMT.CODE=%s AND VMT.IS_UDA='TRUE'");
        self.cursor.execute(self.query,(clusterversion,clusterrole))
        healthcheckresponse = self.cursor.fetchone()
        return healthcheckresponse[0]

    def gethealthCheckRequest (self,clusterversion,clusterrole):
        self.query = ("SELECT PR.HEALTH_CHECK_URL AS RESULT FROM PACKAGE_ROLE PR INNER JOIN ROLE_VERSION RV ON PR.ROLE_VERSION_ID=RV.ID INNER JOIN VM_TYPE VMT ON PR.VM_TYPE_ID=VMT.ID AND RV.NAME=%s AND VMT.CODE=%s AND VMT.IS_UDA='TRUE'");
        self.cursor.execute(self.query,(clusterversion,clusterrole))
        healthcheckrequest = self.cursor.fetchone()
        return healthcheckrequest[0]

    def getPersistance (self,clusterversion,clusterrole):
        self.query = ("SELECT PR.PERSISTENCE_METHOD AS RESULT FROM PACKAGE_ROLE PR INNER JOIN ROLE_VERSION RV ON PR.ROLE_VERSION_ID=RV.ID INNER JOIN VM_TYPE VMT ON PR.VM_TYPE_ID=VMT.ID AND RV.NAME=%s AND VMT.CODE=%s AND VMT.IS_UDA='TRUE'");
        self.cursor.execute(self.query,(clusterversion,clusterrole))
        persistance = self.cursor.fetchone()
        return persistance[0]

    def getLbDistMethod (self,clusterversion,clusterrole):
        self.query = ("SELECT PR.LOAD_BALANCE_METHOD AS RESULT FROM PACKAGE_ROLE PR INNER JOIN ROLE_VERSION RV ON PR.ROLE_VERSION_ID=RV.ID INNER JOIN VM_TYPE VMT ON PR.VM_TYPE_ID=VMT.ID AND RV.NAME=%s AND VMT.CODE=%s AND VMT.IS_UDA='TRUE'");
        self.cursor.execute(self.query,(clusterversion,clusterrole))
        lbdistmethod = self.cursor.fetchone()
        return lbdistmethod[0]

    def getCertificate (self,datacenter,environment,domain):
        self.query = ("SELECT C.NAME AS RESULT FROM CERTIFICATE C INNER JOIN DATACENTER D ON C.DATACENTER_ID=D.ID INNER JOIN VM_TIER VMT ON C.VM_TIER_ID=VMT.ID WHERE D.CODE=%s AND VMT.CODE=%s AND VMT.IS_UDA='TRUE' AND C.DOMAIN=%s");
        self.cursor.execute(self.query,(datacenter,environment,domain))
        certificate = self.cursor.fetchone()
        return certificate[0]

    def getHttpsRedirect (self,datacenter,environment):
        self.query = ("SELECT LB.HTTPS_REDIRECT_POLICY AS RESULT FROM LOAD_BALANCE LB INNER JOIN DATACENTER D ON LB.DATACENTER_ID=D.ID INNER JOIN VM_TIER VMT ON VMT.ID= LB.VM_TIER_ID WHERE D.CODE=%s AND VMT.CODE=%s AND VMT.IS_UDA='TRUE'");
        self.cursor.execute(self.query,(datacenter,environment))
        httpsredirect = self.cursor.fetchone()
        return httpsredirect[0]

    def getLoadBalancer (self,datacenter,environment):
        self.query = ("SELECT LB.NAME AS RESULT FROM LOAD_BALANCE LB INNER JOIN DATACENTER D ON D.ID = LB.DATACENTER_ID INNER JOIN VM_TIER VMTI ON VMTI.ID = LB.VM_TIER_ID WHERE D.CODE = %s AND VMTI.CODE =%s AND VMTI.IS_UDA='TRUE'");
        self.cursor.execute(self.query,(datacenter,environment))
        loadbalancer = self.cursor.fetchone()
        return loadbalancer[0]

    def getHealthCheckMonitorType (self,clusterrole,clusterversion,packagename):
        self.query = ("SELECT PR.HEALTH_CHECK_MONITOR_TYPE AS RESULT FROM PACKAGE_ROLE PR INNER JOIN VM_TYPE VMTY ON VMTY.ID = PR.VM_TYPE_ID INNER JOIN ROLE_VERSION RV ON RV.ID = PR.ROLE_VERSION_ID INNER JOIN PACKAGE P On P.ID=PR.PACKAGE_ID WHERE VMTY.CODE = %s AND RV.NAME=%s AND P.NAME=%s and PR.HEALTH_CHECK_MONITOR_TYPE is not null")
        self.cursor.execute(self.query,(clusterrole,clusterversion,packagename))
        monitortype = self.cursor.fetchone()
        return monitortype[0]

    def getLbServerPort (self,packagename,clusterrole):
        self.query = ("SELECT PR.SERVER_PORT AS RESULT FROM PACKAGE_ROLE PR INNER JOIN PACKAGE P ON P.ID = PR.PACKAGE_ID INNER JOIN VM_TYPE VMTY ON VMTY.ID=PR.VM_TYPE_ID WHERE VMTY.IS_UDA='TRUE' AND PR.IS_PRIMARY='TRUE' AND P.NAME =%s AND VMTY.CODE=%s");
        self.cursor.execute(self.query,(packagename,clusterrole))
        lbserverport = self.cursor.fetchone()
        return lbserverport[0]

    def getpublicCSName (self,datacenter,environment):
        self.query = ("SELECT DCTVT.FQDN AS RESULT FROM DATACENTER_TO_VM_TIER DCTVT INNER JOIN VM_TIER VMTI ON VMTI.ID=DCTVT.VM_TIER_ID INNER JOIN DATACENTER D ON D.ID=DCTVT.DATACENTER_ID WHERE D.CODE = %s AND VMTI.CODE = %s");
        self.cursor.execute(self.query,(datacenter,environment))
        publiccsname = self.cursor.fetchone()
        return publiccsname[0]

    def isLoadBalanced (self,fqdn,packagename,clusterrole):
        if fqdn == 'ANY':
            self.query = ("SELECT PR.ID from PACKAGE_ROLE PR INNER JOIN PACKAGE P ON PR.PACKAGE_ID = P.ID INNER JOIN VM_TYPE VMTY ON PR.VM_TYPE_ID = VMTY.ID WHERE PR.IS_LOAD_BALANCED = 1 AND P.NAME = %s AND VMTY.CODE = %s");
            self.cursor.execute(self.query,(packagename,clusterrole))
        else:
            self.query = ("SELECT PR.ID from PACKAGE_ROLE PR INNER JOIN PACKAGE P ON PR.PACKAGE_ID = P.ID INNER JOIN VM_TYPE VMTY ON PR.VM_TYPE_ID = VMTY.ID WHERE PR.IS_LOAD_BALANCED = 1 AND PR.FQDN_TYPE = %s AND P.NAME = %s AND VMTY.CODE = %s");
            self.cursor.execute(self.query,(fqdn,packagename,clusterrole))
        loadbalanced = self.cursor.fetchone()
        logging.info("Cluster loadbalanced:: "+ str(loadbalanced))
        if loadbalanced:
            return loadbalanced[0]
        else:
            return None

    def getDNSZoneForVip (self,datacenter,environment):
        self.query = ("SELECT DOMAIN AS RESULT FROM CERTIFICATE C INNER JOIN VM_TIER VMTI ON VMTI.ID=C.VM_TIER_ID INNER JOIN DATACENTER D ON D.ID=C.DATACENTER_ID WHERE D.CODE = %s AND VMTI.CODE=%s");
        self.cursor.execute(self.query,(datacenter,environment))
        zone = self.cursor.fetchone()
        return zone[0]

    def getPrimaryDNS(self,datacenter):
        self.query = ("SELECT INTERNAL_DNS1 AS RESULT FROM DATACENTER D WHERE D.CODE = %s");
        self.cursor.execute(self.query,(datacenter))
        dns1 = self.cursor.fetchone()
        return dns1[0]

    def Datastore(self,datacenter,environment,clusterrole,packagename,esxcluster):
        self.query = ("SELECT DISTINCT DATASTORE FROM GET_DATASTORES_SALT(%s,%s,%s,%s,%s)");
        self.cursor.execute(self.query,(datacenter,environment,clusterrole,packagename,esxcluster))
        datastore = self.cursor.fetchone()
        return datastore[0]

    def win_Datastore(self,datacenter,environment,clusterrole,packagename,esxcluster):
        self.query = ("SELECT DISTINCT DATASTORE FROM GET_DATASTORES(%s,%s,%s,%s,%s)");
        self.cursor.execute(self.query,(datacenter,environment,clusterrole,packagename,esxcluster))
        datastore = self.cursor.fetchone()
        return datastore[0]

    def RTdatastore(self,datacenter,environment,clusterrole,packagename,esxcluster):
        self.query = ("SELECT DISTINCT DATASTORE FROM GET_DATASTORES_ROLE_TEMPLATE(%s,%s,%s,%s,%s)")
        self.cursor.execute(self.query,(datacenter,environment,clusterrole,packagename,esxcluster))
        datastore = self.cursor.fetchone()
        return datastore[0]
 

    def AddorUpdateServerVersion (self,Vmname,clusterrole,packagename,patch,workflowname,Status):
        self.query = ("Exec AddorUpdateServerVersion_v17_1 %s,%s,%s,%s,%s,%s");
        self.cursor.execute(self.query,(Vmname,clusterrole,packagename,patch,workflowname,Status))
        rowsaffected = self.cursor.fetchone()
        return rowsaffected

    def getDomain (self,datacenter,session=None):
        self.query = ("SELECT WINDOWS_DOMAIN AS RESULT FROM DATACENTER WHERE CODE = %s");
        self.cursor.execute(self.query,(datacenter))
        domain = self.cursor.fetchone()
        if session:
          return domain[0]
        self.conn.close()
        return domain[0]

    def getPrometheusserver (self,datacenter):
        self.query = ("SELECT PROMETHEUS_SERVER AS RESULT FROM DATACENTER WHERE CODE = %s");
        self.cursor.execute(self.query,(datacenter))
        prometheus = self.cursor.fetchone()
        return prometheus[0]

    def lbDict(self,clustername,packagename):
        clusterName = clustername.upper()
        d = clustername.split("-")
        datacenter = d[0]
        clusterversion = d[1]
        environment = d[2]
        clusterrole = d[3]
        psclustername = clusterName.replace("-","_")
        clusternum = str(d[4][1:5])
        patsetname = "ps_" + psclustername + "_fqdns"
        data = dict()
        data['datacenter'] = datacenter
        data['environment'] = environment
        data['clusterName'] = clusterName
        data['clusterVersion'] = clusterversion
        data['clusterRole'] = clusterrole
        data['packageName'] = packagename
        data['domain']= SaltJob.getpublicdomain(self,datacenter,environment)
        data['lbMaintainanceServer'] = SaltJob.getlbmaintainanceserver (self,datacenter,environment)
        data['psClusterName'] = psclustername
        data['patSetName'] = patsetname
        data['clusterNum'] = clusternum
        data['healthCheckResponse'] = SaltJob.gethealthCheckResponse (self,clusterversion,clusterrole)
        data['healthCheckRequest'] = SaltJob.gethealthCheckRequest (self,clusterversion,clusterrole)
        data['serverPort'] = SaltJob.getLbServerPort (self,packagename,clusterrole)
        data['LB'] = SaltJob.getLoadBalancer (self,datacenter,environment)
        data['persistence'] = SaltJob.getPersistance (self,clusterversion,clusterrole)
        data['loadDistMethod'] = SaltJob.getLbDistMethod (self,clusterversion,clusterrole)
        data['certificate'] = SaltJob.getCertificate (self,datacenter,environment,data["domain"])
        data['httpsRedirect'] = SaltJob.getHttpsRedirect (self,datacenter,environment)
        data['publicCsName'] = SaltJob.getpublicCSName (self,datacenter,environment)
        data['monitorType'] = SaltJob.getHealthCheckMonitorType (self,clusterrole,clusterversion,packagename)
        return data


####################################
########SECOPS FUNCTIONS############
    def getRoleversion(self,version,role,session=None):
        self.cursor.execute("SELECT RV.NAME AS ROLVEVERSION FROM PACKAGE P INNER JOIN PACKAGE_ROLE PR ON P.id = PR.PACKAGE_ID INNER JOIN VM_TYPE VT ON VT.id = PR.VM_TYPE_ID JOIN ROLE_VERSION RV ON RV.id = PR.ROLE_VERSION_ID WHERE P.NAME ='" + version + "' and VT.CODE ='" + role + "'")
        records = self.cursor.fetchone()
        if session:
          return records[0]
        self.conn.close()
        return records[0]


    def getBenchmarkID(self,version,vm_type,role_version):
        self.cursor.execute("SELECT distinct(sb.BENCHMARK_UUID) FROM SEC_APP_POLICY SAP inner join SEC_APP_POLICY_TO_BENCHMARK_CHECK SAPTBC on saptbc.SEC_APP_POLICY_ID=sap.id inner join SEC_BENCHMARK_TO_SEC_CHECK SBTSC on SBTSC.id=SAPTBC.SEC_BENCHMARK_TO_SEC_CHECK_ID inner join SEC_BENCHMARK sb on sb.id=sbtsc.SEC_BENCHMARK_ID inner join SEC_CHECK sc on sc.id=SBTSC.SEC_CHECK_ID left join SEC_VARIABLE_OVERRIDES svo on saptbc.ID=svo.SEC_APP_POLICY_TO_BENCHMARK_CHECK_ID left join SEC_VARIABLE_DEFS SVD on SC.ID=SVD.SEC_CHECK_ID inner join package p on p.id=sap.PACKAGE_ID inner join vm_type vmty on vmty.id=sap.VM_TYPE_ID inner join ROLE_VERSION rv on rv.id=sap.ROLE_VERSION_ID where p.name='" + version + "' AND VMTY.CODE='" + vm_type + "' AND RV.NAME='" + str(role_version) + "'")
        row = self.cursor.fetchone()
        self.conn.close()
        return row[0]

    def getCheckID(self,version,vm_type,role_version):
        self.cursor.execute("SELECT distinct(sc.CHECK_UUID) FROM SEC_APP_POLICY SAP inner join SEC_APP_POLICY_TO_BENCHMARK_CHECK SAPTBC on saptbc.SEC_APP_POLICY_ID=sap.id inner join SEC_BENCHMARK_TO_SEC_CHECK SBTSC on SBTSC.id=SAPTBC.SEC_BENCHMARK_TO_SEC_CHECK_ID inner join SEC_BENCHMARK sb on sb.id=sbtsc.SEC_BENCHMARK_ID inner join SEC_CHECK sc on sc.id=SBTSC.SEC_CHECK_ID left join SEC_VARIABLE_OVERRIDES svo on saptbc.ID=svo.SEC_APP_POLICY_TO_BENCHMARK_CHECK_ID left join SEC_VARIABLE_DEFS SVD on SC.ID=SVD.SEC_CHECK_ID inner join package p on p.id=sap.PACKAGE_ID inner join vm_type vmty on vmty.id=sap.VM_TYPE_ID inner join ROLE_VERSION rv on rv.id=sap.ROLE_VERSION_ID where p.name='" + version + "' AND VMTY.CODE='" + vm_type + "' AND RV.NAME='" + str(role_version) + "' AND saptbc.ISEXEMPTED=0")
        chk = self.cursor.fetchall()
        checks = []
        for row in chk:
            checks.append(row[0])
        self.conn.close()
        return checks

    def getVariables(self,version,vm_type,role_version):
        self.cursor.execute("SELECT sc.CHECK_UUID,svd.NAME as variable_name,coalesce(svo.OVERRIDE_VALUE,svd.VALUE) as variable_value FROM SEC_APP_POLICY SAP inner join SEC_APP_POLICY_TO_BENCHMARK_CHECK SAPTBC on saptbc.SEC_APP_POLICY_ID=sap.id inner join SEC_BENCHMARK_TO_SEC_CHECK SBTSC on SBTSC.id=SAPTBC.SEC_BENCHMARK_TO_SEC_CHECK_ID inner join SEC_BENCHMARK sb on sb.id=sbtsc.SEC_BENCHMARK_ID inner join SEC_CHECK sc on sc.id=SBTSC.SEC_CHECK_ID inner join SEC_VARIABLE_DEFS SVD on SC.ID=SVD.SEC_CHECK_ID left join SEC_VARIABLE_OVERRIDES svo on saptbc.ID=svo.SEC_APP_POLICY_TO_BENCHMARK_CHECK_ID inner join package p on p.id=sap.PACKAGE_ID inner join vm_type vmty on vmty.id=sap.VM_TYPE_ID inner join ROLE_VERSION rv on rv.id=sap.ROLE_VERSION_ID where p.name='" + version + "' AND VMTY.CODE='" + vm_type + "' AND RV.NAME='" + str(role_version) + "' AND saptbc.ISEXEMPTED=0")
        var = self.cursor.fetchall()
        variables=[]
        for row in var:
          var={
            "check_uuid":row[0],
            "name":row[1],
            "value":row[2]}
          variables.append(var)
        self.conn.close()
        return variables

    def getCPU_COUNT(self,version,role,podName=None,session=None):
        if podName:
           self.cursor.execute("select PR2PT.VM_MEMORY,PR2PT.VM_CPU_COUNT from PACKAGE P WITH (NOLOCK) inner join PACKAGE_ROLE PR WITH (NOLOCK) on PR.PACKAGE_ID = P.ID inner join vm_type vty WITH (NOLOCK) on vty.ID = PR.VM_TYPE_ID inner join ROLE_VERSION RV WITH (NOLOCK) on RV.id = PR.ROLE_VERSION_ID inner join PACKAGE_ROLE_TO_POD_TYPE PR2PT WITH (NOLOCK) on PR2PT.PACKAGE_ROLE_ID = PR.ID and PR2PT.POD_TYPE_ID = (select POD_TYPE_ID from POD WITH (NOLOCK) where [NAME] = '" + podName + "') where p.name = '" + version + "' and VTY.CODE = '" + role + "'")
           data = self.cursor.fetchone()
           if data:
             return data
        self.cursor.execute("SELECT RV.NAME AS ROLVEVERSION FROM PACKAGE P WITH (NOLOCK) INNER JOIN PACKAGE_ROLE PR WITH (NOLOCK) ON P.id = PR.PACKAGE_ID INNER JOIN VM_TYPE VT WITH (NOLOCK) ON VT.id = PR.VM_TYPE_ID JOIN ROLE_VERSION RV WITH (NOLOCK) ON RV.id = PR.ROLE_VERSION_ID WHERE P.NAME ='" + version + "' and VT.CODE ='" + role + "'")
        records = self.cursor.fetchone()
        RV = records[0]
        self.cursor.execute("SELECT PR.VM_MEMORY,PR.VM_CPU_COUNT FROM PACKAGE_ROLE PR WITH (NOLOCK) INNER JOIN VM_TYPE VMTY WITH (NOLOCK) ON VMTY.ID = PR.VM_TYPE_ID INNER JOIN ROLE_VERSION RV WITH (NOLOCK) ON RV.ID = PR.ROLE_VERSION_ID INNER JOIN PACKAGE P WITH (NOLOCK) On P.ID=PR.PACKAGE_ID WHERE VMTY.CODE ='" + role + "' AND RV.NAME='" + RV + "' AND P.NAME='" + version + "'")
        record = self.cursor.fetchone()
        Memory = record[0]
        CPU = record[1]
        if session:
          return Memory,CPU
        self.conn.close()
        return Memory,CPU

    def Nameservers(self,datacenter,session=None):
        self.cursor.execute("SELECT INTERNAL_DNS1,INTERNAL_DNS2 from DATACENTER where code ='" + datacenter + "'")
        data = self.cursor.fetchone()
        DNS1 = data[0]
        DNS2 = data[1]
        if session:
          return DNS1,DNS2  
        self.conn.close()
        return DNS1,DNS2

    def defaultGateway(self,networkname,session=None):
        self.cursor.execute("select DEFAULT_GATEWAY as RESULT from IP_SUBNET where DIST_PORT_GROUP ='" + networkname + "'")
        record = self.cursor.fetchone()
        if session:
          return record[0]
        self.conn.close()
        return record[0]

    def subnet_mask(self,networkname):
        self.cursor.execute("select SUBNET as RESULT from IP_SUBNET where DIST_PORT_GROUP ='" + networkname + "'")
        record = self.cursor.fetchone()
        data = IPv4Network(record[0].replace(" ", ""))
        self.conn.close()
        return data.netmask

    def getSaltMasters(self,datacenter,session=None):
        self.cursor.execute("select CKTD.VALUE AS RESULT from CONFIGURATION_KEY_TO_DATACENTER cktd inner join CONFIGURATION_KEY ck on ck.id = cktd.CONFIGURATION_KEY_ID inner join DATACENTER d on d.ID = cktd.DATACENTER_ID where d.CODE ='" + datacenter + "' and ck.[KEY] = 'CO_SALT_MASTERS'")
        data = self.cursor.fetchone()
        servers = data[0].split(",")
        if session:
          return servers
        self.conn.close()
        return servers

    def getSaltClusterID(self,datacenter):
        try:
            self.cursor.execute("select SALT_CLUSTER_ID from DATACENTER where code ='" + datacenter + "'")
            record = self.cursor.fetchone()
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return record[0]

    def getpassword(self,source):
        return data.get_PMP_pass(source)

    def getDVS_switch(self,Port_Group):
        try:
            self.cursor.execute("select DVS_SWITCH from IP_SUBNET where DIST_PORT_GROUP = '"+ Port_Group +"'")
            record = self.cursor.fetchone()
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return record[0]

    def Splunk(self,datacenter):
        try:
            self.cursor.execute("select CKTD.VALUE AS RESULT from CONFIGURATION_KEY_TO_DATACENTER cktd inner join CONFIGURATION_KEY ck on ck.id = cktd.CONFIGURATION_KEY_ID inner join DATACENTER d on d.ID = cktd.DATACENTER_ID where d.CODE ='" + datacenter + "' and ck.[KEY] = 'LINUX_SPLUNK_INSTALLER'")
            data = self.cursor.fetchone()
        except (Exception) as error:
            print(error)
            print("Cannot locate Splunk binaries for Environment :" + datacenter)
            raise
        finally:
            self.conn.close()
            return data[0]

    def getStreamCacheList(self,ClusterName):
        try:
            self.cursor.execute("SELECT CKAC.VALUE AS RESULT FROM CONFIGURATION_KEY_TO_APP_CLUSTER CKAC INNER JOIN CONFIGURATION_KEY CK ON CK.ID=CKAC.CONFIGURATION_KEY_ID INNER JOIN APP_CLUSTER AC2 ON AC2.ID = CKAC.APP_CLUSTER_ID INNER JOIN APP_CLUSTER AC ON AC.ASSOCIATE_APP_CLUSTER_ID = AC2.ID WHERE CK.[KEY] = 'STRMEMCACHESERVERLIST' AND AC.NAME = '" + clusterName + "'")
            record = self.cursor.fetchone()
            if record.length == 0:
              self.cursor.execute("SELECT CKAC.VALUE AS RESULT FROM CONFIGURATION_KEY_TO_APP_CLUSTER CKAC INNER JOIN CONFIGURATION_KEY CK ON CK.ID=CKAC.CONFIGURATION_KEY_ID INNER JOIN APP_CLUSTER AC3 on AC3.ID = CKAC.APP_CLUSTER_ID INNER JOIN APP_CLUSTER AC2 ON AC2.ASSOCIATE_APP_CLUSTER_ID = AC3.ID INNER JOIN APP_CLUSTER AC ON AC.ASSOCIATE_APP_CLUSTER_ID = AC2.ID WHERE CK.[KEY] ='STRMEMCACHESERVERLIST' AND AC.NAME = '" + ClusterName + "'")
            record = self.cursor.fetchone()
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return record[0]

    def VM_TIER(self,Environment,session=None):
        try:
            self.cursor.execute("SELECT [ID] FROM [VM_TIER] WHERE [CODE] ='" + Environment + "'")
            data = self.cursor.fetchone()
        except (Exception) as error:
            print(error)
            print("Cannot locate TIER_ID for Environment :" + Environment)
        finally:
            if session:
              return str(data[0])
            self.conn.close()
            return str(data[0])

    def TYPE_ID(self,Role,session=None):
        try:
            self.cursor.execute("SELECT [ID] FROM [VM_TYPE] WHERE [CODE] ='" + Role + "'")
            record = self.cursor.fetchone()
#            print(Role + " Role VM Type ID : " + str(data[0]))
        except (Exception) as error:
            print(error)
            print("Cannot locate TYPE_ID for role :" + Role)
        finally:
            if session:
              return str(record[0])
            self.conn.close()
            return str(record[0])

    def get_assocAppClusterId(self,associateClusterName,session=None):
        try:
            self.cursor.execute("SELECT ID AS RESULT FROM APP_CLUSTER WHERE NAME = '" + associateClusterName + "'")
            data = self.cursor.fetchone()
            return data[0]
        except (Exception) as error:
            raise Exception(error)
        finally:
            if not session:
              self.conn.close()

    def InsertVMname(self,vmName,vmIP,uuid,os,Role,Environment,fqdn,session=None):
        try:
            typeid = SaltJob.TYPE_ID(self,Role,session=True)
            vmTireid = SaltJob.VM_TIER(self,Environment,session=True)
            self.query = ("INSERT INTO VM(DNSNAME, IP, NAME, DESCRIPTION, UID, SERVER_ID, TYPE_ID, TIER_ID, OS, POWERSTATE, FIRST_UPDATED, LAST_UPDATED, FQDN) VALUES (%s,%s,%s,'Provisioned by Salt-Cloud',%s,'48',%s,%s,%s,'poweredOff',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,%s)")
            self.cursor.execute(self.query,(vmName,vmIP,vmName,uuid,str(typeid),str(vmTireid),os,fqdn))
            self.conn.commit()
            if self.cursor.rowcount == 0:
                raise Exception("No records were added to VM Table.  Please investigate")
            else:
                return True
        except (Exception) as error:
            raise Exception(error)
            self.conn.rollback()
        finally:
            if not session:
              self.conn.close()


    def validCluster(self,clusterName):
        try:
            self.query = ("SELECT NAME as RESULT from APP_CLUSTER where name = '" + clusterName + "'")
            self.cursor.execute(self.query)
            record = self.cursor.fetchall()
            if self.cursor.rowcount == 0:
                return True
            else:
                return False
        except Exception:
            raise

    def addNewClusterinfo(self,clusterName,associateClusterName,isDedicated,isValidated,podClusterCode,udaPackage):
        try:
            if SaltJob.validCluster(self,clusterName):
                clusterNameArray = clusterName.upper().split("-")
                datacenter = clusterNameArray[0]
                clusterVersion = clusterNameArray[1]
                environment = clusterNameArray[2]
                clusterRole = clusterNameArray[3]
                if associateClusterName == '':
                    assocAppClusterId = 'null'
                else:
                    assocAppClusterId = SaltJob.get_assocAppClusterId(self,associateClusterName,session=True)
                self.cursor.execute("INSERT INTO APP_CLUSTER(VM_TYPE_ID,VM_TIER_ID,NAME,ROLE_VERSION_ID,DATACENTER_ID,ASSOCIATE_APP_CLUSTER_ID,IS_DEDICATED,IQ_STATUS,PACKAGE_ID,POD_CLUSTER_CODE) " + "(SELECT VM_TYPE.ID,VM_TIER.ID,'" + clusterName + "',RV.ID,DC.ID," + str(assocAppClusterId) + "," + isDedicated + ",'" + isValidated + "',P.ID," + podClusterCode + " " + "FROM VM_TYPE, VM_TIER, ROLE_VERSION RV, DATACENTER DC, PACKAGE_ROLE PR, PACKAGE P  WHERE VM_TYPE.CODE = '" + clusterRole + "' AND VM_TIER.CODE = '" + environment + "' " + "AND RV.NAME = '" + clusterVersion + "' AND PR.VM_TYPE_ID = VM_TYPE.ID AND PR.ROLE_VERSION_ID = RV.ID AND DC.CODE = '" + datacenter + "' " + "AND PR.PACKAGE_ID = P.ID AND P.NAME = '" + udaPackage + "')")
                self.conn.commit()
                if self.cursor.rowcount == 0:
                    raise Exception("No records were added to APP_CLUSTER.  Please investigate")
                else:
                    return True
            else:
                log.debug("Found a existing record with clusterName :%s", clusterName)
                return True

        except (Exception) as error:
            raise Exception(error)
            self.conn.rollback()
        finally:
            self.conn.close()


    def AppClusterVMIDbyVMName(self,vmName,session=None):
        try:
            self.cursor.execute("select ACVM.VM_ID as RESULT from vm  INNER JOIN APP_CLUSTER_VM ACVM on ACVM.VM_ID = VM.ID WHERE VM.NAME ='" + vmName + "'")
            data = self.cursor.fetchall()
            if len(data) != 0:
                print(" App cluster VM ID : " + str(data[0]))
        except (Exception) as error:
            print(error)
            logger.error(error)
            raise
        finally:
            if session:
              return data
            self.conn.close()
            return data

    def vmNotAssociatedWithAppCluster(self,vmName,acvmID,session=None):
        try:
            self.cursor.execute("select ID as RESULT from vm  WHERE NAME = '" + vmName + "' and ID != '" + acvmID + "'")
            data = self.cursor.fetchall()
            vmIDs = []
            for row in data:
                vmIDs.append(row[0])
        except (Exception) as error:
            print(error)
            logger.error(error)
            raise
        finally:
            if session:
              return vmIDs
            self.conn.close()
            return vmIDs

    def FixVM(self,vmIDs,session=None):
        try:
            for vmID in vmIDs:
                self.cursor.execute("exec delete_vm " + vmID + " ")
                self.conn.commit()
                print(vmID + " VM ID has been fixed")
        except (Exception) as error:
            print(error)
            logger.error(error)
            raise
        finally:
            if session:
              return vmIDs
            self.conn.close()
            return vmIDs

    def InsertAppClusterVM(self,clusterName,uuid,session=None):
        try:
            self.query= ("INSERT INTO APP_CLUSTER_VM(APP_CLUSTER_ID,VM_ID) (SELECT AC.ID,VM.ID FROM APP_CLUSTER AC,VM VM WHERE AC.NAME=%s AND VM.[UID]=%s)")
            self.cursor.execute(self.query,(clusterName,uuid))
            self.conn.commit()
            if self.cursor.rowcount == 1:
                return True
            else:
                return False
        except (Exception) as error:
            raise Exception(error)
            self.conn.rollback()

    def UpdateExistingVM(self,vmName,vmIP,os,uuid,Role,Environment,fqdn,session=None):
        try:
            typeid = SaltJob.TYPE_ID(self,Role,session=True)
            vmTireid = SaltJob.VM_TIER(self,Environment,session=True)
            self.query= ("UPDATE VM SET DNSNAME=%s,IP=%s,NAME=%s,DESCRIPTION='updated Provisioned by Salt-Cloud',SERVER_ID='48',TYPE_ID=%s,TIER_ID=%s,OS=%s,POWERSTATE='poweredOn', LAST_UPDATED=CURRENT_TIMESTAMP, FQDN=%s WHERE UID=%s")
            self.cursor.execute(self.query,(vmName,vmIP,vmName,typeid,vmTireid,os,uuid,fqdn))
            self.conn.commit()
            return self.cursor.rowcount
        except (Exception) as error:
            print(error)
            raise
            self.conn.rollback()

    def checkVMexits(self,vmName,session=None):
        try:
            self.cursor.execute("SELECT VM.NAME AS RESULT FROM VM WHERE VM.NAME='" + vmName + "' AND VM.POWERSTATE != 'deleted'")
            data = self.cursor.fetchall()
        except (Exception) as error:
            raise Exception(error)
        finally:
            if session:
              return data
            self.conn.close()
            return data
           
    def UUID(self,vmName,vmIP,uuid,os,Role,Environment,ClusterName,fqdn):
        record = ''
        try:
            self.cursor.execute("SELECT id FROM VM WHERE UID ='" + str(uuid) + "'")
            if self.cursor.fetchall():
                SaltJob.UpdateExistingVM(self,vmName,vmIP,os,uuid,Role,Environment,fqdn,session=True)
                return SaltJob.InsertAppClusterVM(self,ClusterName,uuid,session=True)
            elif SaltJob.InsertVMname(self,vmName,vmIP,uuid,os,Role,Environment,fqdn,session=True):
                record = SaltJob.checkVMexits(self,vmName,session=True)
                if record:
                   if len(record) == 1:
                       return SaltJob.InsertAppClusterVM(self,ClusterName,uuid,session=True)
                   elif len(record) > 1:
                       acvmID = SaltJob.AppClusterVMIDbyVMName(self,vmName,session=True)
                       vmIDs = SaltJob.vmNotAssociatedWithAppCluster(self,vmName,acvmID,session=True)
                       return SaltJob.FixVM(self,vmIDs,session=True)
                else:
                    return False
            else:
                return False
        except (Exception) as error:
            raise Exception(error)

##########Networkfile

    def ipformat(self,Ip):
        regex = '''^(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(
            25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(
            25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(
            25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)$'''
        if(re.search(regex, Ip)):
            return True
        else:
            return False

    def ping_ip(self,current_ip_address):
        try:
            output = subprocess.check_output("ping -{} 1 {}".format('n' if platform.system().lower(
            ) == "windows" else 'c', current_ip_address), shell=True, universal_newlines=True)
            if 'unreachable' in output:
                return False
            else:
                print ('valid IP')
                return True
        except Exception:
            return False

    def isIpIn_cmdb(self,value,key):
        try:
            if key == 'Name':
                keyword = 'NAME'
            else:
                keyword = 'IP'
            self.query = ("SELECT NAME as RESULT from VM where POWERSTATE <> 'deleted' and "+ keyword +" = '" + value + "'")
            self.cursor.execute(self.query)
            record = self.cursor.fetchall()
            if self.cursor.rowcount == 0:
                return False
            else:
                return True
        except Exception as error:
            raise

    def FindIp(self,networkname,datacenter,numOfServers,**args):
        IpList = []
        try:
            config = SaltJob.OrionDB_CONFIG(self,datacenter,session=True)
            passwd = self.PMPClass.PMP_resource(config['SOLARWINDS_ORION_DB_NAME'],config['SOLARWINDS_ORION_USERNAME'])
            Orionclass =  oriondb_IPAM.oriondb(config,passwd)
            lbIPlist = netscaler.server_getall(**args)
            #zonedata = SaltJob.querydns(self,datacenter,'IP')
            for i in range(len(networkname)):
                subnet = networkname[i][0].split("/")[0]
                cidr = networkname[i][0].split("/")[1]
                data = Orionclass.IpList(subnet,cidr,session=True)
                if len(data) == 0:
                    print ("No Ips avaiilable for subnet")
                else:
                    for record in data:
                        IPNodeID = record[0]
                        ipaddress = record[1]
                        if SaltJob.ipformat(self,ipaddress):
                            if SaltJob.ping_ip(self,ipaddress):
                                print(ipaddress)
                                Orionclass.UpdateStatus(ipaddress,session=True)
                            elif SaltJob.isIpIn_cmdb(self,ipaddress,'IP'):
                                pass
                            elif ipaddress in lbIPlist:
                                Orionclass.UpdateStatus(ipaddress,session=True)
                            #elif ipaddress in zonedata:
                            #    pass
                            else:
                                log.info("IP validation success " + ipaddress)
                                Orionclass.UpdateStatus(ipaddress,session=True)
                                data = {'ipaddress':ipaddress,'Port_Group':networkname[i][1]}
                                IpList.append(data)
                                if len(IpList) == int(numOfServers):
                                    return IpList
                                    break
        except (Exception) as error:
            raise Exception(error)

    def reserveIP(self,ipaddress,datacenter):
        try:
            config = SaltJob.OrionDB_CONFIG(self,datacenter)
            passwd = self.PMPClass.PMP_resource(config['SOLARWINDS_ORION_DB_NAME'],config['SOLARWINDS_ORION_USERNAME'])
            Orionclass =  oriondb_IPAM.oriondb(config,passwd)
            return Orionclass.UpdateStatus(ipaddress)
        except (Exception) as error:
            raise Exception(error)

    def cleanupIpamNodes(self,datacenter):
        try:
            config = SaltJob.OrionDB_CONFIG(self,datacenter)
            passwd = self.PMPClass.PMP_resource(config['SOLARWINDS_ORION_DB_NAME'],config['SOLARWINDS_ORION_USERNAME'])
            Orionclass =  oriondb_IPAM.oriondb(config,passwd)
            return Orionclass.cleanupIpamNodes()
        except (Exception) as error:
            raise Exception(error)

    def getVLAN(self,ipaddress):
        try:
            #IP = ipaddress.split(".")
            #Subnet = IP[0]+"."+IP[1]+"."+IP[2]+"."+"%"
            self.cursor.execute("select OS from VM where IP = '"+ ipaddress +"' and POWERSTATE <> 'deleted'")
            record = self.cursor.fetchone()
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()
            return record[0]

    def UpdateVMdata(self,uuid,os,fqdn,vmName,ClusterName,PowerState):
        record = ''
        self.cursor.execute("SELECT ID FROM VM WHERE ID NOT IN (select V.ID from VM V inner join APP_CLUSTER_VM ACV on ACV.VM_ID = V.id inner join APP_CLUSTER AC on AC.id = ACV.APP_CLUSTER_ID where AC.name = '"+ ClusterName +"' ) AND NAME = '"+ vmName +"'")
        record = self.cursor.fetchone()
        if record:
            self.cursor.execute("exec delete_vm '" + str(record[0]) + "'")
        self.query = ("UPDATE VM SET [UID]  = %s, FQDN = %s, OS = %s, POWERSTATE = %s WHERE [NAME] = %s")
        self.cursor.execute(self.query,(uuid,fqdn,os,PowerState,vmName))
        self.conn.commit()
        if self.cursor.rowcount == 1:
            return True
        else:
            return False


    def checkServerExists(self,ClusterName):
        try:
            self.cursor.execute("SELECT V.NAME,V.IP FROM VM V INNER JOIN APP_CLUSTER_VM ACV on ACV.VM_ID = V.ID INNER JOIN APP_CLUSTER AC on AC.ID = ACV.APP_CLUSTER_ID WHERE AC.NAME = '"+ ClusterName +"' AND V.POWERSTATE = 'poweredOn'")
            record = self.cursor.fetchall()
            if len(record) == 0:
                return True
            else:
                return False
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()

    def querydns(self,datacenter,value):
        PrimaryDNS = SaltJob.getPrimaryDNS(self,datacenter)
        domain = SaltJob.getDomain(self,datacenter)
        zonefile = dns.zone.from_xfr(dns.query.xfr(PrimaryDNS, domain))
        names = zonefile.nodes.keys()
        nodelist = []
        if value == 'Name':
            array = '0'
        else:
            array = '4'
        for data in names:
            text = zonefile[data].to_text(data)
            validate = text.split(" ")[int(array)]
            nodelist.append(validate)
        return nodelist

    def getservername(self,ClusterName,numOfServers,datacenter):
        try:
            log.info("Getting servers list for cluster :" + ClusterName)
            serverlist = []
            ClusterName = ClusterName.split("-")
            self.cursor.execute("select SHORTCODE from VM_TIER where CODE = '"+ ClusterName[2] +"'")
            envCode = self.cursor.fetchone() 
            serverPrefix = ClusterName[0] + ClusterName[3] + envCode[0] + str(ClusterName[4][1:5]) + "N"
        #    zonedata = SaltJob.querydns(self,datacenter,'Name')
            i = 0
            while i < 99:
                i += 1
                serverformat = serverPrefix + '{:03d}'.format(i)
                time.sleep(3)
                if SaltJob.isIpIn_cmdb(self,serverformat,'Name'):
        #       if serverformat in zonedata:
                    continue
                else:
                    serverlist.append(serverformat)
                    log.info("Server name validation success " + serverformat)
                if len(serverlist) == int(numOfServers):
                    break
            return serverlist
        except (Exception) as error:
            raise Exception(error)


    def esxClusterName(self,datacenter,environment,clusterrole,session=None):
        self.query = ("SELECT DISTINCT C.NAME AS RESULT FROM APP_FUNCTION_TO_CLUSTER AFTC INNER JOIN APP_FUNCTION AF ON AF.ID=AFTC.APP_FUNCTION_ID INNER JOIN CLUSTER C ON C.ID=AFTC.CLUSTER_ID INNER JOIN VM_TIER VMTI ON VMTI.ID=AFTC.VM_TIER_ID INNER JOIN DATACENTER D ON D.ID=AFTC.DATACENTER_ID INNER JOIN VM_TYPE VMTY ON AFTC.VM_TIER_ID=VMTI.ID AND AF.ID=VMTY.APP_FUNCTION_ID WHERE D.CODE=%s AND VMTI.IS_UDA='TRUE' AND VMTI.CODE=%s AND VMTY.IS_UDA='TRUE' AND VMTY.CODE=%s")
        self.cursor.execute(self.query,(datacenter,environment,clusterrole))
        record = self.cursor.fetchone()
        if session:
          return record[0]
        self.conn.close()
        return record[0]


    def getServers(self,ClusterName,session=None):
        try:
            self.cursor.execute("SELECT V.NAME FROM VM V INNER JOIN APP_CLUSTER_VM ACV on ACV.VM_ID = V.ID INNER JOIN APP_CLUSTER AC on AC.ID = ACV.APP_CLUSTER_ID WHERE AC.NAME = '"+ ClusterName +"'") # AND V.POWERSTATE = 'poweredOn'")
            record = self.cursor.fetchall()
            servers = [i[0] for i in record]
#           ips = [i[1] for i in record]
            if session:
              return servers
            self.conn.close()
            return servers
        except (Exception) as error:
            raise Exception(error)

    def getcmdb_clusterVmIps(self,ClusterName,session=None):
        try:
            self.cursor.execute("select IP AS RESULT from VM inner join app_cluster_vm on app_cluster_vm.vm_id = vm.id inner join app_cluster on app_cluster.id = app_cluster_vm.APP_CLUSTER_ID where app_cluster.name = '" + ClusterName + "' ORDER BY vm.name")
            data = self.cursor.fetchall()
            VmIps = []
            for row in data:
                VmIps.append(row[0])
        except (Exception,StandardError) as error:
            raise Exception(error)
        finally:
            if session:
              return VmIps
            self.conn.close()
            return VmIps

    def get_assoclusterVmIps(self,ClusterName,session=None):
        try:
            result = ''
            iplist = SaltJob.getcmdb_clusterVmIps(self,ClusterName,session=True)
            for i in range(len(iplist)):
                if i > 0:
                    result = result + ',' + iplist[i]
                else:
                    result = iplist[i]         
        except (Exception,StandardError) as error:
            raise Exception(error)
        finally:
            if session:
              return result
            self.conn.close()
            return result

    def checkConfig(self,config_key,ClusterName,session=None):
        self.query= ("SELECT CONFIGURATION_KEY_ID,APP_CLUSTER_ID FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE CONFIGURATION_KEY_ID = (select CK.ID FROM CONFIGURATION_KEY CK WHERE CK.[KEY]=%s) and APP_CLUSTER_ID = (Select ID from APP_CLUSTER where name = %s)")
        self.cursor.execute(self.query,(config_key,ClusterName))
        record = self.cursor.fetchone()
        if self.cursor.rowcount == 0:
            return True
        else:
            return False

    def DCC_CONFIGKEYS(self,ClusterName):
        try:
            nodeList = ''
            pwToUse = ''
            iplist = SaltJob.getcmdb_clusterVmIps(self,ClusterName,session=True)
            dccPort = SaltJob.getConfigKey(self,"DCC_REDIS_PORT",session=True)
            ResourceName = ClusterName
            AccountName = "redis"
            pwToUse = ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(16))
            self.PMPClass.add_resource(AccountName,pwToUse,ResourceName,"Linux")
            AdminPwd = self.PMPClass.PMP_resource(ResourceName,AccountName)
            for i in range(len(iplist)):
                if i > 0:
                    nodeList = nodeList + ',' + iplist[i]
                else:
                    nodeList = iplist[i]
            cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"DCC_REDIS_PORT","CONFIGURATION_KEY_VALUE":dccPort}];
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"DCC_REDIS_NODES","CONFIGURATION_KEY_VALUE":nodeList});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"DCC_REDIS_PWD","CONFIGURATION_KEY_VALUE":AdminPwd});
            for i in range(len(cmdbAdditions)):
                if SaltJob.checkConfig(self,cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                    self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                    self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                    self.conn.commit()
                    if self.cursor.rowcount == 0:
                        raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                        return False
            return True 
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()


    def UXD_CONFIGKEYS(self,ClusterName):
        try:
            nodeList = ''
            vmList = SaltJob.getServers(self,ClusterName,session=True)
            details = self.PMPClass.get_PMP_details('UXDTemplate')
            dbAdmin = details['account']
            dbAdminPwd = self.PMPClass.get_PMP_pass('UXDTemplate')
            for i in range(len(vmList)):
                if i > 0:
                    nodeList = nodeList + ',' + vmList[i]
                else:
                    nodeList = vmList[i]
            cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"UXD_DB_SERVER","CONFIGURATION_KEY_VALUE":nodeList}]
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UXD_ADMIN_USER","CONFIGURATION_KEY_VALUE":dbAdmin})
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UXD_ADMIN_PASSWORD","CONFIGURATION_KEY_VALUE":dbAdminPwd});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UXD_DB_PORT","CONFIGURATION_KEY_VALUE":"3306"});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UXD_DB_INSTANCE","CONFIGURATION_KEY_VALUE":nodeList});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UXD_DB_TYPE","CONFIGURATION_KEY_VALUE":"MYSQL"})
            for i in range(len(cmdbAdditions)):
                if SaltJob.checkConfig(self,cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                    self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                    self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                    self.conn.commit()
                    if self.cursor.rowcount == 0:
                        raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                        return False
            return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()

    def UMD_CONFIGKEYS(self,ClusterName):
        try:
            nodeList = ''
            vmList = SaltJob.getServers(self,ClusterName,session=True)
            details = self.PMPClass.get_PMP_details('UMDTemplate')
            dbAdmin = details['account']
            dbAdminPwd = self.PMPClass.get_PMP_pass('UMDTemplate')
            for i in range(len(vmList)):
                if i > 0:
                    nodeList = nodeList + ',' + vmList[i]
                else:
                    nodeList = vmList[i]
            cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"UMD_DB_SERVER","CONFIGURATION_KEY_VALUE":nodeList}]
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UMD_ADMIN_USER","CONFIGURATION_KEY_VALUE":dbAdmin});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UMD_ADMIN_PASSWORD","CONFIGURATION_KEY_VALUE":dbAdminPwd});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UMD_DB_PORT","CONFIGURATION_KEY_VALUE":"27017"});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UMD_DB_INSTANCE","CONFIGURATION_KEY_VALUE":nodeList})
            for i in range(len(cmdbAdditions)):
                if SaltJob.checkConfig(self,cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                    self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                    self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                    self.conn.commit()
                    if self.cursor.rowcount == 0:
                        raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                        return False
            return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()


    def UKA_CONFIGKEYS(self,ClusterName):
        try:
            result = ''
            uebresult = ''
            pwToUse = ''
            uebpwToUse = ''
            iplist = SaltJob.getcmdb_clusterVmIps(self,ClusterName,session=True)
            kafkaport = SaltJob.getConfigKey(self,"UKA_PORT",session=True)
            uebport = "15672"
            for i in range(len(iplist)):
                if i > 0:
                    uebresult = uebresult + ',' + iplist[i]
                else:
                    uebresult = iplist[i]

            for i in range(len(iplist)):
                if i > 0:
                    result = result + ',' + iplist[i]+":"+kafkaport
                else:
                    result = iplist[i]+":"+kafkaport
            uebResourceName = ClusterName
            uebAccountName = "rabbitadmin"
            dbAdminResource = ClusterName
            dbAdminUser = "kafkaAppuser"
            pwToUse = ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(16))
            uebpwToUse = ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(16))
            self.PMPClass.add_resource(dbAdminUser,pwToUse,dbAdminResource,"Linux")
            self.PMPClass.add_resource(uebAccountName,uebpwToUse,uebResourceName,"Linux")
            dbAdminPwd = self.PMPClass.PMP_resource(dbAdminResource,dbAdminUser)
            uebAdminPwd = self.PMPClass.PMP_resource(uebResourceName,uebAccountName)
            cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"UKA_SERVER_NODES","CONFIGURATION_KEY_VALUE":result}];
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UKA_PORT","CONFIGURATION_KEY_VALUE":kafkaport});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UKA_APPLICATION_USER","CONFIGURATION_KEY_VALUE":dbAdminUser});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UKA_APPLICATION_PWD","CONFIGURATION_KEY_VALUE":None});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UEB_PORT","CONFIGURATION_KEY_VALUE":uebport});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UEB_SERVER_NODES","CONFIGURATION_KEY_VALUE":uebresult});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UEB_USER","CONFIGURATION_KEY_VALUE":uebAccountName});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UEB_PASSWORD","CONFIGURATION_KEY_VALUE":uebAdminPwd});
            for i in range(len(cmdbAdditions)):
                if SaltJob.checkConfig(self,cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                    self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                    self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                    self.conn.commit()
                    if self.cursor.rowcount == 0:
                        raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                        return False
            return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()


    def CSD_CONFIGKEYS(self,ClusterName):
        try:
            result = ''
            pwToUse = ''
            iplist = SaltJob.getcmdb_clusterVmIps(self,ClusterName,session=True)
            csdport = SaltJob.getConfigKey(self,"CSD_PORT",session=True)
            for i in range(len(iplist)):
                if i > 0:
                    result = result + ',' + iplist[i]
                else:
                    result = iplist[i]
            dbAdminResource = ClusterName
            dbAdminUser = "csdadminuser"
            pwToUse = ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(16))
            self.PMPClass.add_resource(dbAdminUser,pwToUse,dbAdminResource,"Linux")
            dbAdminPwd = self.PMPClass.PMP_resource(dbAdminResource,dbAdminUser)
            cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"CSD_SERVER_NODES","CONFIGURATION_KEY_VALUE":result}];
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"CSD_PORT","CONFIGURATION_KEY_VALUE":csdport});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"CSD_DB_ADMIN_PWD","CONFIGURATION_KEY_VALUE":dbAdminPwd});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"CSD_DB_ADMIN_USER ","CONFIGURATION_KEY_VALUE":dbAdminUser});
            for i in range(len(cmdbAdditions)):
                if SaltJob.checkConfig(self,cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                    self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                    self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                    self.conn.commit()
                    if self.cursor.rowcount == 0:
                        raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                        return False
            return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()


    def UEC_CONFIGKEYS(self,ClusterName):
        try:
            pwToUse = ''
            dbAdminResource = ClusterName
            dbAdminUser = "uecAdminUser"
            pwToUse = ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(16))
            self.PMPClass.add_resource(dbAdminUser,pwToUse,dbAdminResource,"Linux")
            dbAdminPwd = self.PMPClass.PMP_resource(dbAdminResource,dbAdminUser)
            cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"UEC_ADMIN_USER","CONFIGURATION_KEY_VALUE":dbAdminUser}];
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UEC_ADMIN_PWD","CONFIGURATION_KEY_VALUE":dbAdminPwd});
            for i in range(len(cmdbAdditions)):
                if SaltJob.checkConfig(self,cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                    self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                    self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                    self.conn.commit()
                    if self.cursor.rowcount == 0:
                        raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                        return False
            return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()



    def SCC_CONFIGKEYS(self,ClusterName):
        try:
            nodeList = ''
            pwToUse = ''
            iplist = SaltJob.getcmdb_clusterVmIps(self,ClusterName,session=True)
            sccPort = SaltJob.getConfigKey(self,"SCC_REDIS_PORT",session=True)
            ResourceName = ClusterName
            AccountName = "redis"
            pwToUse = ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(16))
            self.PMPClass.add_resource(AccountName,pwToUse,ResourceName,"Linux")
            AdminPwd = self.PMPClass.PMP_resource(ResourceName,AccountName)
            for i in range(len(iplist)):
                if i > 0:
                    nodeList = nodeList + ',' + iplist[i]
                else:
                    nodeList = iplist[i]
            cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"SCC_REDIS_PORT","CONFIGURATION_KEY_VALUE":sccPort}];
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"SCC_REDIS_NODES","CONFIGURATION_KEY_VALUE":nodeList});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"SCC_REDIS_PWD","CONFIGURATION_KEY_VALUE":AdminPwd});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"SESSION_REPO_TYPE","CONFIGURATION_KEY_VALUE":AccountName});
            for i in range(len(cmdbAdditions)):
                if SaltJob.checkConfig(self,cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                    self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                    self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                    self.conn.commit()
                    if self.cursor.rowcount == 0:
                        raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                        return False
            return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()


    def HAM_CONFIGKEYS(self,ClusterName):
        try:
            nodeList = ''
            pwToUse = ''
            iplist = SaltJob.getcmdb_clusterVmIps(self,ClusterName,session=True)
            hamSccPort = SaltJob.getConfigKey(self,"HAM_SCC_SENTINEL_PORT",session=True)
            hamDccPort = SaltJob.getConfigKey(self,"HAM_DCC_SENTINEL_PORT",session=True)
            for i in range(len(iplist)):
                if i > 0:
                    nodeList = nodeList + ',' + iplist[i]
                else:
                    nodeList = iplist[i]
            cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"HAM_SCC_SENTINEL_PORT","CONFIGURATION_KEY_VALUE":hamSccPort}];
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"HAM_DCC_SENTINEL_PORT","CONFIGURATION_KEY_VALUE":hamDccPort});
            cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"HAM_SERVER_NODES","CONFIGURATION_KEY_VALUE":nodeList});
            for i in range(len(cmdbAdditions)):
                if SaltJob.checkConfig(self,cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                    self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                    self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                    self.conn.commit()
                    if self.cursor.rowcount == 0:
                        raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                        return False
            return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()

    def getclusterVM_first(self,clusterName,session=None):
        try:
            self.query = ("SELECT Top 1 DNSNAME AS RESULT FROM VM INNER JOIN APP_CLUSTER_VM ACVM ON ACVM.VM_ID = VM.ID INNER JOIN APP_CLUSTER AC ON AC.ID = ACVM.APP_CLUSTER_ID WHERE VM.POWERSTATE='poweredOn' AND AC.NAME='" + clusterName + "'")
            self.cursor.execute(self.query)
            vmdata = self.cursor.fetchone()
            if self.cursor.rowcount == 0:
                self.cursor.execute("SELECT Top 1 VM.NAME AS RESULT FROM VM INNER JOIN APP_CLUSTER_VM ACVM ON ACVM.VM_ID = VM.ID INNER JOIN APP_CLUSTER AC ON AC.ID = ACVM.APP_CLUSTER_ID WHERE VM.POWERSTATE='poweredOn' AND AC.NAME='" + clusterName + "'")
                record = self.cursor.fetchone()
                return record[0]
            return vmdata[0]
        except (Exception) as error:
            raise Exception(error)
        finally:
            if not session:
              self.conn.close()

    def getConfig_KEY_DATACENTER(self,datacenter,configurationKey,session=None):
        try:
            self.query = ("SELECT CKTD.VALUE AS RESULT FROM CONFIGURATION_KEY_TO_DATACENTER CKTD INNER JOIN CONFIGURATION_KEY CK ON CK.ID = CKTD.CONFIGURATION_KEY_ID INNER JOIN DATACENTER D ON D.ID = CKTD.DATACENTER_ID WHERE D.CODE = '" + datacenter + "' AND CK.[KEY] = '" + configurationKey + "'")
            self.cursor.execute(self.query)
            cofigkey = self.cursor.fetchone()
        except (Exception) as error:
            raise Exception(error)
        finally:
            if session:
              return cofigkey[0]
            self.conn.close()
            return cofigkey[0]

    def getSTRMEMCACHESERVERLIST(self,ClusterName,session=None):
        try:
            self.query = ("SELECT CKAC.VALUE AS RESULT FROM CONFIGURATION_KEY_TO_APP_CLUSTER CKAC INNER JOIN CONFIGURATION_KEY CK ON CK.ID=CKAC.CONFIGURATION_KEY_ID INNER JOIN APP_CLUSTER AC2 ON AC2.ID = CKAC.APP_CLUSTER_ID INNER JOIN APP_CLUSTER AC ON AC.ASSOCIATE_APP_CLUSTER_ID = AC2.ID WHERE CK.[KEY] = 'STRMEMCACHESERVERLIST' AND AC.NAME = '" + ClusterName + "'")
            self.cursor.execute(self.query)
            vmdata = self.cursor.fetchone()
            if self.cursor.rowcount == 0:
                self.cursor.execute("SELECT CKAC.VALUE AS RESULT FROM CONFIGURATION_KEY_TO_APP_CLUSTER CKAC INNER JOIN CONFIGURATION_KEY CK ON CK.ID=CKAC.CONFIGURATION_KEY_ID INNER JOIN APP_CLUSTER AC3 on AC3.ID = CKAC.APP_CLUSTER_ID INNER JOIN APP_CLUSTER AC2 ON AC2.ASSOCIATE_APP_CLUSTER_ID = AC3.ID INNER JOIN APP_CLUSTER AC ON AC.ASSOCIATE_APP_CLUSTER_ID = AC2.ID WHERE CK.[KEY] = 'STRMEMCACHESERVERLIST' AND AC.NAME = '" + ClusterName + "'")
                record = self.cursor.fetchone()
                return '' if record is None else record[0]
            return '' if vmdata is None else vmdata[0] 
        except (Exception) as error:
            raise Exception(error)
        finally:
            if not session:
              self.conn.close()


    def UWD_CONFIGKEYS(self,ClusterName,packageName):
        try:
            if not SaltJob.validCluster(self,ClusterName):
                clusterNameArray = ClusterName.upper().split("-")
                datacenter = clusterNameArray[0]
                clusterVersion = clusterNameArray[1]
                environment = clusterNameArray[2]
                clusterRole = clusterNameArray[3]
                clusterNumber = clusterNameArray[4][1:5]
                winDomain = SaltJob.getDomain(self,datacenter,session=True)
                DEFAULT_APP_POOL_USER = 'svc_' + datacenter + environment[0] + clusterRole + clusterNumber
                DEFAULT_APP_POOL_USER_PMP = DEFAULT_APP_POOL_USER.lower()
                DEFAULT_APP_POOL_USER = winDomain + "\\" + DEFAULT_APP_POOL_USER.lower()
                cluster_Name = ClusterName.replace("-","_")
                clusterDistributorDBName = cluster_Name + "_dist_db"
                clusterSSISDBName = "SSISFRAMEWORK"
                dbAdmin = cluster_Name + "_dbadmin"
                clusterDistributorDBAdmin = "distributor_admin"
                clusterSSISDBAdmin = cluster_Name + "_ssis_dbadmin"
                defaultDBName = "local"
                ouName="OU=UDA,OU=service_accounts,OU=groups_users,DC=" + winDomain.split(".")[0] + ",DC=" + winDomain.split(".")[1]
                roleName = SaltJob.getRoleversion(self,packageName,clusterRole,session=True)
                if roleName == 'SS16' or 'SS16CU15':
                  snapshotfolder = "s:\\mssql\\snapshots"
                firstServerName = SaltJob.getclusterVM_first(self,ClusterName,session=True)
                UWD_DB_SERVER = firstServerName
                self.PMPClass.winadd_dbresource(dbAdmin,firstServerName,defaultDBName,"True","MS SQL Server")
                if roleName != 'SS16':
                  self.PMPClass.winadd_dbresource(clusterDistributorDBAdmin,firstServerName,clusterDistributorDBName,"True","MS SQL Server")
                  clusterDistributorDBAdminPwd = self.PMPClass.PMP_resource(firstServerName,clusterDistributorDBAdmin)
                self.PMPClass.winadd_dbresource(clusterSSISDBAdmin,firstServerName,clusterSSISDBName,"True","MS SQL Server")
                self.PMPClass.winadd_resource(DEFAULT_APP_POOL_USER_PMP,ClusterName,"True","Svc_accounts")
                dbAdminPwd = self.PMPClass.PMP_resource(firstServerName,dbAdmin)
                clusterSSISDBAdminPwd = self.PMPClass.PMP_resource(firstServerName,clusterSSISDBAdmin)
                DEFAULT_APP_POOL_PASSWORD = self.PMPClass.PMP_resource(ClusterName,DEFAULT_APP_POOL_USER_PMP)
                cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"UWD_ADMIN_USER","CONFIGURATION_KEY_VALUE":dbAdmin}];
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UWD_ADMIN_PASSWORD","CONFIGURATION_KEY_VALUE":dbAdminPwd});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UWD_SSIS_DB_SERVER","CONFIGURATION_KEY_VALUE":firstServerName});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UWD_SSIS_DB_NAME","CONFIGURATION_KEY_VALUE":clusterSSISDBName});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UWD_SSIS_DB_USER","CONFIGURATION_KEY_VALUE":clusterSSISDBAdmin});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UWD_SSIS_DB_PASSWORD","CONFIGURATION_KEY_VALUE":clusterSSISDBAdminPwd});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"DEFAULT_APP_POOL_USER","CONFIGURATION_KEY_VALUE":DEFAULT_APP_POOL_USER});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"DEFAULT_APP_POOL_PASSWORD","CONFIGURATION_KEY_VALUE":str(DEFAULT_APP_POOL_PASSWORD)});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UWD_DB_SERVER","CONFIGURATION_KEY_VALUE":UWD_DB_SERVER});
                if roleName == 'SS16' or "SS16CU15":
                  cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UWD_SNAPSHOT_DIRECTORY","CONFIGURATION_KEY_VALUE":snapshotfolder});
                else:
                  cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UWD_DISTRIBUTOR_DB_SERVER","CONFIGURATION_KEY_VALUE":firstServerName});
                  cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UWD_DISTRIBUTOR_DB_NAME","CONFIGURATION_KEY_VALUE":clusterDistributorDBName});
                  cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UWD_DISTRIBUTOR_DB_USER","CONFIGURATION_KEY_VALUE":clusterDistributorDBAdmin});
                  cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UWD_DISTRIBUTOR_DB_PASSWORD","CONFIGURATION_KEY_VALUE":clusterDistributorDBAdminPwd});
                for i in range(len(cmdbAdditions)):
                    if SaltJob.checkConfig(self,cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                        self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                        self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                        self.conn.commit()
                        if self.cursor.rowcount == 0:
                            raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                            return False
                return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()


    def URW_CONFIGKEYS(self,ClusterName,packageName):
        try:
            if not SaltJob.validCluster(self,ClusterName):
                clusterNameArray = ClusterName.upper().split("-")
                datacenter = clusterNameArray[0]
                clusterVersion = clusterNameArray[1]
                environment = clusterNameArray[2]
                clusterRole = clusterNameArray[3]
                clusterNumber = clusterNameArray[4][1:5]
                winDomain = SaltJob.getDomain(self,datacenter,session=True)
                DEFAULT_APP_POOL_USER = 'svc_' + datacenter + environment[0] + clusterRole + clusterNumber
                DEFAULT_APP_POOL_USER_PMP = DEFAULT_APP_POOL_USER.lower()
                DEFAULT_APP_POOL_USER = winDomain + "\\" + DEFAULT_APP_POOL_USER.lower()
                cluster_Name = ClusterName.replace("-","_")
                dbAdmin = cluster_Name + '_dbadmin'
                defaultDBName = cluster_Name + '_db'
                JASPER_SUPERUSER_NAME= "superuser"
                ouName="OU=UDA,OU=service_accounts,OU=groups_users,DC=" + winDomain.split(".")[0] + ",DC=" + winDomain.split(".")[1]
                jasperResource = ClusterName + '-JS'
                associatedCluster = SaltJob.getassociatedcluster(self,ClusterName,session=True)
                assfirstServerName = SaltJob.getclusterVM_first(self,associatedCluster,session=True)
                self.PMPClass.winadd_dbresource(dbAdmin,assfirstServerName,defaultDBName,"True","MS SQL Server")
                self.PMPClass.winadd_resource(JASPER_SUPERUSER_NAME,jasperResource,"True","JasperSoft")
                self.PMPClass.winadd_resource(DEFAULT_APP_POOL_USER_PMP,ClusterName,"True","Svc_accounts")
                dbAdminPwd = self.PMPClass.PMP_resource(assfirstServerName,dbAdmin)
                JASPER_SUPERUSER_PASSWORD = self.PMPClass.PMP_resource(jasperResource,JASPER_SUPERUSER_NAME)
                DEFAULT_APP_POOL_PASSWORD = self.PMPClass.PMP_resource(ClusterName,DEFAULT_APP_POOL_USER_PMP)
                cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"URD_DB_NAME","CONFIGURATION_KEY_VALUE":defaultDBName}]
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"URD_DB_USER","CONFIGURATION_KEY_VALUE":dbAdmin});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"URD_DB_PASSWORD","CONFIGURATION_KEY_VALUE":dbAdminPwd});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"JASPER_SUPERUSER_NAME","CONFIGURATION_KEY_VALUE":JASPER_SUPERUSER_NAME});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"JASPER_SUPERUSER_PASSWORD","CONFIGURATION_KEY_VALUE":JASPER_SUPERUSER_PASSWORD});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"DEFAULT_APP_POOL_USER","CONFIGURATION_KEY_VALUE":DEFAULT_APP_POOL_USER});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"DEFAULT_APP_POOL_PASSWORD","CONFIGURATION_KEY_VALUE":str(DEFAULT_APP_POOL_PASSWORD)});
                for i in range(len(cmdbAdditions)):
                    if SaltJob.checkConfig(self,cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                        self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                        self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                        self.conn.commit()
                        if self.cursor.rowcount == 0:
                            raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                            return False
                return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()


    def USA_CONFIGKEYS(self,ClusterName,packageName):
        try:
            if not SaltJob.validCluster(self,ClusterName):
                clusterNameArray = ClusterName.upper().split("-")
                datacenter = clusterNameArray[0]
                clusterVersion = clusterNameArray[1]
                environment = clusterNameArray[2]
                clusterRole = clusterNameArray[3]
                clusterNumber = clusterNameArray[4][1:5]
                domain_public = SaltJob.getpublicdomain(self,datacenter,environment)
                if environment.upper() == 'PROD':
                  clusterFDQN = ClusterName + "." + domain_public
                else:
                  clusterFDQN = ClusterName + "." + environment + "." + domain_public
                USA_SEARCH_URL = "https://" + clusterFDQN + "/solr"

                #Check VM inserts
                resourceName = ClusterName
                accountName = "solradmin"
                pwToUse = ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(16))
                self.PMPClass.add_resource(accountName,pwToUse,resourceName,"MS SQL Server")
                pwOut = self.PMPClass.PMP_resource(resourceName,accountName)
                cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"USA_SEARCH_URL","CONFIGURATION_KEY_VALUE":USA_SEARCH_URL}]
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"SOLR_PWD","CONFIGURATION_KEY_VALUE":pwOut});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"SOLR_USER","CONFIGURATION_KEY_VALUE":accountName});
                for i in range(len(cmdbAdditions)):
                    if SaltJob.checkConfig(self,cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                        self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                        self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                        self.conn.commit()
                        if self.cursor.rowcount == 0:
                            raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                            return False
                return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()


    def UGM_CONFIGKEYS(self,ClusterName,packageName):
        try:
            if not SaltJob.validCluster(self,ClusterName):
                clusterNameArray = ClusterName.upper().split("-")
                datacenter = clusterNameArray[0]
                clusterVersion = clusterNameArray[1]
                environment = clusterNameArray[2]
                clusterRole = clusterNameArray[3]
                clusterNumber = clusterNameArray[4][1:5]
                winDomain = SaltJob.getDomain(self,datacenter,session=True)
                DEFAULT_APP_POOL_USER = 'svc_' + datacenter + environment[0] + clusterRole + clusterNumber
                DEFAULT_APP_POOL_USER_PMP = DEFAULT_APP_POOL_USER.lower()
                DEFAULT_APP_POOL_USER = winDomain + "\\" + DEFAULT_APP_POOL_USER.lower()
                ouName="OU=UDA,OU=service_accounts,OU=groups_users,DC=" + winDomain.split(".")[0] + ",DC=" + winDomain.split(".")[1]
                domain_public = SaltJob.getpublicdomain(self,datacenter,environment)
                if environment.upper() == 'PROD':
                  clusterFDQN = ClusterName + "." + domain_public
                else:
                  clusterFDQN = ClusterName + "." + environment + "." + domain_public
                UGM_SERVICE_URL = "https://" + clusterFDQN + "/api/gamification"
                cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"UGM_SERVICE_URL","CONFIGURATION_KEY_VALUE":UGM_SERVICE_URL}]
                for i in range(len(cmdbAdditions)):
                    if SaltJob.checkConfig(self,cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                        self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                        self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                        self.conn.commit()
                        if self.cursor.rowcount == 0:
                            raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                            return False
                return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()


    def UUW_CONFIGKEYS(self,ClusterName,packageName):
        try:
            if not SaltJob.validCluster(self,ClusterName):
                clusterNameArray = ClusterName.upper().split("-")
                datacenter = clusterNameArray[0]
                clusterVersion = clusterNameArray[1]
                environment = clusterNameArray[2]
                clusterRole = clusterNameArray[3]
                clusterNumber = clusterNameArray[4][1:5]
                winDomain = SaltJob.getDomain(self,datacenter,session=True)
                DEFAULT_APP_POOL_USER = 'svc_' + datacenter + environment[0] + clusterRole + clusterNumber
                DEFAULT_APP_POOL_USER_PMP = DEFAULT_APP_POOL_USER.lower()
                DEFAULT_APP_POOL_USER = winDomain + "\\" + DEFAULT_APP_POOL_USER.lower()
                #STRMEMCACHESERVERLIST = SaltJob().getSTRMEMCACHESERVERLIST(ClusterName)
                installRoot = SaltJob.getConfig_KEY_DATACENTER(self,datacenter,"INSTALL_ROOT",session=True)
                STRCOREFOLDERPATH = installRoot + packageName + "\\WebContent\\Talent\\Lightyear"
                STRLYPLUGINDEBUGPATH = installRoot + packageName + "\\WebContent\\Talent\\Lightyear\\Bin"
                STRLYPLUGINPATH = installRoot + packageName + "\\WebContent\\Talent\\Lightyear\\Bin"
                UFS_SHARE_LOCATION = "D:\\tenantShares\\"
                ouName="OU=UDA,OU=service_accounts,OU=groups_users,DC=" + winDomain.split(".")[0] + ",DC=" + winDomain.split(".")[1]
                userAccountName = ClusterName + "db"
                DbAccountName = userAccountName.replace("-","")
                self.PMPClass.winadd_resource(DEFAULT_APP_POOL_USER_PMP,ClusterName,"True","Svc_accounts")
                DEFAULT_APP_POOL_PASSWORD = self.PMPClass.PMP_resource(ClusterName,DEFAULT_APP_POOL_USER_PMP)
                STREMAILSERVER = "localhost"
                cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"UFS_SHARE_LOCATION","CONFIGURATION_KEY_VALUE":UFS_SHARE_LOCATION}];
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"STRCOREFOLDERPATH","CONFIGURATION_KEY_VALUE":STRCOREFOLDERPATH});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"STRLYPLUGINDEBUGPATH","CONFIGURATION_KEY_VALUE":STRLYPLUGINDEBUGPATH});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"STRLYPLUGINPATH","CONFIGURATION_KEY_VALUE":STRLYPLUGINPATH});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"DEFAULT_APP_POOL_USER","CONFIGURATION_KEY_VALUE":DEFAULT_APP_POOL_USER});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"DEFAULT_APP_POOL_PASSWORD","CONFIGURATION_KEY_VALUE":str(DEFAULT_APP_POOL_PASSWORD)});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"STREMAILSERVER","CONFIGURATION_KEY_VALUE":STREMAILSERVER});
                thumbprintNew = "A0B5B1AB15322534C5B1AE7A7D26CFB746352033"
                thumbprintOld = "C37D2E6565F95D052A5E527732229D13AE385A59"
                self.cursor.execute("select package.id AS RESULT from package where package.name = '" + packageName + "' and package.id >= (select top 1 package.id from package where package.name like '18.3%')")
                reco = self.cursor.fetchall()
                if self.cursor.rowcount > 0:
                  cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"BROKER_CERTIFICATE_THUMBPRINT","CONFIGURATION_KEY_VALUE":thumbprintNew});
                else:
                  cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"BROKER_CERTIFICATE_THUMBPRINT","CONFIGURATION_KEY_VALUE":thumbprintOld});
                for i in range(len(cmdbAdditions)):
                    if SaltJob.checkConfig(self,cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                        self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                        self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                        self.conn.commit()
                        if self.cursor.rowcount == 0:
                            raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                            return False
                return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()

    def UTA_CONFIGKEYS(self,ClusterName,packageName):
        try:
            if not SaltJob.validCluster(self,ClusterName):
                clusterNameArray = ClusterName.upper().split("-")
                datacenter = clusterNameArray[0]
                clusterVersion = clusterNameArray[1]
                environment = clusterNameArray[2]
                clusterRole = clusterNameArray[3]
                clusterNumber = clusterNameArray[4][1:5]
                winDomain = SaltJob.getDomain(self,datacenter,session=True)
                domain_public = SaltJob.getpublicdomain(self,datacenter,environment)
                if environment.upper() == 'PROD':
                  clusterFDQN = ClusterName + "." + domain_public
                else:
                  clusterFDQN = ClusterName + "." + environment + "." + domain_public
                DEFAULT_APP_POOL_USER = 'svc_' + datacenter + environment[0] + clusterRole + clusterNumber
                DEFAULT_APP_POOL_USER_PMP = DEFAULT_APP_POOL_USER.lower()
                DEFAULT_APP_POOL_USER = winDomain + "\\" + DEFAULT_APP_POOL_USER.lower()
                cluster_Name = ClusterName.replace("-","_")
                dbAdmin = cluster_Name + '_dbadmin'
                defaultDBName = cluster_Name + '_db'
                self.cursor.execute("SELECT RV.NAME AS ROLVEVERSION FROM PACKAGE P INNER JOIN PACKAGE_ROLE PR ON P.id = PR.PACKAGE_ID INNER JOIN VM_TYPE VT ON VT.id = PR.VM_TYPE_ID JOIN ROLE_VERSION RV ON RV.id = PR.ROLE_VERSION_ID WHERE P.NAME ='" + packageName + "' and VT.CODE ='" + clusterRole + "'")
                utaPort = self.cursor.fetchone()
                if utaPort:
                  UTA_SCHEDULER_URL="https://" + clusterFDQN +"/esbjob/service"
                  STRWEBSERVICEBASEURL41020="https://" + clusterFDQN
                else:
                  UTA_SCHEDULER_URL="http://" + clusterFDQN +":8987/esbjob/service"
                  STRWEBSERVICEBASEURL41020="http://" + clusterFDQN
                installRoot = SaltJob.getConfig_KEY_DATACENTER(self,datacenter,"INSTALL_ROOT",session=True)
                STRCOREFOLDERPATH = installRoot + packageName + "\\WebContent\\Talent\\Lightyear"
                STRLYPLUGINDEBUGPATH = installRoot + packageName + "\\WebContent\\Talent\\Lightyear\\Bin"
                STRLYPLUGINPATH = installRoot + packageName + "\\WebContent\\Talent\\Lightyear\\Bin"
                #STRMEMCACHESERVERLIST = SaltJob.getSTRMEMCACHESERVERLIST(self,ClusterName)
                ouName="OU=UDA,OU=service_accounts,OU=groups_users,DC=" + winDomain.split(".")[0] + ",DC=" + winDomain.split(".")[1]
                associatedCluster = SaltJob.getassociatedcluster(self,ClusterName,session=True)
                assfirstServerName = SaltJob.getclusterVM_first(self,associatedCluster,session=True)
                self.PMPClass.winadd_dbresource(dbAdmin,assfirstServerName,defaultDBName,"True","MS SQL Server")
                self.PMPClass.winadd_resource(DEFAULT_APP_POOL_USER_PMP,ClusterName,"True","Svc_accounts")
                dbAdminPwd = self.PMPClass.PMP_resource(assfirstServerName,dbAdmin)
                DEFAULT_APP_POOL_PASSWORD = self.PMPClass.PMP_resource(ClusterName,DEFAULT_APP_POOL_USER_PMP)
                STREMAILSERVER="localhost"
                cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"UTD_DB_NAME","CONFIGURATION_KEY_VALUE":defaultDBName}];
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UTD_DB_USER","CONFIGURATION_KEY_VALUE":dbAdmin});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UTD_DB_PASSWORD","CONFIGURATION_KEY_VALUE":dbAdminPwd});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"STRWEBSERVICEBASEURL41020","CONFIGURATION_KEY_VALUE":STRWEBSERVICEBASEURL41020});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UTA_SCHEDULER_URL","CONFIGURATION_KEY_VALUE":UTA_SCHEDULER_URL});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"STRCOREFOLDERPATH","CONFIGURATION_KEY_VALUE":STRCOREFOLDERPATH});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"STRLYPLUGINDEBUGPATH","CONFIGURATION_KEY_VALUE":STRLYPLUGINDEBUGPATH});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"STRLYPLUGINPATH","CONFIGURATION_KEY_VALUE":STRLYPLUGINPATH});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"DEFAULT_APP_POOL_USER","CONFIGURATION_KEY_VALUE":DEFAULT_APP_POOL_USER});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"DEFAULT_APP_POOL_PASSWORD","CONFIGURATION_KEY_VALUE":str(DEFAULT_APP_POOL_PASSWORD)});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"STREMAILSERVER","CONFIGURATION_KEY_VALUE":STREMAILSERVER});
                thumbprintNew = "A0B5B1AB15322534C5B1AE7A7D26CFB746352033"
                thumbprintOld = "C37D2E6565F95D052A5E527732229D13AE385A59"
                self.cursor.execute("select package.id AS RESULT from package where package.name = '" + packageName + "' and package.id >= (select top 1 package.id from package where package.name like '18.3%')")
                reco = self.cursor.fetchall()
                if self.cursor.rowcount > 0:
                  cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"BROKER_CERTIFICATE_THUMBPRINT","CONFIGURATION_KEY_VALUE":thumbprintNew});
                else:
                  cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"BROKER_CERTIFICATE_THUMBPRINT","CONFIGURATION_KEY_VALUE":thumbprintOld});
                for i in range(len(cmdbAdditions)):
                    if SaltJob.checkConfig(self,cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                        self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                        self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                        self.conn.commit()
                        if self.cursor.rowcount == 0:
                            raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                            return False
                return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()


    def USM_CONFIGKEYS(self,ClusterName,packageName):
        try:
            if not SaltJob.validCluster(self,ClusterName):
                clusterNameArray = ClusterName.upper().split("-")
                datacenter = clusterNameArray[0]
                clusterVersion = clusterNameArray[1]
                environment = clusterNameArray[2]
                clusterRole = clusterNameArray[3]
                clusterNumber = clusterNameArray[4][1:5]
                nodeList = ''
                vmList = SaltJob.getServers(self,ClusterName,session=True)
                for i in range(len(vmList)):
                  if i > 0:
                    nodeList = nodeList + ',' + vmList[i]
                  else:
                    nodeList = vmList[i]
                cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"USM_CLUSTER_NODES","CONFIGURATION_KEY_VALUE":nodeList}]
                for i in range(len(cmdbAdditions)):
                    if SaltJob.checkConfig(self,cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                        self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                        self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                        self.conn.commit()
                        if self.cursor.rowcount == 0:
                            raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                            return False
                for i in range(len(vmList)):
                    VALUE = i+1
                    self.query= ("INSERT INTO CONFIGURATION_KEY_TO_VM (VALUE,CONFIGURATION_KEY_ID,VM_ID) (SELECT %s,CK.ID,VM.ID FROM CONFIGURATION_KEY CK,VM VM WHERE CK.[KEY]=%s AND VM.[NAME]=%s AND NOT EXISTS (SELECT 1 FROM CONFIGURATION_KEY_TO_VM WHERE VM_ID=VM.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                    self.cursor.execute(self.query,(VALUE,"ZOOKEEPER_NODE_ID",vmList[i]))
                    self.conn.commit()
                    if self.cursor.rowcount == 0:
                         raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_VM")
                         return False
                return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()


    def UUD_CONFIGKEYS(self,ClusterName,packageName):
        try:
            if not SaltJob.validCluster(self,ClusterName):
                clusterNameArray = ClusterName.upper().split("-")
                datacenter = clusterNameArray[0]
                clusterVersion = clusterNameArray[1]
                environment = clusterNameArray[2]
                clusterRole = clusterNameArray[3]
                clusterNumber = clusterNameArray[4][1:5]
                cluster_Name = ClusterName.replace("-","_")
                dbAdmin = cluster_Name + "_dbadmin"
                defaultDBName = "local"
                firstServerName = SaltJob.getclusterVM_first(self,ClusterName,session=True)
                UUD_DB_SERVER = firstServerName
                clusterDistributorDBName = cluster_Name + "_dist_db"
                self.PMPClass.winadd_dbresource(dbAdmin,firstServerName,defaultDBName,"True","MS SQL Server")
                dbAdminPwd = self.PMPClass.PMP_resource(firstServerName,dbAdmin)
                cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"UUD_ADMIN_USER","CONFIGURATION_KEY_VALUE":dbAdmin}]
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UUD_ADMIN_PASSWORD","CONFIGURATION_KEY_VALUE":dbAdminPwd});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UUD_DB_SERVER","CONFIGURATION_KEY_VALUE":UUD_DB_SERVER});
                roleName = SaltJob.getRoleversion(self,packageName,clusterRole,session=True)
                if roleName == 'SS16' or 'SS16CU15':
                  cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UWD_DISTRIBUTOR_DB_NAME","CONFIGURATION_KEY_VALUE":clusterDistributorDBName});
                for i in range(len(cmdbAdditions)):
                    if SaltJob.checkConfig(self,cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                        self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                        self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                        self.conn.commit()
                        if self.cursor.rowcount == 0:
                            raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                            return False
                return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()


    def UTD_CONFIGKEYS(self,ClusterName,packageName):
        try:
            if not SaltJob.validCluster(self,ClusterName):
                clusterNameArray = ClusterName.upper().split("-")
                datacenter = clusterNameArray[0]
                clusterVersion = clusterNameArray[1]
                environment = clusterNameArray[2]
                clusterRole = clusterNameArray[3]
                clusterNumber = clusterNameArray[4][1:5]
                cluster_Name = ClusterName.replace("-","_")
                dbAdmin = cluster_Name + "_dbadmin"
                defaultDBName = "local"
                STRMEMCACHESERVERLIST = SaltJob.getSTRMEMCACHESERVERLIST(self,ClusterName,session=True)
                firstServerName = SaltJob.getclusterVM_first(self,ClusterName,session=True)
                self.PMPClass.winadd_dbresource(dbAdmin,firstServerName,defaultDBName,"True","MS SQL Server")
                dbAdminPwd = self.PMPClass.PMP_resource(firstServerName,dbAdmin)
                cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"UTD_ADMIN_USER","CONFIGURATION_KEY_VALUE":dbAdmin}]
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UTD_ADMIN_PASSWORD","CONFIGURATION_KEY_VALUE":dbAdminPwd});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UTD_DB_SERVER","CONFIGURATION_KEY_VALUE":firstServerName});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"STRMEMCACHESERVERLIST","CONFIGURATION_KEY_VALUE":STRMEMCACHESERVERLIST});
                for i in range(len(cmdbAdditions)):
                    if SaltJob.checkConfig(self,cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                        self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                        self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                        self.conn.commit()
                        if self.cursor.rowcount == 0:
                            raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                            return False
                return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()

    def URD_CONFIGKEYS(self,ClusterName,packageName):
        try:
            if not SaltJob.validCluster(self,ClusterName):
                clusterNameArray = ClusterName.upper().split("-")
                datacenter = clusterNameArray[0]
                clusterVersion = clusterNameArray[1]
                environment = clusterNameArray[2]
                clusterRole = clusterNameArray[3]
                clusterNumber = clusterNameArray[4][1:5]
                cluster_Name = ClusterName.replace("-","_")
                dbAdmin = cluster_Name + "_dbadmin"
                defaultDBName = "local"
                firstServerName = SaltJob.getclusterVM_first(self,ClusterName,session=True)
                self.PMPClass.winadd_dbresource(dbAdmin,firstServerName,defaultDBName,"True","MS SQL Server")
                dbAdminPwd = self.PMPClass.PMP_resource(firstServerName,dbAdmin)
                cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"URD_ADMIN_USER","CONFIGURATION_KEY_VALUE":dbAdmin}]
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"URD_ADMIN_PASSWORD","CONFIGURATION_KEY_VALUE":dbAdminPwd});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"URD_DB_SERVER","CONFIGURATION_KEY_VALUE":firstServerName});
                for i in range(len(cmdbAdditions)):
                    if SaltJob.checkConfig(self,cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                        self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                        self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                        self.conn.commit()
                        if self.cursor.rowcount == 0:
                            raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                            return False
                return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()


    def UDD_CONFIGKEYS(self,ClusterName,packageName):
        try:
            if not SaltJob.validCluster(self,ClusterName):
                clusterNameArray = ClusterName.upper().split("-")
                datacenter = clusterNameArray[0]
                clusterVersion = clusterNameArray[1]
                environment = clusterNameArray[2]
                clusterRole = clusterNameArray[3]
                clusterNumber = clusterNameArray[4][1:5]
                cluster_Name = ClusterName.replace("-","_")
                dbAdmin = cluster_Name + "_dbadmin"
                defaultDBName = "local"
                firstServerName = SaltJob.getclusterVM_first(self,ClusterName,session=True)
                UDD_DB_SERVER = firstServerName
                clusterDistributorDBAdmin = "distributor_admin"
                self.PMPClass.winadd_dbresource(clusterDistributorDBAdmin,firstServerName,firstServerName,"True","MS SQL Server")
                self.PMPClass.winadd_dbresource(dbAdmin,firstServerName,defaultDBName,"True","MS SQL Server")
                dbAdminPwd = self.PMPClass.PMP_resource(firstServerName,dbAdmin)
                clusterDistributorDBAdminPwd = self.PMPClass.PMP_resource(firstServerName,clusterDistributorDBAdmin)
                cmdbAdditions = [{"CONFIGURATION_KEY_KEY":"UWD_DISTRIBUTOR_ADMIN_PASSWORD","CONFIGURATION_KEY_VALUE":dbAdminPwd}]
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UWD_DISTRIBUTOR_ADMIN_USER","CONFIGURATION_KEY_VALUE":dbAdmin});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UWD_DISTRIBUTOR_DB_SERVER","CONFIGURATION_KEY_VALUE":UDD_DB_SERVER});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UWD_DISTRIBUTOR_DB_PASSWORD","CONFIGURATION_KEY_VALUE":clusterDistributorDBAdminPwd});
                cmdbAdditions.append({"CONFIGURATION_KEY_KEY":"UWD_DISTRIBUTOR_DB_USER","CONFIGURATION_KEY_VALUE":clusterDistributorDBAdmin});
                for i in range(len(cmdbAdditions)):
                    if SaltJob.checkConfig(self,cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName):
                        self.query= ("INSERT INTO CONFIGURATION_KEY_TO_APP_CLUSTER (VALUE,CONFIGURATION_KEY_ID,APP_CLUSTER_ID) (SELECT %s,CK.ID,AC.ID FROM CONFIGURATION_KEY CK,APP_CLUSTER AC WHERE CK.[KEY]=%s AND AC.[NAME]=%s AND NOT EXISTS (SELECT * FROM CONFIGURATION_KEY_TO_APP_CLUSTER WHERE APP_CLUSTER_ID=AC.ID AND CONFIGURATION_KEY_ID=CK.ID))")
                        self.cursor.execute(self.query,(cmdbAdditions[i]["CONFIGURATION_KEY_VALUE"],cmdbAdditions[i]["CONFIGURATION_KEY_KEY"],ClusterName))
                        self.conn.commit()
                        if self.cursor.rowcount == 0:
                            raise Exception("Unable to insert Record into table CONFIGURATION_KEY_TO_APP_CLUSTER for" + cmdbAdditions[i]["CONFIGURATION_KEY_KEY"])
                            return False
                return True
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()

    def SYSLOG_SERVER(self,datacenter):
        try:
            self.cursor.execute("select CK2DC.VALUE from CONFIGURATION_KEY ck inner join CONFIGURATION_KEY_TO_DATACENTER ck2dc on ck.ID = ck2dc.CONFIGURATION_KEY_ID inner join DATACENTER d  on ck2dc.DATACENTER_ID = d.ID where ck.[key] = 'CO_SYSLOG_SERVER' AND D.CODE = '"+ datacenter +"'")
            data = self.cursor.fetchone()
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return data[0]

    def NTP_SERVER(self,datacenter):
        try:
            self.cursor.execute("select CK2DC.VALUE from CONFIGURATION_KEY ck inner join CONFIGURATION_KEY_TO_DATACENTER ck2dc on ck.ID = ck2dc.CONFIGURATION_KEY_ID inner join DATACENTER d  on ck2dc.DATACENTER_ID = d.ID where ck.[key] = 'CO_NTP_SERVER' AND D.CODE = '"+ datacenter +"'")
            data = self.cursor.fetchone()
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return data[0]

    def ESET_CONFIG(self,datacenter):
        try:
            self.cursor.execute("select CK.[KEY],CK2DC.VALUE from CONFIGURATION_KEY ck inner join CONFIGURATION_KEY_TO_DATACENTER ck2dc on ck.ID = ck2dc.CONFIGURATION_KEY_ID inner join DATACENTER d  on ck2dc.DATACENTER_ID = d.ID where ck.[key] in ('CO_ESET_SERVER','CO_ESET_PORT','CO_ESET_WEBCONSOLE_PORT','CO_ESET_WEBCONSOLE_RESOURCENAME','CO_ESET_WEBCONSOLE_ACCOUNTNAME') AND D.CODE = '"+ datacenter +"'")
            data = self.cursor.fetchall()
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return dict(data)

    def repoServer(self,datacenter,session=None):
        try:
            self.cursor.execute("select CKTD.VALUE AS RESULT from CONFIGURATION_KEY_TO_DATACENTER cktd inner join CONFIGURATION_KEY ck on ck.id = cktd.CONFIGURATION_KEY_ID inner join DATACENTER d on d.ID = cktd.DATACENTER_ID where d.CODE = '"+ datacenter +"' and ck.[KEY] = 'CO_REPO_SERVER'")
            record = self.cursor.fetchone()
        except (Exception) as error:
            raise(error)
        finally:
            if session:
              return record[0]
            self.conn.close()
            return record[0]

    def WsusServer(self,datacenter):
        try:
            self.cursor.execute("select CKTD.VALUE AS RESULT from CONFIGURATION_KEY_TO_DATACENTER cktd inner join CONFIGURATION_KEY ck on ck.id = cktd.CONFIGURATION_KEY_ID inner join DATACENTER d on d.ID = cktd.DATACENTER_ID where d.CODE = '"+ datacenter +"' and ck.[KEY] = 'CO_WSUS_SERVER'")
            record = self.cursor.fetchone()
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return record[0]

    def splunkDeploymentServer(self,datacenter):
        try:
            self.cursor.execute("select CKTD.VALUE AS RESULT from CONFIGURATION_KEY_TO_DATACENTER cktd inner join CONFIGURATION_KEY ck on ck.id = cktd.CONFIGURATION_KEY_ID inner join DATACENTER d on d.ID = cktd.DATACENTER_ID where d.CODE = '"+ datacenter +"' and ck.[KEY] = 'CO_SPLUNK_DEPLOYMENT_SERVER'")
            record = self.cursor.fetchone()
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return record[0]

    def splunkWindowsInstaller(self,datacenter):
        try:
            self.cursor.execute("select CKTD.VALUE AS RESULT from CONFIGURATION_KEY_TO_DATACENTER cktd inner join CONFIGURATION_KEY ck on ck.id = cktd.CONFIGURATION_KEY_ID inner join DATACENTER d on d.ID = cktd.DATACENTER_ID where d.CODE = '"+ datacenter +"' and ck.[KEY] = 'WINDOWS_SPLUNK_INSTALLER'")
            record = self.cursor.fetchone()
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return record[0]

    def scomManagementServer(self,datacenter):
        try:
            self.cursor.execute("select SCOM_MANAGEMENT_SERVER AS RESULT FROM DATACENTER where CODE = '"+ datacenter +"'")
            record = self.cursor.fetchone()
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return record[0]

    def OrionDB_CONFIG(self,datacenter,session=None):
        try:
            self.cursor.execute("select CK.[KEY],CK2DC.VALUE from CONFIGURATION_KEY ck inner join CONFIGURATION_KEY_TO_DATACENTER ck2dc on ck.ID = ck2dc.CONFIGURATION_KEY_ID inner join DATACENTER d  on ck2dc.DATACENTER_ID = d.ID where ck.[key] in ('SOLARWINDS_ORION_HOST','SOLARWINDS_ORION_DB_NAME','SOLARWINDS_ORION_INSTANCE_NAME','SOLARWINDS_ORION_PORT','SOLARWINDS_ORION_USERNAME') AND D.CODE = '"+ datacenter +"'")
            data = self.cursor.fetchall()
        except (Exception) as error:
            raise(error)
        finally:
            if session:
              return dict(data)
            self.conn.close()
            return dict(data)

    def getBaseTemplate(self,datacenter,clusterrole,packageName,session=None):
        try:
            self.cursor.execute("SELECT VM_TEMPLATE.NAME AS RESULT FROM VM_TEMPLATE INNER JOIN PACKAGE_ROLE ON PACKAGE_ROLE.ROLE_VERSION_ID=VM_TEMPLATE.ROLE_VERSION_ID INNER JOIN ROLE_VERSION ON PACKAGE_ROLE.ROLE_VERSION_ID=ROLE_VERSION.ID INNER JOIN PACKAGE ON PACKAGE.ID=PACKAGE_ROLE.PACKAGE_ID INNER JOIN VM_TYPE ON VM_TYPE.ID=PACKAGE_ROLE.VM_TYPE_ID INNER JOIN VM_TEMPLATE_TO_DATACENTER ON VM_TEMPLATE.ID = VM_TEMPLATE_TO_DATACENTER.VM_TEMPLATE_ID INNER JOIN DATACENTER ON DATACENTER.ID = VM_TEMPLATE_TO_DATACENTER.DATACENTER_ID WHERE DATACENTER.CODE = '"+ datacenter +"' AND VM_TYPE.CODE = '"+ clusterrole +"' AND PACKAGE.NAME='"+ packageName +"' AND VM_TEMPLATE.VM_TYPE_ID = VM_TYPE.ID AND VM_TEMPLATE.AUTOMATION_TYPE = 'SALT' AND VM_TEMPLATE.APP_FUNCTION_ID = 3")
            record = self.cursor.fetchone()
        except (Exception) as error:
            raise(error)
        finally:
            if session:
              return record[0]
            self.conn.close()
            return record[0]

    def getSubnet(self,Port_Group):
        try:
            self.cursor.execute("select SUBNET from IP_SUBNET where DIST_PORT_GROUP = '"+ Port_Group +"'")
            record = self.cursor.fetchone()
            subnet = record[0].split("/")[0]
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return subnet

    def getRoleTemplate(self,datacenter,clusterrole,packageName):
        try:
            self.cursor.execute("SELECT VM_TEMPLATE.NAME AS RESULT FROM VM_TEMPLATE INNER JOIN PACKAGE_ROLE ON PACKAGE_ROLE.ROLE_VERSION_ID=VM_TEMPLATE.ROLE_VERSION_ID INNER JOIN ROLE_VERSION ON PACKAGE_ROLE.ROLE_VERSION_ID=ROLE_VERSION.ID INNER JOIN PACKAGE ON PACKAGE.ID=PACKAGE_ROLE.PACKAGE_ID INNER JOIN VM_TYPE ON VM_TYPE.ID=PACKAGE_ROLE.VM_TYPE_ID INNER JOIN VM_TEMPLATE_TO_DATACENTER ON VM_TEMPLATE.ID = VM_TEMPLATE_TO_DATACENTER.VM_TEMPLATE_ID AND VM_TEMPLATE.PACKAGE_ID = PACKAGE.ID INNER JOIN DATACENTER ON DATACENTER.ID = VM_TEMPLATE_TO_DATACENTER.DATACENTER_ID WHERE DATACENTER.CODE = '"+ datacenter +"' AND VM_TYPE.CODE = '"+ clusterrole +"' AND PACKAGE.NAME='"+ packageName +"' AND VM_TEMPLATE.VM_TYPE_ID = VM_TYPE.ID AND VM_TEMPLATE.AUTOMATION_TYPE = 'SALT' AND VM_TEMPLATE.APP_FUNCTION_ID != 3 AND VM_TEMPLATE.PACKAGE_ID = (SELECT ID FROM PACKAGE WHERE PACKAGE.NAME = '"+ packageName +"')")
            record = self.cursor.fetchone()
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return record[0]

    def getassociatedcluster(self,cluster,session=None):
        try:
            self.cursor.execute("SELECT ISNULL(B.NAME,'') AS ASSCLUSTER FROM APP_CLUSTER A JOIN APP_CLUSTER B ON A.ASSOCIATE_APP_CLUSTER_ID=B.ID WHERE A.NAME = '"+cluster+"'")
            record = self.cursor.fetchall()
        except (Exception) as error:
            raise(error)
        finally:
            if session:
              return record[0][0]
            self.conn.close()
            return record[0][0]

    def getPackageLocation(self,datacenter,package,session=None):
        try:
            #query = "select replace(APP_PACKAGE_LOCATION,'\','\\') from DATACENTER where code = '"+datacenter+"' order by 1 desc"
            query = "select APP_PACKAGE_LOCATION from DATACENTER where code = '"+datacenter+"' order by 1 desc"
            print(query)
            self.cursor.execute(query)
            record = self.cursor.fetchone()
            location = (record[0]).replace('\\\\','\\')
            packageLocation = location + "\\" + datacenter + "-packages" + "\\" + package
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return packageLocation

    def get_install_params(self,query,packagename,clusterrole,datacenter,sqladmin,udacresource,saltaccount):
        dictdata = {}
        self.cursor.execute(query)
#        self.cursor.execute("select [dbo].[GET_PS_INSTALL_PARAMETERS]('"+params+"')")
        rows = self.cursor.fetchall()
        xml = rows[0][0]
        xmldoc = minidom.parseString(xml)
        udacKeyVals = xmldoc.getElementsByTagName('Key')
        for s in udacKeyVals:
            name = ''
            value = ''
            name = s.attributes['name'].value
            if s.hasAttribute('value'):
                value = s.attributes['value'].value
                if s.hasAttribute('secure') and s.attributes['secure'].value == '1' and value != '':
                    value = value
            dictdata[name] = value
        dictdata['CMDB_DB_PASSWORD'] = self.PMPClass.PMP_resource(udacresource.split('.')[0],"installer")
        domain = SaltJob.getDomain(self,datacenter,session=True)
        dbroles = SaltJob.getwindowsDB(self,packagename)
        if clusterrole in dbroles:
            domain = SaltJob.getDomain(self,datacenter,session=True).split('.')[0]
            dictdata["domain_user"] =  domain+"\\"+ sqladmin
            dictdata["domain_pwd"] = (self.PMPClass.PMP_resource('Svc_Accounts',sqladmin)).replace('%','%%')
            dictdata["sa_pwd"] = (self.PMPClass.PMP_resource('vRATemplate','sa')).replace('%','%%')
        if clusterrole == 'UXD':
            dictdata["defaultuser"] = "root"
            dictdata["defaultuserpwd"] = (self.PMPClass.PMP_resource('uxdDefaultuser','defaultUser')).replace('%','%%')
        #dictdata["package_share_location"] = SaltJob.getPackageLocation(self,datacenter,packagename,session=True)
        dictdata["package_share_location"] = '\\\\' + domain + '\\UDASHARE' + '\\' + datacenter + "-packages" + '\\' + packagename
        dictdata["domain"] = domain
        dictdata["user"] = saltaccount
        dictdata["password"] = (self.PMPClass.PMP_resource(saltaccount,saltaccount))
        self.conn.close()
        return dict(dictdata)

    def getVMdata(self,ClusterName):
        VMdata = []
        IPs = ''
        clusterIPs = SaltJob.getcmdb_clusterVmIps(self,ClusterName,session=True)
        for item in clusterIPs:
            IPs = IPs+ ','+item
        IPs = IPs[1:]
        try:
            self.cursor.execute("SELECT IP +' '+NAME+' '+FQDN FROM VM WHERE POWERSTATE <> 'deleted' and IP IN (SELECT SPLITDATA FROM DBO.fnSplitString('"+IPs+"',','))")
            rows = self.cursor.fetchall()
            for row in rows:
                VMdata.append(row[0])
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return VMdata

    def checkLock(self,lockname):
        self.cursor.execute("select [LOCKNAME] ,[SOURCE], [CREATED_DATE] ,[MAX_AGE] from SALT_JOB_LOCKS WHERE [LOCKNAME] = '"+ lockname +"'")
        record = self.cursor.fetchall()
        if len(record) == 0:
            return True
        return False

    def setLock(self,lockname,maxage):
        while True:
            time.sleep(30)
            check = SaltJob.checkLock(self,lockname)
            if check:
                self.cursor.execute("BEGIN TRAN insert into SALT_JOB_LOCKS (lockname, source, max_age) values ('"+ lockname +"', 'salt',"+ maxage +") COMMIT")
                self.conn.commit()
                return True
                break;
            else:
                self.cursor.execute("select datediff(ss, (SELECT DATEADD(minute,(select max_age from SALT_JOB_LOCKS WHERE [LOCKNAME] = '"+ lockname +"'),(select CREATED_DATE from SALT_JOB_LOCKS WHERE [LOCKNAME] = '"+ lockname +"'))) , (select GETUTCDATE())) as TimeDiff")
                record = self.cursor.fetchone()
                if record:
                    if record[0] > 0:
                        self.cursor.execute("BEGIN TRAN DELETE FROM SALT_JOB_LOCKS WHERE LOCKNAME = '"+ lockname +"' Insert into SALT_JOB_LOCKS (lockname, source, max_age) values ('" + lockname + "', 'salt', " + maxage + ") COMMIT")
                        self.conn.commit()
                        return True
                        break;
                else:
                    continue

    def deleteLock(self,lockname):
        self.cursor.execute("BEGIN TRAN DELETE FROM SALT_JOB_LOCKS WHERE LOCKNAME = '"+ lockname +"' COMMIT")
        self.conn.commit()
        return True


    def get_winDrive(self,datacenter,environment,clusterrole,packagename,esxcluster):
        self.query = ("SELECT DISTINCT DATASTORE, DRIVE_LETTER, DRIVE_SIZE FROM GET_DATASTORES_ROLE_TEMPLATE(%s,%s,%s,%s,%s)");
        self.cursor.execute(self.query,(datacenter,environment,clusterrole,packagename,esxcluster))
        datastore = self.cursor.fetchall()
        result = dict()
        record = []
        for data in datastore:
          if not data[1] == 'C':
            result['DATASTORE'] = data[0]
            result['DRIVE_LETTER'] = data[1]
            result['DRIVE_SIZE'] = data[2]
            record.append(result.copy())
        return record

    def get_Drivemap(self,datacenter,environment,clusterrole,packagename,esxcluster):
        self.query = ("SELECT DISTINCT DRIVE_NUMBER, DRIVE_LETTER, DRIVE_LABEL FROM GET_DATASTORES_ROLE_TEMPLATE(%s,%s,%s,%s,%s)");
        self.cursor.execute(self.query,(datacenter,environment,clusterrole,packagename,esxcluster))
        datastore = self.cursor.fetchall()
        result = dict()
        checks = []
        for data in datastore:
          if not data[1] == 'C':
            result['DRIVE_NUMBER'] = data[0]
            result['DRIVE_LETTER'] = data[1]
            result['DRIVE_LABEL'] = data[2]
            checks.append(result.copy())
        return checks

    def getwindowsDB(self,packagename):
        roles = []
        self.cursor.execute("select vt.CODE from VM_TYPE vt inner join PACKAGE_ROLE pr on pr.VM_TYPE_ID = vt.ID inner join PACKAGE p on p.ID = pr.PACKAGE_ID where vt.APP_FUNCTION_ID = 1 and p.name = '"+ packagename +"'")
        dbroles = self.cursor.fetchall()
        for role in dbroles:
          roles += role
        return roles

    def getConfigValueByKey(self,datacenter,key,session=None):
        try:
            self.cursor.execute("select CKTD.VALUE AS RESULT from CONFIGURATION_KEY_TO_DATACENTER cktd inner join CONFIGURATION_KEY ck on ck.id = cktd.CONFIGURATION_KEY_ID inner join DATACENTER d on d.ID = cktd.DATACENTER_ID where d.CODE ='" + datacenter + "' and ck.[KEY] = '"+key+"'")
            data = self.cursor.fetchone()
        except (Exception) as error:
            print(error)
            raise
        finally:
            if session:
              return data[0]
            self.conn.close()
            return data[0]

    def getprerequisiteurls(self,packagename,clusterrole,datacenter,sqladmin,saltaccount):
        dict = {}
        self.query = ("EXEC GET_PREREQISITE_URLS %s,%s,%s");
        self.cursor.execute(self.query,(packagename,clusterrole,datacenter))
        rows = self.cursor.fetchall()
        for row in rows:
          dict[row[0]] = row[1]
        dbroles = SaltJob.getwindowsDB(self,packagename)
        domain = SaltJob.getDomain(self,datacenter,session=True)
        if clusterrole in dbroles:
            domain = SaltJob.getDomain(self,datacenter,session=True).split('.')[0]
            roleversion = SaltJob.getRoleversion(self,packagename,clusterrole,session=True)
            RTname = SaltJob.getRoleTemplateName(self,datacenter,clusterrole,roleversion,packagename,session=True)
            backuppath = (SaltJob.getConfigValueByKey(self,datacenter,"CO_UDA_WIN_DB_BACKUPLOCATION",session=True))
            backupLocation = backuppath.replace("\\\\","\\")+"\\"+RTname
            #roleversion = SaltJob.getRoleVersionbyRoleandPackage(self,packagename,clusterrole)
            dict["domain_user"] =  domain+"\\"+ sqladmin
            dict["domain_pwd"] = (self.PMPClass.PMP_resource('Svc_Accounts',sqladmin)).replace('%','%%')
            dict["sa_pwd"] = (self.PMPClass.PMP_resource('vRATemplate','sa')).replace('%','%%')
            dict["smtp_host"] = SaltJob.getConfigValueByKey(self,datacenter,"SMART_SMTP_HOST")
            dict["backupLocation"] = backupLocation
        if clusterrole == 'UXD':
            dict["defaultuser"] = "root"
            dict["defaultuserpwd"] = (self.PMPClass.PMP_resource('uxdDefaultuser','defaultUser')).replace('%','%%')
        #dict["package_share_location"] = SaltJob.getPackageLocation(self,datacenter,packagename,session=True)
        dict["package_share_location"] = '\\\\\\\\' + domain + '\\\\UDASHARE' + '\\\\' + datacenter + "-packages" + '\\\\' + packagename
        dict["domain"] = domain
        dict["user"] = saltaccount
        dict["password"] = (self.PMPClass.PMP_resource(saltaccount,saltaccount))
        return dict

    def insertRoleTemplate(self,role,package,datacenter,templateName,templateDescription):
        try:
            self.cursor.execute("EXEC [INSERT_VM_ROLE_TEMPLATE] '"+role+"', '"+package+"', '"+datacenter+"', '"+templateName+"', '"+templateDescription+"'")
            self.conn.commit()
            rows = self.cursor.fetchall()
        except (Exception) as error:
            raise(error)
        finally:
            return True

    def getRoleTemplateName(self,datacenter,role,roleVersion,package,session=None):
        try:
            self.cursor.execute("select concat('"+datacenter+"', 'RT', (select id from package where name = '"+package+"'), '"+role+"', (select id from role_version where name = '"+roleVersion+"')) AS RESULT");
            record = self.cursor.fetchone()
        except (Exception) as error:
            raise(error)
        finally:
            if session:
              return record[0]
            self.conn.close()
            return record[0]

    def getRoleTemplateNamev1(self,datacenter,roles,package,session=None):
        RTvm = []
        try:
            for role in roles:
                self.cursor.execute("select concat('"+datacenter+"', 'RT', (select id from package where name = '"+package+"'), '"+role+"', (select id from role_version where name = (SELECT RV.NAME AS ROLVEVERSION FROM PACKAGE P INNER JOIN PACKAGE_ROLE PR ON P.id = PR.PACKAGE_ID INNER JOIN VM_TYPE VT ON VT.id = PR.VM_TYPE_ID JOIN ROLE_VERSION RV ON RV.id = PR.ROLE_VERSION_ID WHERE P.NAME ='" + package + "' and VT.CODE ='" + role + "'))) AS RESULT");
                record = self.cursor.fetchone()
                dataset = {'role':role,'instance': record[0]}
                RTvm.append(dataset)
        except (Exception) as error:
            raise(error)
        finally:
            if session:
              return RTvm
            self.conn.close()
            return RTvm

    def get_ConfigInfo(self,ClusterName):
        dict = {}
        self.cursor.execute("select distinct ck.[key] AS INFO,ckac.VALUE from CONFIGURATION_KEY_TO_APP_CLUSTER ckac inner join APP_CLUSTER ac on ac.ID = ckac.APP_CLUSTER_ID inner join CONFIGURATION_KEY ck on ck.id = ckac.CONFIGURATION_KEY_ID where ac.id = (select id from APP_CLUSTER where  name = '"+ ClusterName +"')")
        rows = self.cursor.fetchall()
        for row in rows:
          dict[row[0]] = row[1]
        return dict


    def isLinux(self,clusterRole):
        self.cursor.execute("SELECT AF.NAME AS RESULT FROM VM_TYPE VT INNER JOIN APP_FUNCTION AF on AF.ID = VT.APP_FUNCTION_ID WHERE VT.CODE = '"+clusterRole+"'")
        rows = self.cursor.fetchone()
        return rows[0]

    def getdata(self,result,datacenter):
        try:
            self.cursor.execute("SELECT "+ result +" AS RESULT FROM DATACENTER WHERE CODE = '"+ datacenter +"'")
            record = self.cursor.fetchone()
        except (Exception) as error:
            raise(error)
        finally:
            self.conn.close()
            return record[0]

    def getSmartHost(self,datacenter):
        try:
            self.cursor.execute("select CKTD.VALUE AS RESULT from CONFIGURATION_KEY_TO_DATACENTER cktd inner join CONFIGURATION_KEY ck on ck.id = cktd.CONFIGURATION_KEY_ID inner join DATACENTER d on d.ID = cktd.DATACENTER_ID where d.CODE ='" + datacenter + "' and ck.[KEY] = 'SMART_SMTP_HOST'")
            data = self.cursor.fetchone()
        except (Exception) as error:
            print(error)
            raise
        finally:
            self.conn.close()
            return data[0]

    def getTimeZone(self,datacenter):
        try:
            self.cursor.execute("select CKTD.VALUE AS RESULT from CONFIGURATION_KEY_TO_DATACENTER cktd inner join CONFIGURATION_KEY ck on ck.id = cktd.CONFIGURATION_KEY_ID inner join DATACENTER d on d.ID = cktd.DATACENTER_ID where d.CODE ='" + datacenter + "' and ck.[KEY] = 'TimeZone'")
            data = self.cursor.fetchone()
        except (Exception) as error:
            print(error)
            raise
        finally:
            self.conn.close()
            return data[0]

    def getPackageShare(self,datacenter):
        try:
            self.cursor.execute("select CKTD.VALUE AS RESULT from CONFIGURATION_KEY_TO_DATACENTER cktd inner join CONFIGURATION_KEY ck on ck.id = cktd.CONFIGURATION_KEY_ID inner join DATACENTER d on d.ID = cktd.DATACENTER_ID where d.CODE ='" + datacenter + "' and ck.[KEY] = 'PACKAGE_SHARE'")
            data = self.cursor.fetchone()
        except (Exception) as error:
            print(error)
            raise
        finally:
            self.conn.close()
            return data[0]

    def getTenantShare(self,datacenter):
        try:
            self.cursor.execute("select CKTD.VALUE AS RESULT from CONFIGURATION_KEY_TO_DATACENTER cktd inner join CONFIGURATION_KEY ck on ck.id = cktd.CONFIGURATION_KEY_ID inner join DATACENTER d on d.ID = cktd.DATACENTER_ID where d.CODE ='" + datacenter + "' and ck.[KEY] = 'TENANT_SHARE'")
            data = self.cursor.fetchone()
        except (Exception) as error:
            print(error)
            raise
        finally:
            self.conn.close()
            return data[0]

    def getLBResourceName(self,datacenter):
        try:
            self.cursor.execute("select CKTD.VALUE AS RESULT from CONFIGURATION_KEY_TO_DATACENTER cktd inner join CONFIGURATION_KEY ck on ck.id = cktd.CONFIGURATION_KEY_ID inner join DATACENTER d on d.ID = cktd.DATACENTER_ID where d.CODE ='" + datacenter + "' and ck.[KEY] = 'LB_RESOURCENAME'")
            data = self.cursor.fetchone()
        except (Exception) as error:
            print(error)
            raise
        finally:
            self.conn.close()
            return data[0]

    def getLBAccountName(self,datacenter):
        try:
            self.cursor.execute("select CKTD.VALUE AS RESULT from CONFIGURATION_KEY_TO_DATACENTER cktd inner join CONFIGURATION_KEY ck on ck.id = cktd.CONFIGURATION_KEY_ID inner join DATACENTER d on d.ID = cktd.DATACENTER_ID where d.CODE ='" + datacenter + "' and ck.[KEY] = 'LB_ACCOUNTNAME'")
            data = self.cursor.fetchone()
        except (Exception) as error:
            print(error)
            raise
        finally:
            self.conn.close()
            return data[0]

    def getWindowsResourceName(self,datacenter):
        try:
            self.cursor.execute("select CKTD.VALUE AS RESULT from CONFIGURATION_KEY_TO_DATACENTER cktd inner join CONFIGURATION_KEY ck on ck.id = cktd.CONFIGURATION_KEY_ID inner join DATACENTER d on d.ID = cktd.DATACENTER_ID where d.CODE ='" + datacenter + "' and ck.[KEY] = 'CO_WINDOWS_RESOURCENAME'")
            data = self.cursor.fetchone()
        except (Exception) as error:
            print(error)
            raise
        finally:
            self.conn.close()
            return data[0]

    def getWindowsAccountName(self,datacenter):
        try:
            self.cursor.execute("select CKTD.VALUE AS RESULT from CONFIGURATION_KEY_TO_DATACENTER cktd inner join CONFIGURATION_KEY ck on ck.id = cktd.CONFIGURATION_KEY_ID inner join DATACENTER d on d.ID = cktd.DATACENTER_ID where d.CODE ='" + datacenter + "' and ck.[KEY] = 'CO_WINDOWS_ACCOUNTNAME'")
            data = self.cursor.fetchone()
        except (Exception) as error:
            print(error)
            raise
        finally:
            self.conn.close()
            return data[0]

    def getSvcAccountOU(self,datacenter):
        try:
            self.cursor.execute("select CKTD.VALUE AS RESULT from CONFIGURATION_KEY_TO_DATACENTER cktd inner join CONFIGURATION_KEY ck on ck.id = cktd.CONFIGURATION_KEY_ID inner join DATACENTER d on d.ID = cktd.DATACENTER_ID where d.CODE ='" + datacenter + "' and ck.[KEY] = 'SVC_ACCOUNTS_OU'")
            data = self.cursor.fetchone()
        except (Exception) as error:
            print(error)
            raise
        finally:
            self.conn.close()
            return data[0]

    def getIPsubnet(self,networkname,session=None):
        subnetDetails = {}
        try:
            self.cursor.execute("select SUBNET,DEFAULT_GATEWAY,DVS_SWITCH from IP_SUBNET WITH (NOLOCK) where DIST_PORT_GROUP ='" + networkname + "'")
            data = self.cursor.fetchone()
            subnetmask = IPv4Network(data[0].replace(" ", "")).netmask
            subnetDetails['SUBNET'] = str(subnetmask)
            subnetDetails['DEFAULT_GATEWAY'] = data[1]
            subnetDetails['DVS_SWITCH'] = data[2]
        except (Exception) as error:
            print(error)
            raise
        finally:
            if session:
              return dict(subnetDetails)
            self.conn.close()
            return dict(subnetDetails)


    def getInstancevars(self,packageName,clusterrole,datacenter,environment,domainuser,numOfServers,**args):
        dataset = {}
        try:
             dataset['Roleversion'] = SaltJob.getRoleversion (self,packageName,clusterrole,True)
             dataset['esxCluster'] = SaltJob.esxClusterName(self,datacenter,environment,clusterrole,session=True)
             dataset['Datastore'] = SaltJob.RTdatastore(self,datacenter,environment,clusterrole,packageName,dataset['esxCluster'])
             Networks = SaltJob.ipSublist(self,clusterrole,datacenter,environment,session=True)
             dataset['baseTemplate'] = SaltJob.getBaseTemplate(self,datacenter,clusterrole,packageName,True)
             dataset['vmSize'] = SaltJob.getCPU_COUNT(self,packageName,clusterrole,session=True)
             getIPdetails = SaltJob.FindIp(self,Networks,datacenter,numOfServers,**args)
             dataset['retriveIP'] = getIPdetails[0]
             dataset['Networkadapter'] = SaltJob.getIPsubnet(self,dataset['retriveIP']['Port_Group'],session=True)
             dataset['Nameservers'] = SaltJob.Nameservers(self,datacenter,True)
             dataset['Domain'] = SaltJob.getDomain(self,datacenter,True)
             dataset['repoServer'] = SaltJob.repoServer(self,datacenter,True)
             dataset['instance'] = SaltJob.getRoleTemplateName(self,datacenter,clusterrole,dataset['Roleversion'],packageName,session=True)
             dataset['SaltMasters'] = SaltJob.getSaltMasters(self,datacenter)
             dataset['domainpasswd'] = self.PMPClass.PMP_resource(domainuser,domainuser)             
        except (Exception) as error:
            print(error)
            raise
        finally:
            self.conn.close()
            return dict(dataset)

    def cleanupIPAddresses(self):
        try:
            self.query="update vm set IP = NULL where id in (select id from vm with (nolock) where vm.ip is not NULL and (vm.powerstate = 'poweredOff' or vm.powerstate = 'deleted') and vm.id not in (select vm_id from app_cluster_vm acv with (nolock) inner join app_cluster ac with (nolock) on acv.APP_CLUSTER_ID = ac.id) and DateDiff(d, vm.check_in, GetDate()) > 31)"
            self.cursor.execute(self.query)
            self.conn.commit()
            return self.cursor.rowcount
        except (Exception) as error:
            raise Exception(error)
        finally:
            self.conn.close()

    def getConfigKey(self,configurationKey,session=None):
        try:
            self.query = ("SELECT DEFAULT_VALUE FROM CONFIGURATION_KEY WHERE [KEY] = '" + configurationKey + "'")
            self.cursor.execute(self.query)
            cofigkey = self.cursor.fetchone()
        except (Exception) as error:
            raise Exception(error)
        finally:
            if session:
              return cofigkey[0]
            self.conn.close()
            return cofigkey[0]

    def getClientFqdnClustersbyFqdn(self,fqdn,session=None):
        try:
            self.query = ("SELECT RESULT FROM GET_CLUSTERS_BY_FQDN('" + fqdn + "')")
            self.cursor.execute(self.query)
            fqdnclusters = self.cursor.fetchone()
        except (Exception) as error:
            raise Exception(error)
        finally:
            if session:
              return fqdnclusters
            self.conn.close()
            return fqdnclusters

    def getClusterbysiteKeyandRole(self,sitekey,role,session=None):
        try:
            self.query = ("select AC.NAME AS RESULT from CUSTOMER_ENVIRONMENT_TO_APP_CLUSTER CE2AC INNER JOIN APP_CLUSTER AC on AC.ID = CE2AC.APP_CLUSTER_ID INNER JOIN CUSTOMER_ENVIRONMENT CE on CE.ID = CE2AC.CUSTOMER_ENVIRONMENT_ID INNER JOIN VM_TYPE VMT on VMT.ID = AC.VM_TYPE_ID Where CE.SITE_KEY = '"+sitekey+"' and VMT.CODE = '"+role+"'")
            self.cursor.execute(self.query)
            cluster = self.cursor.fetchone()
        except (Exception) as error:
            raise Exception(error)
        finally:
            if session:
              return cluster
            self.conn.close()
            return cluster

    def getClientfqdnClusterbyFQDN(self,fqdn,session=None):
        try:
            self.query = ("SELECT RESULT FROM GET_CLUSTERS_BY_FQDN('" + fqdn + "')")
            self.cursor.execute(self.query)
            clientfqdn = self.cursor.fetchone()
        except (Exception) as error:
            raise Exception(error)
        finally:
            if session:
              return clientfqdn
            self.conn.close()
            return clientfqdn

    def getUDASHare(self,datacenter,session=None):
        try:
            self.query = ("select replace(ISILON_LOCATION,'\','\\\\'),replace(APP_PACKAGE_LOCATION,'\','\\\\') from DATACENTER WHERE CODE = '"+datacenter+"'")
            self.cursor.execute(self.query)
            udashare = self.cursor.fetchall()
        except (Exception) as error:
            raise Exception(error)
        finally:
            if session:
              return udashare
            self.conn.close()
            return list(udashare)

    def getvdomandfirewall(self,datacenter,session=None):
        try:
            self.query =("select v.name AS VDOM,f.name AS FIREWALL from vdom v inner join FIREWALL_PAIR_TO_VDOM fptv on fptv.VDOM_ID=v.id inner join FIREWALL_PAIR fp on fp.id=fptv.FIREWALL_PAIR_ID inner join firewall f on f.id=fp.FIREWALL_ID_1 where v.datacenter_id = (SELECT MAX(ID) FROM DATACENTER WHERE CODE='"+datacenter+"')")
            self.cursor.execute(self.query)
            vdomfirewall = self.cursor.fetchall()
        except (Exception) as error:
            raise Exception(error)
        finally:
            if session:
              return dict(vdomfirewall)
            self.conn.close()
            return vdomfirewall
