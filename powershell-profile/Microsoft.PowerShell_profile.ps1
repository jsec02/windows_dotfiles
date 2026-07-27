# ================================================================================
# =                              POWERSHELL_PROFILE                              =
# ================================================================================

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

# git
function Get-GitStatus {
    git status 
}

function Update-GitMaster {
    git pull origin master
}

# =================================== ALIASES ====================================

# Help
Set-Alias -Name gcp -Value Get-CommandParams
Set-Alias -Name gce -Value Get-CommandExamples

# git
Set-Alias -Name gs -Value Get-GitStatus
Set-Alias -Name gpom -Value Update-GitMaster

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
