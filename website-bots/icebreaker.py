#!/usr/bin/env python3

from base import run, write_html, post_to_slack, strip_non_ascii
import logging
import requests
from lxml import html
import time


CRAWLER = 'icebreaker-mens'

check_interval_secs = 1200

site = 'icebreaker'


def scrape_icebreaker(cfg):
    data = []
    page = requests.get(cfg.url)
    tree = html.fromstring(page.content)
    product_elements = tree.xpath('//*/div[contains(@class, "product-tile")]')
    try:
        for product in product_elements:
            title = strip_non_ascii(product.xpath('.//div[@class="name"]/a/text()')[0])
            link = product.xpath('.//div[@class="name"]/a/@href')[0]
            price = product.xpath('.//div[@class="product-price"]//span/text()')
            price = price[-1].strip() if price else "N/A"
            data.append({"title": title, "link": link, "price": price})
    except IndexError as e:
        logging.error(e)
        write_html('icebreaker-error.html', page)
    return data


if __name__ == "__main__":
    while True:
        run(CRAWLER, scrape_icebreaker)
        time.sleep(check_interval_secs)
