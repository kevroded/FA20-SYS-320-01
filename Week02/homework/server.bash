#!/bin/bash

# Script to create a wireguard server


# Check if file exists
if [[ -f "wg0.conf" ]]
then
  # Prompt if we need to overwrite
  echo "The file wg0.conf already exists."
  echo -n "Would you like to overwrite it? [y|N] "
  read to_overwrite

  if [[ "${to_overwrite}" == "N" || "${to_overwrite}" == "" || "${to_overwrite}" == "n" ]]
  then
    echo "Exit..."
    exit 0
  elif [[ "${to_overwrite}" == "Y" || "${to_overwrite}" == "y" ]]
  then
    echo "Creating the wireguard configuration file..."
  else
    echo "Error: Input not recognized"
    echo "Exiting..."
    exit 1
  fi
fi

# Create Private Key
p="$(wg genkey)"

# Create Public Key
pub="$(echo ${p} | wg pubkey)"

# Set address
address="10.254.132.0/24,172.16.28.0/24"

# Set Server IP addresses
serveraddress="10.254.132.1/24,172.16.28.1/24"

# Set listen port
lport="4282"

# Create format for the client config
peerInfo="# ${address} 198.199.97.163:4282 ${pub} 8.8.8.8,1.1.1.1 1280 120 0.0.0.0/0"

: '
# 10.254.132.0/24,172.16.28.0/24 162.243.2.92:4282 PUBLICKEY 8.8.8.8,1.1.1.1 1280 0.0.0.0/0
[Interface]
Address = 10.254.132.1/24,172.16.28.1/24
# PostUp = /etc/wireguard/wg-down.bash
# PostDown = /etc/wireguard/wg-down.bash
ListenPort = 4282
PrivateKey = PRIVATEKEY
'
echo "${peerInfo}
[Interface]
Address = ${serveraddress}
#PostUp = /etc/wireguard/wg-down.bash
#PostDown = /etc/wireguard/wg-down.bash
ListenPort = ${lport}
PrivateKey=${p}
" > wg0.conf
