# -*- coding: utf-8 -*-
"""
:Module to provide connectivity to the CMDB
:depends:   - FreeTDS
            - pymssql Python module
"""

# Import python libs
from __future__ import absolute_import, print_function, unicode_literals

"""
#from json import JSONEncoder, loads
#from datetime import datetime
# from 192.cmdb_lib import Foo1
#import salt.ext.six as six
"""
import base64
import mssqlHelper
import logging
import sys
import logging
import uuid
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
import requests
import json
from xml.dom import minidom
from ipaddress import IPv4Network
logging.basicConfig(format='%(asctime)s - %(message)s')

try:
    import pymssql

    HAS_ALL_IMPORTS = True
except ImportError:
    HAS_ALL_IMPORTS = False
    print("Import Failed")


__virtualname__ = "addTenant"


def __virtual__():
    """
    Only load if import successful
    """
    if HAS_ALL_IMPORTS:
        return __virtualname__
    else:
        return (
            False,
            "The addTenant module cannot be loaded: dependent package(s) unavailable.",
        )

def append_dict(dict,key,value):
    dict[key]= value
    return dict

def getClusterID(connect, datacenter):
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
    msObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
    #msObj = mssqlHelper.mssqlHelper(connect)
    query = (
        "select SALT_CLUSTER_ID from DATACENTER where code ='" + datacenter + "'"
    )  # .format(datacenter)
    logging.debug(
        "Select command called with query: {0} and parameter: {1}".format(
            query, datacenter
        )
    )
    return msObj.fetchOne(query)

def isRoleDefined(connect, role, packageName):
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
    print(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
    msObj = mssqlHelper.mssqlHelper('DEV_CMDB_AG','installer','YMqUzCWD2ZwvpWrEY38P','CMDB')
    #msObj = mssqlHelper.mssqlHelper(connect)
    query = "SELECT P.ID AS RESULT FROM PACKAGE_ROLE AS PR INNER JOIN VM_TYPE VMT ON VMT.ID = PR.VM_TYPE_ID INNER JOIN PACKAGE P ON P.ID = PR.PACKAGE_ID WHERE VMT.CODE = '{0}' AND P.NAME = '{1}'".format(role, packageName)
    logging.debug("Select command called with query: {0} and parameters: {1},{2}".format(query, role, packageName))
    if msObj.fetchOne(query) is not None:
        return True
    else:
        return False

def getassociatedcluster(connect, clusterName):
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
    msObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
    #msObj = mssqlHelper.mssqlHelper(connect)
    query = ("select ac2.name as RESULT from app_cluster ac inner join app_cluster ac2 on ac.ASSOCIATE_APP_CLUSTER_ID = ac2.id where ac.name = '"+ clusterName + "'")
    logging.debug("Select command called with query: {0} and parameter: {1}".format(query, clusterName))
    return msObj.fetchOne(query)

def AddTenant_Association(connect, fqdn, AR, clusterDict, datacenter, packageName):
    #msObj = mssqlHelper.mssqlHelper(connect)
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
    msObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])

    try:
        clusterArray = []
        clustersAsString = ""
        RolestoCheck = ["UMD","CSD","UEC","HAM","UKA","UXD"]  # Please try to send there role variables fron VRO
        clusterArray.append(clusterDict["UUW"])
        clusterArray.append(clusterDict["UUD"])
        clusterArray.append(clusterDict["UGM"])
        if AR or datacenter != "GSL":
            clusterArray.append(clusterDict["URW"])
            clusterArray.append(clusterDict["UWD"])
        clusterArray.append(clusterDict["UTA"])
        clusterArray.append(clusterDict["USA"])
        clusterArray.append(clusterDict["UFS"])

        for role in RolestoCheck:
            logging.debug("Checking if role: '"+ role + "'  is defined for the packageName : '"+ packageName + "' ")
            query = "SELECT P.ID AS RESULT FROM PACKAGE_ROLE AS PR INNER JOIN VM_TYPE VMT ON VMT.ID = PR.VM_TYPE_ID INNER JOIN PACKAGE P ON P.ID = PR.PACKAGE_ID WHERE VMT.CODE = '" + role +"' AND P.NAME = '"+ packageName +"'"
            PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
            CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
            msObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
            #msObj = mssqlHelper.mssqlHelper(connect)
            if msObj.fetchOne(query) is not None and role == "UKA":
                clusterUKA = getassociatedcluster(connect, clusterDict["UEC"])
                clusterArray.append(clusterUKA)
            else:
                logging.info("Role :: "+role)
                clusterArray.append(clusterDict[role])
        for cluster in range(len(clusterArray)):
            #logging.info("Cluster " + cluster + ": " + clusterArray[cluster])
            if cluster > 0:
                clustersAsString = clustersAsString + "," + clusterArray[cluster]
            else:
                clustersAsString = clusterArray[cluster]

        logging.info("Clusters as a string: " + clustersAsString)
        PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
        CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
        msObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
        #msObj = mssqlHelper.mssqlHelper(connect)
        setCustomerEnv = msObj.executeSP("EXEC SET_CUSTOMER_ENVIRONMENT_TO_APP_CLUSTER '"+ fqdn + "','" + clustersAsString + "'")
        if setCustomerEnv:
            logging.info("Clusters successfully set in CMDB.")
            #print("AddTenant Association has been successfully set in CMDB")
            return True
        else:
            logging.error("Customer environment set failed with return code: "+ str(setCustomerEnv))
            #logging.warning("AddTenant Association has been unsuccessfull for clusters: "+ clustersAsString)
            return False

    except (Exception) as error:
        logging.error("AddTenant_Association function failed to associate customer environemnt with error " + error)
        raise Exception(error)

