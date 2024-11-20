#!/bin/bash

# Function to validate the IP octet
validate_ip_octet() {
  local value=$1
  if ! [[ "$value" =~ ^[0-9]+$ ]] || [ "$value" -lt 1 ] || [ "$value" -gt 254 ]; then
    echo "Invalid IP octet: $value. It should be a number between 1 and 254."
    exit 1
  fi
}

# Function to check if an IP is free using arp-scan
check_ip_free() {
  local ip=$1
  local interface=$2
  sudo arp-scan -I "$interface" "$ip" 2>/dev/null | awk '{print $1}' | grep -qw "$ip"
}

# Function to find the first free IP in a subnet
find_free_ip() {
  local subnet=$1
  local interface=$2
  for i in {110..254}; do
    local ip="$subnet.$i"
    if ! check_ip_free "$ip" "$interface"; then
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

# Define subnets and interface
subnet1="192.168.1"
subnet2="192.168.5"
interface="ens192"  # Update this if your network interface differs

# Ensure `arp-scan` is installed
if ! command -v arp-scan &> /dev/null; then
  echo "arp-scan is not installed. Installing..."
  sudo apt update && sudo apt install -y arp-scan
fi

# Find free IPs in each subnet
free_ip1=$(find_free_ip "$subnet1" "$interface")
free_ip2=$(find_free_ip "$subnet2" "$interface")

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
