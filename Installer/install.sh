#!/bin/bash

# This script will automatically install Arya Language, server tools (nginx, apache), and all dependencies

# Developer's Info
DEVELOPER_EMAIL="davidk76011@gmail.com"
DEVELOPER_ADDRESS="Kolkata, Salt Lake Sector 5, West Bengal, India 🇮🇳"
LANGUAGES=("php" "python3" "nodejs" "nginx" "apache2")

# Update package lists and upgrade the system
echo "Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

# Install required base languages and tools
echo "Installing required base languages and server tools..."
for lang in "${LANGUAGES[@]}"; do
    echo "Installing $lang..."
    sudo apt-get install -y $lang
done

# Install Let's Encrypt and Nginx/Apache SSL Configuration
echo "Installing Let's Encrypt and configuring SSL for Apache and Nginx..."
sudo apt-get install -y certbot python3-certbot-nginx python3-certbot-apache

# Configure Nginx SSL (Let's Encrypt)
echo "Configuring Nginx with Let's Encrypt SSL..."
sudo systemctl restart nginx
sudo certbot --nginx --non-interactive --agree-tos --email $DEVELOPER_EMAIL

# Configure Apache SSL (Let's Encrypt)
echo "Configuring Apache with Let's Encrypt SSL..."
sudo systemctl restart apache2
sudo certbot --apache --non-interactive --agree-tos --email $DEVELOPER_EMAIL

# Download Arya Language package (from GitHub or other repository)
echo "Downloading Arya Language package..."
git clone https://github.com/yourgithub/arya-language.git /usr/local/arya

# Install Arya Language dependencies
echo "Installing Arya dependencies..."
cd /usr/local/arya
python3 -m pip install -r requirements.txt
npm install

# Set permissions
echo "Setting permissions for Arya directory..."
sudo chown -R $USER:$USER /usr/local/arya

# Add Arya Language to system PATH
echo "Adding Arya to system PATH..."
echo 'export PATH=$PATH:/usr/local/arya/bin' >> ~/.bashrc
source ~/.bashrc

# Verify installation
echo "Verifying Arya installation..."
arya --version

echo "Installation completed successfully!"

# Print developer info
echo "Developer: $DEVELOPER_EMAIL"
echo "Address: $DEVELOPER_ADDRESS"