def getUDASHare(connect,datacenter):
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
    mssqlDBObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
    #msObj = mssqlHelper.mssqlHelper(connect)
    query = ("select replace(ISILON_LOCATION,'\','\\\\'),replace(APP_PACKAGE_LOCATION,'\','\\\\') from DATACENTER WHERE CODE = '"+datacenter+"'")
    logging.info("Query to get UDAshare info "+query)
    sharePath =  mssqlDBObj.fetchAll(query)
    logging.info("Sharepath location " +sharePath)
    if sharePath is not None:
      return sharePath
    else:
      logging.error("Failed to return sharepath from cmdb")
      return False

def getsiteKeyfromFQDN(connect,fqdn):
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
    mssqlDBObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
    #mssqlDBObj = mssqlHelper.mssqlHelper(connect)
    query = ("SELECT ce.[SITE_KEY] AS RESULT FROM [CUSTOMER_ENVIRONMENT] ce inner join CUSTOMER_ENVIRONMENT_HOST ceh on ce.ID=ceh.CUSTOMER_ENVIRONMENT_ID where ceh.HOST_ADDRESS='" + fqdn + "'")
    siteKey = mssqlDBObj.fetchOne(query)
    logging.info("SiteKey :: " +siteKey)
    if siteKey:
      return siteKey
    else:
      return False

def getClientfqdnClusterbyFQDN(connect,fqdn):
    fqdnclusters = []
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
    mssqlDBObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
    #mssqlDBObj = mssqlHelper.mssqlHelper(connect)
    query = ("SELECT RESULT FROM GET_CLUSTERS_BY_FQDN('" + fqdn + "')")
    clientfqdn = mssqlDBObj.fetchOne(query)
    logging.info("Client FQDN " +clientfqdn)
    return clientfqdn

def deleteCONFIGURATION_KEY_TO_CUSTOMER_ENVIRONMENT(connect,clientFQDN):
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
    mssqlDBObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
    #mssqlDBObj = mssqlHelper.mssqlHelper(connect)
    query = "DELETE FROM CONFIGURATION_KEY_TO_CUSTOMER_ENVIRONMENT WHERE CUSTOMER_ENVIRONMENT_ID = (SELECT CUSTOMER_ENVIRONMENT_ID FROM CUSTOMER_ENVIRONMENT_HOST WHERE HOST_ADDRESS='{0}') AND CONFIGURATION_KEY_ID= (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY]='UUD_RESTORE_TENANT_BAK')".format(clientFQDN)
    logging.debug("DELETE command called with query: {0} and parameters: {1}".format(query,clientFQDN))
    return mssqlDBObj.executeCommand(query)

def ck2acFromFQDN(connect,fqdn,configurationKey):
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
    mssqlDBObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
    #mssqlDBObj = mssqlHelper.mssqlHelper(connect)
    query = "Select VALUE AS RESULT from CONFIGURATION_KEY_TO_APP_CLUSTER CK2AC inner join CONFIGURATION_KEY CK ON CK.ID = CK2AC.CONFIGURATION_KEY_ID WHERE CK.[KEY] = '{0}' AND CK2AC.APP_CLUSTER_ID = (SELECT DISTINCT AC.ID FROM APP_CLUSTER AC INNER JOIN CUSTOMER_ENVIRONMENT_TO_APP_CLUSTER CETAC ON CETAC.APP_CLUSTER_ID=AC.ID INNER JOIN CUSTOMER_ENVIRONMENT_HOST CEH ON CEH.CUSTOMER_ENVIRONMENT_ID=CETAC.CUSTOMER_ENVIRONMENT_ID INNER JOIN VM_TYPE VMTY ON AC.VM_TYPE_ID=VMTY.ID INNER JOIN PACKAGE_ROLE PR ON PR.VM_TYPE_ID=VMTY.ID INNER JOIN ROLE_VERSION RV ON PR.ROLE_VERSION_ID=RV.ID AND AC.ROLE_VERSION_ID=RV.ID AND VMTY.IS_UDA='TRUE' AND VMTY.CODE='UXD' AND CEH.HOST_ADDRESS='{1}')".format(configurationKey,fqdn)
    #print(query)
    result = mssqlDBObj.fetchOne(query)
    cmdbResult = result if result != None else ""
    return cmdbResult

def environmentFromSitekey(connect,siteKey):
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
    mssqlDBObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
    #mssqlDBObj = mssqlHelper.mssqlHelper(connect)
    query = "SELECT CODE AS RESULT, CE.SITE_KEY FROM VM_TIER VMTI INNER JOIN CUSTOMER_ENVIRONMENT CE ON CE.VM_TIER_ID = VMTI.ID where ce.SITE_KEY = '{0}'".format(siteKey)
    logging.debug("Select command called with query: {0}".format(siteKey))
    result = mssqlDBObj.fetchOne(query)
    cmdbResult = result if result != None else ""
    return cmdbResult

def datacenterFromFQDN(connect,fqdn):
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
    mssqlDBObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
    #mssqlDBObj = mssqlHelper.mssqlHelper(connect)
    query = "SELECT D.CODE AS RESULT FROM DATACENTER_TO_VM_TIER DTVTI INNER JOIN DATACENTER D ON D.ID=DTVTI.DATACENTER_ID  INNER JOIN VM_TIER VMTI ON DTVTI.VM_TIER_ID= VMTI.ID  WHERE VMTI.CODE=(SELECT CODE AS RESULT FROM VM_TIER VMTI INNER JOIN CUSTOMER_ENVIRONMENT CE ON CE.VM_TIER_ID = VMTI.ID INNER JOIN CUSTOMER_ENVIRONMENT_HOST CEH ON CEH.CUSTOMER_ENVIRONMENT_ID = CE.ID WHERE CEH.HOST_ADDRESS = '{0}') AND D.GEO_LOCATION=(SELECT GEO_LOCATION AS RESULT FROM CUSTOMER_ENVIRONMENT CE INNER JOIN CUSTOMER_ENVIRONMENT_HOST CEH ON CEH.CUSTOMER_ENVIRONMENT_ID = CE.ID  WHERE CEH.HOST_ADDRESS = '{1}')".format(fqdn,fqdn)
    logging.debug("Select command called with query: {0}".format(fqdn))
    result = mssqlDBObj.fetchOne(query)
    cmdbResult = result if result != None else ""
    return cmdbResult
    
