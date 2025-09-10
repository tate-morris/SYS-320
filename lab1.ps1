<# Part 8
cd PSScriptRoot

$files = (Get-ChildItem)
for ($j = 0; $j -le $files.Length; $j++) 
{

	if ($files[$j].Name -ilike "*.ps1") 
	{
		Write-Host $files[$j].Name
        }
}
#>

<# Part 9
$folderpath = "PSScriptRoot\outFolder"

if (Test-Path $folderpath) {
    Write-Host "Folder Already Exists"
}
else {
    New-Item -ItemType Directory -Path $folderpath
}
#>

<# Part 10
cd $PSScriptRoot
$files = Get-ChildItem

$folderPath = "PSScriptRoot/outfolder/"
$filePath   = Join-Path $folderPath "out.csv"

# List all the files that have the extension ".ps1" 
# and save the results to out.csv file
$files | Where-Object { $_.Extension -eq ".ps1" } |
    Select-Object Name, FullName |
    Export-Csv -Path $filePath -NoTypeInformation
#>

$files = Get-ChildItem -Recurse -File

$files | Where-Object { $_.Extension -eq ".csv" } |
    Rename-Item -NewName { $_.Name -replace '\.csv$', '.log' }

Get-ChildItem -Recurse -File






