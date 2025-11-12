#! /bin/bash

logFile="/var/log/apache2/access.log"

function displayAllLogs(){
	cat "$logFile"
}

function displayOnlyIPs(){
	cut -d ' ' -f 1 "$logFile" | sort -n | uniq -c
}

function displayOnlyPages(){
	# Pull the request line ("GET /path HTTP/1.1"), then extract the path (2nd token)
	awk -F\" '{print $2}' "$logFile" | awk '{print $2}' | sort | uniq -c
}


function histogram(){
	awk '{print $1, substr($4,2,11)}' "$logFile" | sort -n | uniq -c
}

function frequentVisitors(){
	awk '{print $1, substr($4,2,11)}' "$logFile" \
	| sort -n | uniq -c \
	| awk '$1 > 10 {print}'
}

function suspiciousVisitors(){
	if [[ ! -f ioc.txt ]]; then
		echo "ioc.txt not found in current directory."
		echo "Create it with one indicator per line (e.g., '/bin/bash', '../', '/wp-admin', etc.)."
		return 1
	fi
	grep -E -f ioc.txt "$logFile" | awk '{print $1}' | sort -n | uniq -c
}

while :
do
	echo "Please select an option:"
	echo "[1] Display all Logs"
	echo "[2] Display only IPS"
	echo "[3] Display only Pages"
	echo "[4] Histogram"
	echo "[5] Frequent Visitors"
	echo "[6] Suspicious Visitors"
	echo "[7] Quit"

	read -r userInput
	echo ""

	case "$userInput" in
		7)
			echo "Goodbye"
			break
			;;
		1)
			echo "Displaying all logs:"
			displayAllLogs
			;;
		2)
			echo "Displaying only IPS:"
			displayOnlyIPs
			;;
		3)
			echo "Displaying only Pages:"
			displayOnlyPages
			;;
		4)
			echo "Histogram:"
			histogram
			;;
		5)
			echo "Frequent Visitors:"
			frequentVisitors
			;;
		6)
			echo "Suspicious Visitors:"
			suspiciousVisitors
			;;
		*)
			echo "Invalid option. Please choose a number 1–7."
			;;
	esac

	echo ""
done