def CONFIG_KEY_TO_DATACENTER(connect,datacenter,configurationKey):
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
    mssqlDBObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
    #mssqlDBObj = mssqlHelper.mssqlHelper(connect)
    query = "SELECT CKTD.VALUE AS RESULT FROM CONFIGURATION_KEY_TO_DATACENTER CKTD INNER JOIN CONFIGURATION_KEY CK ON CK.ID = CKTD.CONFIGURATION_KEY_ID INNER JOIN DATACENTER D ON D.ID = CKTD.DATACENTER_ID WHERE D.CODE = '{0}' AND CK.[KEY] = '{1}'".format(datacenter,configurationKey)
    logging.debug("Select command called with query: {0}".format(query))
    result = mssqlDBObj.fetchOne(query)
    cmdbResult = result if result != None else ""
    return cmdbResult

def setcmdb_CONFIGURATION_KEY_TO_CUSTOMER_ENVIRONMENT(connect,siteKey,CONFIGURATION_KEY_KEY,CONFIGURATION_KEY_VALUE):
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
    mssqlDBObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
    #mssqlDBObj = mssqlHelper.mssqlHelper(connect)
    query = "INSERT INTO CONFIGURATION_KEY_TO_CUSTOMER_ENVIRONMENT (VALUE,CONFIGURATION_KEY_ID,CUSTOMER_ENVIRONMENT_ID) (SELECT '{0}',CK.ID,CE.ID FROM CONFIGURATION_KEY CK,CUSTOMER_ENVIRONMENT CE WHERE CK.[KEY]='{1}' AND CE.[SITE_KEY]='{2}' AND NOT EXISTS (SELECT 1 FROM CONFIGURATION_KEY_TO_CUSTOMER_ENVIRONMENT WHERE CUSTOMER_ENVIRONMENT_ID=CE.ID AND CONFIGURATION_KEY_ID=CK.ID))".format(CONFIGURATION_KEY_VALUE,CONFIGURATION_KEY_KEY,siteKey)
    logging.debug("Insert command called with query: {0}".format(query))
    return mssqlDBObj.executeCommand(query)

