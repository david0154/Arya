#!/bin/bash

# This script will automatically install Arya Language, server tools (nginx, apache), and all dependencies

# Developer's Info
DEVELOPER_EMAIL="davidk76011@gmail.com"
DEVELOPER_ADDRESS="Kolkata, Salt Lake Sector 5, West Bengal, India 🇮🇳"

# Base languages to install
LANGUAGES=("php" "python3" "nodejs" "nginx" "apache2" "openjdk-11-jdk" "golang" "gcc" "rustc" "composer" "npm")

# Update package lists and upgrade the system
echo "Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

# Install required base languages and server tools
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
git clone https://github.com/david0154/Arya.git /usr/local/arya

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

# Verify Arya installation
echo "Verifying Arya installation..."
arya --version

# Ensure language directories exist and install libraries

# PHP Libraries Installation
if [ ! -d "/usr/local/arya/php" ]; then
    echo "Directory /usr/local/arya/php not found. Creating..."
    mkdir -p /usr/local/arya/php
fi
echo "Installing all PHP Libraries..."
cd /usr/local/arya/php
composer global require laravel/installer symfony/console doctrine/orm phpunit/phpunit

# Python Libraries Installation
if [ ! -d "/usr/local/arya/python" ]; then
    echo "Directory /usr/local/arya/python not found. Creating..."
    mkdir -p /usr/local/arya/python
fi
echo "Installing all Python Libraries..."
cd /usr/local/arya/python
pip install numpy pandas scikit-learn tensorflow keras flask django requests beautifulsoup4 matplotlib

# Node.js Libraries Installation
if [ ! -d "/usr/local/arya/nodejs" ]; then
    echo "Directory /usr/local/arya/nodejs not found. Creating..."
    mkdir -p /usr/local/arya/nodejs
fi
echo "Installing all Node.js Libraries..."
cd /usr/local/arya/nodejs
npm install express react lodash axios mongoose socket.io moment

# Go Libraries Installation
if [ ! -d "/usr/local/arya/go" ]; then
    echo "Directory /usr/local/arya/go not found. Creating..."
    mkdir -p /usr/local/arya/go
fi
echo "Installing all Go Libraries..."
cd /usr/local/arya/go
go get github.com/gin-gonic/gin golang.org/x/tools github.com/sirupsen/logrus

# Java Libraries Installation
if [ ! -d "/usr/local/arya/java" ]; then
    echo "Directory /usr/local/arya/java not found. Creating..."
    mkdir -p /usr/local/arya/java
fi
echo "Installing all Java Libraries..."
cd /usr/local/arya/java
mvn install org.springframework.boot:spring-boot-starter org.apache.commons:commons-lang3 org.hibernate:hibernate-core

# Rust Libraries Installation
if [ ! -d "/usr/local/arya/rust" ]; then
    echo "Directory /usr/local/arya/rust not found. Creating..."
    mkdir -p /usr/local/arya/rust
fi
echo "Installing all Rust Libraries..."
cd /usr/local/arya/rust
cargo install rocket actix-web serde serde_json

echo "All base language libraries installed successfully!"

# Installation completed
echo "Installation completed successfully!"

# Print developer info
echo "Developer: $DEVELOPER_EMAIL"
echo "Address: $DEVELOPER_ADDRESS"
