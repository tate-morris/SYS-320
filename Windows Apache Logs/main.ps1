. .\Apache-Logs.ps1

$results = Get-ApacheLogs -Page "index.html" -HttpCode "404" -Browser "Chrome"

$counts = $results | Group-Object IP
$counts | Select-Object Count, Name