def addTenantUpdateConfigValues(connect,fqdn,siteKey,AR,packageName,AUDIT_ENABLED,environment,datacenter,UUD_RESTORE_TENANT_BAK=None):
    #mssqlDBObj = mssqlHelper.mssqlHelper(connect)
    databaseNames = []
    userNames = []
    resourceCreate = []
    TENANT_KEY = siteKey
    cmdbAdditions = {"CONFIGURATION_KEY_KEY":[],"CONFIGURATION_KEY_VALUE":[]}
    cmdbAdditions["CONFIGURATION_KEY_KEY"].append("TENANT_KEY")
    cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(TENANT_KEY)
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    #tenantKey = connect.siteKey
    if AR :
         UWD_DB_NAME = siteKey + "_UWD_db"
         databaseNames.append(UWD_DB_NAME)
         cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UWD_DB_NAME")
         cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(UWD_DB_NAME)           
         UWD_DB_USER = siteKey + "_UWD_dbadmin"
         userNames.append(UWD_DB_USER)
         cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UWD_DB_USER")
         cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(UWD_DB_USER) 
         UWD_JS_USER = "UWD_JASPER_USER_" + siteKey
         userNames.append(UWD_JS_USER)
         cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UWD_JASPERSOFT_USER")
         cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(UWD_JS_USER)
         UWD_JS_DB = "UWD_JS_DB_" + siteKey
         databaseNames.append(UWD_JS_DB)
         #cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UWD_JS_DB")
         #cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(UWD_JS_DB)
           
    cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UUD_RESTORE_TENANT_BAK")
    print(UUD_RESTORE_TENANT_BAK)
    if UUD_RESTORE_TENANT_BAK is None:
        UUD_RESTORE_TENANT_BAK = ''
        print(UUD_RESTORE_TENANT_BAK)
    cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(UUD_RESTORE_TENANT_BAK)
    UUD_DB_NAME = siteKey + "_UUD_db"
    databaseNames.append(UUD_DB_NAME)
    cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UUD_DB_NAME")
    cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(UUD_DB_NAME)
    UUD_DB_USER = siteKey + "_UUD_dbadmin"
    userNames.append(UUD_DB_USER)
    cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UUD_DB_USER")
    cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(UUD_DB_USER)

    UFS_TENANT_SHARE_LOCATION = "d:\\tenantShares\\" + siteKey
    cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UFS_TENANT_SHARE_LOCATION")
    cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(UFS_TENANT_SHARE_LOCATION)
    
    cmdbAdditions["CONFIGURATION_KEY_KEY"].append("TENANT_FQDN")
    cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(fqdn)

    cmdbAdditions["CONFIGURATION_KEY_KEY"].append("AUDIT_ENABLED")
    cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(AUDIT_ENABLED)

    for c in range(len(databaseNames)):
        #print(c)
        if c == 0:
            resourceCreate.append(True)
        else:
            resourceCreate.append(False)
    resourceType = "MS SQL Server"
    initialPassword = []
    for i in range(len(databaseNames)):
        print("Database Name: {0}, accountName:{1},resourceName:{2},resourceCreate:{3}".format(databaseNames[i],userNames[i],siteKey,resourceCreate[i]))
        #connect.PMPClass.add_resource(userNames[i],siteKey,resourceCreate[i],resourceType)
        PMPClass.winadd_dbresource(userNames[i],siteKey,databaseNames[i],resourceCreate[i],resourceType)
        initialPassword.append(PMPClass.PMP_resource(siteKey,userNames[i]))
    #for u in userNames:
    #    print("User Name: {0} ".format(u))
    #for b in resourceCreate:
    #    print("Resource Name: {0}".format(b))
    print(initialPassword)
    if AR:
        cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UWD_DB_PASSWORD")
        cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(initialPassword[0])
        cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UWD_JASPERSOFT_PASSWORD")
        cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(initialPassword[1])
        cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UUD_DB_PASSWORD")
        cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(initialPassword[2])
    else:
        cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UUD_DB_PASSWORD")
        cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(initialPassword[0])
           
    if isRoleDefined(connect,"UXD",packageName):
        """
        UXD_DB_SERVER = connect.ck2acFromFQDN(fqdn,"UXD_DB_SERVER")
        cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UXD_DB_SERVER")
        cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(UXD_DB_SERVER)
        UXD_ADMIN_USER = connect.ck2acFromFQDN(fqdn,"UXD_ADMIN_USER")
        cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UXD_ADMIN_USER")
        cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(UXD_ADMIN_USER)
        UXD_ADMIN_PASSWORD = connect.ck2acFromFQDN(fqdn,"UXD_ADMIN_PASSWORD")
        cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UXD_ADMIN_PASSWORD")
        cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(UXD_ADMIN_PASSWORD)
        UXD_DB_PORT = connect.ck2acFromFQDN(fqdn,"UXD_DB_PORT")
        cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UXD_DB_PORT")
        cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(UXD_DB_PORT)
        UXD_DB_INSTANCE = connect.ck2acFromFQDN(fqdn,"UXD_DB_INSTANCE")
        cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UXD_DB_INSTANCE")
        cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(UXD_DB_INSTANCE)
        """
        UXD_TENANT_DB_NAME = "uxd" + siteKey
        UXD_TENANT_DB_NAME = UXD_TENANT_DB_NAME.replace("_","")
        UXD_TENANT_DB_NAME = UXD_TENANT_DB_NAME.replace(" ","")
        UXD_TENANT_DB_NAME = UXD_TENANT_DB_NAME.replace("-","")
        cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UXD_TENANT_DB_NAME")
        cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(UXD_TENANT_DB_NAME)

        UXD_TENANT_DB_USER = siteKey
        UXD_TENANT_DB_USER = UXD_TENANT_DB_USER.replace("_","")
        UXD_TENANT_DB_USER = UXD_TENANT_DB_USER.replace(" ","")
        UXD_TENANT_DB_USER = UXD_TENANT_DB_USER.replace("-","")
        if len(UXD_TENANT_DB_USER) > 22:
            UXD_TENANT_DB_USER = UXD_TENANT_DB_USER[0:22]
        UXD_TENANT_DB_USER = UXD_TENANT_DB_USER + "uxddbadmin"
        print(UXD_TENANT_DB_USER)
        cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UXD_TENANT_DB_USER")
        cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(UXD_TENANT_DB_USER)
        resourceName = siteKey + "UXD"
        pwToUse = ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(14))
        pwToUse = pwToUse + "#7"
        print(pwToUse)
        #connect.PMPClass.add_resource(UXD_TENANT_DB_USER,pwToUse,ResourceName,"Linux")
        print(PMPClass.add_resource(UXD_TENANT_DB_USER,pwToUse,resourceName,"Linux"))
        adminPassword = PMPClass.PMP_resource(resourceName,UXD_TENANT_DB_USER)
        print(adminPassword)
        cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UXD_TENANT_DB_PASSWORD")
        cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(adminPassword)

    if isRoleDefined(connect,"UMD",packageName):
        UMD_TENANT_DB_NAME = "umd" + siteKey
        UMD_TENANT_DB_NAME = UMD_TENANT_DB_NAME.replace("_","")
        UMD_TENANT_DB_NAME = UMD_TENANT_DB_NAME.replace(" ","")
        UMD_TENANT_DB_NAME = UMD_TENANT_DB_NAME.replace("-","")
        cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UMD_TENANT_DB_NAME")
        cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(UMD_TENANT_DB_NAME)

        UMD_TENANT_DB_USER = siteKey + "umddbadmin"
        UMD_TENANT_DB_USER = UMD_TENANT_DB_USER.replace("_","")
        UMD_TENANT_DB_USER = UMD_TENANT_DB_USER.replace(" ","")
        UMD_TENANT_DB_USER = UMD_TENANT_DB_USER.replace("-","")
        cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UMD_TENANT_DB_USER")
        cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(UMD_TENANT_DB_USER)
        resourceName = siteKey + "UMD"
        pwToUse = ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(14))
        pwToUse = pwToUse + "!7"
        print(pwToUse)
        #connect.PMPClass.add_resource(UXD_TENANT_DB_USER,pwToUse,ResourceName,"Linux")
        print(PMPClass.add_resource(UMD_TENANT_DB_USER,pwToUse,resourceName,"Linux"))
        adminPassword = PMPClass.PMP_resource(resourceName,UMD_TENANT_DB_USER)
        print(adminPassword)
        cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UMD_TENANT_DB_PASSWORD")
        cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(adminPassword)

    if isRoleDefined(connect,"CSD",packageName):
        CSD_DB_NAME = "csd" + siteKey
        CSD_DB_NAME = CSD_DB_NAME.replace("_","")
        CSD_DB_NAME = CSD_DB_NAME.replace(" ","")
        CSD_DB_NAME = CSD_DB_NAME.replace("-","")
        cmdbAdditions["CONFIGURATION_KEY_KEY"].append("CSD_DB_NAME")
        cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(CSD_DB_NAME)

        CSD_DB_USER = siteKey + "csddbadmin"
        CSD_DB_USER = CSD_DB_USER.replace("_","")
        CSD_DB_USER = CSD_DB_USER.replace(" ","")
        CSD_DB_USER = CSD_DB_USER.replace("-","")
        cmdbAdditions["CONFIGURATION_KEY_KEY"].append("CSD_DB_USER")
        cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(CSD_DB_USER)
        resourceName = siteKey + "CSD"
        pwToUse = ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits + "!@#$%^&*()") for _ in range(16))
        #connect.PMPClass.add_resource(UXD_TENANT_DB_USER,pwToUse,ResourceName,"Linux")
        print(PMPClass.add_resource(CSD_DB_USER,pwToUse,resourceName,"Linux"))
        adminPassword = PMPClass.PMP_resource(resourceName,CSD_DB_USER)
        print(adminPassword)
        cmdbAdditions["CONFIGURATION_KEY_KEY"].append("CSD_DB_PWD")
        cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(adminPassword)

    # UFSV2 added for 21.1 and up, key is in cmdb so this can be added even for older builds.        
    #environment = environmentFromSitekey(connect,siteKey)
    #datacenter = datacenterFromFQDN(connect,fqdn)
    ufsv2Root = CONFIG_KEY_TO_DATACENTER(connect,datacenter,'UFSV2_SHARE_LOCATION')
    ufsv2ShareLocation = ufsv2Root + "\\" + environment + "\\" + siteKey 
    cmdbAdditions["CONFIGURATION_KEY_KEY"].append("UFSV2_TENANT_SHARE_LOCATION")
    cmdbAdditions["CONFIGURATION_KEY_VALUE"].append(ufsv2ShareLocation)

    print(len(cmdbAdditions["CONFIGURATION_KEY_KEY"]))
    for i in range(0,len(cmdbAdditions["CONFIGURATION_KEY_KEY"])):
        print(cmdbAdditions["CONFIGURATION_KEY_KEY"][i],cmdbAdditions["CONFIGURATION_KEY_VALUE"][i])
        rowsAffected = setcmdb_CONFIGURATION_KEY_TO_CUSTOMER_ENVIRONMENT(connect,siteKey,cmdbAdditions["CONFIGURATION_KEY_KEY"][i],cmdbAdditions["CONFIGURATION_KEY_VALUE"][i])
        if rowsAffected == 0:
           logging.debug("Config key is already inserted into the DB")
    return cmdbAdditions

