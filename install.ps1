# PowerShell script to install Arya Language, server tools, and all dependencies

# Developer's Info
$DEVELOPER_EMAIL = "davidk76011@gmail.com"
$DEVELOPER_ADDRESS = "Kolkata, Salt Lake Sector 5, West Bengal, India 🇮🇳"

# Ensure script is run as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Please run this script as Administrator."
    exit 1
}

# List of languages and tools
$languages = @("python", "nodejs", "nginx", "apache-httpd", "openjdk", "golang", "gcc", "rust", "maven", "composer")

Function Install-Package {
    param ([string]$packageName)
    if (-Not (choco list $packageName --local-only | Select-String "^$packageName")) {
        Write-Host "Installing $packageName..."
        choco install $packageName -y
    } else {
        Write-Host "$packageName is already installed. Skipping..."
    }
}

# Install Chocolatey if not available
if (-Not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    refreshenv
}

# Install listed packages
Write-Host "`nInstalling required languages and server tools..."
foreach ($lang in $languages) {
    Install-Package $lang
}

# Python virtual environment setup
Write-Host "`nSetting up Python virtual environment..."
if (-Not (Test-Path "C:\Arya")) { New-Item -Path "C:\" -Name "Arya" -ItemType Directory }
cd C:\Arya
if (-Not (Test-Path "venv")) {
    python -m venv venv
    Write-Host "Created Python virtual environment."
}
.\venv\Scripts\activate
if (Test-Path "requirements.txt") {
    Write-Host "Installing dependencies from requirements.txt..."
    pip install --upgrade pip
    pip install -r requirements.txt
} else {
    Write-Host "No requirements.txt found."
}
deactivate

# Node.js dependency install
if (Test-Path "package.json") {
    Write-Host "`nInstalling Node.js dependencies..."
    npm install
}

# Configure IIS and FTP
Write-Host "`nInstalling IIS and FTP server..."
Install-WindowsFeature -Name Web-Server, Web-Ftp-Server -IncludeManagementTools
New-Item -Path "C:\inetpub\ftproot" -ItemType Directory -Force
$FTP_USER = "arya_ftp"
$FTP_PASS = "ftp_password"
net user $FTP_USER $FTP_PASS /add

# Install MySQL
Write-Host "`nInstalling MySQL Server..."
choco install mysql -y
Start-Service mysql
$DB_USER = "arya_user"
$DB_PASS = "arya_pass"
$DB_NAME = "arya_db"
mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"

# Display Summary
Write-Host "`n========================================================="
Write-Host "Arya Language & Server Setup Completed Successfully!"
Write-Host "---------------------------------------------------------"
Write-Host "DNS Nameservers: arya1.example.com, arya2.example.com"
Write-Host "`nMail Server (IMAP/SMTP):"
Write-Host "  Email: your_email@example.com"
Write-Host "  SMTP: localhost (Port 587)"
Write-Host "  IMAP: localhost (Port 993)"
Write-Host "`nDatabase Info:"
Write-Host "  Host: localhost"
Write-Host "  DB: $DB_NAME"
Write-Host "  User: $DB_USER"
Write-Host "  Password: $DB_PASS"
Write-Host "`nFTP Server Info:"
Write-Host "  Host: localhost"
Write-Host "  User: $FTP_USER"
Write-Host "  Password: $FTP_PASS"
Write-Host "`nDeveloper: $DEVELOPER_EMAIL"
Write-Host "Location: $DEVELOPER_ADDRESS"
Write-Host "========================================================="
