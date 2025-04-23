# Auto-installer script for Arya Language, server tools, and dependencies.
# Updated for 2025 version compatibility on Windows.

$DeveloperEmail = "davidk76011@gmail.com"
$DeveloperAddress = "Kolkata, Salt Lake Sector 5, West Bengal, India"

# Languages and tools to install
$Languages = @("php", "python", "nodejs", "nginx", "apache2", "openjdk-17", "golang", "gcc", "rust", "maven", "npm", "composer", "python-venv")

# Check if package is installed
Function Check-Installed {
    param($PackageName)
    $installed = Get-Command $PackageName -ErrorAction SilentlyContinue
    return $installed -ne $null
}

# Update system
Write-Host "Updating system packages..."
Start-Process "powershell.exe" -ArgumentList "Set-ExecutionPolicy Unrestricted -Scope Process -Force" -NoNewWindow -Wait

# Install essential build tools
Write-Host "Installing essential tools..."
Invoke-WebRequest "https://aka.ms/install-vs2019" -OutFile "vs_installer.exe"
Start-Process "vs_installer.exe" -ArgumentList "/quiet" -NoNewWindow -Wait
Remove-Item "vs_installer.exe"

# Install packages
Write-Host "Installing required languages and server tools..."
foreach ($lang in $Languages) {
    if (Check-Installed -PackageName $lang) {
        Write-Host "$lang is already installed."
    } else {
        Write-Host "Installing $lang..."
        if ($lang -eq "python") {
            # Install Python via Windows Store (or specify custom method for installation)
            Invoke-WebRequest "https://www.python.org/ftp/python/3.10.0/python-3.10.0.exe" -OutFile "python_installer.exe"
            Start-Process "python_installer.exe" -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -NoNewWindow -Wait
            Remove-Item "python_installer.exe"
        } elseif ($lang -eq "nodejs") {
            Invoke-WebRequest "https://nodejs.org/dist/v20.0.0/node-v20.0.0-x64.msi" -OutFile "nodejs_installer.msi"
            Start-Process "msiexec.exe" -ArgumentList "/i nodejs_installer.msi /quiet" -NoNewWindow -Wait
            Remove-Item "nodejs_installer.msi"
        } else {
            Write-Host "$lang installation method is not implemented."
        }
    }
}

# Install and upgrade pip
Write-Host "Installing pip..."
Start-Process "python.exe" -ArgumentList "-m pip install --upgrade pip setuptools wheel" -NoNewWindow -Wait

# Setup Python virtual environment
Write-Host "Setting up Python venv for Arya..."
$AryaPath = "C:\Program Files\Arya"
If (!(Test-Path $AryaPath)) {
    New-Item -ItemType Directory -Force -Path $AryaPath
}
Set-Location -Path $AryaPath
If (!(Test-Path "venv")) {
    Start-Process "python.exe" -ArgumentList "-m venv venv" -NoNewWindow -Wait
    Write-Host "Virtual environment created."
}
# Activating virtual environment manually
# Run `venv\Scripts\activate` manually from PowerShell if needed

# Node.js dependencies
If (Test-Path "package.json") {
    Write-Host "Installing Node.js dependencies..."
    Start-Process "npm" -ArgumentList "install" -NoNewWindow -Wait
} else {
    Write-Host "No Node.js dependencies found."
}

# Install AI Libraries (PyTorch, TensorFlow, Hugging Face, etc.)
Write-Host "Installing AI development libraries..."
Start-Process "python.exe" -ArgumentList "-m pip install torch torchvision torchaudio" -NoNewWindow -Wait
Start-Process "python.exe" -ArgumentList "-m pip install tensorflow transformers datasets" -NoNewWindow -Wait

# DNS Setup (Bind9) on Windows alternative (like using IIS or DNS server setup in Windows)
Write-Host "DNS Setup: Note - DNS setup is more complex on Windows and needs IIS or custom DNS server."
# Not available directly in Windows PowerShell without further configurations

# Mail Server (use SMTP server on Windows)
Write-Host "Installing Mail Server: Please configure Mail Server settings manually (e.g., using hMailServer)"
# hMailServer or another SMTP server needs to be set up manually on Windows

# MySQL
Write-Host "Setting up MySQL..."
Invoke-WebRequest "https://dev.mysql.com/get/Downloads/MySQLInstaller/mysql-installer-web-community-8.0.29.0.msi" -OutFile "mysql_installer.msi"
Start-Process "msiexec.exe" -ArgumentList "/i mysql_installer.msi /quiet" -NoNewWindow -Wait
Remove-Item "mysql_installer.msi"

# FTP Server (e.g., FileZilla Server)
Write-Host "Installing FTP server (FileZilla Server)..."
Invoke-WebRequest "https://download.filezilla-project.org/server/FileZilla_Server-0_9_60_2.exe" -OutFile "filezilla_installer.exe"
Start-Process "filezilla_installer.exe" -ArgumentList "/S" -NoNewWindow -Wait
Remove-Item "filezilla_installer.exe"

# Summary
Write-Host "Installation Complete!"
Write-Host "Developer: $DeveloperEmail"
Write-Host "Location: $DeveloperAddress"
Write-Host "Note: Manual configurations may be required for some services like DNS, MySQL, and FTP."

# Optional reboot
$confirm = Read-Host "Reboot the system? (y/n)"
If ($confirm -eq "y") {
    Restart-Computer
}
