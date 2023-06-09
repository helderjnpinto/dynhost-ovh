#!/usr/bin/sh

# Account configuration
DOMAIN_NAME=DOMAIN_NAME
LOGIN=LOGIN
PASSWORD=PASSWORD

PATH_LOG=./dynhostovh.log

# Get current IPv4 and corresponding configured
HOST_IP=$(dig +short $DOMAIN_NAME A)
CURRENT_IP=$(curl -m 5 -4 ifconfig.co 2>/dev/null)
echo "CURRENT_IP = $CURRENT_IP"
echo "HOST_IP = $HOST_IP"

if [ -z "$CURRENT_IP" ]; then
  echo "Running dig"
  CURRENT_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
fi
CURRENT_DATETIME=$(date -R)

# Update dynamic IPv4, if needed
if [ -z "$CURRENT_IP" ] || [ -z "$HOST_IP" ]; then
  echo "[$CURRENT_DATETIME]: No IP retrieved" >> $PATH_LOG
else
  if [ "$HOST_IP" != "$CURRENT_IP" ]
  then
    echo "Running DynHost"
    RES=$(curl -m 5 -L --location-trusted --user "$LOGIN:$PASSWORD" "https://www.ovh.com/nic/update?system=dyndns&hostname=$DOMAIN_NAME&myip=$CURRENT_IP")
    echo "[$CURRENT_DATETIME]: IPv4 has changed - request to OVH DynHost: $RES" >> $PATH_LOG
  fi
fi
