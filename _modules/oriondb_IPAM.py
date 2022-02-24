from __future__ import absolute_import, print_function, unicode_literals
from json import JSONEncoder, loads

import sys
import logging
import re

try:
    import pymssql
    HAS_ALL_IMPORTS = True
except ImportError:
    HAS_ALL_IMPORTS = False
    print('Import Failed')

log = logging.getLogger(__name__)

__virtualname__ = 'Oriondb_IPAM'


def __virtual__():
    '''
    Only load if import successful
    '''
    if HAS_ALL_IMPORTS:
        return __virtualname__
    else:
        return False, 'The Orion_LIB module cannot be loaded: pymssql package unavailable.'


class oriondb:

    def __init__(self,config,passwd):
        self.conn = pymssql.connect(config['SOLARWINDS_ORION_HOST'],
                config['SOLARWINDS_ORION_USERNAME'],passwd,config['SOLARWINDS_ORION_DB_NAME'])
        self.cursor = self.conn.cursor()


    def UpdateStatus(self, ServerIP,session=None):
        self.query = ("UPDATE IPAM_Node SET Status = '4',StatusBy = '3',LastSync = NULL,Description = 'Set by SaltStack Automation' WHERE IPAddress =%s")
        self.cursor.execute(self.query, (ServerIP))
        self.conn.commit()
        if not session:
          self.conn.close()
        if self.cursor.rowcount == 0:
            return False
        else:
            return True

    def ping_ip(current_ip_address):
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

    def IpList(self,subnet,cidr,session=None):
        self.query = ("SELECT distinct IPN.IPNodeID,IPN.IPAddress FROM IPAM_Node IPN INNER JOIN IPAM_Group IPG ON IPG.GroupId = IPN.SubnetId WHERE IPN.Status = '2' AND IPG.Address =%s AND IPG.CIDR =%s")
        self.cursor.execute(self.query,(subnet,cidr))
        record = self.cursor.fetchall()
        data = list(record)
        if not session:
          self.conn.close()
        return data

    def reserveIP(self,IPNodeID,ipaddress,session=None):
        try:
            self.cursor.execute("UPDATE IPAM_Node SET Status = '4',StatusBy = '3',LastSync = NULL,Description = 'Set by SaltStack Automation' WHERE IPNodeId = '" + IPNodeID + "' AND IPAddress = '" + ipaddress + "'")
            self.conn.commit()
            if self.cursor.rowcount == 0:
                raise
            else:
                print(self.cursor.rowcount + " record added to row to IPAM Database table IPAM_Node")
        except (Exception,StandardError) as error:
            raise Exception(error)
        finally:
            if session:
              return self.cursor.rowcount
            self.conn.close()
            return self.cursor.rowcount
