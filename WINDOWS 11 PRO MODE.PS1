# ===========================================================
# WINDOWS PRO MODE - ULTIMATE EDITION
# Permanent Debloat, No Ads, No Bing, No OneDrive, No Nags,
# Real Shell Tools, Update Sanity
# Run as ADMIN
# ===========================================================

Write-Host "Entering Ultimate Pro Mode…" -ForegroundColor Cyan

# -----------------------------------------------------------
# 1) Stop Windows from re-installing bloat in the future
# -----------------------------------------------------------
Write-Host "[1/10] Disabling Windows Consumer Experience…" -ForegroundColor Yellow
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name DisableWindowsConsumerFeatures -Type DWord -Value 1

# -----------------------------------------------------------
# 2) Remove PROVISIONED app packages (permanent)
# -----------------------------------------------------------
Write-Host "[2/10] Removing provisioned app packages…" -ForegroundColor Yellow
Get-AppxProvisionedPackage -Online | ForEach-Object {
    Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue | Out-Null
}

# -----------------------------------------------------------
# 3) Remove currently installed UWP bloat
# -----------------------------------------------------------
Write-Host "[3/10] Removing installed bloatware…" -ForegroundColor Yellow
$bloat = @(
 "Microsoft.3DBuilder","Microsoft.GetHelp","Microsoft.Getstarted",
 "Microsoft.MicrosoftOfficeHub","Microsoft.MicrosoftSolitaireCollection",
 "Microsoft.MixedReality.Portal","Microsoft.People","Microsoft.SkypeApp",
 "Microsoft.Todos","Microsoft.XboxApp","Microsoft.XboxGamingOverlay",
 "Microsoft.Xbox.TCUI","Microsoft.ZuneMusic","Microsoft.ZuneVideo",
 "SpotifyAB.SpotifyMusic","Disney.37853FC22B2CE"
)
foreach ($app in $bloat) {
    Get-AppxPackage -AllUsers -Name $app | Remove-AppxPackage -ErrorAction SilentlyContinue
}

# -----------------------------------------------------------
# 4) Disable tasks that silently re-add apps
# -----------------------------------------------------------
Write-Host "[4/10] Disabling scheduled app reinstallation tasks…" -ForegroundColor Yellow
Get-ScheduledTask -TaskName *Xbl* | Disable-ScheduledTask -ErrorAction SilentlyContinue
Get-ScheduledTask -TaskName *Gaming* | Disable-ScheduledTask -ErrorAction SilentlyContinue

# -----------------------------------------------------------
# 5) Remove OneDrive & block future resurrection
# -----------------------------------------------------------
Write-Host "[5/10] Removing OneDrive…" -ForegroundColor Yellow
taskkill /f /im OneDrive.exe -ErrorAction SilentlyContinue
Start-Process "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" "/uninstall" -Wait -ErrorAction SilentlyContinue
Remove-Item "$env:LocalAppData\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:ProgramData\Microsoft OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
reg add "HKLM\Software\Policies\Microsoft\Windows\OneDrive" /v DisableFileSyncNGSC /t REG_DWORD /d 1 /f

# -----------------------------------------------------------
# 6) Turn off Bing web search in Start Menu
# -----------------------------------------------------------
Write-Host "[6/10] Disabling Bing in Windows Search…" -ForegroundColor Yellow
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name DisableSearchBoxSuggestions -Type DWord -Value 1

# -----------------------------------------------------------
# 7) Turn off ads, recommendations, lock screen suggestions
# -----------------------------------------------------------
Write-Host "[7/10] Disabling ads across UI…" -ForegroundColor Yellow
$cdm="HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
Set-ItemProperty $cdm SubscribedContent-338393Enabled 0
Set-ItemProperty $cdm SubscribedContent-338389Enabled 0
Set-ItemProperty $cdm SubscribedContent-353694Enabled 0
Set-ItemProperty $cdm SubscribedContent-353696Enabled 0

# -----------------------------------------------------------
# 8) Telemetry to lowest level allowed on Pro/Home
# -----------------------------------------------------------
Write-Host "[8/10] Minimizing telemetry…" -ForegroundColor Yellow
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f

# -----------------------------------------------------------
# 9) No surprise automatic updates / no forced reboot
# -----------------------------------------------------------
Write-Host "[9/10] Making updates ask first…" -ForegroundColor Yellow
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoRebootWithLoggedOnUsers /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 2 /f

# -----------------------------------------------------------
# 10) Install real tools + Windows Terminal as default
# -----------------------------------------------------------
Write-Host "[10/10] Installing developer essentials…" -ForegroundColor Yellow
winget install --id Microsoft.WindowsTerminal -e --silent
winget install --id Git.Git -e --silent
winget install --id Microsoft.PowerShell -e --silent
winget install --id Microsoft.OpenSSH.Beta -e --silent

Write-Host "Done. Restart recommended." -ForegroundColor Green
