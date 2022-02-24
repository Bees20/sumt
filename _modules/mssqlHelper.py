# -*- coding: utf-8 -*-
"""
:Module to provide connectivity to the CMDB
:depends:   - FreeTDS
            - pymssql Python module
"""

# Import python libs
from __future__ import absolute_import, print_function, unicode_literals
import logging
import pmp_resource
# import salt.utils.args

try:
    import pymssql

    HAS_ALL_IMPORTS = True
except ImportError:
    HAS_ALL_IMPORTS = False
    print("Import Failed")

log = logging.getLogger(__name__)

__virtualname__ = "mssqlHelper"

# logging.basicConfig(filename='/var/example.log', format='%(asctime)s [%(levelname)s] [%(module)s] [%(funcName)s] %(message)s', level=logging.DEBUG)


def __virtual__():
    """
    Only load if import successful
    """
    if HAS_ALL_IMPORTS:
        return __virtualname__
    else:
        return (
            False,
            "The mssqlHepler module cannot be loaded: dependent package(s) unavailable.",
        )


class mssqlHelper:

    def __init__(self,serverName,userName,password,dbName):
        try:
            #self.PMPClass = pmp_resource.PMP(connect['pmpHost'],connect['pmpToken'])
            #CMDB_Passwd = self.PMPClass.PMP_resource(connect['CMDB_server'],connect['CMDB_user'])
            #self.conn = pymssql.connect(connect['CMDB_server'],connect['CMDB_user'],CMDB_Passwd,connect['CMDB_DB_Name'])
            self.conn = pymssql.connect(serverName,userName,password,dbName)
            self.cursor = self.conn.cursor()
        except Exception as error:
            logging.exception("Exception has occurred:{0}".format(error))
        else:
            logging.info(
                "CMDB connection established successfully with DB:{0}".format(serverName)
            )


    def fetchOne(self, query, session=None, **kwargs):
        try:
            logging.debug("Execute command called with query: {0}".format(query))
            self.cursor.execute(query)
            record = self.cursor.fetchone()
            logging.debug("Execute command : {0} ran without any issues and returned: ".format(query))
            print(self.cursor.rowcount)
            if self.cursor.rowcount != 0:
                return record[0]
            else:
                return None
        except (Exception) as error:
            logging.exception("Exception has occurred:{0}".format(error))
        finally:
            if not session:
                self.conn.close()

    def fetchAll(self, query, session=None, **kwargs):
        try:
            logging.debug("Execute command called with query: {0}".format(query))
            self.cursor.execute(query)
            data = self.cursor.fetchall()
            records = []
            for row in data:
                records.append(row)
        except (Exception) as error:
            logging.exception("Exception has occurred:{0}".format(error))
        else:
            logging.info(
                "Execute command : {0} ran without any issues and returned: {1} ".format(
                    query, records
                )
            )
            return records
        finally:
            if not session:
                self.conn.close()

    def fetchAllToDict(self,query,**kwargs):
        try:
            logging.debug("Execute command called with query: {0}".format(query))
            self.cursor.execute(query)
            data = self.cursor.fetchall()
            records = {}
            #print(data)
        except (Exception) as error:
            logging.exception("Exception has occurred:{0}".format(error))
        else:
            logging.info("Execute command : {0} ran without any issues and returned: {1} ".format(query,records))
            return dict(data)
        finally:
            self.conn.close()

    def executeCommand(self, query, session=None, **kwargs):
        try:
            logging.debug("Execute cmd called with query:{0}".format(query))
            self.cursor.execute(query)
            self.conn.commit()
            logging.info(
                "Number of records affected:{0} after executing the query:{1}".format(
                    self.cursor.rowcount, query
                )
            )
            #return self.cursor.rowcount
        except (Exception) as error:
            logging.exception(
                "Exception has occurred: while executing execute command with query:{0}".format(
                    query
                )
            )
        else:
            logging.info("Execute command : {0} ran without any issues".format(query))
            return self.cursor.rowcount
        finally:
            if not session:
                self.conn.close()

    def executeDDL(self,query,session=None,**kwargs):
        try:
            logging.debug("Execute cmd called with query:{0}".format(query))
            self.conn.autocommit(True)
            self.cursor.execute(query)
            self.conn.autocommit(False)
            #self.conn.commit()
            #logging.info("Number of records affected:{0} after executing the query:{1}".format(self.cursor.rowcount,query))
            #return self.cursor.rowcount
        except pymssql.Error:
            #print("exception:",error)
            logging.exception("Exception has occurred: while executing execute command with query:{0}".format(query))
            return False
        else:
            #self.conn.commit()
            logging.info("Execute command : {0} ran without any issues".format(query))
            return True
        finally:
            if not session :
               self.conn.close()


    def executeQuery(self,query,session=None,**kwargs):
        try:
            logging.debug("Execute cmd called with query:{0}".format(query))
            self.cursor.execute(query)
            #self.conn.commit()
            #logging.info("Number of records affected:{0} after executing the query:{1}".format(self.cursor.rowcount,query))
            #return self.cursor.rowcount
        except pymssql.Error:
            #print("exception:",error)
            logging.exception("Exception has occurred: while executing execute command with query:{0}".format(query))
            return False
        else:
            #self.conn.commit()
            logging.info("Execute command : {0} ran without any issues".format(query))
            return True
        finally:
            if not session :
               self.conn.close()

    def executeSP(self, query, session=None, **kwargs):
        try:
            logging.debug("Execute cmd called with query:{0}".format(query))
            self.cursor.execute(query)
            self.conn.commit()
            logging.info("Number of records affected:{0} after executing the query:{1}".format(self.cursor.rowcount, query))
            return True
        except (Exception) as error:
            logging.exception("Exception has occurred: while executing execute command with query:{0}".format(query))
            return False
        finally:
            if not session:
                self.conn.close()
