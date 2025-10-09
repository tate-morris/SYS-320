. (Join-Path $PSScriptRoot 'String-Helper.ps1')

<# ******************************
   getLogInAndOffs
   Input:  -timeBack : number of days to look back
   Output: [pscustomobject] with Time, Id, Event, User
****************************** #>
function getLogInAndOffs {
    param([int]$timeBack = 1)

    $since = (Get-Date).AddDays(-[math]::Abs($timeBack))

    $loginouts = Get-EventLog -LogName System -Source 'Microsoft-Windows-Winlogon' -After $since -ErrorAction SilentlyContinue

    $rows = @()
    foreach ($e in $loginouts) {
        $type = switch ($e.InstanceId) { 7001 { 'Logon' } 7002 { 'Logoff' } default { $null } }
        if (-not $type) { continue }

        $user = $null
        if ($e.ReplacementStrings -and $e.ReplacementStrings.Count -ge 2) {
            $user = $e.ReplacementStrings[1]
        } else {
            $user = $e.UserName
        }

        $rows += [pscustomobject]@{
            Time  = $e.TimeGenerated
            Id    = $e.InstanceId
            Event = $type
            User  = $user
        }
    }
    return $rows
}

<# ******************************
   getFailedLogins
   Input:  -timeBack : number of days to look back
   Output: [pscustomobject] with Time, Id, Event='Failed', User='DOMAIN\Name'.
****************************** #>
function getFailedLogins {
    param([int]$timeBack = 1)

    $since = (Get-Date).AddDays(-[math]::Abs($timeBack))

    $events = @()

    try {
        $events = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625; StartTime=$since} -ErrorAction Stop
    } catch {
        try {
            $events = Get-EventLog -LogName Security -After $since -ErrorAction Stop | Where-Object { $_.EventID -eq 4625 }
        } catch {
            throw "Unable to read Security log (Event ID 4625). Try running as Administrator."
        }
    }

    $rows = @()
    foreach ($e in $events) {
        $msg = $e.Message
        $time = if ($e.PSObject.Properties['TimeCreated']) { $e.TimeCreated } else { $e.TimeGenerated }
        $id = if ($e.PSObject.Properties['Id']) { $e.Id } else { $e.EventID }

        $usrLines = getMatchingLines $msg '*Account Name*'
        $dmnLines = getMatchingLines $msg '*Account Domain*'

        $usr = $null
        $dmn = $null

        if ($usrLines.Count -ge 2) {
            $usr = ($usrLines[1] -split ':',2)[1].Trim()
        } elseif ($usrLines.Count -ge 1) {
            $usr = ($usrLines[0] -split ':',2)[1].Trim()
        }

        if ($dmnLines.Count -ge 2) {
            $dmn = ($dmnLines[1] -split ':',2)[1].Trim()
        } elseif ($dmnLines.Count -ge 1) {
            $dmn = ($dmnLines[0] -split ':',2)[1].Trim()
        }

        $user = if ($usr -and $dmn) { "$dmn\$usr" } else { $usr }

        $rows += [pscustomobject]@{
            Time  = $time
            Id    = $id
            Event = 'Failed'
            User  = $user
        }
    }

    return $rows
}
