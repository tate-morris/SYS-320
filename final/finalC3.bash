#!/bin/bash

INPUT="report.txt"          # created in Challenge 2
TMPFILE="report.html"       # temporary file in current directory

# Start the HTML document
cat <<EOF > "$TMPFILE"
<html>
<head>
    <title>Access logs with IOC indicators</title>
</head>
<body>
<h2>Access logs with IOC indicators:</h2>
<table border="1">
EOF

# Read each line of report.txt: ip, datetime, page
while read -r ip datetime page
do
    # skip any empty lines
    [ -z "$ip" ] && continue
    echo "<tr><td>${ip}</td><td>${datetime}</td><td>${page}</td></tr>" >> "$TMPFILE"
done < "$INPUT"

# Close the HTML document
cat <<EOF >> "$TMPFILE"
</table>
</body>
</html>
EOF

# Move the HTML file into Apache's web root so you can open it as http://localhost/report.html
sudo mv "$TMPFILE" /var/www/html/report.html
