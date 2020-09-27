#!/bin/bash

# Script to parse ips and block ips for different firewall systems

# check if emerging threats already exists
# if no: downlaod else prompt for download
FILE=/tmp/emerging-drop.rules
if test -f "$FILE"; then
  read -p "The threat file already exists. Would you like to download it again? [y|N] " choice
  case "$choice" in
    y|Y)
    wget http://rules.emergingthreats.net/blockrules/emerging-drop.rules -O /tmp/emerging-drop.rules
    ;;
    n|N)
    ;;
  esac
else
  wget http://rules.emergingthreats.net/blockrules/emerging-drop.rules -O /tmp/emerging-drop.rules
fi

# process IPs
egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}' /tmp/emerging-drop.rules | sort -u | tee badIPs.txt

# Using getopts allow options to block ips for iptables, cisco, windows and mac
while getopts 'hicwmnt' OPTION ; do

  case "$OPTION" in
    i)
      for eachIP in $(cat badIPs.txt)
      do
        echo "iptables -A INPUT -s ${eachIP} -j DROP" | tee -a badIPS.iptables
      done
    ;;
    c)
      for eachIP in $(cat badIPs.txt)
      do
        echo "acess-list 1 deny host ${eachIP}" | tee -a badIPS.cisco
      done
    ;;
    w)
      for eachIP in $(cat badIPs.txt)
      do
        echo "netsh advfirewall firewall add rule dir=in interface=any action=block remoteip=${eachIP}" | tee -a badIPS.windows
      done
    ;;
    m)
      for eachIP in $(cat badIPs.txt)
      do
        echo "block drop from any to ${eachIP}" | tee -a pf.conf
      done
    ;;
    n)
      for eachIP in $(cat badIPs.txt)
      do
        echo "block drop from any to ${eachIP}" | tee -a pf.conf
      done
    h)
      echo ""
      echo "Usage: $(basename $0) [-i]|[-c]|[-w]|[-m]|[n]|[-t]"
      echo ""
      exit 1
    ;;
# also have a switch to parse csv
    t)
    FILE=/tmp/targetedthreats.csv
    if test -f "$FILE"; then
      read -p "The file already exists. Would you like to download it again? [y|N] " choice
      case "$choice" in
        y|Y)
        wget https://raw.githubusercontent.com/botherder/targetedthreats/master/targetedthreats.csv -O /tmp/targetedthreats.csv
        ;;
        n|N)
        ;;
      esac
    else
      wget https://raw.githubusercontent.com/botherder/targetedthreats/master/targetedthreats.csv -O /tmp/targetedthreats.csv
    fi
    grep \"domain\" /tmp/targetedthreats.csv | cut -d, -f2 | tee badurl.txt
    for eachurl in $(cat badurl.txt)
    do
      echo -e "class-map match-any BAD_URLS\nmatch protocol http host ${eachurl}" | tee -a UrlFilter.cisco
    done
    ;;
    *)
      echo "Invalid Value"
      exit 1
    ;;
  esac
done
