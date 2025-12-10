#!/bin/bash

# Change this to the IP of your web server (the one hosting IOC.html)
SERVER_IP="localhost"

# Full URL of the IOC page
IOC_URL="http://${SERVER_IP}/IOC.html"

# Get the page and save it as IOC.txt
curl -s "$IOC_URL" > IOC.txt
