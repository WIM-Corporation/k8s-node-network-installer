#!/bin/bash

# Function to validate IP address component
validate_ip_component() {
  local value=$1
  if ! [[ "$value" =~ ^[0-9]+$ ]] || [ "$value" -lt 1 ] || [ "$value" -gt 255 ]; then
    echo "Invalid IP component: $value. It should be a number between 1 and 255."
    exit 1
  fi
}

# Function to check if an IP address is already in use with arping
check_ip_in_use() {
  local ip=$1
  if ! arping -c 1 -w 1 "$ip" > /dev/null 2>&1; then
    echo "IP address $ip is already in use."
    exit 1
  fi
}

# Check if only one argument is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <x> (where x is the last octet of the IP address)"
  exit 1
fi

# Validate the provided x value
x=$1
validate_ip_component "$x"

# Check if the IPs are in use for both subnets
check_ip_in_use "192.168.1.$x"
check_ip_in_use "192.168.5.$x"

# Create the Netplan configuration files
sudo tee /etc/netplan/01-ens192-installer-config.yaml > /dev/null <<EOF
network:
  version: 2
  ethernets:
    ens192:
      addresses:
      - 192.168.1.$x/24
      nameservers:
        addresses:
        - 1.1.1.1
      routes:
      - to: default
        via: 192.168.1.1
EOF

sudo tee /etc/netplan/02-ens192-vlan5-installer-config.yaml > /dev/null <<EOF
network:
  version: 2
  vlans:
    ens192.5:
      id: 5
      link: ens192
      addresses:
      - 192.168.5.$x/24
EOF

# Apply the Netplan configuration and handle errors
if sudo netplan apply; then
  echo "Network configuration applied successfully for IPs: 192.168.1.$x and 192.168.5.$x"
else
  echo "Failed to apply Netplan configuration. Please check your network settings."
  exit 1
fi
