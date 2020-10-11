#!/bin/bash

# Script to parse ips and block ips for different firewall systems

# Using getopts allow options to block ips for iptables, cisco, windows and mac
while getopts 'hicwmntf:' OPTION ; do

  case "$OPTION" in
    f) tFile=${OPTARG}
    if [[ ! -f ${tFile} ]]
    then
      echo "File does not exist"
      exit 1
    fi
    awk '{ print $1 }' ${tFile} | sort -u | tee badIPS.txt
    ;;
    i)
      for eachIP in $(cat badIPs.txt)
      do
        echo "iptables -A INPUT -s ${eachIP} -j DROP" | tee -a badIPS.iptables
      done
    ;;
    c)
      for eachIP in $(cat badIPs.txt)
      do
        echo "access-list 1 deny host ${eachIP}" | tee -a badIPS.cisco
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
    ;;
    h)
      echo ""
      echo "Usage: $(basename $0) [-i]|[-c]|[-w]|[-m]|[n]|[-t]"
      echo ""
      exit 1
    ;;
    *)
      echo "Invalid Value"
      exit 1
    ;;
  esac
done
