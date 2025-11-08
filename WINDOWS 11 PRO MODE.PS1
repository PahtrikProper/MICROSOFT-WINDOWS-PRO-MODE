# ===========================================================
# WINDOWS 11 PRO 25H2 - ULTIMATE PRO MODE + HARD MODE
# Clean, fast, private, no ads, no bloat, no Bing, no Copilot,
# no cloud search, no forced Xbox junk, real control retained.
# Run as ADMIN
# ===========================================================

Write-Host "Applying Windows 11 Pro Ultimate Pro Mode..." -ForegroundColor Cyan

# -----------------------------------------------------------
# 1) Stop auto-install of consumer bloat
# -----------------------------------------------------------
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 1

# -----------------------------------------------------------
# 2) Remove provisioned bloat (permanent for future users)
# -----------------------------------------------------------
Write-Host "Removing provisioned bloat..." -ForegroundColor Yellow
Get-AppxProvisionedPackage -Online |
Where-Object { $_.PackageName -notmatch "WindowsCalculator|Store|ShellExperienceHost|StartMenuExperienceHost|DesktopAppInstaller|StorePurchaseApp" } |
ForEach-Object {
    Write-Host " - Removing: $($_.PackageName)"
    Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue | Out-Null
}

# -----------------------------------------------------------
# 3) Remove installed UWP junk for all users
# -----------------------------------------------------------
$bloat = @(
 "Microsoft.GetHelp","Microsoft.Getstarted","Microsoft.MicrosoftOfficeHub",
 "Microsoft.MicrosoftSolitaireCollection","Microsoft.People",
 "Microsoft.SkypeApp","Microsoft.Todos",
 "Microsoft.XboxApp","Microsoft.XboxGamingOverlay","Microsoft.Xbox.TCUI",
 "Microsoft.ZuneMusic","Microsoft.ZuneVideo","SpotifyAB.SpotifyMusic"
)
foreach ($app in $bloat) {
    Get-AppxPackage -AllUsers -Name $app | Remove-AppxPackage -ErrorAction SilentlyContinue
}

# -----------------------------------------------------------
# 4) Stop Xbox/Gaming auto-respawn tasks
# -----------------------------------------------------------
Get-ScheduledTask -TaskName *Xbl* -ErrorAction SilentlyContinue | Disable-ScheduledTask
Get-ScheduledTask -TaskName *Gaming* -ErrorAction SilentlyContinue | Disable-ScheduledTask

# -----------------------------------------------------------
# 5) Remove OneDrive fully + block reinstallation
# -----------------------------------------------------------
Write-Host "Removing OneDrive..." -ForegroundColor Yellow
taskkill /f /im OneDrive.exe 2>$null
$oneDriveSetup = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
if (!(Test-Path $oneDriveSetup)) { $oneDriveSetup = "$env:SystemRoot\System32\OneDriveSetup.exe" }
Start-Process $oneDriveSetup -ArgumentList "/uninstall" -Wait 2>$null
Remove-Item "$env:LocalAppData\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:ProgramData\Microsoft OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
reg add "HKLM\Software\Policies\Microsoft\Windows\OneDrive" /v DisableFileSyncNGSC /t REG_DWORD /d 1 /f

# -----------------------------------------------------------
# 6) Disable Bing Search + Suggested Results
# -----------------------------------------------------------
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "DisableSearchBoxSuggestions" 1

# -----------------------------------------------------------
# 6A) REMOVE COPILOT
# -----------------------------------------------------------
Write-Host "Removing Microsoft Copilot..." -ForegroundColor Yellow
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowCopilotButton /t REG_DWORD /d 0 /f

Get-AppxPackage -AllUsers *Microsoft.Windows.Copilot* | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
Get-AppxPackage -AllUsers *WebExperience* | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -match "WebExperience"} |
Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null

reg add "HKLM\Software\Policies\Microsoft\Edge" /v WebWidgetEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Policies\Microsoft\Edge" /v HubsSidebarEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Policies\Microsoft\Edge" /v QuickActionMenuEnabled /t REG_DWORD /d 0 /f

# -----------------------------------------------------------
# 7) Disable Lock Screen + Start Menu ads
# -----------------------------------------------------------
$cdm="HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
Set-ItemProperty $cdm SubscribedContent-338389Enabled 0
Set-ItemProperty $cdm SubscribedContent-338393Enabled 0
Set-ItemProperty $cdm SubscribedContent-353694Enabled 0
Set-ItemProperty $cdm SubscribedContent-353696Enabled 0

# -----------------------------------------------------------
# 8) Minimize Telemetry
# -----------------------------------------------------------
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f

# -----------------------------------------------------------
# 9) Make Windows Update notify only
# -----------------------------------------------------------
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 2 /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoRebootWithLoggedOnUsers /t REG_DWORD /d 1 /f

# -----------------------------------------------------------
# 10) FIXED WINGET NON-INTERACTIVE MODE (WORKS ON 25H2)
# -----------------------------------------------------------
Write-Host "Configuring Winget as non-interactive..." -ForegroundColor Yellow

$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
$dir = Split-Path $settingsPath
if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

@"
{
  "source": { "autoAcceptAgreements": true },
  "upgrade": { "suppressPromptForInstalls": true },
  "installBehavior": { "preferences": { "scope": "machine" } }
}
"@ | Set-Content $settingsPath -Encoding UTF8 -Force

# -----------------------------------------------------------
# 11) Install Tools Silently
# -----------------------------------------------------------
Write-Host "Installing tools..." -ForegroundColor Yellow
winget install --id Microsoft.WindowsTerminal -e --silent --accept-source-agreements --accept-package-agreements
winget install --id Git.Git -e --silent --accept-source-agreements --accept-package-agreements
winget install --id Microsoft.PowerShell -e --silent --accept-source-agreements --accept-package-agreements
winget install --id Microsoft.OpenSSH.Beta -e --silent --accept-source-agreements --accept-package-agreements

# -----------------------------------------------------------
# HARD MODE: TRUE LOCAL SEARCH, NO WEB QUERIES EVER
# -----------------------------------------------------------
Write-Host "Applying HARD MODE (classic offline search)..." -ForegroundColor Magenta

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v DisableWebSearch /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v CortanaEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v SearchAppUseRemoteResources /t REG_DWORD /d 0 /f

Stop-Process -Name SearchApp, SearchHost, explorer -Force 2>$null
Start-Process explorer.exe

Write-Host "✅ Ultimate Pro Mode + HARD MODE applied."
Write-Host "🔁 Restart recommended." -ForegroundColor Green
