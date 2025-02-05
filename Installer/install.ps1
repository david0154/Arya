# This script installs Arya Language, necessary dependencies, and server tools on Windows

# Developer Info
$DEVELOPER_EMAIL = "davidk76011@gmail.com"
$DEVELOPER_ADDRESS = "Kolkata, Salt Lake Sector 5, West Bengal, India 🇮🇳"

# Check if Chocolatey is installed, if not, install it
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
} else {
    Write-Host "Chocolatey already installed"
}

# Install base tools (PHP, Python, Node.js, Git, Apache, Nginx)
Write-Host "Installing dependencies..."
choco install php python nodejs git apache nginx -y

# Install WSL (Windows Subsystem for Linux)
Write-Host "Installing WSL..."
wsl --install

# Install Ubuntu (or any preferred Linux distro for WSL)
Write-Host "Installing Ubuntu for WSL..."
wsl --set-default Ubuntu

# Install Let's Encrypt dependencies
Write-Host "Installing Let's Encrypt dependencies..."
choco install certbot -y

# Set up directories for Arya Language installation
$aryaInstallDir = "C:\Program Files\AryaLanguage"
New-Item -Path $aryaInstallDir -ItemType Directory -Force

# Clone Arya Language from GitHub
Write-Host "Cloning Arya Language from GitHub..."
git clone https://github.com/yourgithub/arya-language.git $aryaInstallDir

# Install Python dependencies
Write-Host "Installing Python dependencies..."
pip install -r $aryaInstallDir\requirements.txt

# Install Node.js dependencies
Write-Host "Installing Node.js dependencies..."
cd $aryaInstallDir
npm install

# Setup environment variables for Arya Language
Write-Host "Setting up Arya environment variables..."
$envPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("PATH", "$envPath;$aryaInstallDir\bin", [System.EnvironmentVariableTarget]::Machine)

# Install SSL Certificates using Let's Encrypt (for Apache and Nginx)
Write-Host "Setting up SSL certificates for Apache and Nginx..."

# Apache setup
certbot --apache --non-interactive --agree-tos --email $DEVELOPER_EMAIL

# Nginx setup
certbot --nginx --non-interactive --agree-tos --email $DEVELOPER_EMAIL

# Verify Arya Language Installation
Write-Host "Verifying Arya Language installation..."
arya --version

# Completion message
Write-Host "Installation completed successfully!"
Write-Host "Developer: $DEVELOPER_EMAIL"
Write-Host "Address: $DEVELOPER_ADDRESS"