def get_INSTALL_TENANT(connect,siteKey,packageName,workflow):
    executionorder = {}
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
    mssqlDBObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
    #mssqlDBObj = mssqlHelper.mssqlHelper(connect)
    logging.info("Getting Role execution order for package " +packageName)
    query = ("EXEC GET_SERVERS_TO_INSTALL_TENANT_WORKFLOWS '"+siteKey+"','"+packageName+"','"+workflow+"'")
    records =  mssqlDBObj.fetchAll(query)
    return records
    for i in range(len(records)):
        #print("Range i " +str(i))
        executionorder["ROLE_CODE"].append(records[i])
        executionorder["CLUSTER"].append(records[i][2])
        executionorder["FIRST_SERVER"].append(records[i][3])
        executionorder["EXECUTE_FROM"].append(records[i][4])
        executionorder["EXECUTE_ON"].append(records[i][5])
        executionorder["OS_TYPE"].append(records[i][6])
        executionorder["EXECUTE_ORDER"].append(records[i][7])
    return executionorder


def getcmdb_uuwServerForUfsExec(connect,siteKey):
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
    mssqlDBObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])    
    #mssqlDBObj = mssqlHelper.mssqlHelper(connect)
    query = ("SELECT TOP 1 VM.NAME AS RESULT FROM CUSTOMER_ENVIRONMENT CE "
            "INNER JOIN CUSTOMER_ENVIRONMENT_TO_APP_CLUSTER CETAC ON CETAC.CUSTOMER_ENVIRONMENT_ID=CE.ID INNER JOIN APP_CLUSTER_VM ACVM ON ACVM.APP_CLUSTER_ID=CETAC.APP_CLUSTER_ID "
            "INNER JOIN APP_CLUSTER AC ON AC.ID= CETAC.APP_CLUSTER_ID INNER JOIN VM_TYPE VMTY ON VMTY.ID= AC.VM_TYPE_ID INNER JOIN VM ON ACVM.VM_ID=VM.ID "
            "WHERE CE.SITE_KEY='{0}' AND VMTY.CODE='UUW' AND VM.NAME <> '' order by vm.id desc".format(siteKey))
        #print(query)
    logging.debug("Select command called with query: {0}".format(query))
    result = mssqlDBObj.fetchOne(query)
    cmdbResult = result if result != None else ""
    return cmdbResult

def getcmdb_uuwServerForUxdExec(connect,siteKey):
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
    mssqlDBObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
    #mssqlDBObj = mssqlHelper.mssqlHelper(connect)
    query = ("SELECT TOP 1 VM.NAME AS RESULT FROM CUSTOMER_ENVIRONMENT CE "
            "INNER JOIN CUSTOMER_ENVIRONMENT_TO_APP_CLUSTER CETAC ON CETAC.CUSTOMER_ENVIRONMENT_ID=CE.ID INNER JOIN APP_CLUSTER_VM ACVM ON ACVM.APP_CLUSTER_ID=CETAC.APP_CLUSTER_ID "
            "INNER JOIN APP_CLUSTER AC ON AC.ID= CETAC.APP_CLUSTER_ID INNER JOIN VM_TYPE VMTY ON VMTY.ID= AC.VM_TYPE_ID INNER JOIN VM ON ACVM.VM_ID=VM.ID "
            "WHERE CE.SITE_KEY='{0}' AND VMTY.CODE='UUW' AND VM.NAME <> '' order by vm.id desc".format(siteKey))
        #print(query)
    logging.debug("Select command called with query: {0}".format(query))
    result = mssqlDBObj.fetchOne(query)
    cmdbResult = result if result != None else ""
    return cmdbResult

def getcmdb_clusterFirstvm(connect,clusterName):
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
    mssqlDBObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
    #mssqlDBObj = mssqlHelper.mssqlHelper(connect)
    query = ("SELECT Top 1 DNSNAME AS RESULT FROM VM INNER JOIN APP_CLUSTER_VM ACVM ON ACVM.VM_ID = VM.ID INNER JOIN APP_CLUSTER AC ON AC.ID = ACVM.APP_CLUSTER_ID WHERE AC.NAME='" + clusterName + "'")
    logging.debug("Select command called with query: {0}".format(query))
    result = mssqlDBObj.fetchOne(query)
    if result != None:
      return result
    else:
      return False

