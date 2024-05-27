#!/bin/bash

# 업데이트 패키지 목록
echo "Updating package list..."
sudo apt-get update -y

# OpenSSH 서버 설치
echo "Installing OpenSSH server..."
sudo apt-get install -y openssh-server

# OpenSSH 서버 서비스 시작 및 활성화
echo "Starting and enabling SSH service..."
sudo systemctl start ssh
sudo systemctl enable ssh

# 방화벽 규칙 설정 (UFW가 설치된 경우)
if command -v ufw > /dev/null; then
    echo "Configuring firewall to allow SSH connections..."
    sudo ufw allow ssh
    sudo ufw reload
fi

# 상태 확인
echo "OpenSSH server installation completed. Checking SSH service status..."
sudo systemctl status ssh

echo "OpenSSH server is now installed and running."
