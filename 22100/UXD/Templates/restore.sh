#!/bin/bash
mysql -h "$1" -u "$2" --password="$3" -D "$4" < "$5"