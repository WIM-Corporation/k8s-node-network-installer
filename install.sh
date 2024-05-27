#!/bin/bash

# Function to validate IP address components
validate_ip_component() {
  local value=$1
  if ! [[ "$value" =~ ^[0-9]+$ ]] || [ "$value" -lt 1 ] || [ "$value" -gt 255 ]; then
    echo "Invalid IP component: $value"
    exit 1
  fi
}

# Function to check if an IP address is already in use
check_ip_in_use() {
  local ip=$1
  if ping -c 1 -W 1 $ip > /dev/null; then
    echo "IP address $ip is already in use."
    exit 1
  fi
}

# Check if two arguments are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <192.168.c.d> <192.168.5.d>"
  exit 1
fi

# Extract and validate components of the first IP
IFS='.' read -r -a ip1 <<< "$1"
if [ "${ip1[0]}" != "192" ] || [ "${ip1[1]}" != "168" ]; then
  echo "Invalid IP format: $1"
  exit 1
fi
validate_ip_component "${ip1[2]}"
validate_ip_component "${ip1[3]}"

# Extract and validate components of the second IP
IFS='.' read -r -a ip2 <<< "$2"
if [ "${ip2[0]}" != "192" ] || [ "${ip2[1]}" != "168" ] || [ "${ip2[2]}" != "5" ]; then
  echo "Invalid IP format: $2"
  exit 1
fi
validate_ip_component "${ip2[3]}"

# Assign variables for easier reference
c="${ip1[2]}"
d1="${ip1[3]}"
d2="${ip2[3]}"

# Check if the IPs are in use
check_ip_in_use "192.168.$c.$d1"
check_ip_in_use "192.168.5.$d2"

# Create the Netplan configuration files
cat <<EOF | sudo tee /etc/netplan/01-ens192-installer-config.yaml > /dev/null
network:
  ethernets:
    ens192:
      addresses:
      - 192.168.$c.$d1/24
      nameservers:
        addresses:
        - 1.1.1.1
      routes:
      - to: default
        via: 192.168.1.1
EOF

cat <<EOF | sudo tee /etc/netplan/02-ens192-vlan5-installer-config.yaml > /dev/null
network:
  vlans:
    ens192.5:
      id: 5
      link: ens192
      addresses: [192.168.5.$d2/24]
      routes:
        - to: 0.0.0.0/0
          via: 192.168.5.1
          metric: 100
  version: 2
EOF

# Apply the Netplan configuration
sudo netplan try && sudo netplan apply
