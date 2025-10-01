#IP = 184.171.147.19

# Part 1


$scraped_page = Invoke-WebRequest -TimeoutSec 10 "http://184.171.147.19/ToBeScraped.html"
#$scraped_page.Links.Count


# Part 2

#$scraped_page.Links

# Part 3

#$scraped_page.Links | Select-Object href, innertext

# Part 4

<#
$h2s = $scraped_page.ParsedHtml.body.getElementsByTagName("h2") | Select-Object outerText
$h2s
#>

# Part 5

$divs1 = $scraped_page.ParsedHtml.body.getElementsByTagName("div") | where {
$_.getAttributeNode("class").Value -ilike "div-1" } | select innerText

$divs1