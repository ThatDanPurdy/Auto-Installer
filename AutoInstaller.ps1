# ==========================================================
# Multi-App Installer v0.5
# Fully unattended deployment for Windows 11
# Designed for fresh VM baseline
#
# Installs:
# Steam
# Discord
# TreeSize Free
# Hard Disk Sentinel (true silent)
# Corsair iCUE
# AMD Adrenalin
# ==========================================================

# ---------- CONFIG ----------
$DownloadPath = "$env:TEMP\AppInstallers"
New-Item -ItemType Directory -Force -Path $DownloadPath | Out-Null

# ---------- HELPER: Check if installed ----------
function Test-AppInstalled {
    param($DisplayName)

    $apps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* ,
                              HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
                              -ErrorAction SilentlyContinue

    return $apps.DisplayName -like "*$DisplayName*"
}

# ---------- HELPER: Download file ----------
function Download-File {
    param($Url, $Output)

    Write-Host "Downloading $Url"
    Invoke-WebRequest -Uri $Url -OutFile $Output -UseBasicParsing -TimeoutSec 300
}

# ---------- HELPER: Install with timeout ----------
function Install-Exe {
    param($Path, $Arguments, $Timeout = 600)

    Write-Host "Running installer: $Path"

    $process = Start-Process $Path -ArgumentList $Arguments -PassThru

    if (-not $process.WaitForExit($Timeout * 1000)) {
        Write-Host "Installer timeout reached — terminating"
        $process.Kill()
    }
}

# ==========================================================
# STEAM
# ==========================================================
if (!(Test-AppInstalled "Steam")) {
    Write-Host "Installing Steam..."
    $file = "$DownloadPath\SteamSetup.exe"
    Download-File "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe" $file
    Install-Exe $file "/S"
}
else { Write-Host "Steam already installed" }

# ==========================================================
# DISCORD (Enterprise Reliable Install)
# ==========================================================
if (!(Test-AppInstalled "Discord")) {
    Write-Host "Installing Discord (enterprise method)..."

    $file = "$DownloadPath\DiscordSetup.exe"
    Download-File "https://discord.com/api/download?platform=win" $file

    # Run installer without waiting (it spawns Update.exe)
    Start-Process $file -ArgumentList "/S" -NoNewWindow

    Write-Host "Monitoring Discord installation..."

    $timeout = 300
    $elapsed = 0

    do {
        Start-Sleep 3
        $elapsed += 3

        $discordInstalled = Test-Path "$env:LOCALAPPDATA\Discord\Update.exe"
    }
    until ($discordInstalled -or $elapsed -ge $timeout)

    if ($discordInstalled) {
        Write-Host "Discord installed successfully"
    }
    else {
        Write-Host "Discord install timed out — continuing safely"
    }
}
else { Write-Host "Discord already installed" }

# ==========================================================
# TREESIZE FREE
# ==========================================================
if (!(Test-AppInstalled "TreeSize")) {
    Write-Host "Installing TreeSize Free..."
    $file = "$DownloadPath\TreeSizeFreeSetup.exe"
    Download-File "https://downloads.jam-software.de/treesize_free/TreeSizeFreeSetup.exe" $file
    Install-Exe $file "/VERYSILENT /NORESTART"
}
else { Write-Host "TreeSize already installed" }

# ==========================================================
# HARD DISK SENTINEL (TRUE SILENT INSTALL)
# ==========================================================
if (!(Test-AppInstalled "Hard Disk Sentinel")) {
    Write-Host "Installing Hard Disk Sentinel..."

    $zip = "$DownloadPath\hds.zip"
    $extract = "$DownloadPath\HDS"

    Download-File "https://www.hdsentinel.com/hdsentinel_setup.zip" $zip

    Expand-Archive $zip $extract -Force

    $exe = Get-ChildItem $extract -Filter "*setup*.exe" -Recurse | Select-Object -First 1

    if ($exe) {
        Install-Exe $exe.FullName "/SILENT /NORESTART"
    }
    else {
        Write-Host "ERROR: Hard Disk Sentinel installer not found"
    }
}
else { Write-Host "Hard Disk Sentinel already installed" }

# ==========================================================
# CORSAIR iCUE
# ==========================================================
if (!(Test-AppInstalled "Corsair iCUE")) {
    Write-Host "Installing Corsair iCUE..."
    $file = "$DownloadPath\iCUESetup.exe"
    Download-File "https://www.corsair.com/downloads" $file
    Install-Exe $file "/S"
}
else { Write-Host "iCUE already installed" }

# ==========================================================
# AMD ADRENALIN
# ==========================================================
if (!(Test-AppInstalled "AMD Software")) {
    Write-Host "Installing AMD Adrenalin..."
    $file = "$DownloadPath\AMDSetup.exe"
    Download-File "https://drivers.amd.com/drivers/installer/amd-software-adrenalin-edition.exe" $file
    Install-Exe $file "-install"
}
else { Write-Host "AMD Adrenalin already installed" }

# ==========================================================
# COMPLETE
# ==========================================================
Write-Host ""
Write-Host "All installation steps completed"
Write-Host "Installer cache located at: $DownloadPath"