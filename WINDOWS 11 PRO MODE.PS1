Write-Host "=== WINDOWS 11 PRO 25H2 - ULTIMATE PRO MODE + HARD MODE + TPM PRIVACY + CLASSIC UI ===" -ForegroundColor Cyan

# -----------------------------------------------------------
# 1) STOP CONSUMER BLOAT AUTOINSTALL
# -----------------------------------------------------------
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 1

# -----------------------------------------------------------
# 2) REMOVE PROVISIONED BLOAT (PERMANENT)
# -----------------------------------------------------------
Write-Host "Removing provisioned bloat..." -ForegroundColor Yellow
Get-AppxProvisionedPackage -Online |
Where-Object { $_.PackageName -notmatch "WindowsCalculator|Store|ShellExperienceHost|StartMenuExperienceHost|DesktopAppInstaller|StorePurchaseApp" } |
Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null

# -----------------------------------------------------------
# 3) REMOVE USER APPX BLOAT
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
# 4) DISABLE XBOX / GAMING RE-SPAWN TASKS
# -----------------------------------------------------------
Get-ScheduledTask -TaskName *Xbl* -ErrorAction SilentlyContinue | Disable-ScheduledTask
Get-ScheduledTask -TaskName *Gaming* -ErrorAction SilentlyContinue | Disable-ScheduledTask

# -----------------------------------------------------------
# 5) REMOVE ONEDRIVE + BLOCK REINSTALL
# -----------------------------------------------------------
Write-Host "Removing OneDrive..." -ForegroundColor Yellow
taskkill /f /im OneDrive.exe 2>$null
$od = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
if (!(Test-Path $od)) { $od = "$env:SystemRoot\System32\OneDriveSetup.exe" }
Start-Process $od -ArgumentList "/uninstall" -Wait 2>$null
Remove-Item "$env:LocalAppData\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:ProgramData\Microsoft OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
reg add "HKLM\Software\Policies\Microsoft\Windows\OneDrive" /v DisableFileSyncNGSC /t REG_DWORD /d 1 /f

# -----------------------------------------------------------
# 6) DISABLE BING / CLOUD SEARCH
# -----------------------------------------------------------
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v DisableSearchBoxSuggestions /t REG_DWORD /d 1 /f

# -----------------------------------------------------------
# 6A) REMOVE COPILOT + WEBEXPERIENCE (Recall backend)
# -----------------------------------------------------------
Write-Host "Removing Copilot + Web Experience..." -ForegroundColor Yellow
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowCopilotButton /t REG_DWORD /d 0 /f

Get-AppxPackage -AllUsers *WebExperience* | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -match "WebExperience"} |
Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null

# -----------------------------------------------------------
# 7) DISABLE UI ADS / STORE PROMOTION
# -----------------------------------------------------------
$cdm="HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
Set-ItemProperty $cdm SubscribedContent-338389Enabled 0
Set-ItemProperty $cdm SubscribedContent-338393Enabled 0
Set-ItemProperty $cdm SubscribedContent-353694Enabled 0
Set-ItemProperty $cdm SubscribedContent-353696Enabled 0

# -----------------------------------------------------------
# 8) MINIMIZE TELEMETRY
# -----------------------------------------------------------
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f

# -----------------------------------------------------------
# 9) WINDOWS UPDATE: NOTIFY ONLY (NO AUTO DOWNLOAD)
# -----------------------------------------------------------
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 2 /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoRebootWithLoggedOnUsers /t REG_DWORD /d 1 /f

# -----------------------------------------------------------
# 10) WINGET NON-INTERACTIVE MODE
# -----------------------------------------------------------
Write-Host "Configuring Winget non-interactive..." -ForegroundColor Yellow
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
# 11) INSTALL TOOLS
# -----------------------------------------------------------
winget install --id Microsoft.WindowsTerminal -e --silent
winget install --id Git.Git -e --silent
winget install --id Microsoft.PowerShell -e --silent
winget install --id Microsoft.OpenSSH.Beta -e --silent

# -----------------------------------------------------------
# 12) TPM PRIVACY SANDBOX
# -----------------------------------------------------------
Write-Host "Applying TPM Privacy Sandboxing..." -ForegroundColor Magenta
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v NoConnectedUser /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v BlockUserFromMSAccount /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v EnableBDEWithAutoTPM /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceHealth" /v EnableDeviceHealthAttestation /t REG_DWORD /d 0 /f
Stop-Service -Name DeviceHealthAttestationService -ErrorAction SilentlyContinue
Set-Service -Name DeviceHealthAttestationService -StartupType Disabled

# -----------------------------------------------------------
# 13) FORCE OFFLINE SEARCH (NO BING EVER)
# -----------------------------------------------------------
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v SearchAppUseRemoteResources /t REG_DWORD /d 0 /f

# -----------------------------------------------------------
# 14) CLASSIC UI MODE
# -----------------------------------------------------------
Write-Host "Applying Classic UI mode..." -ForegroundColor Cyan

# Classic Context Menu
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f

# Taskbar Left Align
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAl /t REG_DWORD /d 0 /f

# Taskbar Drag & Drop Restore
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDndEnabled /t REG_DWORD /d 1 /f

# Install Open-Shell Classic Start Menu
winget install --id Open-Shell.Open-Shell-Menu -e --silent

# Classic Explorer Status + All Folders
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowStatusBar /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v NavPaneShowAllFolders /t REG_DWORD /d 1 /f

# -----------------------------------------------------------
# FINALIZE
# -----------------------------------------------------------
Stop-Process -Name explorer -Force 2>$null
Start-Process explorer.exe

Write-Host "`n✅ FULL SYSTEM OPTIMIZATION COMPLETE"
Write-Host "🔁 Restart recommended to finalize Classic UI + TPM Privacy." -ForegroundColor Green
