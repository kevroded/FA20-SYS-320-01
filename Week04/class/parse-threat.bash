#!/bin/bash
# Extract ips from emergingthreats.net and create a firewall ruleset\

#wget http://rules.emergingthreats.net/blockrules/emerging-drop.rules -O /tmp/emerging-drop.rules
# Regex to extract the networks
egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}' /tmp/emerging-drop.rules | sort -u | tee badIPs.txt

# create a firewall ruleset
for eachIP in $(cat badIPs.txt)
do
  echo "iptables -A INPUT -s ${eachIP} -j DROP" | tee -a badIPS.iptables
done
