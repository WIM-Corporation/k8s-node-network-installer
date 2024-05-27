#!/bin/bash

# /etc/multipath.conf 파일에 새로운 라인 추가
echo "Adding new configuration to /etc/multipath.conf..."

sudo tee -a /etc/multipath.conf > /dev/null <<EOL

blacklist {
    devnode "^sd[a-z0-9]+"
}
EOL

# multipathd 서비스 재시작
echo "Restarting multipathd service..."
sudo systemctl restart multipathd.service

echo "Configuration added and multipathd service restarted."
