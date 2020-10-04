#!/bin/bash

# Script to perform security checks

function checks() {
  if [[ $2 != $3 ]]
  then
    echo -e "\e[1;31mThe $1 policy is not complient The current policy should be: $2, the current value is: $3\nRemdiation\n$4\e[0m"
  else
    echo -e "\e[1;32mThe $1 policy is complient. Current Value $3\e[0m"
  fi
}

# Check the password max days policy
pmax=$(egrep -i '^PASS_MAX_DAYS' /etc/login.defs | awk ' { print $2 } ')
# Check for password max
checks "Password Max Days" "365" "${pmax}"

# Checks the pass min days between changes
pmin=$(egrep -i '^PASS_MIN_DAYS' /etc/login.defs | awk ' { print $2 } ')
checks "Password Min Days" "14" "${pmin}"

# Check the pass warn age
pwarn=$(egrep -i '^PASS_WARN_AGE' /etc/login.defs | awk ' { print $2 } ')
checks "Password Warn Age" "7" "${pwarn}"

# Check the ssh UsePam configuration
chkSSHPAM=$(egrep -i "^UsePAM" /etc/ssh/sshd_config | awk '{ print $2 } ')
checks "SSH UsePAM" "yes" "${chkSSHPAM}"

# Check permissions on users home directory
echo ""
for eachDir in $(ls -l /home/ | egrep '^d' | awk '{ print $3 }')
do
  chDir=$(ls -ld /home/${eachDir} | awk ' { print $1 } ')
  checks "Home directory ${eachDir}" "drwx------" "${chDir}"
done

