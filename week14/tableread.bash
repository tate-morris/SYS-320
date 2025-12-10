#!/bin/bash

URL="http://10.0.17.47/Assignment.html"

# Get the HTML page
curl -s "$URL" > page.html

# First table  (Temperature)
awk '
/<table/ {count++}
count==1 {print}
/<\/table>/ && count==1 {exit}
' page.html > temp_table.html

# Second table (Pressure)
awk '
/<table/ {count++}
count==2 {print}
/<\/table>/ && count==2 {exit}
' page.html > press_table.html

parse_table () {
    # grab all <td>...</td>, strip the tags so we just have the values
    grep -o '<td>[^<]*</td>' "$1" \
        | sed -e 's/<td>//g' -e 's/<\/td>//g' \
        | awk 'NR%2==1 {v=$0; next} {print v" "$0}'
    # result: one line per row: "VALUE DATE-TIME"
}

# Temperature rows
parse_table temp_table.html  > temperature.txt
# Pressure rows
parse_table press_table.html > pressure.txt

# pressure.txt:   "P  DATE"
# temperature.txt:"T  DATE"
# paste side-by-side, then reorder fields
paste pressure.txt temperature.txt \
    | awk '{print $1" "$3" "$2}'