def isRoleDefinedTest(connect, role, packageName):
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
    mssqlDBObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
    query = "SELECT P.ID AS RESULT FROM PACKAGE_ROLE AS PR INNER JOIN VM_TYPE VMT ON VMT.ID = PR.VM_TYPE_ID INNER JOIN PACKAGE P ON P.ID = PR.PACKAGE_ID WHERE VMT.CODE = '{0}' AND P.NAME = '{1}'".format(role, packageName)
    logging.debug("Select command called with query: {0} and parameters: {1},{2}".format(query, role, packageName))
    if mssqlDBObj.fetchOne(query) is not None:
        return True
    else:
        return False

def setcmdb_removePodReservation(connect, siteKey):
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
    mssqlDBObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
    query = "delete from POD_RESERVATION where sitekey = '{0}' and POD_ID = (select distinct pod.id from pod inner join POD_TO_APP_CLUSTER PAC on pac.POD_ID = pod.id inner join app_cluster ac on ac.id = pac.APP_CLUSTER_ID inner join CUSTOMER_ENVIRONMENT_TO_APP_CLUSTER ce2ac on ce2ac.APP_CLUSTER_ID = ac.id inner join customer_environment ce on ce.id = ce2ac.CUSTOMER_ENVIRONMENT_ID where ce.SITE_KEY = '{1}')".format(siteKey,siteKey)
    logging.debug("Delete command called with the query {0} for tenant {1}".format(query,siteKey))
    return mssqlDBObj.executeCommand(query)

def removePODReservation(connect, environment, siteKey):
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
    mssqlDBObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
    if environment.upper() == 'PROD' or environment.upper() == 'STAGE':
        query = "select pr.id as RESULT from pod_reservation pr inner join pod on pod.id = pr.pod_id inner join pod_type pty on pod.POD_TYPE_ID = pty.id inner join datacenter d on d.id = pod.DATACENTER_ID inner join vm_tier vti on vti.id = pod.VM_TIER_ID where pr.sitekey = '{0}'".format(siteKey)
        if mssqlDBObj.fetchOne(query):
            if setcmdb_removePodReservation(connect,siteKey) > 0:
                logging.debug("Successfully removed reservation for tenant {0}".format(siteKey))
            else:
                logging.error("Unable to remove the pod reservation in the CMDB for siteKey {0}.  Please remove this reservation manually.".format(siteKey))
        else:
            logging.debug("There is no reservation to remove for this tenant {0}".format(siteKey))

def getcmdbConfigValues(connect, siteKey):
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
    mssqlDBObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
    query = ("select CK.[KEY] as [KEY], CK2AC.[VALUE] as [VALUE] from CONFIGURATION_KEY_TO_APP_CLUSTER CK2AC \n"
             " INNER JOIN CUSTOMER_ENVIRONMENT_TO_APP_CLUSTER CE2AC ON CK2AC.APP_CLUSTER_ID=CE2AC.APP_CLUSTER_ID \n"
             " INNER JOIN CUSTOMER_ENVIRONMENT CE ON CE2AC.CUSTOMER_ENVIRONMENT_ID = CE.ID \n"
             " INNER JOIN APP_CLUSTER AC on CK2AC.APP_CLUSTER_ID = AC.ID \n"
             " INNER JOIN CONFIGURATION_KEY CK on CK2AC.CONFIGURATION_KEY_ID = CK.ID \n"
             " WHERE CE.SITE_KEY = '{0}' \n"
             " and CK.[KEY] in ('UWD_DB_SERVER','UWD_ADMIN_USER','UWD_ADMIN_PASSWORD','UUD_DB_SERVER','UUD_ADMIN_USER','UUD_ADMIN_PASSWORD')").format(siteKey)
    logging.debug("Select command called with the query {0} for tenant {1}".format(query,siteKey))
    return mssqlDBObj.fetchAllToDict(query)

def getDatabaseName(connect, role, siteKey):
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
    mssqlDBObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
    query = ("select CK2CE.VALUE AS RESULT from CUSTOMER_ENVIRONMENT ce \n"
             "INNER JOIN CONFIGURATION_KEY_TO_CUSTOMER_ENVIRONMENT CK2CE ON CK2CE.CUSTOMER_ENVIRONMENT_ID=CE.ID \n"
             "Inner join CONFIGURATION_KEY ck on ck.id = CK2CE.CONFIGURATION_KEY_ID \n"
             "where ck.[key]='{0}_DB_NAME' and ce.SITE_KEY = '{1}'").format(role,siteKey)
    logging.debug("Select command called with the query {0} for tenant {1}".format(query,siteKey))
    return mssqlDBObj.fetchOne(query)


