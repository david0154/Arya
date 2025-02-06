#!/bin/bash

# This script will automatically install Arya Language, server tools (nginx, apache), and all dependencies

# Developer's Info
DEVELOPER_EMAIL="davidk76011@gmail.com"
DEVELOPER_ADDRESS="Kolkata, Salt Lake Sector 5, West Bengal, India 🇮🇳"

# Base languages to install
LANGUAGES=("php" "python3" "nodejs" "nginx" "apache2" "openjdk-11-jdk" "golang" "gcc" "rustc" "composer" "npm" "maven" "rust" "make" "libc-dev")

# Update package lists and upgrade the system
echo "Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

# Install required base languages and server tools
echo "Installing required base languages and server tools..."
for lang in "${LANGUAGES[@]}"; do
    echo "Installing $lang..."
    sudo apt-get install -y $lang
done

# Check if Go is installed
echo "Checking if Go is installed..."
if ! command -v go &> /dev/null
then
    echo "Go not found. Installing Go..."
    sudo apt-get install -y golang
fi

# Check if Rust is installed (install cargo if missing)
echo "Checking if Rust is installed..."
if ! command -v cargo &> /dev/null
then
    echo "Rust not found. Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source $HOME/.cargo/env
fi

# Install Maven if it's missing
echo "Checking if Maven is installed..."
if ! command -v mvn &> /dev/null
then
    echo "Maven not found. Installing Maven..."
    sudo apt-get install -y maven
fi

# Install pip if it's missing
echo "Checking if pip is installed..."
if ! command -v pip &> /dev/null
then
    echo "pip not found. Installing pip..."
    sudo apt-get install -y python3-pip
fi

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

# Function to ensure directory existence and install libraries
install_libraries() {
    local language=$1
    local dir=$2
    local install_command=$3
    
    if [ ! -d "$dir" ]; then
        echo "Directory $dir not found. Creating..."
        mkdir -p "$dir"
    fi
    
    echo "Installing libraries for $language..."
    cd "$dir"
    eval "$install_command"
}

# PHP Libraries Installation
install_libraries "PHP" "/usr/local/arya/php" "composer install"

# Python Libraries Installation
install_libraries "Python" "/usr/local/arya/python" "pip install -r requirements.txt"

# Node.js Libraries Installation
install_libraries "Node.js" "/usr/local/arya/nodejs" "npm install"

# Go Libraries Installation
install_libraries "Go" "/usr/local/arya/go" "go get github.com/gin-gonic/gin golang.org/x/tools github.com/sirupsen/logrus"

# Java Libraries Installation
install_libraries "Java" "/usr/local/arya/java" "mvn install"

# Rust Libraries Installation
install_libraries "Rust" "/usr/local/arya/rust" "cargo install rocket actix-web serde serde_json"

# C Libraries Installation
install_libraries "C" "/usr/local/arya/c" "gcc -o hello_world hello_world.c"

echo "All base language libraries installed successfully!"

# Installation completed
echo "Installation completed successfully!"

# Print developer info
echo "Developer: $DEVELOPER_EMAIL"
echo "Address: $DEVELOPER_ADDRESS"
