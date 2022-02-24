#mport pymssql
import requests
import json
import socket
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
from json import JSONEncoder, loads
from datetime import datetime
import logging

try:
    import requests
    HAS_ALL_IMPORTS = True
except ImportError:
    HAS_ALL_IMPORTS = False
    print('Import Failed')

log = logging.getLogger(__name__)

__virtualname__ = 'pmp_resource'

def __virtual__():
    '''
    Only load if import successful
    '''
    if HAS_ALL_IMPORTS:
        return __virtualname__
    else:
        return False, 'The pmp_resource module cannot be loaded: dependent package(s) unavailable.'

class PMP:

    def __init__(self,pmpHost,pmpToken):
        self.token = pmpToken
        self.pmpHost = pmpHost
    
    def get_PMP_details(self,source):
        if source == 'svc_saltstack':
            return {'resource' : 'svc_saltstack', 'account' : 'svc_saltstack' }
        elif source == 'UXDTemplate':
            return {'resource' : 'vraUXDTemplate', 'account' : 'coadminauto' }
        elif source == 'UMDTemplate':
            return {'resource' : 'vraUMDTemplate', 'account' : 'coumdadminauto' }
        elif source == 'root':
            return {'resource' : 'vRATemplate', 'account' : 'root' }
        elif source == 'vro-admin':
            return {'resource' : 'network_administrators', 'account' : 'vro-admin' }
 
    
    def get_resource(self,getaccount):
        details = self.get_PMP_details(getaccount)
        resource = details['resource']
        account = details['account']
        response = requests.get('https://%s/restapi/json/v1/resources/resourcename/%s/accounts/accountname/%s?AUTHTOKEN=%s' % (self.pmpHost,resource,account,self.token), verify=False)
        pmp_json = json.loads(response.text)
        RESOURCEID = pmp_json['operation']['Details']['RESOURCEID']
        ACCOUNTID = pmp_json['operation']['Details']['ACCOUNTID']
        return RESOURCEID,ACCOUNTID
    
    def get_PMP_pass(self,getaccount):
        RESOURCEID,ACCOUNTID = self.get_resource(getaccount)
        response = requests.get('https://%s/restapi/json/v1/resources/%s/accounts/%s/password?AUTHTOKEN=%s' % (self.pmpHost,RESOURCEID,ACCOUNTID,self.token), verify=False)
        if response.status_code == 200:
            pmp_json = json.loads(response.text)
            pp = pmp_json['operation']['Details']['PASSWORD']
            return pp
        else:
            raise Exception(pmp_json)

    def add_resource(self,accountName,accountPassword,resourceName,resourceType):
        changeControl = 'SaltCluster' #as of now hardcorded
        content = 'INPUT_DATA={"operation":{"Details":{"ACCOUNTNAME": "' + accountName + '","PASSWORD": "' + accountPassword + '","RESOURCENAME": "' + resourceName + '","RESOURCETYPE": "' + resourceType + '","RESOURCECUSTOMFIELD": [{"CUSTOMLABEL": "CHANGE_CONTROL","CUSTOMVALUE": "' + changeControl + '"}],"ACCOUNTCUSTOMFIELD":[{"CUSTOMLABEL":"CHANGE_CONTROL","CUSTOMVALUE":"' + changeControl + '"}]}}}'
        url = "https://%s/restapi/json/v1/resources?AUTHTOKEN=%s" % (self.pmpHost,self.token)
        headers = {'Content-type': 'application/json'}
        response = requests.post(url, data=content, headers=headers, verify=False)
        pmp_json = json.loads(response.text)
        if pmp_json['operation']['result']['status'] != 'Success':
            if 'Resource already exists' in pmp_json['operation']['result']['message']:
                return True
            else:
                raise Exception(pmp_json['operation']['result']['message'])
        else:
            return pmp_json['operation']['result']['message']

    def winadd_dbresource(self,accountName,resourceName,databaseName,resourceCreate,resourceType):
        changeControl = 'SaltCluster' #as of now hardcorded
        if resourceCreate:
          if resourceType == "MS SQL Server":
            content = 'INPUT_DATA={"operation":{"Details":{"ACCOUNTNAME": "' + accountName + '","PASSWORD": "","RESOURCENAME": "' + resourceName + '","RESOURCETYPE": "' + resourceType +'","RESOURCECUSTOMFIELD": [{"CUSTOMLABEL": "CHANGE_CONTROL","CUSTOMVALUE": "' + changeControl + '"}],"ACCOUNTCUSTOMFIELD":[{"CUSTOMLABEL":"CHANGE_CONTROL","CUSTOMVALUE":"' + changeControl + '"},{"CUSTOMLABEL":"DATABASE_NAME","CUSTOMVALUE":"' + databaseName + '"}]}}}'
        else:
            content = 'INPUT_DATA={"operation":{"Details":{"ACCOUNTNAME": "' + accountName + '","PASSWORD": "","RESOURCENAME": "' + resourceName + '","RESOURCETYPE": "MS SQL Server","ACCOUNTCUSTOMFIELD":[{"CUSTOMLABEL":"CHANGE_CONTROL","CUSTOMVALUE":"' + changeControl + '"},{"CUSTOMLABEL":"DATABASE_NAME","CUSTOMVALUE":"' + databaseName + '"}]}}}'
        url = "https://%s/restapi/json/v1/resources?AUTHTOKEN=%s" % (self.pmpHost,self.token)
        headers = {'Content-type': 'application/json'}
        response = requests.post(url, data=content, headers=headers, verify=False)
        pmp_json = json.loads(response.text)
        if pmp_json['operation']['result']['status'] != 'Success':
            if 'Resource already exists' in pmp_json['operation']['result']['message']:
                return True
            else:
                raise Exception(pmp_json['operation']['result']['message'])
        else:
            return pmp_json['operation']['result']['message']


    def winadd_resource(self,accountName,resourceName,resourceCreate,resourceType):
        changeControl = 'SaltCluster' #as of now hardcorded
        if resourceCreate:
          if resourceType == "JasperSoft" or "Svc_accounts":
            content = 'INPUT_DATA={"operation":{"Details":{"ACCOUNTNAME": "' + accountName + '","PASSWORD": "","RESOURCENAME": "' + resourceName + '","RESOURCETYPE": "' + resourceType +'","RESOURCECUSTOMFIELD": [{"CUSTOMLABEL": "CHANGE_CONTROL","CUSTOMVALUE": "' + changeControl + '"}],"ACCOUNTCUSTOMFIELD":[{"CUSTOMLABEL":"CHANGE_CONTROL","CUSTOMVALUE":"' + changeControl + '"}]}}}'
        else:
            content = 'INPUT_DATA={"operation":{"Details":{"ACCOUNTNAME": "' + accountName + '","PASSWORD": "' + jasperPassword + '","RESOURCENAME": "' + resourceName + '","RESOURCETYPE": "JasperSoft","ACCOUNTCUSTOMFIELD":[{"CUSTOMLABEL":"CHANGE_CONTROL","CUSTOMVALUE":"' + changeControl + '"}]}}}'
        url = "https://%s/restapi/json/v1/resources?AUTHTOKEN=%s" % (self.pmpHost,self.token)
        headers = {'Content-type': 'application/json'}
        response = requests.post(url, data=content, headers=headers, verify=False)
        pmp_json = json.loads(response.text)
        if pmp_json['operation']['result']['status'] != 'Success':
            if 'Resource already exists' in pmp_json['operation']['result']['message']:
                return True
            else:
                raise Exception(pmp_json['operation']['result']['message'])
        else:
            return pmp_json['operation']['result']['message']

    def PMP_resource(self,resource,account):
        response = requests.get('https://%s/restapi/json/v1/resources/resourcename/%s/accounts/accountname/%s?AUTHTOKEN=%s' % (self.pmpHost,resource,account,self.token), verify=False)
        pmp_json = json.loads(response.text)
        RESOURCEID = pmp_json['operation']['Details']['RESOURCEID']
        ACCOUNTID = pmp_json['operation']['Details']['ACCOUNTID']
        response = requests.get('https://%s/restapi/json/v1/resources/%s/accounts/%s/password?AUTHTOKEN=%s' % (self.pmpHost,RESOURCEID,ACCOUNTID,self.token), verify=False)
        if response.status_code == 200:
            pmp_json = json.loads(response.text)
            data = pmp_json['operation']['Details']['PASSWORD']
            return data
        else:
            raise Exception(pmp_json)
