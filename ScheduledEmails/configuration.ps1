$script:DaysRegex = '^\d+$'
$script:TimeRegex = '^(0?[1-9]|1[0-2]):([0-5][0-9])\s?(AM|PM)$'

function Get-ConfigPath {
    Join-Path -Path $PSScriptRoot -ChildPath 'configuration.txt'
}

function readConfiguration {
    $path = Get-ConfigPath
    if (-not (Test-Path $path)) {
        Write-Warning "configuration.txt not found."
        return [pscustomobject]@{ Days=$null; SendTime=$null; Status='Missing' }
    }

    $lines = Get-Content $path
    if ($lines.Count -lt 2) {
        Write-Warning "configuration.txt must have two lines."
        return [pscustomobject]@{ Days=$null; SendTime=$null; Status='Incomplete' }
    }

    $days = $lines[0].Trim()
    $time = $lines[1].Trim()

    $daysValid = $days -match $script:DaysRegex
    $timeValid = $time -match $script:TimeRegex

    # inline normalization
    if ($timeValid) {
        $m = [regex]::Match($time, '^(0?[1-9]|1[0-2]):([0-5][0-9])\s*(?i)(am|pm)$')
        $time = ('{0}:{1} {2}' -f $m.Groups[1].Value, $m.Groups[2].Value, $m.Groups[3].Value.ToUpper())
    }

    $status = if ($daysValid -and $timeValid) { 'OK' }
              elseif (-not $daysValid -and -not $timeValid) { 'Invalid: Both' }
              elseif (-not $daysValid) { 'Invalid: Days' }
              else { 'Invalid: Time' }

    [pscustomobject]@{
        Days     = if ($daysValid) { [int]$days } else { $null }
        SendTime = $time
        Status   = $status
    }
}

function changeConfiguration {
    $path = Get-ConfigPath
    Write-Host "`n--- Change Configuration ---" -ForegroundColor Cyan

    do { $days = Read-Host 'Enter number of days (digits only)' } until ($days -match $script:DaysRegex)
    do { $time = Read-Host 'Enter execution time (e.g., 9:05 AM)' } until ($time -match $script:TimeRegex)

    # inline normalization
    $m = [regex]::Match($time, '^(0?[1-9]|1[0-2]):([0-5][0-9])\s*(?i)(am|pm)$')
    $time = ('{0}:{1} {2}' -f $m.Groups[1].Value, $m.Groups[2].Value, $m.Groups[3].Value.ToUpper())

    "$days","$time" | Set-Content $path -Encoding UTF8
    Write-Host "Configuration updated successfully." -ForegroundColor Green
}

function configurationMenu {
    $keepGoing = $true
    while ($keepGoing) {
        Write-Host "`n======================================"
        Write-Host "        Configuration Menu"
        Write-Host "======================================"
        Write-Host "1) Show configuration"
        Write-Host "2) Change configuration"
        Write-Host "3) Exit"
        $choice = (Read-Host 'Select an option (1-3)').Trim()

        if ($choice -notmatch '^[123]$') {
            Write-Host "Invalid option." -ForegroundColor Yellow
            continue
        }

        switch ($choice) {
            '1' {
                Write-Host "`n--- Current Configuration ---" -ForegroundColor Cyan
                $cfg = readConfiguration
                $cfg | Format-Table -AutoSize | Out-Host
                if ($cfg.Status -ne 'OK') {
                    Write-Host "Note: Status is '$($cfg.Status)'. Use Option 2 to fix." -ForegroundColor Yellow
                }
            }
            '2' { changeConfiguration }
            '3' {
                Write-Host "Exiting..." -ForegroundColor Cyan
                $keepGoing = $false
            }
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    configurationMenu
}
