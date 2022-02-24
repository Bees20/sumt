try:
    import winrm
    import paramiko
    import logging
    HAS_ALL_IMPORTS = True
except ImportError:
    HAS_ALL_IMPORTS = False
    print('Import Failed')

__virtualname__ = 'SaltCommon'

def __virtual__():
    '''
    Only load if import successful
    '''
    if HAS_ALL_IMPORTS:
        return __virtualname__
    else:
        return False, 

def Restartsaltminion(host,user,password):
    try:
        session = winrm.Session(host,auth=(user, password), transport='ntlm')
        result = session.run_cmd('net start salt-minion') # To run command in cmd
        return True
    except (Exception) as error:
        raise Exception(error)
        return False
#result = session.run_ps('Get-Acl') # To run Powershell block


def RemoveLinuxSaltMinion(ip,port,username,password):
    try:
        cmd = 'sudo systemctl stop salt-minion ; sudo rm -rf /etc/salt/ ; sudo rm -rf /usr/lib/systemd/system/salt-minion.service'
        ssh=paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(ip,port,username,password)
        stdin,stdout,stderr=ssh.exec_command(cmd)
        outlines=stdout.readlines()
        resp=''.join(outlines)
        logging.info("Response : "+ resp)
        return True
    except (Exception) as error:
        raise Exception(error)
        return False

def AddServertoWhiteList(firewall,vdom,servername,ipaddr,username,password,test):
    try:
        commands = ['config vdom','edit '+vdom+'','config firewall address','edit '+servername+'','set subnet '+ipaddr+' 255.255.255.255','next','end','config firewall addrgrp','edit AMS_Provision_Allow_List','append member '+servername+'','next','end','end','exit']
        if test:
          logging.info("List of Commands "+str(commands))
          return commands
        else:
          ssh=paramiko.SSHClient()
          ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
          ssh.connect(firewall,22,username,password)
          logging.info("List of Commands "+str(commands))
          for command in commands:
              stdin,stdout,stderr=ssh.exec_command(command)
              outlines=stdout.readlines()
              resp=''.join(outlines)
              logging.info("Response : "+ resp)
              #return command
              return True
    except (Exception) as error:
        raise Exception(error)
        return False

def RemoveServerfromWhiteList(firewall,vdom,servername,ipaddr,username,password,test):
    try:
        commands = ['config vdom','edit '+vdom+'','config firewall addrgrp','edit AMS_Provision_Allow_List','unselect member addr_'+ipaddr+'','next','end','config firewall address','delete addr_'+ipaddr+'','end','end','exit']
        if test:
          logging.info("List of Commands "+str(commands))
          return commands
        else:
          ssh=paramiko.SSHClient()
          ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
          ssh.connect(firewall,22,username,password)
          logging.info("List of Commands "+str(commands))
          for command in commands:
              stdin,stdout,stderr=ssh.exec_command(command)
              outlines=stdout.readlines()
              resp=''.join(outlines)
              logging.info("Response : "+ resp)
              #return command
              return True
    except (Exception) as error:
        raise Exception(error)
        return False

#print(RemoveServerfromWhiteList("DEVFW","PROD-NET","127.0.0.1","127.0.0.0","soo","helo",True))
