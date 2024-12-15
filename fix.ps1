# Function to check and display the current Enhanced Pointer Precision settings
function Check-MouseSettings {
    $mouseKey = "HKCU:\Control Panel\Mouse"
    $mouseSpeed = Get-ItemProperty -Path $mouseKey -Name "MouseSpeed" | Select-Object -ExpandProperty MouseSpeed
    $mouseThreshold1 = Get-ItemProperty -Path $mouseKey -Name "MouseThreshold1" | Select-Object -ExpandProperty MouseThreshold1
    $mouseThreshold2 = Get-ItemProperty -Path $mouseKey -Name "MouseThreshold2" | Select-Object -ExpandProperty MouseThreshold2

    Write-Output "Current Enhanced Pointer Precision settings:"
    Write-Output "MouseSpeed: $mouseSpeed"
    Write-Output "MouseThreshold1: $mouseThreshold1"
    Write-Output "MouseThreshold2: $mouseThreshold2"
}

# Function to check the WMI service status
function Check-WMIStatus {
    $wmiStatus = Get-Service -Name "Winmgmt" | Select-Object -ExpandProperty Status
    Write-Output "Current WMI service status: $wmiStatus"
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
Check-MouseSettings
Check-WMIStatus

# Ask for confirmation to disable Enhanced Pointer Precision
$disableMouseAcceleration = Read-Host "Do you want to disable Enhanced Pointer Precision (Mouse Acceleration)? (Yes/No)"
if ($disableMouseAcceleration -eq "Yes") {
    Disable-MouseAcceleration
} else {
    Write-Output "Mouse acceleration settings were not changed."
}

# Ask for confirmation to disable WMI service
$disableWMI = Read-Host "Do you want to disable the Windows Management Instrumentation (WMI) service? (Yes/No)"
if ($disableWMI -eq "Yes") {
    Disable-WMIService
} else {
    Write-Output "WMI service settings were not changed."
}

Write-Output "Script execution complete."
