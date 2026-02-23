# ============================================
# Steam + Discord Installer (Idempotent)
# Installs only if not already present
# Uses official desktop installers (no Store)
# ============================================

# ---------- CONFIGURATION ----------

# Create a temporary working directory inside the Windows temp folder
$TempPath = "$env:TEMP\AppInstallers"

# Ensure the folder exists (Force prevents error if already present)
New-Item -ItemType Directory -Force -Path $TempPath | Out-Null


# ---------- DETECTION FUNCTIONS ----------

# Checks if Steam is installed by verifying the default install path
function Test-SteamInstalled {
    return Test-Path "C:\Program Files (x86)\Steam\Steam.exe"
}

# Checks if Discord is installed for the current user
# Discord installs per-user under AppData
function Test-DiscordInstalled {
    return Test-Path "$env:LOCALAPPDATA\Discord\Update.exe"
}


# ---------- INSTALL FUNCTIONS ----------

# Downloads and installs Steam silently
function Install-Steam {

    Write-Host "Steam not detected. Installing..."

    # Define installer path
    $SteamInstaller = "$TempPath\SteamSetup.exe"

    # Download official installer
    Invoke-WebRequest `
        -Uri "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe" `
        -OutFile $SteamInstaller

    # Run installer silently and wait for completion
    Start-Process `
        -FilePath $SteamInstaller `
        -ArgumentList "/S" `
        -Wait
}

# Downloads and installs Discord silently
function Install-Discord {

    Write-Host "Discord not detected. Installing..."

    # Define installer path
    $DiscordInstaller = "$TempPath\DiscordSetup.exe"

    # Download official installer
    Invoke-WebRequest `
        -Uri "https://discord.com/api/download?platform=win" `
        -OutFile $DiscordInstaller

    # Run installer silently and wait for completion
    Start-Process `
        -FilePath $DiscordInstaller `
        -ArgumentList "/S" `
        -Wait
}


# ---------- MAIN EXECUTION ----------

Write-Host "Starting application check..."

# Steam detection + install
if (Test-SteamInstalled) {
    Write-Host "Steam already installed ✔"
}
else {
    Install-Steam
}

# Discord detection + install
if (Test-DiscordInstalled) {
    Write-Host "Discord already installed ✔"
}
else {
    Install-Discord
}

# ---------- CLEANUP ----------

Write-Host "Cleaning temporary files..."

# Remove temp directory and all contents
Remove-Item $TempPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Deployment complete ✅"