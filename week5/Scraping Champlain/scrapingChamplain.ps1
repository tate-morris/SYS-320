function gatherClasses() {

    $page = Invoke-WebRequest -TimeoutSec 2 "http://184.171.147.19/Courses2025FA.html"

    $trs = $page.ParsedHtml.body.getElementsByTagName('tr')

    $FullTable = @()

    for ($i = 1; $i -lt $trs.length; $i++) {

        $tds = $trs.item($i).getElementsByTagName('td')

	$shift = 0
	
	 if ($tds[4].innerText -eq "TBA") {
            $shift = -1
        }

        $Times = $tds[5 + $shift].innerText.Split('-')

        $FullTable += [pscustomobject]@{
            "Class Code" = $tds[0].innerText
            "Title"      = $tds[1].innerText
            "Days"       = $tds[4].innerText
            "Time Start" = $Times[0]
            "Time End"   = $Times[1]
            "Instructor" = $tds[6 + $shift].innerText
            "Location"   = $tds[9  + $shift].innerText
        }
    }

    return $FullTable
}


function daysTranslator($FullTable){
    # Go over every record in the table
    for($i = 0; $i -lt $FullTable.length; $i++){

        # Empty array to hold days for every record
        $SDays = @()

        # If you see "M"  -> Monday
        if ($FullTable[$i].Days -ilike "*M*") { $SDays += "Monday" }

        # If you see "TH" -> Thursday  (check this FIRST so it doesn't get counted as Tuesday)
        if ($FullTable[$i].Days -ilike "*TH*") { $SDays += "Thursday" }

        # If you see "T" but NOT "TH" -> Tuesday
        if ( ($FullTable[$i].Days -ilike "*T*") -and ($FullTable[$i].Days -notlike "*TH*") ) {
            $SDays += "Tuesday"
        }

        # If you see "W"  -> Wednesday
        if ($FullTable[$i].Days -ilike "*W*") { $SDays += "Wednesday" }

        # If you see "F"  -> Friday
        if ($FullTable[$i].Days -ilike "*F*") { $SDays += "Friday" }

        # Make the switch: replace the Days property with the array you built
        $FullTable[$i].Days = $SDays
    }

    return $FullTable
}

