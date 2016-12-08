#!/bin/bash

function slack {
  curl https://hooks.slack.com/services/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 -d "payload={'text': '$1'}"
}

function opentable_request {
  res_id=$1  # e.g. 3542
  n_seats=$2 # number of seats
  date=$3    # in the format of 2016-01-01
  time=$4    # in the format of 19:00
  url="http://www.opentable.com/restaurant/profile/$res_id/search"
  body="{\"covers\":\"$n_seats\", \"dateTime\":\"$date $time\"}"
  response=$(curl -s "$url" \
    -H 'Accept-Encoding: gzip, deflate' \
    -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.98 Safari/537.36' \
    -H 'Content-Type: application/json; charset=UTF-8' \
    -H 'X-Requested-With: XMLHttpRequest' \
    -H 'Connection: keep-alive' \
    -H 'DNT: 1' \
    -H 'Accept: text/html, */*; q=0.01' \
    --data-binary "$body" \
    --compressed)
}

while [[ 1 ]]; do
  for i in `seq 26 30`; do
    date="2016-12-$i"
    opentable_request 3542 2 $date '19:00'

    #echo $?
    #other_availability=$(echo "$response" | pup '.rest-row-info text{}')
    #available_time=$(echo "$response" | pup '.content-section-body text{}' | grep -E '^[0-9:]* PM$')
    available_times=$(echo "$response" | pup 'a attr{data-datetime}' | sort -u)

    [[ $available_times =~ $date ]] && has_found=true || has_found=false

    if [[ $has_found == true ]]; then
      msg="Found tables: $(echo "$available_times" | grep -Eo '[:0-9 -]*' | tr '\n' ' ')"
      slack "$msg"
    fi

    echo "Checked $date: $available_times"
    sleep 1
  done
  sleep 30
done
