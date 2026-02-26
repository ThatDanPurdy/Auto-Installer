# ============================================
# Multi-App Installer
# Version: v0.3
# Purpose:
#   Installs common baseline software on a
#   fresh Windows 11 system.
#
# Behaviour:
#   - Checks if app is already installed
#   - Downloads official installer if missing
#   - Runs silent install where supported
#   - Cleans temporary files
#
# Designed for:
#   Fresh OS deployment / home lab build
# ============================================


# ---------- GLOBAL SETTINGS ----------

# Stop script immediately if any command fails
# (Enterprise deployment best practice)
$ErrorActionPreference = "Stop"

# Create a temporary working directory inside Windows temp
# All installers will be downloaded here
$TempPath = "$env:TEMP\AppInstallers"

# Ensure folder exists (Force prevents errors if already present)
New-Item -ItemType Directory -Force -Path $TempPath | Out-Null

Write-Host "=== Application Deployment Started ==="


# ---------- GENERIC INSTALL FUNCTION ----------

# Reusable function to:
#   1. Download installer from URL
#   2. Execute installer silently
#   3. Wait for completion before continuing
#
# Parameters:
#   Name          -> Friendly app name (for console output)
#   Url           -> Direct download link
#   InstallerPath -> Local path to save installer
#   Arguments     -> Silent install switches
#
function Install-FromUrl {
    param(
        [string]$Name,
        [string]$Url,
        [string]$InstallerPath,
        [string]$Arguments = "/S"
    )

    Write-Host "Downloading $Name..."
    Invoke-WebRequest -Uri $Url -OutFile $InstallerPath

    Write-Host "Installing $Name..."
    Start-Process -FilePath $InstallerPath -ArgumentList $Arguments -Wait
}


# =====================================================
# APPLICATION INSTALL BLOCKS
# Each section:
#   1. Checks if software exists
#   2. Installs only if missing
# =====================================================


# ---------- STEAM ----------

# Detect Steam by checking default install location
if (Test-Path "C:\Program Files (x86)\Steam\Steam.exe") {
    Write-Host "Steam already installed ✔"
}
else {
    Install-FromUrl `
        -Name "Steam" `
        -Url "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe" `
        -InstallerPath "$TempPath\SteamSetup.exe"
}


# ---------- DISCORD ----------

# Discord installs per-user under AppData
if (Test-Path "$env:LOCALAPPDATA\Discord\Update.exe") {
    Write-Host "Discord already installed ✔"
}
else {
    Install-FromUrl `
        -Name "Discord" `
        -Url "https://discord.com/api/download?platform=win" `
        -InstallerPath "$TempPath\DiscordSetup.exe"
}


# ---------- TREESIZE FREE ----------

# Detect TreeSize Free standard install path
if (Test-Path "C:\Program Files\JAM Software\TreeSize Free\TreeSizeFree.exe") {
    Write-Host "TreeSize already installed ✔"
}
else {
    Install-FromUrl `
        -Name "TreeSize" `
        -Url "https://downloads.jam-software.com/treesize_free/TreeSizeFreeSetup.exe" `
        -InstallerPath "$TempPath\TreeSize.exe"
}


# ---------- HARD DISK SENTINEL ----------

# Vendor distributes as ZIP archive
# Script must:
#   1. Download ZIP
#   2. Extract contents
#   3. Launch installer

if (Test-Path "C:\Program Files\Hard Disk Sentinel\HDSentinel.exe") {
    Write-Host "HD Sentinel already installed ✔"
}
else {
    Write-Host "Downloading HD Sentinel..."

    # Download compressed installer
    $ZipPath = "$TempPath\HDSentinel.zip"
    Invoke-WebRequest -Uri "https://www.hdsentinel.com/hdsentinel_setup.zip" -OutFile $ZipPath

    # Extract archive contents
    Expand-Archive $ZipPath -DestinationPath $TempPath -Force

    # Execute installer
    Write-Host "Installing HD Sentinel..."
    Start-Process "$TempPath\HDSentinel_setup.exe" -Wait
}


# ---------- CORSAIR ICUE ----------

# Detect default install location
if (Test-Path "C:\Program Files\Corsair\CORSAIR iCUE Software\iCUE.exe") {
    Write-Host "Corsair iCUE already installed ✔"
}
else {
    Install-FromUrl `
        -Name "Corsair iCUE" `
        -Url "https://downloads.corsair.com/Files/CUE/iCUESetup.exe" `
        -InstallerPath "$TempPath\iCUESetup.exe" `
        -Arguments "/quiet"
}


# ---------- AMD ADRENALIN ----------

# Detect AMD software package
# Relevant for Radeon GPU systems
if (Test-Path "C:\Program Files\AMD\CNext\CNext\RadeonSoftware.exe") {
    Write-Host "AMD Adrenalin already installed ✔"
}
else {
    Install-FromUrl `
        -Name "AMD Adrenalin" `
        -Url "https://drivers.amd.com/drivers/installer/amd-software-adrenalin-edition.exe" `
        -InstallerPath "$TempPath\AMDAdrenalin.exe" `
        -Arguments "-install"
}


# ---------- CLEANUP ----------

Write-Host "Cleaning temporary files..."

# Remove temp installer directory and contents
Remove-Item $TempPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "=== Deployment Complete ==="

# Exit success code (useful for automation tools)
exit 0