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

# =================================== ENV VARS ===================================

# PowerShell recurses into directories in PSModulePath looking for .psd1 and .psm1 files
# As a result, we only need to specify the top level directory here
# This is behavior is unlike normal Path on both pwsh and Unix shells
$Env:PSModulePath += ";$HOME\powershell\modules"

# ================================== FUNCTIONS ===================================

# Most functions belong in a module in $HOME\powershell\modules

# Prediction
function Enable-Prediction {
    Set-PSReadLineOption -PredictionSource History
}

function Disable-Prediction {
    Set-PSReadLineOption -PredictionSource None
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
