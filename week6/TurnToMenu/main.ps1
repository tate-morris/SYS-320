. "$PSScriptRoot\Apache-Logs.ps1"
. "$PSScriptRoot\Event-Logs.ps1"

function Test-FunctionExists {
    param([Parameter(Mandatory)][string]$Name)
    return [bool](Get-Command -Name $Name -CommandType Function -ErrorAction SilentlyContinue)
}

function Pause-ForUser {
    Write-Host ""
    Read-Host "Press ENTER to return to the menu"
}

function Show-Menu {
    Clear-Host
    Write-Host "===== Systems Scripting Menu ====="
    Write-Host "1) Display last 10 Apache logs"
    Write-Host "2) Display last 10 failed logins for all users"
    Write-Host "3) Display at-risk users"
    Write-Host "4) Start Chrome and navigate to champlain.edu (only if not running)"
    Write-Host "5) Exit"
    Write-Host "=================================="
}

do {
    Show-Menu
    $choice = Read-Host "Enter a choice (1-5)"

    if ($choice -notmatch '^[1-5]$') {
        Write-Warning "Invalid input. Please enter a number from 1 to 5."
        Start-Sleep -Milliseconds 900
        continue
    }

    switch ($choice) {

        '1' {
            if (-not (Test-FunctionExists -Name 'Get-ApacheLogs')) {
                Write-Error "Function 'Get-ApacheLogs' not found. Ensure Apache-Logs.ps1 is dot-sourced and defines it."
                Pause-ForUser; break
            }
            $records = Get-ApacheLogs | Select-Object -Last 10
            if ($null -eq $records -or $records.Count -eq 0) {
                Write-Host "No Apache records found."
            } else {
                $records | Format-Table -AutoSize -Wrap
            }
            Pause-ForUser
        }

        '2' {
            $fn = 'getFailedLogins'
            if (-not (Test-FunctionExists -Name $fn)) {
                Write-Error "Function 'getFailedLogins' not found. Ensure Event-Logs.ps1 is dot-sourced and exposes it."
                Pause-ForUser; break
            }
            $failed = & $fn | Select-Object -Last 10
            if ($null -eq $failed -or $failed.Count -eq 0) {
                Write-Host "No failed logins found."
            } else {
                $failed | Format-Table -AutoSize
            }
            Pause-ForUser
        }

        '3' {
    if (-not (Test-FunctionExists -Name 'getFailedLogins')) {
       Write-Error "Function 'getFailedLogins' not found. Ensure Event-Logs.ps1 is dot-sourced and exposes it."
       Pause-ForUser; break
    }

    $days = Read-Host "How many days back should we search?"
    if ($days -notmatch '^\d+$' -or [int]$days -le 0) {
        Write-Host "Invalid entry. Please enter a positive integer."
        Pause-ForUser; break
    }

    $threshold = Read-Host "Minimum number of failed logins to flag a user"
    if ($threshold -notmatch '^\d+$' -or [int]$threshold -le 0) {
        Write-Host "Invalid entry. Please enter a positive integer."
        Pause-ForUser; break
    }

    try {
        $failed = getFailedLogins -timeBack $days
        if (-not $failed) { 
            Write-Host "No failed login events found in the last $days day(s)."
            Pause-ForUser; break
        }

        $grouped = $failed | Group-Object User | Where-Object { $_.Count -ge $threshold } | Sort-Object Count -Descending

        if ($grouped) {
            $grouped |
                Select-Object @{n='User'; e={$_.Name}}, @{n='FailedCount'; e={$_.Count}} |
                Format-Table -AutoSize
        } else {
            Write-Host "No users met the threshold of $threshold failed logins in the last $days day(s)."
        }
    }
    catch {
        Write-Host "Error computing at-risk users: $($_.Exception.Message)"
    }

    Pause-ForUser
}


        '4' {
            $chrome = Get-Process -Name chrome -ErrorAction SilentlyContinue
            if ($null -eq $chrome) {
                try {
                    Start-Process "chrome.exe" "https://www.champlain.edu"
                    Write-Host "Chrome started and navigated to champlain.edu."
                } catch {
                    Write-Error "Could not start Chrome: $($_.Exception.Message)"
                }
            } else {
                Write-Host "Chrome is already running; no new instance started."
            }
            Pause-ForUser
        }

        '5' {
            Write-Host "Exiting. Goodbye."
        }
    }
} while ($choice -ne '5')
