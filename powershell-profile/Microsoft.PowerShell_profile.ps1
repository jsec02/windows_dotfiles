# ================================================================================
# =                              POWERSHELL_PROFILE                              =
# ================================================================================

# Load secrets
$LocalProfile = 'C:\Users\master\Documents/powerShell/Microsoft.PowerShell_profile.local.ps1'
if (Test-Path $LocalProfile) {
    . $LocalProfile 
}

# ================================== FUNCTIONS ===================================

function Get-CommandParams {
    param([string]$Command)
    Get-Help $Command -Parameter *
}

function Get-CommandExamples {
    param([string]$Command)
    Get-Help $Command -Example
}

# =================================== ALIASES ====================================

Set-Alias gcp Get-CommandParams
Set-Alias gce Get-CommandExamples

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
