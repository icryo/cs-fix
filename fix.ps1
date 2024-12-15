# Function to check and display the current Enhanced Pointer Precision settings
function Check-MouseSettings {
    $mouseKey = "HKCU:\Control Panel\Mouse"
    $mouseSpeed = Get-ItemProperty -Path $mouseKey -Name "MouseSpeed" | Select-Object -ExpandProperty MouseSpeed
    $mouseThreshold1 = Get-ItemProperty -Path $mouseKey -Name "MouseThreshold1" | Select-Object -ExpandProperty MouseThreshold1
    $mouseThreshold2 = Get-ItemProperty -Path $mouseKey -Name "MouseThreshold2" | Select-Object -ExpandProperty MouseThreshold2

    if ($mouseSpeed -eq "0" -and $mouseThreshold1 -eq "0" -and $mouseThreshold2 -eq "0") {
        return $true
    } else {
        return $false
    }
}

# Function to check the WMI service status
function Check-WMIStatus {
    $wmiStatus = (Get-Service -Name "Winmgmt").Status
    if ($wmiStatus -eq "Stopped") {
        return $true
    } else {
        return $false
    }
}

# Function to disable Enhanced Pointer Precision
function Disable-MouseAcceleration {
    $mouseKey = "HKCU:\Control Panel\Mouse"
    Set-ItemProperty -Path $mouseKey -Name "MouseSpeed" -Value "0"
    Set-ItemProperty -Path $mouseKey -Name "MouseThreshold1" -Value "0"
    Set-ItemProperty -Path $mouseKey -Name "MouseThreshold2" -Value "0"
    Write-Output "Enhanced Pointer Precision (Mouse Acceleration) has been disabled."
}

# Function to disable WMI service
function Disable-WMIService {
    Stop-Service -Name "Winmgmt" -Force
    Set-Service -Name "Winmgmt" -StartupType Disabled
    Write-Output "Windows Management Instrumentation (WMI) service has been stopped and disabled."
}

# Main Script Execution
Write-Output "Checking current settings..."

# Check Mouse Settings
$mouseSettingsCorrect = Check-MouseSettings
# Check WMI Status
$wmiStatusCorrect = Check-WMIStatus

if ($mouseSettingsCorrect -and $wmiStatusCorrect) {
    Write-Output "All good! No changes are needed."
    exit
}

if (-not $mouseSettingsCorrect) {
    # Ask for confirmation to disable Enhanced Pointer Precision
    $disableMouseAcceleration = Read-Host "Enhanced Pointer Precision is enabled. Do you want to disable it? (Yes/No)"
    if ($disableMouseAcceleration -eq "Yes") {
        Disable-MouseAcceleration
    } else {
        Write-Output "Mouse acceleration settings were not changed."
    }
}

if (-not $wmiStatusCorrect) {
    # Ask for confirmation to disable WMI service
    $disableWMI = Read-Host "WMI service is running. Do you want to disable it? (Yes/No)"
    if ($disableWMI -eq "Yes") {
        Disable-WMIService
    } else {
        Write-Output "WMI service settings were not changed."
    }
}

Write-Output "Script execution complete."
