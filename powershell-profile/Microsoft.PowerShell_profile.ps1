# ================================================================================
# =                              POWERSHELL_PROFILE                              =
# ================================================================================


# Automatically start zellij
# pwsh is not supported with zellij setup --generate-auto-start
if (-not ($env:ZELLIJ)) {
    if ($env:ZELLIJ_AUTO_ATTACH -eq 'true') {
        zellij attach -c
    } else {
        zellij
    }

    if ($env:ZELLIJ_AUTO_EXIT -eq 'true') {
        exit
    }
}

# Load secrets
$LocalProfile = 'C:/Users/master/Documents/powerShell/Microsoft.PowerShell_profile.local.ps1'
if (Test-Path -Path $LocalProfile) {
    . $LocalProfile 
}

# ================================== FUNCTIONS ===================================

# Help
function Get-CommandParams {
    param([string]$Command)
    Get-Help -Name $Command -Parameter *
}

function Get-CommandExamples {
    param([string]$Command)
    Get-Help -Name $Command -Example
}

# WinGet
function Update-Packages {
    Get-WinGetPackage | Where-Object IsUpdateAvailable | Update-WinGetPackage -Mode Silent
}

# git
function Get-GitStatus {
    git status 
}

function Update-GitMaster {
    git pull origin master
}

# Processes
function Get-GroupedProcesses {
    Get-Process | Group-Object -Property ProcessName | ForEach-Object {
        [PSCustomObject]@{
            'NPM(K)' = (($_.Group.NonpagedSystemMemorySize64 | Measure-Object -Sum).Sum / 1KB)
            'PM(M)' = (($_.Group.PagedMemorySize64 | Measure-Object -Sum).Sum / 1MB)
            'WS(M)' = (($_.Group.WorkingSet64 | Measure-Object -Sum).Sum / 1MB)
            'CPU' = ($_.Group.CPU | Measure-Object -Sum).Sum
            'CNT' = $_.Count
            'ProcessName' = $_.Name
        }
    }
}

function Get-SortedGroupedProcesses {
    param([string]$SortBy = 'WS(M)')
    Get-GroupedProcesses | Sort-Object -Property $SortBy -Descending | Format-Table
}

# Prediction
function Enable-Prediction {
    Set-PSReadLineOption -PredictionSource History
}

function Disable-Prediction {
    Set-PSReadLineOption -PredictionSource None
}

# CIM
function Get-CimChildNamespace {
    param([string]$Namespace = 'root')
    Get-CimInstance -Namespace $Namespace -ClassName __NAMESPACE | Select-Object -Property Name
}

# Drivers
function Get-Driver {
    Get-CimInstance -Namespace Root\CIMv2 -ClassName Win32_SystemDriver | ForEach-Object {
        [PSCustomObject]@{
            'ModuleName' = $_.Name
            'DisplayName' = $_.DisplayName
            'DriverType' = $_.ServiceType
        }
    }
}

# Drives
function Get-LocalDrive {
    # DriveType of 3 signifies a local disk type
    Get-CimInstance -Namespace Root\CIMv2 -ClassName Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | ForEach-Object {
        [PSCustomObject]@{
            'DeviceID' = $_.DeviceID
            'VolumeName' = $_.VolumeName
            'Size(G)' = $_.Size / 1GB
            'Free(G)' = $_.FreeSpace / 1GB
            'PercentFree' = ($_.FreeSpace / $_.Size) * 100
        }
    } | Format-Table
} 

# CPU
function Get-CPU {
    Get-CimInstance -Namespace Root\CIMv2 -ClassName Win32_Processor |  ForEach-Object {
        [PSCustomObject]@{
            'DeviceID' = $_.DeviceID
            'Name' = $_.Name
            'Cores' = $_.NumberOfCores
            'LogicalProcessors' = $_.NumberOfLogicalProcessors
            'Threads' = $_.ThreadCount
            'CurrentClockSpeed' = $_.CurrentClockSpeed
        }
    }
}

# GPU
function Get-GPU {
    Get-CimInstance -Namespace Root\CIMv2 -ClassName Win32_VideoController |  ForEach-Object {
        [PSCustomObject]@{
            'DeviceID' = $_.DeviceID
            'Name' = $_.Name
            'DriverDate' = $_.DriverDate
            'DriverVersion' = $_.DriverVersion
        }
    } | Format-List
}

# =================================== ALIASES ====================================

# Help
Set-Alias -Name gcp -Value Get-CommandParams
Set-Alias -Name gce -Value Get-CommandExamples

# WinGet
Set-Alias -Name up -Value Update-Packages

# git
Set-Alias -Name gs -Value Get-GitStatus
Set-Alias -Name gpom -Value Update-GitMaster

# Processes
Set-Alias -Name ps -Value Get-SortedGroupedProcesses

# CIM
Set-Alias -Name gcc -Value Get-CimClass
Set-Alias -Name gccn -Value Get-CimChildNamespace

# =================================== VI-MODE ====================================

# Enable Vim command line mode
Set-PSReadLineOption -EditMode Vi

# Dynamically change cursor based on mode
$OnViModeChange = [scriptblock]{
    if ($args[0] -eq 'Command') {
        Write-Host -NoNewLine "`e[2 q" # Block cursor
    } else {
        Write-Host -NoNewLine "`e[5 q" # Line cursor
    }
}
Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler $OnViModeChange

# ================================ HISTORY/ATUIN =================================

atuin init powershell | Out-String | Invoke-Expression

# =============================== AUTOSUGGESTIONS ================================

# With zsh, the way to get ghost text auto-suggestions working is with
# zsh-autosuggestions. zsh-autosuggestions integrates directly atuin seen here
# https://docs.atuin.sh/latest/integrations/ which means on zsh, we can drop native 
# history entirely. On pwsh, no such integration exists so we still need to keep 
# C:\Users\master\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
# alongside C:\Users\master\.local\share\atuin\history.db
# This is apparent in the history module inside the windows inventory
Set-PSReadLineOption -PredictionSource History
