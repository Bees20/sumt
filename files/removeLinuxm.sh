#!/bin/bash

date >> /tmp/datec.txt
sudo yum -y remove salt*
sudo rm -rf /etc/salt/
date
date >> /tmp/datec.txt
sleep 10
date >> /tmp/datec.txt
sleep 5
hostname >> /tmp/datec.txt
