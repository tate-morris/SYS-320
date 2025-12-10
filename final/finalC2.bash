#!/bin/bash

LOGFILE="$1"
IOCFILE="$2"

> report.txt

while read IOC
do
    grep -F "$IOC" "$LOGFILE" | awk '
    {
        ip=$1
        gsub(/^\[/,"",$4)
        datetime=$4
        gsub(/^\"/,"",$7)
        page=$7
        print ip, datetime, page
    }' >> report.txt
done < "$IOCFILE"
