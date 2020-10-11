#!/bin/bash

# Parse an apache log file

# Read in file

# Arguments using the position
APACHE_LOG="$1"

# Parse options with getopts
while getopts 'ps:c:f:' OPTION ; do
  case "$OPTION" in
    f) APACHE_LOG=${OPTARG}
    ;;
    p) print=${OPTION}
    ;;
    s) save=${OPTARG}
    ;;
    c) create=${OPTARG}
    ;;
    *)
    echo ""
    echo "Usage: $(basename $0) LogFile [-p]|[-s FileName]|[-c Firewall]"
    exit 1
    ;;
  esac
done

# Check if file exists
if [[ ! -f ${APACHE_LOG} ]]
then
  echo "Please specify the path to a log file."
  exit 1
fi

if [[ ${print} ]]
then
  # Looking for web scanners.
  sed -e "s/\[//g" -e "s/\"//g" ${APACHE_LOG} | \
  egrep -i "test|shell|echo|passwd|select|phpmyadmin|setup|admin|w00t" | \
  awk ' BEGIN { format = "%-15s %-20s %-7s %-6s %-10s %s\n"
                printf format, "IP", "Date", "Method", "Status", "Size", "URI"
                printf format, "--", "----", "------", "------", "----", "---"}

  { printf format, $1, $4, $6, $9, $10, $7 }'
fi

if [[ ${save} ]]
then
  # Looking for web scanners.
  sed -e "s/\[//g" -e "s/\"//g" ${APACHE_LOG} | \
  egrep -i "test|shell|echo|passwd|select|phpmyadmin|setup|admin|w00t" | \
  awk ' BEGIN { format = "%-15s %-20s %-7s %-6s %-10s %s\n"
                printf format, "IP", "Date", "Method", "Status", "Size", "URI"
                printf format, "--", "----", "------", "------", "----", "---"}

  { printf format, $1, $4, $6, $9, $10, $7 }' | \
  tee "${save}"
fi

if [[ ${create} ]]
then
  if [[ ${create} == "iptables" ]]
  then
    $(bash parse-threatIP.bash -f ${APACHE_LOG} -i > /dev/null 2>&1)
  elif [[ ${create} == "cisco" ]]
  then
     $(bash "parse-threatIP.bash" -f ${APACHE_LOG} -c > /dev/null 2>&1)
  elif [[ ${create} == "windows" ]]
  then
    $(bash parse-threatIP.bash -f ${APACHE_LOG} -w > /dev/null 2>&1)
  elif [[ ${create} == "mac" ]]
  then
    $(bash parse-threatIP.bash -f ${APACHE_LOG} -m > /dev/null 2>&1)
  else
    echo "Unknown firewall"
  fi
fi
