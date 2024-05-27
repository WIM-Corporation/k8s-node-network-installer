#!/bin/bash

# 새로운 호스트네임을 인자로 받기
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <new_host_name>"
  exit 1
fi

new_host_name=$1

# 호스트네임 변경
echo "Changing hostname to $new_host_name..."
sudo hostnamectl set-hostname "$new_host_name"

# /etc/hosts 파일 업데이트
echo "Updating /etc/hosts..."
sudo sed -i "s/127.0.1.1 .*/127.0.1.1 $new_host_name/" /etc/hosts

# 호스트네임 검증
current_host_name=$(hostname)
if [ "$current_host_name" != "$new_host_name" ]; then
  echo "Hostname change failed: current hostname is $current_host_name"
  exit 1
fi

echo "Hostname successfully changed to $new_host_name"

# 로그인 세션 종료
echo "Ending login session..."

if [ "$SHELL" == "/bin/bash" ]; then
  kill -HUP $PPID
else
  logout
fi
