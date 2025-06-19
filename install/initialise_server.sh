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

# Pull down the files we need to host Supabase
git clone --depth 1 https://github.com/cepro/supabase-host.git

# Configure firewall
ufw --force enable
ufw allow 22/tcp
ufw allow 5432/tcp
ufw allow 8000/tcp

# Start Supabase
echo "Starting Supabase services..."
cd supabase-host/docker
if ! docker-compose up -d; then
    echo "ERROR: Failed to start services. Check the logs..."
    docker-compose logs
    exit 1
fi

