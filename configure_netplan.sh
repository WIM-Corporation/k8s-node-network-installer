#!/bin/bash

# Function to validate the IP octet
validate_ip_octet() {
  local value=$1
  if ! [[ "$value" =~ ^[0-9]+$ ]] || [ "$value" -lt 1 ] || [ "$value" -gt 254 ]; then
    echo "Invalid IP octet: $value. It should be a number between 1 and 254."
    exit 1
  fi
}

# Function to check if an IP is in use (ARPing as default)
check_ip_free() {
  local ip=$1
  # Use arping or fallback to ping if arping fails
  if arping -c 1 -w 1 "$ip" > /dev/null 2>&1; then
    return 1 # IP is in use
  fi
  return 0 # IP is free
}

# Function to find the first free IP in a subnet
find_free_ip() {
  local subnet=$1
  for i in {1..254}; do
    local ip="$subnet.$i"
    if check_ip_free "$ip"; then
      echo "$ip"
      return 0
    fi
  done
  echo "No free IP addresses found in the $subnet.0/24 range."
  exit 1
}

# Main script logic
if [ "$#" -ne 0 ]; then
  echo "Usage: $0 (no arguments required)"
  exit 1
fi

# Define subnets
subnet1="192.168.1"
subnet2="192.168.5"

# Find free IPs in each subnet
free_ip1=$(find_free_ip "$subnet1")
free_ip2=$(find_free_ip "$subnet2")

# Generate Netplan configuration files
cat <<EOF | sudo tee /etc/netplan/01-ens192-installer-config.yaml > /dev/null
network:
  version: 2
  ethernets:
    ens192:
      addresses:
      - $free_ip1/24
      nameservers:
        addresses:
        - 1.1.1.1
      routes:
      - to: default
        via: 192.168.1.1
EOF

cat <<EOF | sudo tee /etc/netplan/02-ens192-vlan5-installer-config.yaml > /dev/null
network:
  version: 2
  vlans:
    ens192.5:
      id: 5
      link: ens192
      addresses:
      - $free_ip2/24
EOF

# Apply the configuration and handle errors
if sudo netplan apply; then
  echo "Network configuration applied successfully for IPs: $free_ip1 and $free_ip2"
else
  echo "Failed to apply Netplan configuration. Please check your network settings."
  exit 1
fi
