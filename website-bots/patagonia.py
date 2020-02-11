#!/usr/bin/env python

from lxml import html
import requests
import json
import logging
import sys
import time

LOGGING_FORMAT = '[%(asctime)-15s] %(message)s'
logging.basicConfig(format=LOGGING_FORMAT, stream=sys.stdout, level=logging.INFO)

mens_format_url = "https://www.patagonia.com/shop/web-specials-mens?prefn1=size&sz={window_size}&start={start_pos}&format=page-element&prefv1=XS"
boys_format_url = "https://www.patagonia.com/shop/web-specials-kids-boys?prefn1=size&sz={window_size}&start={start_pos}&format=page-element&prefv1=XXL"
cache_file = "/Users/wc/Downloads/patagonia_cache.txt"

window_size = 36
total_limit = 200
check_interval_secs = 600

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
        title = map(strip_non_ascii, tree.xpath('//*/div[3]/div[1]/a/text()'))
        link = tree.xpath('//*/div[3]/div[1]/a/@href')
        price = map(lambda x: x.strip(), tree.xpath('//*/div[3]/div[2]/div/span[2]/text()'))
        assert len(title) == len(price) == len(link)
        logging.debug("fetched {} for {}".format(len(title), url))
        if not len(title):
            break
        data += map(lambda z: {"title": z[0], "link": z[1], "price": z[2]}, zip(title, link, price))
    return data


def find_new_additions(curr_results, prev_results):
    prev_titles = map(lambda r: r["title"], prev_results)
    additions = []
    for curr_row in curr_results:
        curr_title = curr_row["title"]
        if curr_title not in prev_titles:
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


def run():
    prev_results = read_cache_file()
    curr_results = []
    for format_url in [mens_format_url, boys_format_url]:
        curr_results += scrape_patagonia(format_url)
    additions = find_new_additions(curr_results, prev_results)
    if additions:
        logging.info("additions compared to last run:")
        for row in additions:
            logging.info("{} - {} - {}".format(row["title"], row["price"], row["link"]))
    else:
        logging.info("no new additions")
    overwrite_to_cache_file(curr_results)


if __name__ == "__main__":
    while True:
        run()
        time.sleep(check_interval_secs)

