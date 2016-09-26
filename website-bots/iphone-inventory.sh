#!/bin/bash
## Checks for iPhone 7 inventory, via istocknow.com
## Can be run on linux or mac.
## Requires: curl and jq

DEBUG=false

# if this is not set, then Slack will not be enabled
SLACK_URL=""

function dlog {
  [[ $DEBUG == 'true' ]] && log "$*"
}

function log {
  echo "[$(date '+%Y-%m-%d %H:%M:%S%z')] $*"
}

function slack {
  msg=$(echo "$*" | tr \" \')
  if [[ -n $SLACK_URL ]]; then
    log $(curl -s -X POST --data-urlencode "payload={\"channel\": \"#iphone-inventory\", \"username\": \"webhookbot\", \"text\": \"$msg\", \"icon_emoji\": \":ghost:\"}" "$SLACK_URL")
  fi
  log "Slacked: $msg"
}

function get_url {
  color=$1
  model="128GB"
  operator="att"
  phone_type="7Plus"

  echo "http://www.istocknow.com/live/live.php?type=$phone_type&operator=$operator&color=$color&model=$model&ajax=1&nocache=$(date -u '+%s%u')&nobb=false&notarget=false&noradioshack=false&nostock=true"
}

phone_base_description="ATT 7+ 128GB"


while true; do
  sleep=60

  #for color in Black Rose Gold; do
  for color in Black; do
    url=$(get_url $color)
    phone_description="$phone_base_description $color"

    dlog "requesting $phone_description: $url"
    response=$(curl -s "$url")

    json=$(echo "$response" | jq -e '.' 2>/dev/null)
    if [[ $? -ne 0 ]]; then
      sleep=300
      dlog "Not a valid JSON"
    else
      dlog "$json"
    fi

    stores=( 21 22 23 24 25 27 28 29 30 33 )
    for store in ${stores[@]}; do
      #store_name=$(echo "$response" | jq -M -e ".[\"dataz\"][\"$store\"][\"title\"]")
      #contains_store=$(echo "$response" | jq -M -e '[.dataz[].store] | map(. == "'$store'") | any')
      store_name=$(echo "$response" | jq -M -e '[.dataz[]? | {store, title}] | .[] | select(.store == "'$store'") | .title')
      if [[ -n $store_name ]]; then
         slack "Found $phone_description in store $store_name at $(date)"
         sleep=900
      fi

      # way to do it without jq
      # match=$(echo $json | grep -o "\"store\":\"$store\"")
      # if [[ -n $match ]]; then
      #   payload=$(echo $json | python -mjson.tool | grep -A3 -B5 "\"store\": \"$store\"")
      #   store_name=$(echo "$payload" | sed -n 's/.*title": "\(.*\)",/\1/p')
      #   msg="Found $phone_description in store $store_name at $(date)"
      #   echo "$msg"
      #   slack "$msg"
      # fi
    done
  done

  log "sleeping for $sleep seconds"
  sleep $sleep
done