def postValidationSteps(connect, role, siteKey, environment):
    if role.upper() == 'UUD' or role.upper() == "UWD":
        data = getcmdbConfigValues(connect,siteKey)
        print(data)
        serverName = data[role+"_DB_SERVER"]
        userName = data[role+"_ADMIN_USER"]
        password = data[role+"_ADMIN_PASSWORD"]
        dbName = 'master'
        if role.upper() == 'UUD':
            logging.debug("disableJobsQuery for tenant {0}".format(siteKey))
            disableJobsQuery = ("use msdb \n"
                                "DECLARE @tenantName nvarchar(128) \n"
                                "SET @tenantName = '{0}' \n"
                                "DECLARE @cursor cursor \n"
                                "DECLARE @sysjobsdisable Table (name nvarchar(128)) \n"
                                "insert into @sysjobsdisable (name) \n"
                                "select name from sysjobs where name like '%' + @tenantName + '%' and name not like '%NightlyCleanup%' \n"
                                "set @cursor = cursor local fast_forward for \n"
                                "select * from @sysjobsdisable order by name asc \n"
                                "open @cursor \n"
                                "DECLARE @sysjobname nvarchar(128) \n"
                                "WHILE 1=1 BEGIN \n"
                                "FETCH NEXT FROM @cursor INTO @sysjobname \n"
                                "if @@fetch_status <> 0 break \n"
                                "EXEC msdb.dbo.sp_update_job @job_name = @sysjobname, @enabled = 0 \n"
                                "PRINT N'Job ' + @sysjobname + ' disabled' \n"
                                "END \n"
                                "close @cursor \n"
                                "deallocate @cursor").format(siteKey)
            mssqlDBObj2 = mssqlHelper.mssqlHelper(serverName,userName,password,dbName)
            logging.debug("Disable Jobs query command called on {0} with the query {1} for tenant {2}".format(role,disableJobsQuery,siteKey))
            output =  mssqlDBObj2.executeQuery(disableJobsQuery,session=True)
            if output:
               logging.debug("Disable Job script ran without any issues")
            else:
               logging.debug("disableJobsQuery script has failed. Please run manually execute the query {0}".format(disableJobsQuery))
            UUD_DB_Name = getDatabaseName(connect,role,siteKey)
            if environment.upper() == "PROD":
                setRecoveryModeQuery = "ALTER DATABASE {0} SET RECOVERY FULL".format(UUD_DB_Name)
                output =  mssqlDBObj2.executeDDL(setRecoveryModeQuery,session=True)
                if output:
                   logging.debug("setRecoveryModeQuery script ran without any issues")
                else:
                   logging.debug("setRecoveryModeQuery script has failed. Please run manually execute the query {0}".format(setRecoveryModeQuery))
                logging.debug("setRecoveryMode query command called on {0} with the query {1} for tenant {2}".format(role,setRecoveryModeQuery,siteKey))
            else:
                setRecoveryModeQuery = "ALTER DATABASE {0} SET RECOVERY SIMPLE".format(UUD_DB_Name)
                output =  mssqlDBObj2.executeDDL(setRecoveryModeQuery,session=True)
                if output:
                   logging.debug("setRecoveryModeQuery script ran without any issues")
                else:
                   logging.debug("setRecoveryModeQuery script has failed. Please run manually execute the query {0}".format(setRecoveryModeQuery))
                logging.debug("setRecoveryMode query command called on {0} with the query {1} for tenant {2}".format(role,setRecoveryModeQuery,siteKey))
            grantAlterTraceQuery = "use master GRANT ALTER TRACE TO {0}_UUD_dbadmin".format(siteKey)
            output =  mssqlDBObj2.executeQuery(grantAlterTraceQuery,session=True)
            if output:
               logging.debug("grantAlterTraceQuery script ran without any issues")
            else:
               logging.debug("grantAlterTraceQuery script has failed. Please run manually execute the query {0}".format(grantAlterTraceQuery))
            logging.debug("grantAlterTraceQuery query command called on {0} with the query {1} for tenant {2}".format(role,grantAlterTraceQuery,siteKey))
            #indexOptimizeQuery = "EXECUTE [dbo].[IndexOptimize] @Databases = '{0}'".format(UUD_DB_NAME)
            indexOptimizeQuery = ("use dbaAdmin \n"
                                  "EXECUTE [dbo].[IndexOptimize] @Databases = '{0}'").format(UUD_DB_Name)
            output =  mssqlDBObj2.executeQuery(indexOptimizeQuery,session=False)
            if output:
               logging.debug("indexOptimizeQuery script ran without any issues")
            else:
               logging.debug("indexOptimizeQuery script has failed. Please run manually execute the query {0}".format(indexOptimizeQuery))
            logging.debug("indexOptimizeQuery query command called on {0} with the query {1} for tenant {2}".format(role,indexOptimizeQuery,siteKey))
        if role.upper() == 'UWD':
            disableJobsQuery = ("use msdb \n"
                                "DECLARE @tenantName nvarchar(128) \n"
                                "SET @tenantName = '{0}' \n"
                                "DECLARE @cursor cursor \n"
                                "DECLARE @sysjobsdisable Table (name nvarchar(128)) \n"
                                "insert into @sysjobsdisable (name) \n"
                                "select name from sysjobs where name like 'ReportingETL_' + @tenantName + '%' \n"
                                "set @cursor = cursor local fast_forward for \n"
                                "select * from @sysjobsdisable order by name asc \n"
                                "open @cursor \n"
                                "DECLARE @sysjobname nvarchar(128) \n"
                                "WHILE 1=1 BEGIN \n"
                                "FETCH NEXT FROM @cursor INTO @sysjobname \n"
                                "if @@fetch_status <> 0 break \n"
                                "EXEC msdb.dbo.sp_update_job @job_name = @sysjobname, @enabled = 0 \n"
                                "PRINT N'Job ' + @sysjobname + ' disabled' \n"
                                "END \n"
                                "close @cursor \n"
                                "deallocate @cursor").format(siteKey)
            mssqlDBObj2 = mssqlHelper.mssqlHelper(serverName,userName,password,dbName)
            output =  mssqlDBObj2.executeQuery(disableJobsQuery,session=True)
            if output:
               logging.debug("Disable Job script ran without any issues")
            else:
               logging.debug("disableJobsQuery script has failed. Please run manually execute the query {0}".format(disableJobsQuery))
            logging.debug("Disable Jobs query command called on {0} with the query {1} for tenant {2}".format(role,disableJobsQuery,siteKey))
            UWD_DB_Name = getDatabaseName(connect,role,siteKey)
            setRecoveryModeQuery = "ALTER DATABASE {0} SET RECOVERY SIMPLE".format(UWD_DB_Name)
            output =  mssqlDBObj2.executeDDL(setRecoveryModeQuery,session=False)
            if output:
               logging.debug("setRecoveryModeQuery script ran without any issues")
            else:
               logging.debug("setRecoveryModeQuery script has failed. Please run manually execute the query {0}".format(setRecoveryModeQuery))
            logging.debug("setRecoveryMode query command called on {0} with the query {1} for tenant {2}".format(role,setRecoveryModeQuery,siteKey))

