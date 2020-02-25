#!/usr/bin/env python

from base import *
import logging
import requests
from lxml import html


CRAWLER = 'icebreaker-mens'

base_url = 'https://www.icebreaker.com/en-us/web-specials?prefn1=gender&prefn2=phClass&prefv3=S&prefv1=Mens&prefv2=Short%20Sleeve%20Tops&prefn3=size&format=ajax'

total_limit = 10
window_size = 10

site = 'icebreaker'


def scrape_icebreaker():
    data = []
    for i in range(0, total_limit, window_size):
        url = base_url.format(window_size=window_size, start_pos=i)
        page = requests.get(url)
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
            html_fname = '{}-error.html'.format(site)
            with open(html_fname, 'w') as f:
                f.write(page.content)
            logging.info("saved page as {}".format(html_fname))
        html_fname = '{}-error.html'.format(site)
        with open(html_fname, 'w') as f:
            f.write(page.content)
        if not product_elements:
            break
    return data


if __name__ == "__main__":
    run(CRAWLER, scrape_icebreaker)
