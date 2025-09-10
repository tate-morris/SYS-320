<# Part 1
Get-Process | Where-Object { $_.ProcessName -like 'C*' } | 
Select-Object ProcessName, Id, CPU, StartTime -ErrorAction SilentlyContinue
#>

<# Part 2
Get-Process | Where-Object { $_.Path -notlike '*\system32\*' } | Select-Object ProcessName, Id, Path
#>

<# Part 3
$out = Join-Path $PSScriptRoot 'stopped-services.csv'

Get-Service | Where-Object { $_.Status -eq 'Stopped' } | Sort-Object Name |
  Select-Object Name, DisplayName, Status, StartType |
  Export-Csv -Path $out -NoTypeInformation

Write-Host "Saved:" $out
#>


$proc = Get-Process -Name 'chrome' -ErrorAction SilentlyContinue

if (-not $proc) {
    # Not running → start to Champlain
    Start-Process -FilePath 'chrome.exe' -ArgumentList 'https://www.champlain.edu'
    Write-Host "Chrome started and directed to Champlain.edu"
}
else {
    # Already running → try graceful close, then force if needed
    $closed = $false
    foreach ($p in $proc) {
        if ($p.CloseMainWindow()) { $closed = $true }
    }
    Start-Sleep -Milliseconds 750
    if (Get-Process -Name 'chrome' -ErrorAction SilentlyContinue) {
        Stop-Process -Name 'chrome' -Force
        Write-Host "Chrome was running; processes terminated."
    }
    elseif ($closed) {
        Write-Host "Chrome was running; windows closed gracefully."
    }
}