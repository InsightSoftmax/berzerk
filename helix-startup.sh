#!/bin/bash

set -e

export HOME=/root

ollama pull llama3
ollama list

# Get the VM IP
VM_IP=$(hostname -I | awk '{print $1}')

# Update the Helix config to use the VM IP
sed -i "s|http://localhost:8080|http://$VM_IP:8080|g" /opt/HelixML/.env
sed -i "s|http://localhost:8080|http://$VM_IP:8080|g" /opt/HelixML/.env

# Change env file then Docker compose up -d
cd /opt/HelixML
docker compose up -d

# Config internal firewall to allow Helix to communicate with Ollama
HELLIX_NETWORK_SUBNET=$(docker network inspect helix_default -f '{{(index .IPAM.Config 0).Subnet}}')
ufw allow from $HELLIX_NETWORK_SUBNET to any port 11434
