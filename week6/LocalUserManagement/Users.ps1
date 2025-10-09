function Test-IsAdmin {
    $id  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $pr  = New-Object Security.Principal.WindowsPrincipal($id)
    return $pr.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Assert-Admin {
    if (-not (Test-IsAdmin)) {
        throw "Administrator privileges are required for this operation. Please re-run PowerShell as Administrator."
    }
}

function getEnabledUsers {
    Get-LocalUser | Where-Object { $_.Enabled -eq $true } | Select-Object Name, SID
}

function getNotEnabledUsers {
    Get-LocalUser | Where-Object { $_.Enabled -ne $true } | Select-Object Name, SID
}

function createAUser {
    param(
        [Parameter(Mandatory=$true)][string]$name,
        [Parameter(Mandatory=$true)][System.Security.SecureString]$password
    )
    Assert-Admin
    if (Get-LocalUser -Name $name -ErrorAction SilentlyContinue) {
        throw "A local user named '$name' already exists."
    }
    $newUser = New-LocalUser -Name $name -Password $password -FullName $name -Description 'Created by Local User Management Menu'
    return $newUser
}

function removeAUser {
    param([Parameter(Mandatory=$true)][string]$name)
    Assert-Admin
    $user = Get-LocalUser -Name $name -ErrorAction SilentlyContinue
    if (-not $user) { throw "User '$name' not found." }
    Remove-LocalUser -Name $name
}

function disableAUser {
    param([Parameter(Mandatory=$true)][string]$name)
    Assert-Admin
    $user = Get-LocalUser -Name $name -ErrorAction SilentlyContinue
    if (-not $user) { throw "User '$name' not found." }
    Disable-LocalUser -Name $name
}

function enableAUser {
    param([Parameter(Mandatory=$true)][string]$name)
    Assert-Admin
    $user = Get-LocalUser -Name $name -ErrorAction SilentlyContinue
    if (-not $user) { throw "User '$name' not found." }
    Enable-LocalUser -Name $name
}
