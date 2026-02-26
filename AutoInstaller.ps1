# ==========================================================
# Local Multi-App Installer (Your Exact Files)
# Designed for fresh Windows 11 VM
# ==========================================================

# 👉 CHANGE THIS if your installers are somewhere else
$InstallerPath = "$env:USERPROFILE\Downloads"

# ---------- HELPER: Check if installed ----------
function Test-AppInstalled {
    param($DisplayName)

    $apps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* ,
                              HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
                              -ErrorAction SilentlyContinue

    return $apps.DisplayName -like "*$DisplayName*"
}

# ---------- HELPER: Run installer safely ----------
function Install-Exe {
    param($File, $Arguments, $Timeout = 600)

    if (!(Test-Path $File)) {
        Write-Host "Installer missing: $File"
        return
    }

    Write-Host "Running $File"

    $process = Start-Process $File -ArgumentList $Arguments -PassThru

    if (-not $process.WaitForExit($Timeout * 1000)) {
        Write-Host "Timeout reached — terminating installer"
        $process.Kill()
    }
}

# ==========================================================
# STEAM
# ==========================================================
if (!(Test-AppInstalled "Steam")) {
    Install-Exe "$InstallerPath\SteamSetup (1).exe" "/S"
}
else { Write-Host "Steam already installed" }

# ==========================================================
# DISCORD (special handling)
# ==========================================================
if (!(Test-AppInstalled "Discord")) {
    $file = "$InstallerPath\DiscordSetup.exe"

    if (Test-Path $file) {
        Write-Host "Installing Discord..."
        Start-Process $file -ArgumentList "/S"
        Start-Sleep 25
    }
    else { Write-Host "Discord installer missing" }
}
else { Write-Host "Discord already installed" }

# ==========================================================
# TREESIZE
# ==========================================================
if (!(Test-AppInstalled "TreeSize")) {
    Install-Exe "$InstallerPath\TreeSizeFreeSetup.exe" "/VERYSILENT /NORESTART"
}
else { Write-Host "TreeSize already installed" }

# ==========================================================
# HARD DISK SENTINEL
# ==========================================================
if (!(Test-AppInstalled "Hard Disk Sentinel")) {
    Install-Exe "$InstallerPath\hdsentinel_setup.exe" "/SILENT /NORESTART"
}
else { Write-Host "Hard Disk Sentinel already installed" }

# ==========================================================
# CORSAIR ICUE
# ==========================================================
if (!(Test-AppInstalled "Corsair iCUE")) {
    Install-Exe "$InstallerPath\Install iCUE.exe" "/S"
}
else { Write-Host "iCUE already installed" }

# ==========================================================
# AMD ADRENALIN
# ==========================================================
if (!(Test-AppInstalled "AMD Software")) {
    Install-Exe "$InstallerPath\amd-software-adrenalin-edition-26.2.2-minimalsetup-260225_web.exe" "-install"
}
else { Write-Host "AMD Software already installed" }

# ==========================================================
Write-Host ""
Write-Host "All installation steps completed"