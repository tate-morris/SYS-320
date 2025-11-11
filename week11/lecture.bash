file="/var/log/apache2/access.log"

if [[ ! -r "$file" ]]; then
  echo "Error: cannot read $file" >&2
  exit 1
fi

grep "page2.html" "$file" \
  | cut -d' ' -f1,7 \
  | tr -d '/'    \
  | tr ' ' '\n'  \
  | paste - - 
  
pageCount(){
  cut -d' ' -f7 "$file" | sort | uniq -c
}

countingCurlAccess(){
  grep "curl" /var/log/apache2/access.log | cut -d' ' -f1 | sort | uniq -c
}


pageCount
countingCurlAccess
