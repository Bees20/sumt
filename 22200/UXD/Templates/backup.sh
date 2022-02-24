#!/bin/bash
mysqldump -h "$1" -u "$2" --password="$3" "$4" -r "$5" --ignore-table="$4".tincanactivityprovider --ignore-table="$4".TinCanPermissions