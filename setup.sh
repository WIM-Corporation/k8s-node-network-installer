#!/bin/bash

# Function to validate hostname
validate_hostname() {
  local hostname=$1
  # Hostname must be 1-63 characters long and can only contain alphanumeric characters, hyphens, and periods
  if [[ ! "$hostname" =~ ^[a-zA-Z0-9.-]{1,63}$ ]] || [[ "$hostname" =~ [.-]$ ]]; then
    echo "Invalid hostname: $hostname"
    echo "A hostname can only contain alphanumeric characters, hyphens (-), and periods (.) and must not end with a hyphen or period."
    exit 1
  fi
}

# Check if hostname is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <hostname>"
  exit 1
fi

# Validate the provided hostname
hostname=$1
validate_hostname "$hostname"

# Sequentially execute the other scripts
echo "Starting the configuration process with hostname: $hostname"

# Step 1: Configure Netplan
echo "Executing configure_netplan.sh..."
if ./configure_netplan.sh; then
  echo "Netplan configuration completed successfully."
else
  echo "Failed to configure Netplan."
  exit 1
fi

# Step 2: Install OpenSSH Server
echo "Executing install_openssh_server.sh..."
if ./install_openssh_server.sh; then
  echo "OpenSSH Server installation completed successfully."
else
  echo "Failed to install OpenSSH Server."
  exit 1
fi

# Step 3: Update Hostname
echo "Executing update_hostname.sh..."
if ./update_hostname.sh "$hostname"; then
  echo "Hostname updated successfully to $hostname."
else
  echo "Failed to update hostname."
  exit 1
fi

echo "All steps completed successfully."

# 로그인 세션 종료
echo "Ending login session..."

if [ "$SHELL" == "/bin/bash" ]; then
  kill -HUP $PPID
else
  logout
fi
