# ============================================
# Multi-App Installer
# Version: v0.4
# Purpose:
#   Installs baseline software on a fresh
#   Windows 11 system.
#
# Behaviour:
#   - Installs only if missing
#   - Handles Discord installer hang correctly
#   - Uses official installers
#   - Provides timeout-based failure detection
#   - Cleans up temporary files
# ============================================

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$TempPath = "$env:TEMP\AppInstallers"
New-Item -ItemType Directory -Force -Path $TempPath | Out-Null

Write-Host ""
Write-Host "=== Multi-App Deployment Started ==="
Write-Host ""


# ---------- GENERIC INSTALL FUNCTION ----------

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
# STEAM
# =====================================================

if (Test-Path "C:\Program Files (x86)\Steam\Steam.exe") {
    Write-Host "Steam already installed ✔"
}
else {
    Install-FromUrl `
        -Name "Steam" `
        -Url "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe" `
        -InstallerPath "$TempPath\SteamSetup.exe"
}


# =====================================================
# DISCORD (NON-HANGING INSTALL)
# =====================================================

if (Test-Path "$env:LOCALAPPDATA\Discord\Update.exe") {
    Write-Host "Discord already installed ✔"
}
else {
    Write-Host "Downloading Discord..."
    $DiscordInstaller = "$TempPath\DiscordSetup.exe"
    Invoke-WebRequest "https://discord.com/api/download?platform=win" -OutFile $DiscordInstaller

    Write-Host "Installing Discord (non-blocking)..."

    Start-Process -FilePath $DiscordInstaller -ArgumentList "/S"

    $Timeout = 180
    $Elapsed = 0

    while (-not (Test-Path "$env:LOCALAPPDATA\Discord\Update.exe") -and $Elapsed -lt $Timeout) {
        Start-Sleep 3
        $Elapsed += 3
    }

    if (Test-Path "$env:LOCALAPPDATA\Discord\Update.exe") {
        Write-Host "Discord installed successfully ✔"
    }
    else {
        Write-Host "Discord install timed out ❌"
        exit 1
    }
}


# =====================================================
# TREESIZE FREE
# =====================================================

if (Test-Path "C:\Program Files\JAM Software\TreeSize Free\TreeSizeFree.exe") {
    Write-Host "TreeSize already installed ✔"
}
else {
    Install-FromUrl `
        -Name "TreeSize" `
        -Url "https://downloads.jam-software.com/treesize_free/TreeSizeFreeSetup.exe" `
        -InstallerPath "$TempPath\TreeSize.exe"
}


# =====================================================
# HARD DISK SENTINEL
# =====================================================

if (Test-Path "C:\Program Files\Hard Disk Sentinel\HDSentinel.exe") {
    Write-Host "Hard Disk Sentinel already installed ✔"
}
else {
    Write-Host "Downloading Hard Disk Sentinel..."
    $ZipPath = "$TempPath\HDSentinel.zip"
    Invoke-WebRequest -Uri "https://www.hdsentinel.com/hdsentinel_setup.zip" -OutFile $ZipPath

    Expand-Archive $ZipPath -DestinationPath $TempPath -Force

    Write-Host "Installing Hard Disk Sentinel..."
    Start-Process "$TempPath\HDSentinel_setup.exe" -Wait
}


# =====================================================
# CORSAIR ICUE
# =====================================================

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


# =====================================================
# AMD ADRENALIN
# =====================================================

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


# =====================================================
# CLEANUP
# =====================================================

Write-Host ""
Write-Host "Cleaning temporary files..."
Remove-Item $TempPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "=== Deployment Complete ==="
exit 0