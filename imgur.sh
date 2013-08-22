#!/bin/bash

url=$1
folder=$2
[[ ! $url =~ '/all' ]] && url=$url/all
echo "url is $url"
content=`curl -s $url`
title=`echo $content | grep -Eo -A2 "<title>.*</title>" | sed -E "s/.*> *(.*) *<.*/\1/g" | sed -e "s/ - Imgur//" -e 's/^ *//g' -e 's/ *$//g'`

if [[ ! $folder ]]; then
  folder="/Users/wchen/Downloads/$title"
  echo "folder is $folder"
  mkdir "$folder"
fi
cd "$folder"
#[[ ! $? ]] && exit

links=`echo $content | grep -o "http://i\.imgur\.com/[A-Za-z0-9]*\.\(jpg\|png\|gif\)" | grep -v "albumview\.gif" | sed -E 's/s\.(jpg|png|gif)/.\1/g' | sort | uniq`
count=`echo -e "$links" | wc -l`
echo "Total of $count"

echo -e "$links" | xargs wget --quiet
open "$folder"
