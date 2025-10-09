<# ******************************************************
   Function: getMatchingLines
   Input:   1) Text with multiple lines  
            2) Keyword
   Output:  Array of lines that contain the keyword
********************************************************* #>
function getMatchingLines {
    param([string]$contents, [string]$lookline)

    $allines = @()
    if ([string]::IsNullOrEmpty($contents)) { return $allines }

    $splitted = $contents -split [Environment]::NewLine
    for ($j = 0; $j -lt $splitted.Count; $j++) {
        $line = $splitted[$j]
        if ($null -ne $line -and $line.Trim().Length -gt 0) {
            if ($line -like $lookline) { $allines += $line }
        }
    }
    return $allines
}
