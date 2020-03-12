#!/usr/bin/env python3

from base import run, write_html, post_to_slack, strip_non_ascii
from lxml import html
import requests
import json
import logging
import sys
import time
import socket

CRAWLER = 'patagonia'
CHECK_INTERVAL_SECS = 1200


def scrape_patagonia(cfg):
    data = []
    for base_url in cfg.urls:
        for i in range(0, cfg.params.total_limit, cfg.params.window_size):
            url = base_url.format(window_size=cfg.params.window_size, start_pos=i)
            page = requests.get(url)
            tree = html.fromstring(page.content)
            product_elements = tree.xpath('//*/div[@class="product"]')
            try:
                for product in product_elements:
                    title = strip_non_ascii(product.xpath('.//*/h4/text()')[0])
                    price = product.xpath('.//*/span[@class="value"]/@content')
                    price = price[-1] if price else "N/A"
                    opt_text = product.xpath('.//div[@data-color]/@data-color')
                    opt_links = product.xpath('.//div[@data-color]/a/@href')
                    href_prefix = 'https://www.patagonia.com'
                    links = [{'href': href_prefix + href, 'text': text} for href, text in zip(opt_links, opt_text)]
                    data.append({"title": title, "links": links, "price": price})
                logging.debug("fetched {} for {}".format(len(title), url))
            except IndexError as e:
                logging.error(e)
                write_html('patagonia-error.html', page)
                post_to_slack('error encountered for patagonia', cfg.slack)
                sys.exit(1)
            if not product_elements:
                break
    return data


if __name__ == "__main__":
    while True:
        run(CRAWLER, scrape_patagonia)
        time.sleep(CHECK_INTERVAL_SECS)

