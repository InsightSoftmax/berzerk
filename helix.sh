#!/bin/bash

echo "01: Prepration"

## Prerequisites
chmod +x /root/packer-helper.sh
. /root/packer-helper.sh
# error_detect_on
install_cloud_init latest

# Install Docker if not installed
if ! [ -x "$(command -v docker)" ]; then
  curl -fsSL https://get.docker.com | sh -
fi

# Install Ollama if not installed
if ! [ -x "$(command -v ollama)" ]; then
  curl -fsSL https://ollama.com/install.sh | sh
fi

echo "02: Configure Helix"
curl -sL -O https://get.helix.ml/install.sh
chmod +x install.sh
yes | ./install.sh --openai-api-key ollama --openai-base-url http://host.docker.internal:11434/v1

echo "03: Install Helix"
# Config Ollma server to accept Helix if not already done
if ! grep -q "OLLAMA_HOST" /etc/systemd/system/ollama.service; then
  sed -i "/\[Service\]/a Environment=\"OLLAMA_HOST=0.0.0.0:11434\"" /etc/systemd/system/ollama.service
  systemctl daemon-reload
  systemctl restart ollama
fi

chmod +x /opt/helix-startup.sh

# Cleanup apt cache
apt-get clean --yes && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Pull required images
cd /opt/HelixML
docker compose pull

# I want to create a new service for systemd, create it plz
cat <<EOF > /etc/systemd/system/helix-startup.service
[Unit]
Description=Run My Script Once at Startup
After=docker.service ollama.service
Requires=docker.service ollama.service

[Service]
ExecStart=/opt/helix-startup.sh
Type=oneshot
RemainAfterExit=true

[Install]
WantedBy=default.target
EOF

# Enable the service
systemctl enable helix-startup.service

echo "04: Clean up"
## Prepare server snapshot for Marketplace
clean_system
