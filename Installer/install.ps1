# This script will automatically install Arya Language, base languages (PHP, Python, Node.js, Go, Java, Rust), and necessary dependencies on Windows.

# Developer's Info
$DEVELOPER_EMAIL = "davidk76011@gmail.com"
$DEVELOPER_ADDRESS = "Kolkata, Salt Lake Sector 5, West Bengal, India 🇮🇳"

# Install Base languages and tools
$languages = @(
    "php", "python", "nodejs", "nginx", "apache", "openjdk", "golang", "rust", "composer", "npm"
)

# Updating system and installing base languages
Write-Host "Updating system and installing base languages..."

# Function to install a program via Chocolatey (if installed)
function Install-ChocoPackage {
    param([string]$packageName)
    choco install $packageName -y
}

# Install Chocolatey if it's not installed
if (-Not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Install languages and tools via Chocolatey
foreach ($lang in $languages) {
    Write-Host "Installing $lang..."
    Install-ChocoPackage -packageName $lang
}

# Install Arya Language
Write-Host "Downloading Arya Language from GitHub..."
git clone https://github.com/david0154/Arya.git "C:\Program Files\Arya"

# Install Arya dependencies
Write-Host "Installing Arya dependencies..."

# Install Python dependencies
Write-Host "Installing Python dependencies..."
pip install -r "C:\Program Files\Arya\requirements.txt"

# Install Node.js dependencies
Write-Host "Installing Node.js dependencies..."
npm install --prefix "C:\Program Files\Arya"

# Set PATH for Arya Language to be available globally
$env:Path += ";C:\Program Files\Arya\bin"
[System.Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)

# Verify Arya installation
Write-Host "Verifying Arya installation..."
arya --version

# Install Libraries for each language

# PHP Libraries Installation using Composer
Write-Host "Installing PHP Libraries..."
composer global require laravel/installer symfony/console doctrine/orm phpunit/phpunit

# Python Libraries Installation
Write-Host "Installing Python Libraries..."
pip install numpy pandas scikit-learn tensorflow keras flask django requests beautifulsoup4 matplotlib

# Node.js Libraries Installation
Write-Host "Installing Node.js Libraries..."
npm install express react lodash axios mongoose socket.io moment

# Go Libraries Installation
Write-Host "Installing Go Libraries..."
go get github.com/gin-gonic/gin golang.org/x/tools github.com/sirupsen/logrus

# Java Libraries Installation (using Maven)
Write-Host "Installing Java Libraries..."
mvn install org.springframework.boot:spring-boot-starter org.apache.commons:commons-lang3 org.hibernate:hibernate-core

# Rust Libraries Installation
Write-Host "Installing Rust Libraries..."
cargo install rocket actix-web serde serde_json

Write-Host "All base language libraries installed successfully!"

# Completion Message
Write-Host "Installation completed successfully!"

# Print developer info
Write-Host "Developer: $DEVELOPER_EMAIL"
Write-Host "Address: $DEVELOPER_ADDRESS"
