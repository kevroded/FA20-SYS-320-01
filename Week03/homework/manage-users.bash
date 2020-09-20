#!/bin/bash

# Script to add and delete VPN peers

while getopts 'hdau:c' OPTION ; do

  case "$OPTION" in

    d) u_del=${OPTION}
    ;;
    a) u_add=${OPTION}
    ;;
    c) check=${OPTION}
    ;;
    u) t_user=${OPTARG}
    ;;
    h)
      echo ""
      echo "Usage: $(basename $0) [-a]|[-d]|[-c] -u username"
      echo ""
      exit 1
    ;;
    *)
      echo "Invalid Value"
      exit 1
    ;;

  esac
done

# Check to see if -a and -d are empty or if they are both specified: throw error
if [[ (${u_del} == "" && ${u_add} == "" && ${check} == "") || (${u_del} != "" && ${u_add} != "" ) ]]
then
  echo "Please specify -a OR -d and the username"
  exit 1
fi

# Check to ensure -u is specified
if [[ (${u_del} != "" || ${u_add} != "") && ${t_user} == "" ]]
then
  echo "Please specify a user (-u)!"
  echo "Usage: $(basename $0) [-a]|[-d] -u username"
  exit 1
fi

# Delete a user
if [[ ${u_del} ]]
then
  echo "Deleting User..."
  sed -i "/# ${t_user} begin/,/# ${t_user} end/d" wg0.conf

fi

# Add a user
if [[ ${u_add}  ]]
then
  echo "Creating user..."
  bash peer.bash ${t_user}

fi

# Check to see if the user exists
if [[ ${check} ]]
then
  test=$(grep ${t_user} wg0.conf)
  if [[ $test != "" ]]
  then
    echo "User already exists"
  else
    echo "user does not exist"
  fi
fi
