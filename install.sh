#!/bin/bash

# This script automatically installs Arya Language, server tools, and all dependencies.
# It checks existing languages and libraries, installs the missing ones, and sets up DNS, mail, MySQL, and FTP.

# Developer's Info
DEVELOPER_EMAIL="davidk76011@gmail.com"
DEVELOPER_ADDRESS="Kolkata, Salt Lake Sector 5, West Bengal, India 🇮🇳"

# Languages and tools to check and install
LANGUAGES=("php" "python3" "nodejs" "nginx" "apache2" "openjdk-11-jdk" "golang" "gcc" "rustc" "maven" "npm" "composer" "python3-venv")

# Function to check if a package is installed
check_installed() {
    dpkg -l | grep -q $1
}

# Update and upgrade the system
echo "Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

# Install required languages and tools
echo "Checking and installing missing languages and server tools..."
for lang in "${LANGUAGES[@]}"; do
    if check_installed $lang; then
        echo "$lang is already installed. Skipping..."
    else
        echo "Installing $lang..."
        sudo apt-get install -y $lang
    fi
done

# Install pip for Python and upgrade it
echo "Installing and upgrading pip for Python..."
sudo apt install -y python3-pip
python3 -m pip install --upgrade pip

# Create and activate Python virtual environment for Arya
echo "Setting up Python virtual environment for Arya..."
cd /usr/local/Arya || exit
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo "Virtual environment created."
else
    echo "Virtual environment already exists."
fi

# Activate the virtual environment
source venv/bin/activate
echo "Virtual environment activated."

# Install Python dependencies inside the virtual environment
if [ -f "requirements.txt" ]; then
    echo "Installing Python dependencies from requirements.txt..."
    pip install -r requirements.txt
else
    echo "No requirements.txt file found. Skipping Python dependencies."
fi

# Deactivate virtual environment
deactivate
echo "Python virtual environment deactivated."

# Install Node.js dependencies if package.json exists
if [ -f "package.json" ]; then
    npm install
else
    echo "No package.json file found. Skipping Node.js dependencies."
fi

# Set permissions for Arya directory
sudo chown -R $USER:$USER /usr/local/Arya
echo 'export PATH=$PATH:/usr/local/Arya/bin' >> ~/.bashrc
source ~/.bashrc

# Verify Arya installation
echo "Verifying Arya installation..."
arya --version

# Install libraries for PHP, Python (venv), Node.js, Go, Java, Rust, and C
echo "Installing language-specific libraries..."

# PHP Libraries
composer global require laravel/installer symfony/console doctrine/orm phpunit/phpunit

# Node.js Libraries
npm install -g express react lodash axios mongoose socket.io moment

# Go Libraries
go mod init example.com/myproject
go get github.com/gin-gonic/gin golang.org/x/tools github.com/sirupsen/logrus

# Java Libraries
mvn install org.springframework.boot:spring-boot-starter org.apache.commons:commons-lang3 org.hibernate:hibernate-core

# Rust Libraries
cargo install rocket actix-web serde serde_json

# C Libraries
sudo apt install -y build-essential
gcc --version

# DNS Configuration (arya1 and arya2)
echo "Configuring DNS server with Bind9..."
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
                          2         ; Serial
                     604800         ; Refresh
                      86400         ; Retry
                    2419200         ; Expire
                     604800 )       ; Negative Cache TTL
;
@       IN      NS      arya1.example.com.
@       IN      NS      arya2.example.com.
arya1   IN      A       $IP
arya2   IN      A       $IP
EOF
sudo systemctl restart bind9

# Mail Server Setup (Postfix and Dovecot)
echo "Setting up mail server (Postfix and Dovecot)..."
sudo apt install -y postfix dovecot-core dovecot-imapd
sudo systemctl restart postfix dovecot

# MySQL Database Setup
echo "Installing and configuring MySQL server..."
sudo apt install -y mysql-server
sudo systemctl start mysql
DB_USER="arya_user"
DB_PASS="arya_pass"
DB_NAME="arya_db"
mysql -e "CREATE DATABASE $DB_NAME;"
mysql -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"

# FTP Server Setup (VSFTPD)
echo "Setting up FTP server (VSFTPD)..."
sudo apt install -y vsftpd
sudo systemctl restart vsftpd
FTP_USER="arya_ftp"
FTP_PASS="ftp_password"
sudo useradd -m $FTP_USER -s /bin/bash
echo "$FTP_USER:$FTP_PASS" | sudo chpasswd

# Display Final Configuration Details
echo "Installation completed successfully! Here are your configuration details:"
echo "========================================================="
echo "DNS Nameservers: arya1.example.com, arya2.example.com"
echo "Mail Server (IMAP/SMTP):"
echo "  Login: your_email@example.com"
echo "  SMTP: $IP (Port 587)"
echo "  IMAP: $IP (Port 993)"
echo "Database:"
echo "  MySQL Host: localhost"
echo "  Database Name: $DB_NAME"
echo "  Username: $DB_USER"
echo "  Password: $DB_PASS"
echo "FTP Server:"
echo "  FTP Host: $IP"
echo "  Username: $FTP_USER"
echo "  Password: $FTP_PASS"
echo "========================================================="
echo "Developer: $DEVELOPER_EMAIL"
echo "Address: $DEVELOPER_ADDRESS"

# Optional Reboot
# echo "Rebooting system..."
# sudo reboot
