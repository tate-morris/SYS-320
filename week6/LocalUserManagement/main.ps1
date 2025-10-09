. (Join-Path $PSScriptRoot 'Users.ps1')
. (Join-Path $PSScriptRoot 'Event-Logs.ps1')

Clear-Host

function Read-MenuChoice {
    param([int[]]$ValidChoices)
    while ($true) {
        $raw = Read-Host 'Enter choice'
        $num = 0
        if ([int]::TryParse($raw, [ref]$num)) {
            if ($ValidChoices -contains $num) { return $num }
        }
        Write-Host "Invalid selection. Please enter one of: $($ValidChoices -join ', ')"
    }
}

function Read-PositiveInt([string]$prompt) {
    while ($true) {
        $raw = Read-Host $prompt
        $n = 0
        if ([int]::TryParse($raw, [ref]$n)) {
            if ($n -ge 0) { return $n }
        }
        Write-Host "Please enter a non-negative integer."
    }
}

function Read-NonEmpty([string]$prompt) {
    while ($true) {
        $v = Read-Host $prompt
        if ($null -ne $v -and $v.Trim().Length -gt 0) { return $v.Trim() }
        Write-Host "Input cannot be empty."
    }
}

function Read-PasswordMasked([string]$Prompt = 'Enter password') {
    Write-Host -NoNewline "${Prompt}: "
    $secure = New-Object System.Security.SecureString
    while ($true) {
        $key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        if ($key.VirtualKeyCode -eq 13) {
            break
        } elseif ($key.VirtualKeyCode -eq 8) {
            if ($secure.Length -gt 0) {
                $secure.RemoveAt($secure.Length - 1)
                $pos = $Host.UI.RawUI.CursorPosition
                if ($pos.X -gt 0) {
                    $pos.X = $pos.X - 1
                    $Host.UI.RawUI.CursorPosition = $pos
                    Write-Host ' ' -NoNewline
                    $pos = $Host.UI.RawUI.CursorPosition
                    $pos.X = $pos.X - 1
                    $Host.UI.RawUI.CursorPosition = $pos
                }
            }
        } else {
            if ($key.Character) {
                $secure.AppendChar($key.Character)
                Write-Host '*' -NoNewline
            }
        }
    }
    Write-Host
    return $secure
}

:menu while ($true) {
    Write-Host ''
    Write-Host 'Please choose your operation:'
    Write-Host '1 - List Enabled Users'
    Write-Host '2 - List Disabled Users'
    Write-Host '3 - Create a User'
    Write-Host '4 - Remove a User'
    Write-Host '5 - Enable a User'
    Write-Host '6 - Disable a User'
    Write-Host '7 - Get Log-In/Log-Off Logs'
    Write-Host '8 - Get Failed Log-In Logs'
    Write-Host '9 - List "At-Risk" Users (failed logins > threshold)'
    Write-Host '10 - Exit'

    $choice = Read-MenuChoice -ValidChoices (1..10)

    switch ($choice) {
        1 {
            $rows = getEnabledUsers
            if ($rows) { $rows | Format-Table -AutoSize } else { Write-Host 'No enabled users found.'}
        }
        2 {
            $rows = getNotEnabledUsers
            if ($rows) { $rows | Format-Table -AutoSize } else { Write-Host 'No disabled users found.'}
        }
        3 {
            $name = Read-NonEmpty 'Enter new username'
            $pw   = Read-PasswordMasked 'Enter password for the new user'
            try {
                createAUser -name $name -password $pw
                Write-Host "User '$name' created."
            } catch {
                Write-Host "Failed to create user '$name': $($_.Exception.Message)"
            }
        }
        4 {
            $name = Read-NonEmpty 'Enter username to remove'
            try {
                removeAUser -name $name
                Write-Host "User '$name' removed."
            } catch {
                Write-Host "Failed to remove user '$name': $($_.Exception.Message)"
            }
        }
        5 {
            $name = Read-NonEmpty 'Enter username to enable'
            try {
                enableAUser -name $name
                Write-Host "User '$name' enabled."
            } catch {
                Write-Host "Failed to enable user '$name': $($_.Exception.Message)"
            }
        }
        6 {
            $name = Read-NonEmpty 'Enter username to disable'
            try {
                disableAUser -name $name
                Write-Host "User '$name' disabled."
            } catch {
                Write-Host "Failed to disable user '$name': $($_.Exception.Message)"
            }
        }
        7 {
            $days = Read-PositiveInt 'How many days back should we search for logon/logoff?'
            try {
                $logs = getLogInAndOffs -timeBack $days
                if ($logs) { $logs | Sort-Object Time | Format-Table -AutoSize } else { Write-Host 'No logon/logoff events found.' }
            } catch {
                Write-Host "Error reading logon/logoff: $($_.Exception.Message)"
            }
        }
        8 {
            $days = Read-PositiveInt 'How many days back should we search for failed logins?'
            try {
                $logs = getFailedLogins -timeBack $days
                if ($logs) { $logs | Sort-Object Time | Format-Table -AutoSize } else { Write-Host 'No failed login events found.'}
            } catch {
                Write-Host "Error reading failed logins: $($_.Exception.Message)"
            }
        }
        9 {
            $days = Read-PositiveInt 'How many days back should we search?'
            $threshold = Read-PositiveInt 'Minimum number of failed logins to flag a user'
            try {
                $failed = getFailedLogins -timeBack $days
                if (-not $failed) { Write-Host 'No failed login events found.'; break }
                $grouped = $failed | Group-Object User | Where-Object { $_.Count -ge $threshold } | Sort-Object Count -Descending
                if ($grouped) {
                    $grouped | Select-Object @{n='User';e={$_.Name}}, @{n='FailedCount';e={$_.Count}} | Format-Table -AutoSize
                } else {
                    Write-Host "No users met the threshold of $threshold failed logins in the last $days day(s)."
                }
            } catch {
                Write-Host "Error computing at-risk users: $($_.Exception.Message)"
            }
        }
        10 { break menu }
    }
}