def getCNameDestinationCDN(connect,environment,datacenter):
    PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
    CMDB_Passwd = PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
    mssqlDBObj = mssqlHelper.mssqlHelper(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
    query = ("SELECT DCTVT.FQDN AS RESULT, * FROM DATACENTER_TO_VM_TIER DCTVT \n"
             "INNER JOIN VM_TIER VMTI ON VMTI.ID=DCTVT.VM_TIER_ID \n"
             "INNER JOIN DATACENTER D ON D.ID=DCTVT.DATACENTER_ID \n"
             "WHERE D.CODE = '{0}' AND VMTI.CODE = '{1}'").format(datacenter,environment)
    logging.debug("Select command called with the query {0} ".format(query))
    returnValue = mssqlDBObj.fetchOne(query)
    return returnValue.split('_')[1]

def getOriginId(contentSwitch,cdnHostAddress,cdnAcountName,cdnAuthToken):
    try:
        myHeaders = {}
        myHeaders['Authorization']= cdnAuthToken
        myHeaders['Content-type']= 'application/json'
        response = requests.get('https://%s/v2/mcc/customers/%s/origins/adn' % (cdnHostAddress,cdnAcountName), headers=myHeaders)
        originId = ""
        responseJson = json.loads(response.text)
    except Exception as error:
        print("Exception is: %s"%(error))

    if response.status_code >= 400:
        logging.debug("Unable to successfully retrieve the Orgin id's from Edgecast")
        logging.debug("This will need manual intervention")
        logging.debug("HTTPError: status code: %s" %(response.status_code))
        
    else:
        for data in responseJson:
            if data['DirectoryName'] == contentSwitch:
                originId= data['Id']
                logging.debug("The originID for %s is %s "%(contentSwitch,originId))
                break
    return originId

def getAllCNamesCDN(contentSwitch,cdnHostAddress,cdnAcountName,cdnAuthToken,fqdn,originId):
    try:
        myHeaders = {}
        myHeaders['Authorization']= cdnAuthToken
        myHeaders['Content-type']= 'application/json'
        response = requests.get('https://%s/v2/mcc/customers/%s/cnames/adn' % (cdnHostAddress,cdnAcountName), headers=myHeaders)
        responseJson = json.loads(response.text)
    except Exception as error:
        logging.error("Exception has occurred. Exception:{0}".format(error))
    if response.status_code >= 400:
        logging.debug("Unable to successfully retrieve the Orgin id's from Edgecast")
        logging.debug("This will need manual intervention")
        logging.debug("HTTPError: status code: %s" %(response.status_code))
        cdnExists = True
    else:
        for data in responseJson:
            cdnExists = False
            if data['Name'] == fqdn.lower():
                logging.debug("The customerFDQN already exists for %s"%(fqdn.lower()))
                if data['OriginId'] != originId:
                    logging.debug("WARNING:  IT IS POINTING TO ORGIN ID %s and contentswitch %s" %(str(data['OriginId'])))
                    logging.debug("THIS REQUEST SHOULD HAVE IT POINT TO %s for %s" %(originId,contentSwitch))
                else:
                    logging.debug("The orgin ID is already correctly set to %s for %s" %(originId,fqdn))
                    cdnExists= True
                    break
    return cdnExists

def addFQDNToCDN(contentSwitch,cdnHostAddress,cdnAcountName,cdnAuthToken,fqdn,originId):
    try:
        content="<CustomerCnameParameter xmlns=\"http://www.whitecdn.com/schemas/apiservices/\"><DirPath></DirPath><MediaTypeId>14</MediaTypeId><Name>{0}</Name><OriginId>{1}</OriginId><EnableCustomReports>1</EnableCustomReports></CustomerCnameParameter>".format(fqdn,originId)
        myHeaders = {}
        myHeaders['Authorization']= cdnAuthToken
        myHeaders['Content-type']= 'application/xml'
        response = requests.post('https://%s/v2/mcc/customers/%s/cnames' % (cdnHostAddress,cdnAcountName),data=content, headers=myHeaders)
        responseJson = json.loads(response.text)
        logging.debug(response.text)
        logging.debug("Setting {0} in CDN {1} returned status code: {2}".format(fqdn,contentSwitch,response.status_code))
    except Exception as error:
        logging.error("Exception has occurred. Exception:{0}".format(error))
    if response.status_code >= 400:
        logging.debug("Unable to add customer to the Orgin from Edgecast")
        logging.debug("This will need manual intervention")
        logging.debug("HTTPError: status code: %s" %(response.status_code))
        return False
    elif response.status_code == 200:
        logging.debug("Successfully added the customer {0} to the CDN and cnameId is {1}".format(fqdn,responseJson['CNameId']))
        return True

def addCustomerToCDN(connect,fqdn,environment,datacenter,cdnHostAddress,cdnAcountName):
    cdnAuthToken = connect['cdnToken']
    fqdn = fqdn.lower()
    contentSwitch = getCNameDestinationCDN(connect,environment,datacenter)
    logging.debug(contentSwitch)
    if contentSwitch is not None:
        logging.debug("The origin contentswitch of the client is being mapped to :%s " %(contentSwitch))
        idOrigin = getOriginId(contentSwitch,cdnHostAddress,cdnAcountName,cdnAuthToken)
        if idOrigin is not None:
            cdnExists = getAllCNamesCDN(contentSwitch,cdnHostAddress,cdnAcountName,cdnAuthToken,fqdn,idOrigin)
            logging.debug(cdnExists)
            if not cdnExists:
                logging.debug("The customer FQDN is not existing in CDN. Adding the FQDN to the CDN")
                if addFQDNToCDN(contentSwitch,cdnHostAddress,cdnAcountName,cdnAuthToken,fqdn,idOrigin):
                    logging.debug("Successfully added the customer {0} to the CDN".format(fqdn))
                    return True
                else:
                    logging.debug("Unable to add customer to the Orgin from Edgecast")
                    return False
            else:
                return True
        else:
            logging.debug("The origin being evaluated for %s could not be found in the cdn"%(contentSwitch))
            logging.debug("This will need manual intervention")
            return False

