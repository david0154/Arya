#!/bin/bash

# This script will automatically install Arya Language, server tools (nginx, apache), and all dependencies

# Developer's Info
DEVELOPER_EMAIL="davidk76011@gmail.com"
DEVELOPER_ADDRESS="Kolkata, Salt Lake Sector 5, West Bengal, India 🇮🇳"

# Base languages to install
LANGUAGES=("php" "python3" "nodejs" "nginx" "apache2" "openjdk-11-jdk" "golang" "gcc" "rustc" "maven" "npm" "composer")

# Update package lists and upgrade the system
echo "Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

# Install required base languages and server tools
echo "Installing required base languages and server tools..."
for lang in "${LANGUAGES[@]}"; do
    echo "Installing $lang..."
    sudo apt-get install -y $lang
done

# Install pip for Python
echo "Installing pip for Python..."
sudo apt install -y python3-pip

# Ensure pip is upgraded
echo "Upgrading pip..."
python3 -m pip install --upgrade pip

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
git clone https://github.com/david0154/Arya.git /usr/local/Arya

# Install Arya Language dependencies
echo "Installing Arya dependencies..."
cd /usr/local/Arya

# Check if requirements.txt exists
if [ -f "requirements.txt" ]; then
    python3 -m pip install -r requirements.txt
else
    echo "No requirements.txt file found. Skipping Python dependencies."
fi

# Install Node.js dependencies if package.json exists
if [ -f "package.json" ]; then
    npm install
else
    echo "No package.json file found. Skipping Node.js dependencies."
fi

# Set permissions
echo "Setting permissions for Arya directory..."
sudo chown -R $USER:$USER /usr/local/Arya

# Add Arya Language to system PATH
echo "Adding Arya to system PATH..."
echo 'export PATH=$PATH:/usr/local/Arya/bin' >> ~/.bashrc
source ~/.bashrc

# Verify Arya installation
echo "Verifying Arya installation..."
arya --version

# Install Base Language Libraries for each language

# PHP Libraries Installation
echo "Installing all PHP Libraries..."
cd /usr/local/Arya/php
composer global require laravel/installer symfony/console doctrine/orm phpunit/phpunit

# Python Libraries Installation
echo "Installing all Python Libraries..."
cd /usr/local/Arya/python
pip install numpy pandas scikit-learn tensorflow keras flask django requests beautifulsoup4 matplotlib

# Node.js Libraries Installation
echo "Installing all Node.js Libraries..."
cd /usr/local/Arya/nodejs
npm install express react lodash axios mongoose socket.io moment

# Go Libraries Installation
echo "Installing Go (Ensure modules are enabled)..."
cd /usr/local/Arya/go

# Ensure Go Modules are enabled (since 'go get' is deprecated outside modules)
echo "Initializing Go module..."
go mod init example.com/myproject

# Install Go libraries via go get with modules
go get github.com/gin-gonic/gin golang.org/x/tools github.com/sirupsen/logrus

# Java Libraries Installation
echo "Installing all Java Libraries..."
cd /usr/local/Arya/java
mvn install org.springframework.boot:spring-boot-starter org.apache.commons:commons-lang3 org.hibernate:hibernate-core

# Rust Libraries Installation
echo "Installing all Rust Libraries..."
cd /usr/local/Arya/rust

# Install rust libraries using cargo
cargo install rocket actix-web serde serde_json

# C Libraries Installation
echo "Installing all C Libraries..."
cd /usr/local/Arya/c

# Install common C libraries using apt
sudo apt install -y build-essential

# Verify installation of GCC and other C tools
gcc --version

echo "All base language libraries installed successfully!"

# Installation completed
echo "Installation completed successfully!"

# Print developer info
echo "Developer: $DEVELOPER_EMAIL"
echo "Address: $DEVELOPER_ADDRESS"

# Reboot the system (optional)
# echo "Rebooting system..."
# sudo reboot
