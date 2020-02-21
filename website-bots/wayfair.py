#!/usr/bin/env python

from lxml import html
import requests
import json
import logging
import sys
import time
import socket

LOGGING_FORMAT = '[%(asctime)-15s] %(message)s'
logging.basicConfig(format=LOGGING_FORMAT, stream=sys.stdout, level=logging.INFO)

cache_file = ".wayfair_cache.txt"
slack_webhook_url = "https://hooks.slack.com/XXXXX"

product_urls = [
    'https://www.wayfair.com/furniture/pdp/hashtag-home-brody-tv-stand-for-tvs-up-to-65-inches-w002590707.html',
]
http_headers = {
    'authority': 'www.wayfair.com',
    'cache-control': 'max-age=0',
    'upgrade-insecure-requests': '1',
    'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36',
    'sec-fetch-user': '?1',
    'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
    'sec-fetch-site': 'same-origin',
    'sec-fetch-mode': 'navigate',
    'accept-language': 'en-US,en;q=0.9,zh-TW;q=0.8,zh;q=0.7',
}

check_interval_secs = 600


def strip_non_ascii(string):
    ''' Returns the string without non ASCII characters'''
    stripped = (c for c in string.strip() if 0 < ord(c) < 127)
    return ''.join(stripped)


def scrape_wayfair(product_url):
    page = requests.get(product_url, headers=http_headers)
    tree = html.fromstring(page.content)
    product_title = tree.xpath('//*/header[@class="ProductDetailInfoBlock-header"]/h1/text()')[0]
    price = tree.xpath('//*/div[@class="BasePriceBlock"]//text()')[0]
    return {"title": product_title, "price": price, "link": product_url}


def find_lower_price(curr_results, prev_results):
    db = dict(map(lambda r: (r["title"], r["price"]), prev_results))
    additions = []
    for curr_row in curr_results:
        title, price = curr_row["title"], curr_row["price"]
        print db
        print price
        if title in db and price < db[title]:
            additions.append(curr_row)
    return additions


def read_cache_file():
    try:
        return json.loads(open(cache_file).read())
    except ValueError as e:
        # json parsing error
        logging.error(e)
    except IOError as e:
        # file IO error
        logging.error(e)
    return {}


def overwrite_to_cache_file(results):
    with(open(cache_file, 'w')) as f:
        f.write(json.dumps(results))


def post_to_slack(message):
    hostname = socket.gethostname()
    username = "wayfair-" + hostname
    return requests.post(url=slack_webhook_url, json={"text": message, "username": username, "icon_emoji": ":mega:"})


def result_to_json_str(result):
    return "<{}|{}> - {}".format(result["link"], result["title"], result["price"])

def run():
    prev_results = read_cache_file()
    curr_results = []
    for product_url in product_urls:
        curr_results.append(scrape_wayfair(product_url))
    additions = find_lower_price(curr_results, prev_results)
    overwrite_to_cache_file(curr_results)
    if prev_results and additions:
        message = '\n'.join(map(result_to_json_str, additions))
        logging.info("additions compared to last run:\n" + message)
        post_to_slack(message)
    else:
        logging.info("no new additions")


if __name__ == "__main__":
    while True:
        try:
            run()
        except Exception:
            continue
        time.sleep(check_interval_secs)

