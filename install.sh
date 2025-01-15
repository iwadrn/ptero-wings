#!/bin/bash

# Prompt for domain name and email
read -p "Enter your domain name (e.g., example.com): " DOMAIN
read -p "Enter your email address for Let's Encrypt: " EMAIL

# Update system packages
sudo apt-get update

# Install required dependencies
sudo apt-get install -y curl certbot python3-certbot-nginx

# Generate SSL certificate using certbot
sudo certbot certonly --nginx -d "$DOMAIN" --email "$EMAIL" --agree-tos --no-eff-email

# Install Docker
curl -sSL https://get.docker.com/ | CHANNEL=stable bash
sudo systemctl enable --now docker

# Create Pterodactyl directory
sudo mkdir -p /etc/pterodactyl

# Download Wings Daemon
curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$([[ \"$(uname -m)\" == \"x86_64\" ]] && echo \"amd64\" || echo \"arm64\")"
sudo chmod u+x /usr/local/bin/wings

# Create Wings systemd service file
sudo bash -c 'cat > /etc/systemd/system/wings.service <<EOF
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service
PartOf=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF'

# Start Wings Daemon
sudo systemctl enable --now wings

# Display completion message
echo "Pterodactyl installation script completed. Configure /etc/pterodactyl/config.yml as needed."

nano /etc/pterodactyl/config.yml
