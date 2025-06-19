#!/bin/bash
set -e


echo "Starting Supabase installation for CESCO: $CESCO_NAME"

# Update system
apt-get update -y
apt-get upgrade -y
apt-get install -y curl git ufw postgresql-client python3 python3-pip

# Install Docker
mkdir setup
cd setup
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
systemctl enable docker
systemctl start docker

# Create supabase directory
mkdir -p /opt/supabase
cd /opt/supabase

