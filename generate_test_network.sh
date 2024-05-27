#!/bin/bash

# IP 주소의 마지막 옥텟을 인자로 받기
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <last_octet>"
  exit 1
fi

last_octet=$1

# IP 주소 검증 (1 ~ 254)
if ! [[ "$last_octet" =~ ^[0-9]+$ ]] || [ "$last_octet" -lt 1 ] || [ "$last_octet" -gt 254 ]; then
  echo "Invalid IP address last octet: $last_octet"
  exit 1
fi

# Netplan 설정 파일 생성
echo "Creating Netplan configuration file..."
sudo tee . > /dev/null <<EOL
network:
  ethernets:
    ens192:
      addresses:
      - 192.168.1.$last_octet/24
      nameservers:
        addresses:
        - 1.1.1.1
      routes:
      - to: default
        via: 192.168.1.1
EOL


echo "Netplan configuration file created."
