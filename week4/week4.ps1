# Part 1

Get-EventLog -LogName System -Source Microsoft-Windows-Winlogon

# Part 2

$loginouts = Get-EventLog -LogName System -Source Microsoft-Windows-Winlogon -After (Get-Date).AddDays(-14)


$loginoutsTable = @()

for ($i = 0; $i -lt $loginouts.Count; $i++) {

    $event = ""
    if ($loginouts[$i].InstanceId -eq 7001) { $event = "Logon" }
    if ($loginouts[$i].InstanceId -eq 7002) { $event = "Logoff" }


    $user = $loginouts[$i].ReplacementStrings[1]


    $loginoutsTable += [pscustomobject]@{
        Time  = $loginouts[$i].TimeGenerated
        Id    = $loginouts[$i].InstanceId
        Event = $event
        User  = $user
    }
}


 $loginoutsTable | Format-Table -AutoSize

# Part 3

$events = Get-EventLog -LogName System -Source Microsoft-Windows-Winlogon `
          -After (Get-Date).AddDays(-14) |
          Where-Object { $_.InstanceId -in 7001,7002 } |
          Sort-Object TimeGenerated


function Resolve-UserFromStrings {
    param([string[]]$Strings)


    $sidText = $Strings | Where-Object { $_ -match '^S-1-\d+(-\d+)+' } | Select-Object -First 1
    if ($sidText) {
        try {
            return ([System.Security.Principal.SecurityIdentifier]$sidText).
                   Translate([System.Security.Principal.NTAccount]).Value
        } catch {
            return $sidText 
        }
    }


    $candidate = $Strings | Where-Object { $_ -match '\\' -or $_ -match '@' } | Select-Object -First 1
    if ($candidate) { return $candidate }

    return $Strings[0] 
}


$result =
foreach ($e in $events) {
    $label = if ($e.InstanceId -eq 7001) { 'Logon' } else { 'Logoff' }
    $user  = Resolve-UserFromStrings -Strings $e.ReplacementStrings

    [pscustomobject]@{
        Time  = $e.TimeGenerated
        Id    = $e.InstanceId
        Event = $label
        User  = $user
    }
}

$result | Format-Table -AutoSize


# Part 4

function Get-LogonLogoffTable {
    param(
        [int]$DaysBack
    )

    $events = Get-EventLog -LogName System -Source Microsoft-Windows-Winlogon `
              -After (Get-Date).AddDays(-$DaysBack) |
              Where-Object { $_.InstanceId -in 7001,7002 } |
              Sort-Object TimeGenerated

    $results = @()

    foreach ($e in $events) {
        $label = if ($e.InstanceId -eq 7001) { 'Logon' } else { 'Logoff' }

        $sidText = $e.ReplacementStrings | Where-Object { $_ -match '^S-1-\d+(-\d+)+' } | Select-Object -First 1
        if ($sidText) {
            try {
                $user = ([System.Security.Principal.SecurityIdentifier]$sidText).
                        Translate([System.Security.Principal.NTAccount]).Value
            } catch {
                $user = $sidText
            }
        } else {
            $user = $e.ReplacementStrings[1]
        }

        $results += [pscustomobject]@{
            Time  = $e.TimeGenerated
            Id    = $e.InstanceId
            Event = $label
            User  = $user
        }
    }

    return $results
}

Get-LogonLogoffTable -DaysBack 14 | Format-Table -AutoSize


# Part 5

function Get-StartShutdownTable {
    param(
        [int]$DaysBack
    )

    $ids = 6005,6006

    $events = Get-EventLog -LogName System -Source EventLog `
              -After (Get-Date).AddDays(-$DaysBack) |
              Where-Object { $_.EventID -in $ids } |
              Sort-Object TimeGenerated

    $rows = foreach ($e in $events) {
        $label = switch ($e.EventID) {
            6005 { 'Startup'   }
            6006 { 'Shutdown'  }
            default { 'Other' }
        }

        [pscustomobject]@{
            Time  = $e.TimeGenerated    
            Id    = $e.EventID           
            Event = $label              
            User  = 'System'            
        }
    }

    return $rows
}

Get-StartShutdownTable -DaysBack 14 | Format-Table -AutoSize




