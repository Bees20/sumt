#!/bin/bash
mongodump --host="$1" --username="$2" --password="$3" --authenticationDatabase="admin" --db="$4" --out="$5" --port="$6"