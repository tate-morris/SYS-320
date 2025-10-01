. ".\scrapingChamplain.ps1"

# Base

<#
$classes = gatherClasses

$classes = daysTranslator $classes

$classes | Format-List "Class Code", "Title", "Days", "Time Start", "Time End", "Instructor", "Location"

#>

$FullTable = gatherClasses
$FullTable = daysTranslator $FullTable

# Part 1

<#
$FullTable | Where-Object {$_.Instructor -ilike "Furkan Paligu"} | 
	     Select-Object "Class Code", Instructor, Location, Days, "Time Start", "Time End" |
	     Format-List
#>

# Part 2

<#
$FullTable | Where-Object {($_.Location -ilike "JOYC 310") -and ($_.days -contains "Monday")} | 
	     Sort-Object "Time Start" |
	     Select-Object "Time Start", "Time End", "Class Code"
	     Format-List
#>

#Part 3

<#
$ITSInstructors = $FullTable |
  Where-Object {
    $_."Class Code" -ilike "SYS*" -or $_."Class Code" -ilike "NET*" -or
    $_."Class Code" -ilike "SEC*" -or $_."Class Code" -ilike "FOR*" -or
    $_."Class Code" -ilike "CSI*" -or $_."Class Code" -ilike "DAT*"
  } |
  Select-Object "Instructor" |
  Sort-Object "Instructor" -Unique

$ITSInstructors
#>


# Part 4

$ITSInstructors = $FullTable |
    Where-Object {
        ($_."Class Code" -ilike "SYS*") -or
        ($_."Class Code" -ilike "NET*") -or
        ($_."Class Code" -ilike "SEC*") -or
        ($_."Class Code" -ilike "FOR*") -or
        ($_."Class Code" -ilike "CSI*") -or
        ($_."Class Code" -ilike "DAT*")
    } |
    Select-Object "Instructor" |
    Sort-Object "Instructor" -Unique


$FullTable |
    Where-Object { $_.Instructor -in $ITSInstructors.Instructor } |
    Group-Object "Instructor" |
    Select-Object Count, Name |
    Sort-Object Count -Descending
