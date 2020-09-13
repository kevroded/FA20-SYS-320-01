#!/bin/bash

# Creates the client config for wireguard


# What is the peers name
echo -n "What is the user's name? "
read the_client

# Filename Variable
pFile="${the_client}-wg0.conf"
# Check if peer file exists
if [[ -f "${pFile}" ]]
then
  # Prompt if we need to overwrite
  echo "The file ${pFile} already exists."
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
# Generate private key
p="$(wg genkey)"

# Generate public key
clientPub="$(echo ${p} | wg pubkey)"

# Generate preshared key
pre="$(wg genpsk)"
# 10.254.132.0/24,172.16.28.0/24 198.199.97.163:4282 WvXROdG0QLVxcZrgre5p51P7wpdk9/F1F2nAHnZJ/l8= 8.8.8.8,1.1.1.1 1280 0.0.0.0/0

# Endpoint
end="$(head -1 wg0.conf | awk ' { print $3 } ')"

# Server Public Key
pub="$(head -1 wg0.conf | awk ' { print $4 } ')"

# DNS servers
dns="$(head -1 wg0.conf | awk ' { print $5 } ')"

# MTU
mtu="$(head -1 wg0.conf | awk ' { print $6 } ')"

# KeepAlive
keep="$(head -1 wg0.conf | awk ' { print $7 } ')"

# ListenPort
lport="$(shuf -n1 -i 40000-50000)"

# Default Routes for VPN
routes="$(head -1 wg0.conf | awk ' { print $8 } ')"

# Create the client config
: '
[Peer]
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 120
PresharedKey = KEY
PublicKey = KEY
Endpoint = 198.199.97.163:4282

'
echo "[Interface]
Address = 10.254.132.100/24
DNS = ${dns}
ListenPort = ${lport}
MTU = ${mtu}
PrivateKey = ${p}

[Peer]
AllowedIPs = ${routes}
PersistentKeepalive = ${keep}
PresharedKey = ${pre}
PublicKey = ${pub}
Endpoint = ${end}
" > ${pFile}

# Add peer config to server config
echo "

# ${the_client} begin
[Peer]
Publickey = ${clientPub}
PresharedKey = ${pre}
AllowedIPs = 10.254.132.100/32
# ${the_client} end" | tee -a wg0.conf

echo "
sudo cp wg0.conf /etc/wireguard

sudo wg addconf wg0 <(wg-quick strip wg0)
"
