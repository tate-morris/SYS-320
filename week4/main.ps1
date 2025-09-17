. (Join-Path $PSScriptRoot 'week4.ps1')   # dot-source (note the space)

Clear-Host

# Part 6.1
$loginoutsTable = Get-LogonLogoffTable -DaysBack 15
$loginoutsTable | Format-Table -AutoSize

# Part 6.2
$shutdownsTable = Get-StartShutdownTable -DaysBack 25 -Kind Shutdown
$shutdownsTable | Format-Table -AutoSize

# Part 6.3
$startupsTable  = Get-StartShutdownTable -DaysBack 25 -Kind Startup
$startupsTable  | Format-Table -AutoSize
