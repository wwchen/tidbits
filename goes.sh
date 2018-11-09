#!/bin/bash
set -e

ORDER_BY=soonest
LIMIT=10
LOCATION_IDS=(5446)

SLACK_URL="https://hooks.slack.com/services/XXXXXXXXXXXXXXXXXXXX"

while [[ 1 ]]; do
  found=0
  date
  for location_id in ${LOCATION_IDS[@]}; do
    url="https://ttp.cbp.dhs.gov/schedulerapi/slots?orderBy=$ORDER_BY&limit=$LIMIT&locationId=$location_id&minimum=1"
    json=$(curl -s --insecure "$url" -H 'Accept-Language: en-US,en;q=0.9' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3595.0 Safari/537.36' -H 'Content-Type: application/json')
    timestamps=$(echo $json | jq -r .[].startTimestamp)
    
    for timestamp in $timestamps; do
      # ex: 2018-11-10T09:15
      date=$(echo $timestamp | cut -dT -f1)
      time=$(echo $timestamp | cut -dT -f2)
  
      echo $location_id: $date $time
      
      if [[ $location_id == 5446 && $date == "2018-11-09" ]]; then
        message="GOES SFO: $date $time"
        curl -X POST --data-urlencode "payload={\"text\": \"$message\"}" $SLACK_URL
        echo
        found=1
      fi
  
      if [[ $location_id == 9200 && $date == "2018-11-09" ]]; then
        message="GOES PIT: $date $time"
        curl -X POST --data-urlencode "payload={\"text\": \"$message\"}" $SLACK_URL
        echo
      fi
    done
  done
  echo "============="
  if [[ $found -eq 0 ]]; then
    sleep 60
  else
    sleep 600
  fi
done
