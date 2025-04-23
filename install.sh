#!/bin/bash

# Auto-installer script for Arya Language, server tools, and dependencies.
# Updated for 2025 version compatibility and stable installation on Ubuntu 24.04+.

DEVELOPER_EMAIL="davidk76011@gmail.com"
DEVELOPER_ADDRESS="Kolkata, Salt Lake Sector 5, West Bengal, India"

# Languages and tools to install
LANGUAGES=("php" "python3" "nodejs" "nginx" "apache2" "openjdk-17-jdk" "golang-go" "gcc" "rustc" "maven" "npm" "composer" "python3-venv")

# Check if package is installed
check_installed() {
    dpkg -l | grep -qw "$1"
}

# Update system
echo "Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

# Install essential build tools
echo "Installing essential tools..."
sudo apt install -y build-essential curl software-properties-common gnupg2 unzip lsb-release

# Add repositories for latest versions
echo "Adding latest repositories..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
curl -fsSL https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -o packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb

# Install packages
echo "Installing required languages and server tools..."
for lang in "${LANGUAGES[@]}"; do
    if check_installed $lang; then
        echo "$lang is already installed."
    else
        echo "Installing $lang..."
        sudo apt-get install -y $lang
    fi
done

# Install and upgrade pip
echo "Installing pip..."
sudo apt install -y python3-pip
python3 -m pip install --upgrade pip setuptools wheel

# Setup Python virtual environment
echo "Setting up Python venv for Arya..."
cd /usr/local/Arya || sudo mkdir -p /usr/local/Arya && cd /usr/local/Arya
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo "Virtual environment created."
fi
source venv/bin/activate
echo "Virtual environment activated."
[ -f "requirements.txt" ] && pip install -r requirements.txt || echo "No requirements.txt found."
deactivate

# Node.js dependencies
[ -f "package.json" ] && npm install || echo "No Node.js dependencies found."

# Set path
sudo chown -R $USER:$USER /usr/local/Arya
[[ ":$PATH:" != *":/usr/local/Arya/bin:"* ]] && echo 'export PATH=$PATH:/usr/local/Arya/bin' >> ~/.bashrc && source ~/.bashrc

# Verify Arya (replace with actual verification command)
echo "Checking Arya..."
command -v arya && arya --version || echo "Arya command not found."

# Install popular dev libraries
echo "Installing language libraries..."

# PHP
composer global require laravel/installer symfony/console doctrine/orm phpunit/phpunit

# Node.js
npm install -g express react lodash axios mongoose socket.io moment

# Go
go mod init example.com/arya
go get github.com/gin-gonic/gin golang.org/x/tools github.com/sirupsen/logrus

# Java
mvn dependency:get -Dartifact=org.springframework.boot:spring-boot-starter:3.2.0
mvn dependency:get -Dartifact=org.apache.commons:commons-lang3:3.13.0

# Rust
cargo install rocket actix-web serde serde_json

# Install AI Libraries (PyTorch, TensorFlow, Hugging Face, etc.)
echo "Installing AI development libraries..."

# Core ML/DL libraries
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
pip install tensorflow
pip install transformers datasets

# Data science tools
pip install scikit-learn pandas matplotlib seaborn jupyter notebook

# NLP and CV libraries
pip install spacy nltk opencv-python opencv-python-headless

# spaCy English model
python -m spacy download en_core_web_sm

# Extended AI/ML Toolkit Installation
echo "Installing extended AI/ML and deployment tools..."

# Object Detection & Vision
pip install ultralytics  # YOLOv8

# FastAI
pip install fastai

# Deployment frameworks
pip install fastapi uvicorn gradio flask

# LLMs and Prompt Engineering
pip install langchain openai tiktoken

# Model optimization and deployment
pip install onnx onnxruntime openvino-dev

# Speech and audio processing
pip install speechrecognition pyttsx3 gtts

echo "All AI libraries and tools installed successfully."
# DNS Setup
echo "Setting up DNS (Bind9)..."
sudo apt install -y bind9
IP=$(hostname -I | awk '{print $1}')
cat <<EOF | sudo tee /etc/bind/named.conf.local
zone "example.com" {
    type master;
    file "/etc/bind/db.example.com";
};
EOF
cat <<EOF | sudo tee /etc/bind/db.example.com
\$TTL    604800
@       IN      SOA     arya1.example.com. admin.example.com. (
                          2025042301 ; Serial
                          604800     ; Refresh
                          86400      ; Retry
                          2419200    ; Expire
                          604800 )   ; Negative Cache TTL
;
@       IN      NS      arya1.example.com.
@       IN      NS      arya2.example.com.
arya1   IN      A       $IP
arya2   IN      A       $IP
EOF
sudo systemctl restart bind9

# Mail Server
echo "Installing Postfix and Dovecot..."
sudo apt install -y postfix dovecot-core dovecot-imapd mailutils
sudo systemctl restart postfix dovecot

# MySQL
echo "Setting up MySQL..."
sudo apt install -y mysql-server
sudo systemctl enable --now mysql
DB_USER="arya_user"
DB_PASS="arya_pass"
DB_NAME="arya_db"
sudo mysql <<EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

# FTP
echo "Installing FTP server (VSFTPD)..."
sudo apt install -y vsftpd
sudo systemctl restart vsftpd
FTP_USER="arya_ftp"
FTP_PASS="ftp_password"
sudo useradd -m $FTP_USER -s /bin/bash
echo "$FTP_USER:$FTP_PASS" | sudo chpasswd

# Summary
echo -e "\nInstallation Complete!"
cat <<INFO
=========================================================
DNS Nameservers: arya1.example.com, arya2.example.com
Mail Server (IMAP/SMTP):
  SMTP: $IP (Port 587)
  IMAP: $IP (Port 993)
MySQL:
  Host: localhost
  Database: $DB_NAME
  User: $DB_USER
  Password: $DB_PASS
FTP:
  Host: $IP
  User: $FTP_USER
  Password: $FTP_PASS
Developer: $DEVELOPER_EMAIL
Location: $DEVELOPER_ADDRESS
=========================================================
INFO

# Optional reboot
# read -p "Reboot the system? (y/n): " confirm && [[ "$confirm" =~ ^[Yy]$ ]] && sudo reboot
