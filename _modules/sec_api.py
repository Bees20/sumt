from __future__ import absolute_import, print_function, unicode_literals
import json
import time
from sseapiclient import APIClient

try:
    import json
    from sseapiclient import APIClient
    HAS_ALL_IMPORTS = True
except ImportError:
    HAS_ALL_IMPORTS = False
    print('Import Failed')

import logging
log = logging.getLogger(__name__)

__virtualname__ = 'sec_api'

def __virtual__():
    '''
    Only load if import successful
    '''
    if HAS_ALL_IMPORTS:
        return __virtualname__
    else:
        return False, 'The sec_sseapi file cannot be loaded: dependent package(s) unavailable.'

#### CREATE TARGET GROUP  ####
def createTarget(target,API,user,password):
    client = APIClient(API,user,password)
    output=client.api.tgt.save_target_group(
    name=target,
    desc=target,
    tgt={"*":{"tgt_type":"compound", "tgt":"G@host:{}".format(target)}})
    target_uuid=json.dumps(output.ret)
    target_uuid=target_uuid.replace('"','')
    return target_uuid


#### CREATE POLICY  ####
def createPolicy(target,tar_ret_id,benchmark_ids,check_id1,variables,API,user,password):
    client = APIClient(API,user,password)
    output = client.api.sec.save_policy(
    name=target,
    tgt_uuid=tar_ret_id,
    benchmark_uuids=[benchmark_ids],
    check_uuids=[
        check
        for check in check_id1
        ],
    variables=[
        var
        for var in variables
        ])
    policy_id=json.dumps(output.ret)
    policy_id=policy_id.replace('"','')
    return policy_id


def waitforevent(jid,API,user,password):
    client = APIClient(API,user,password)
    while True:
        time.sleep(10)
        data = client.api.ret.get_returns(jid)
        if data.ret['results']:
            time.sleep(10)
            return True
            break;
        else:
            continue
    return {}

def assessPolicy(policy_id,API,user,password):
    client = APIClient(API,user,password)
    result = client.api.sec.assess_policy(policy_uuid=policy_id)
    jid = result[1]['jid']
    return waitforevent(jid,API,user,password)

def trimDatabase(API,user,password,days):
    client = APIClient(API,user,password,timeout=2000)
    return client.api.admin.trim_database(audit=days, events=days, jobs=days, schedule=days, test=False)

def get_policyuuid(policy_name,API,user,password):
    client = APIClient(API,user,password)
    for result in client.api.sec.get_policies(names=[policy_name]).ret["results"]:
        policy_id = result["uuid"]
    return policy_id

def get_policies(policy_id,API,user,password):
    client = APIClient(API,user,password)
    output = client.api.sec.get_policies(policy_uuids=[policy_id],include_stats=True)
    noncompliant = json.dumps(output.ret['results'][0]['stats']['noncompliant'])
    return noncompliant

def win_policy(policy_id,check_id1,API,user,password):
    client = APIClient(API,user,password)
    output = client.api.sec.remediate_policy(policy_uuid=policy_id,check_uuids=[check for check in check_id1])
    jid = output[1]['jid']
    return waitforevent(jid,API,user,password)

def remediateWin_Policy(policy_name,check_id1,API,user,password):
    client = APIClient(API,user,password)
    for result in client.api.sec.get_policies(names=[policy_name]).ret["results"]:
        policy_id = result["uuid"]
    if win_policy(policy_id,check_id1,API,user,password):
        while True:
            result = assessPolicy(policy_id,API,user,password)
            time.sleep(30)
            noncompliant = get_policies(policy_id,API,user,password)
            if int(noncompliant) > 1:
                data = win_policy(policy_id,check_id1,API,user,password)
                continue
            else:
                break;
                return True

####  REMEDIATE POLICY  ####
def remediatePolicy(policy_name,API,user,password):
    client = APIClient(API,user,password)
    for result in client.api.sec.get_policies(names=[policy_name]).ret["results"]:
        policy_id = result["uuid"]
    client = APIClient(API,user,password)
    output = client.api.sec.remediate_policy(policy_uuid=policy_id)
    jid = output[1]['jid']
    return waitforevent(jid,API,user,password)

####  CLEANUP  ####
def deletePolicy(policy_id,target_uuid,API,user,password):
    client = APIClient(API,user,password)
    client.api.sec.delete_policy(policy_uuid=policy_id)
    return client.api.tgt.delete_target_group(tgt_uuid=target_uuid)

#### RE-ASSESS POLICY ####
def reAssessPolicy(policy_name,API,user,password):
    client = APIClient(API,user,password)
    for result in client.api.sec.get_policies(names=[policy_name]).ret["results"]:
        policy_uuid=result["uuid"]
    output = client.api.sec.assess_policy(policy_uuid)
    jid = output[1]['jid']
    return waitforevent(jid,API,user,password)

def DeleteMinionKey(target,cluster,API,user,password):
    client = APIClient(API,user,password)
    list = [cluster,target]
    return client.api.minions.set_minion_key_state(minions=[list],state='delete')

def AcceptMinionKey(target,cluster,API,user,password):
    client = APIClient(API,user,password)
    list = [cluster,target]
    return client.api.minions.set_minion_key_state(minions=[list],state='accept')

#### DELETE POLICY ####
def deletePolicy(policy_name,API,user,password):
    client = APIClient(API,user,password)
    for result in client.api.sec.get_policies(names=[policy_name]).ret["results"]:
        policy_uuid=result["uuid"]
    return client.api.sec.delete_policy(policy_uuid)


#### DELETE TARGET ####
def deleteTarget(policy_name,API,user,password):
    client = APIClient(API,user,password)
    targets = [
        target
        for target in client.api.tgt.get_target_group().ret["results"]
        if policy_name in target["name"]
        ]
    for target in targets:
        target_uuid=target["uuid"]
    return client.api.tgt.delete_target_group(target_uuid)

