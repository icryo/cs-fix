<#
.SYNOPSIS
  Gaming-tuned helper:
  • Detect / disable Windows “Enhanced Pointer Precision”
  • Detect / disable the WMI service
  • (NEW) Clear CS2-related shader caches:
       • Windows DirectX shader cache
       • Steam shader-cache for app 730 (CS2)
       • NVIDIA NV_Cache, AMD DX/GLCache, Intel ShaderCache
.NOTES
  Run from an elevated PowerShell prompt (Administrator).
#>

#--- Utility: check if script is running with admin rights
function Test-IsAdmin {
    $id  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $pri = New-Object Security.Principal.WindowsPrincipal($id)
    return $pri.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    Write-Warning "This script needs to be run as Administrator. Exiting."
    exit
}

#--- Mouse acceleration helpers
function Check-MouseSettings {
    $key = "HKCU:\Control Panel\Mouse"
    $p   = Get-ItemProperty -Path $key
    return ($p.MouseSpeed -eq "0" -and $p.MouseThreshold1 -eq "0" -and $p.MouseThreshold2 -eq "0")
}

function Disable-MouseAcceleration {
    $key = "HKCU:\Control Panel\Mouse"
    Set-ItemProperty -Path $key -Name MouseSpeed      -Value "0"
    Set-ItemProperty -Path $key -Name MouseThreshold1 -Value "0"
    Set-ItemProperty -Path $key -Name MouseThreshold2 -Value "0"
    Write-Output "✅  Enhanced Pointer Precision has been disabled."
}

#--- WMI helpers
function Check-WMIStatus {
    (Get-Service -Name Winmgmt).Status -eq 'Stopped'
}

function Disable-WMIService {
    Stop-Service -Name Winmgmt -Force
    Set-Service  -Name Winmgmt -StartupType Disabled
    Write-Output "✅  WMI service has been stopped and disabled."
}

#--- Shader-cache cleaner
function Clear-ShaderCaches {
    Write-Output "Clearing shader caches…"

    # Windows DirectX shader cache
    $dx = "$env:LOCALAPPDATA\D3DSCache"
    if (Test-Path $dx) { Remove-Item "$dx\*" -Recurse -Force -ErrorAction SilentlyContinue }

    # Locate Steam
    try {
        $steamPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -Name InstallPath -ErrorAction Stop).InstallPath
    } catch { $steamPath = "$env:ProgramFiles(x86)\Steam" }
    $cs2Cache = Join-Path $steamPath "steamapps\shadercache\730"
    if (Test-Path $cs2Cache) { Remove-Item $cs2Cache -Recurse -Force -ErrorAction SilentlyContinue }

    # NVIDIA
    $nv = "$env:LOCALAPPDATA\NVIDIA Corporation\NV_Cache"
    if (Test-Path $nv) { Remove-Item "$nv\*" -Recurse -Force -ErrorAction SilentlyContinue }

    # AMD
    foreach ($amd in @("$env:LOCALAPPDATA\AMD\DXCache", "$env:LOCALAPPDATA\AMD\GLCache")) {
        if (Test-Path $amd) { Remove-Item "$amd\*" -Recurse -Force -ErrorAction SilentlyContinue }
    }

    # Intel
    $intel = "$env:LOCALAPPDATA\Intel\ShaderCache"
    if (Test-Path $intel) { Remove-Item "$intel\*" -Recurse -Force -ErrorAction SilentlyContinue }

    Write-Output "✅  Shader caches cleared. Launch CS2 once to rebuild them."
}

#--- MAIN
Write-Output "=== CS2-Tuning Helper ==="

$mouseOk = Check-MouseSettings
$wmiOk   = Check-WMIStatus

if ($mouseOk -and $wmiOk) {
    Write-Output "Current settings look good."
} else {
    if (-not $mouseOk) {
        if ((Read-Host "Enhanced Pointer Precision is ON. Disable it? (Yes/No)") -eq "Yes") {
            Disable-MouseAcceleration
        } else { Write-Output "Mouse settings unchanged." }
    }

    if (-not $wmiOk) {
        if ((Read-Host "WMI service is running. Disable it? (Yes/No)") -eq "Yes") {
            Disable-WMIService
        } else { Write-Output "WMI service unchanged." }
    }
}

#--- Ask to clear shader caches
if ((Read-Host "Clear Windows/Steam/GPU shader caches for CS2? (Yes/No)") -eq "Yes") {
    Clear-ShaderCaches
} else {
    Write-Output "Shader caches were not touched."
}

Write-Output "All done. Restart your PC for any service-level changes to take effect."
