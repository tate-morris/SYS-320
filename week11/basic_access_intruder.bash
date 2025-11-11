URL="184.171.151.9"
COUNT=20

printf "Target: %s\nRequests: %d\n\n" "$URL" "$COUNT"

for i in $(seq 1 "$COUNT"); do
	curl 184.171.151.9
done

echo -e "\nDone."
