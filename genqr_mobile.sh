##!/bin/sh

#
#SterhTG - I want to believe
#
# This script require to update vairables
# Usage: wg set <interface> [listen-port <port>] [fwmark <mark>] [private-key <file path>] [peer <base64 public key> [remove] [preshared-key <file path>] [endpoint <ip>:<port>] [persistent-keepalive <interval seconds>] [allowed-ips <ip1>/<cidr1>[,<ip2>/<cidr2>]...] ]...
# wg set $WG_INTF peer $public_key persistent-keepalive 30 allowed-ips $WG_CLIENT_IP"/32"
# 
WG_INTF=wg0
WG_CLIENT_IP='0.0.0.0'
WG_DNS=0.0.0.0
WG_SRV_ENDP="0.0.0.0:0"
SRV_PUBKEY="None"
DEBUG=1

if [ $# -eq 0 ]
  then
    if [[ "$DEBUG" -eq 1 ]]; then echo "No arguments supplied, default client ip would be used."; fi
else
  WG_CLIENT_IP=$1
  echo "Client ip:"$WG_CLIENT_IP
fi

private_key=$(wg genkey)
if [[ "$DEBUG" -eq 1 ]]; then  echo "Saved private key:"$private_key; fi
public_key=$( echo $private_key | wg pubkey )
if [[ "$DEBUG" -eq 1 ]]; then echo "Saved publickey:"$public_key; fi

cat << EOF >> tmp_head
[Interface]
PrivateKey = $private_key
Address = $WG_CLIENT_IP/24
DNS = $WG_DNS, 8.8.8.8

[Peer]
PublicKey = $SRV_PUBKEY
AllowedIPs = 0.0.0.0/0
Endpoint = $WG_SRV_ENDP
EOF

qrencode -t ansiutf8 < tmp_head
if [[ "$DEBUG" -eq 1 ]];
 then
  echo "wg set ${WG_INTF} peer ${public_key} persistent-keepalive 30 allowed-ips ${WG_CLIENT_IP}/32"
else
 rm tmp_head
 wg set ${WG_INTF} peer ${public_key} persistent-keepalive 30 allowed-ips ${WG_CLIENT_IP}"/32"
fi
