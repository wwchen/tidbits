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

format_urls = [
    "https://www.patagonia.com/shop/web-specials-mens?prefn1=size&sz={window_size}&start={start_pos}&format=page-element&prefv1=XS",
    "https://www.patagonia.com/shop/web-specials-kids-boys?prefn1=size&sz={window_size}&start={start_pos}&format=page-element&prefv1=XXL",
    "https://www.patagonia.com/shop/web-specials-womens?prefn1=size&sz={window_size}&start={start_pos}&format=page-element&prefv1=S%7CXS"
]
blacklist = [
    'Responsibili-Tee',
    'T-Shirt',
    'Boxers',
    'Pants',
    'Waders'
]
cache_file = ".patagonia_cache.json"
slack_webhook_url = "https://hooks.slack.com/services/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"

window_size = 36
total_limit = 200
check_interval_secs = 1200

results = []


def strip_non_ascii(string):
    ''' Returns the string without non ASCII characters'''
    stripped = (c for c in string.strip() if 0 < ord(c) < 127)
    return ''.join(stripped)


def scrape_patagonia(base_url):
    data = []
    for i in range(0, total_limit, window_size):
        url = base_url.format(window_size=window_size, start_pos=i)
        page = requests.get(url)
        tree = html.fromstring(page.content)
        product_elements = tree.xpath('//*/div[@class="product-tile__meta-primary"]')
        try:
            for product in product_elements:
                title = strip_non_ascii(product.xpath('.//*/h4/text()')[0])
                link = 'https://www.patagonia.com' + product.xpath('.//*/a/@href')[0]
                price = product.xpath('.//*/span[@class="value"]/@content')
                price = price[-1] if price else "N/A"
                data.append({"title": title, "link": link, "price": price})
            logging.debug("fetched {} for {}".format(len(title), url))
        except IndexError as e:
            logging.error(e)
            with open('patagonia-error.html', 'w') as f:
                f.write(page.content)
            logging.info("saved page as patagonia-error.html")
            post_to_slack('error encountered for patagonia')
            sys.exit(1)
        if not product_elements:
            break
    return data


def find_new_additions(curr_results, prev_results):
    prev_titles = map(lambda r: r["title"], prev_results)
    additions = []
    for curr_row in curr_results:
        curr_title = curr_row["title"]
        if curr_title not in prev_titles and all([b not in curr_title for b in blacklist]):
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
    username = "patagonia-" + hostname
    return requests.post(url=slack_webhook_url, json={"text": message, "username": username, "icon_emoji": ":shirt:"})


def result_to_json_str(result):
    return "<{}|{}> - {}".format(result["link"], result["title"], result["price"])

def run():
    prev_results = read_cache_file()
    curr_results = []
    for format_url in format_urls:
        curr_results += scrape_patagonia(format_url)
    additions = find_new_additions(curr_results, prev_results)
    overwrite_to_cache_file(curr_results)
    if prev_results and additions:
        message = '\n'.join(map(result_to_json_str, additions))
        logging.info("additions compared to last run:\n" + message)
        post_to_slack(message)
    else:
        logging.info("no new additions")


if __name__ == "__main__":
    while True:
        run()
        time.sleep(check_interval_secs)

