function Get-ApacheLogs {
    param (
        [string]$Page,
        [string]$HttpCode,
        [string]$Browser
    )

    $logs = Get-Content C:\xampp\apache\logs\access.log

    $filtered = $logs | Where-Object {
        ($_ -match $Page) -and
        ($_ -match $HttpCode) -and
        ($_ -match $Browser)
    }

    $regex = [regex] "^\d{1,3}(\.\d{1,3}){3}"

    $ips = @()
    foreach ($line in $filtered) {
        $match = $regex.Match($line)
        if ($match.Success) {
            $ips += New-Object PSObject -Property @{ "IP" = $match.Value }
        }
    }

    return $ips
}
