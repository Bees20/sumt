#!/bin/bash
# Usage: ./backup <keyspacename> <backupfilename>

keyspaceName=$1
backupfileName=$2
#BACKUP_PATH= `/home/COTESTDEV/`
logFile="/scripts/backup.log"
startTime=`date '+%m/%d/%y %H:%M:%S'`
exec > $logFile 2>&1

mkdir -p /scripts
chmod -R 777 /scripts

/opt/cassandra/apache-cassandra-3.11.5/bin/nodetool snapshot -t $backupfileName $keyspaceName
for TABLE in assignments_user_by_object assignments_user_by_object_future assignments_user_status_change assignments_user_summary fieldsettings notif_tracker user_action_by_week user_action_history user_action_summary user_search_history usersummary_activity_child_or_offering usersummary_activity_master usersummary_assigned_training usersummary_certification_training usersummary_certification_training_history usersummary_context_root_leaf usersummary_domain_setting_cache usersummary_event_log usersummary_permission_cache usersummary_training_context_root usersummary_training_history usersummary_training_master usersummary_user_domain_cache vwlearningactivities webhook_errored webhook_event webhook_latestlog webhook_log
do
mkdir -p /backup/$TABLE
chmod -R 777 /backup/$TABLE

cp -r /opt/cassandra/apache-cassandra-3.11.5/data/data/$1/$TABLE-*/snapshots/$backupfileName /backup/$TABLE/
chown -R cassandra:cassandra /backup/$TABLE
done   
#tar -cvzf $backupfileName.tar.gz /opt/cassandra/apache-cassandra-3.11.5/data/data/$keyspaceName/*/snapshots/$backupfileName

endTime=`date '+%m/%d/%y %H:%M:%S'`
echo "$host: Backup:Success Start: $startTime End: $endTime"
