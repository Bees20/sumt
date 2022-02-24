#!/bin/bash

sudo bin/cqlsh $1 -u $3 -p $4 -e "ALTER KEYSPACE system_auth WITH replication = {'class': 'NetworkTopologyStrategy', 'dc1': '$2' };"
