function ApacheLogs1() {
    $logsNotformatted = Get-Content C:\xampp\apache\logs\access.log
    $tableRecords = @()

    for ($i = 0; $i -lt $logsNotformatted.Count; $i++) {
        # split a string into words
        $words = $logsNotformatted[$i] -split " "

        $tableRecords += New-Object PSObject -Property @{
            "IP"       = $words[0]
            "Time"     = $words[3].Trim('[')
            "Method"   = $words[5].Trim('"')
            "Page"     = $words[6]
            "Protocol" = $words[7].Trim('"')
            "Response" = $words[8]
            "Referrer" = $words[10]
            "Client"   = ($words[11..($words.Count-1)] -join " ")
        }
    }

    # Only return records in the 10.* network
    return $tableRecords | Where-Object { $_.IP -like "10.*" }
}

# Call the function and format output
$tableRecords = ApacheLogs1
$tableRecords | Format-Table -AutoSize -Wrap