# Security Benchmark
echo ""
# Ensure IP forwarding is disabled
ipf=$(egrep -i "^net\.ipv4\.ip_forward" /etc/sysctl.conf | cut -f2 -d'=')
checks "IP Forward" "0" "${ipf}" "Set the following parameter in /etc/sysctl.conf\nnet.ipv4.ip_forward = 0\nThen run\nsysctl -w net.ipv4.ip forward=0\nsysctl -w net.ipv4.route.flush=1"
echo ""
#Ensure ICMP redirects are not accepted
icmp=$(egrep -i "^net\.ipv4\.conf\.all\.accept_redirects" /etc/sysctl.conf| cut -f2 -d'=')
checks "ICMP Redirects" "0" "${icmp}" "net.ipv4.conf.all.accept_redirects = 0\nmnet.ipv4.conf.default.accept_redirects = 0\nsysctl -w net.ipv4.conf.all.accept_redirects=0\nsysctl -w net.ipv4.conf.default.accept_redirects=0\nsysctl -w net.ipv4.route.flush=1"
echo ""
# Ensure permissions on /etc/crontab are configured
crontab=$(ls -l /etc/crontab | awk '{ print $1 $3 $4 }')
checks "Crontab Permissions" "-rw------- rootroot" "${crontab}" "chown root:root /etc/crontab\nchmod og-rwx /etc/crontab"
echo ""
# Ensure permissions on /etc/cron.hourly are configured
crontab=$(ls -ld /etc/cron.hourly | awk '{ print $1 $3 $4 }')
checks "Cron hourly Permissions" "drwx------ rootroot" "${crontab}" "chown root:root /etc/cron.hourly\nchmod og-rwx /etc/cron.hourly"
echo ""
# Ensure permissions on /etc/cron.daily are configured
crontab=$(ls -ld /etc/cron.daily | awk '{ print $1 $3 $4 }')
checks "Cron daily Permissions" "drwx------ rootroot" "${crontab}" "chown root:root /etc/cron.daily\nchmod og-rwx /etc/cron.daily"
echo ""
# Ensure permissions on /etc/cron.weekly are configured
crontab=$(ls -ld /etc/cron.weekly | awk '{ print $1 $3 $4 }')
checks "Cron weekly Permissions" "drwx------ rootroot" "${crontab}" "chown root:root /etc/cron.weekly\nchmod og-rwx /etc/cron.weekly"
echo ""
# Ensure permissions on /etc/cron.monthly are configured
crontab=$(ls -ld /etc/cron.monthly | awk '{ print $1 $3 $4 }')
checks "Cron monthly Permissions" "drwx------ rootroot" "${crontab}" "chown root:root /etc/cron.monthly\nchmod og-rwx /etc/cron.monthly"
echo ""
# Ensure permissions on /etc/passwd are configured
passwd=$(ls -l /etc/passwd | awk '{ print $1 $3 $4 }')
checks "/etc/passwd Permissions" "-rw-r--r--rootroot" "${passwd}" "chown root:root /etc/passwd\nchmod 644 /etc/passwd"
echo ""
# Ensure permissions on /etc/shadow are configured
shadow=$(ls -l /etc/shadow | awk '{ print $1 $3 $4 }')
checks "/etc/shadow Permissions" "-rw-r-----rootshadow" "${shadow}" "chown root:shadow /etc/shadow\nchmod o-rwx,g-rw /etc/shadow"
echo ""
# Ensure permissions on /etc/group are configured
group=$(ls -l /etc/group | awk '{ print $1 $3 $4 }')
checks "/etc/group Permissions" "-rw-r--r--rootroot" "${group}" "chown root:root /etc/group\nchmod 644 /etc/group"
echo ""
# Ensure permissions on /etc/gshadow are configured
gshadow=$(ls -l /etc/gshadow | awk '{ print $1 $3 $4 }')
checks "/etc/gshadow Permissions" "-rw-r-----rootshadow" "${gshadow}" "chown root:shadow /etc/gshadow\nchmod o-rwx,g-rw /etc/gshadow"
echo ""
# Ensure permissions on /etc/passwd- are configured
passwd_=$(ls -l "/etc/passwd-" | awk '{ print $1 $3 $4 }')
checks "/etc/passwd- Permissions" "-rw-r--r--rootroot" "${passwd_}" "chown root:root /etc/passwd-\nchmod u-x,go-wx /etc/passwd-"
echo ""
# Ensure permissions on /etc/shadow- are configured
shadow_=$(ls -l "/etc/shadow-" | awk '{ print $1 $3 $4 }')
checks "/etc/shadow- Permissions" "-rw-r-----rootshadow" "${shadow_}" "chown root:shadow /etc/shadow-\nshadow u-rwx,go-rw /etc/passwd-"
echo ""
# Ensure permissions on /etc/group- are configured
group_=$(ls -l /etc/group- | awk '{ print $1 $3 $4 }')
checks "/etc/group- Permissions" "-rw-r--r--rootroot" "${group_}" "chown root:root /etc/group-\nchmod 644 /etc/group-"
echo ""
# Ensure permissions on /etc/gshadow- are configured
gshadow_=$(ls -l /etc/gshadow- | awk '{ print $1 $3 $4 }')
checks "/etc/gshadow- Permissions" "-rw-r-----rootshadow" "${gshadow_}" "chown root:shadow /etc/gshadow-\nchmod o-rwx,g-rw /etc/gshadow-"\
echo ""
# Ensure no legacy "+" entries exist in /etc/passwd
passwd+=$(egrep -i "^\+" /etc/passwd)
checks "Legacy + in /etc/passwd" "" "${passwd+}" "Remove any entries that exist"
echo ""
# Ensure no legacy "+" entries exist in /etc/shadow
shadow+=$(sudo egrep -i "^\+" /etc/shadow)
checks "Legacy + in /etc/shadow" "" "${shadow+}" "Remove any entries that exist"
echo ""
# Ensure no legacy "+" entries exist in /etc/group
group+=$(egrep -i "^\+" /etc/group)
checks "Legacy + in /etc/group" "" "${group+}" "Remove any entries that exist"
echo ""
# Ensure root is the only UID 0 account
rootcheck=$(cat /etc/passwd | awk -F: '($3 == 0) { print $1 }')
checks "UID" "root" "${rootcheck}" "Remove users or reassign UID"
