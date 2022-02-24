{% import "./vars.sls" as base %}
{% set trialset = salt['network.ipaddrs']( ) %}
{% set val= trialset | replace("['", "") %}
{% set ip_addr= val| replace("']", "") %}


{% if ip_addr == base.csd_master %}
wait for minute:
  cmd.run:
    - name: sleep 180

Create CSD user with user {{base.cassandraadminuser}} {{base.cassandraadminpwd}} :
  cmd.script:
    - name: salt://{{ base.parentfolder }}/CSD/Templates/user.sh
    - cwd: {{base.cassandra_dir}}
    - args: {{base.csd_master}} {{base.cassandraadminuser}} {{base.cassandraadminpwd}}

Delete default user:
  cmd.script:
    - name: salt://{{ base.parentfolder }}/CSD/Templates/delete.sh
    - cwd: {{base.cassandra_dir}}
    - args: {{base.csd_master}} {{base.cassandraadminuser}} {{base.cassandraadminpwd}}

Change strategy and increase replication:
  cmd.script:
    - name: salt://{{ base.parentfolder }}/CSD/Templates/replication.sh
    - cwd: {{base.cassandra_dir}}
    - args: {{base.csd_master}} {{base.replicationfactor}} {{base.cassandraadminuser}} {{base.cassandraadminpwd}}

{% endif %}

