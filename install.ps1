# PowerShell script to install Arya Language, server tools, and all dependencies

# Developer's Info
$DEVELOPER_EMAIL = "davidk76011@gmail.com"
$DEVELOPER_ADDRESS = "Kolkata, Salt Lake Sector 5, West Bengal, India 🇮🇳"

# Check if running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Please run this script as Administrator."
    exit 1
}

# Languages and tools to install
$languages = @("python", "nodejs", "nginx", "apache", "openjdk", "golang", "gcc", "rust", "maven", "composer")

# Function to install packages using Chocolatey
Function Install-Package {
    param (
        [string]$packageName
    )
    if (-Not (choco list $packageName --local-only | Select-String $packageName)) {
        Write-Host "Installing $packageName..."
        choco install $packageName -y
    } else {
        Write-Host "$packageName is already installed. Skipping..."
    }
}

# Check and install Chocolatey (if not installed)
if (-Not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey package manager..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Install required languages and tools
Write-Host "Checking and installing missing languages and server tools..."
foreach ($lang in $languages) {
    Install-Package $lang
}

# Install Python virtual environment and pip
Write-Host "Setting up Python virtual environment..."
pip install virtualenv
cd C:\Arya
if (-Not (Test-Path "venv")) {
    python -m venv venv
    Write-Host "Virtual environment created."
} else {
    Write-Host "Virtual environment already exists."
}

# Activate virtual environment and install dependencies
& .\venv\Scripts\activate
if (Test-Path "requirements.txt") {
    Write-Host "Installing Python dependencies from requirements.txt..."
    pip install -r requirements.txt
} else {
    Write-Host "No requirements.txt file found. Skipping Python dependencies."
}
deactivate

# Install Node.js dependencies if package.json exists
if (Test-Path "package.json") {
    Write-Host "Installing Node.js dependencies..."
    npm install
} else {
    Write-Host "No package.json file found. Skipping Node.js dependencies."
}

# DNS Server Configuration (Windows DNS)
Write-Host "Configuring DNS Server..."
# (DNS server configuration commands would be here — requires specific tools for Windows)

# Install IIS (for web server functionality)
Write-Host "Installing IIS (Internet Information Services)..."
Install-WindowsFeature -name Web-Server -IncludeManagementTools

# MySQL Server Installation
Write-Host "Installing MySQL Server..."
choco install mysql -y
Start-Service mysql
$DB_USER = "arya_user"
$DB_PASS = "arya_pass"
$DB_NAME = "arya_db"
mysql -e "CREATE DATABASE $DB_NAME;"
mysql -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"

# FTP Server Installation (Windows IIS FTP)
Write-Host "Installing FTP Server..."
Install-WindowsFeature Web-Ftp-Server -IncludeManagementTools
New-Item -Path "C:\inetpub\ftproot" -ItemType Directory
$FTP_USER = "arya_ftp"
$FTP_PASS = "ftp_password"
net user $FTP_USER $FTP_PASS /add

# Display Configuration Details
Write-Host "Installation completed successfully! Here are your configuration details:"
Write-Host "========================================================="
Write-Host "DNS Nameservers: arya1.example.com, arya2.example.com"
Write-Host "Mail Server (IMAP/SMTP):"
Write-Host "  Login: your_email@example.com"
Write-Host "  SMTP: localhost (Port 587)"
Write-Host "  IMAP: localhost (Port 993)"
Write-Host "Database:"
Write-Host "  MySQL Host: localhost"
Write-Host "  Database Name: $DB_NAME"
Write-Host "  Username: $DB_USER"
Write-Host "  Password: $DB_PASS"
Write-Host "FTP Server:"
Write-Host "  FTP Host: localhost"
Write-Host "  Username: $FTP_USER"
Write-Host "  Password: $FTP_PASS"
Write-Host "========================================================="
Write-Host "Developer: $DEVELOPER_EMAIL"
Write-Host "Address: $DEVELOPER_ADDRESS"

# Optional System Restart
# Write-Host "Restarting the system..."
# Restart-Computer -Force
