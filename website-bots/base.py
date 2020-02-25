from box import Box
import logging
import sys
import requests
import json


CONFIG = Box.from_yaml(filename='config.yaml')

CRAWLER = 'base'

logging.basicConfig(format=CONFIG.logging.format, stream=sys.stdout, level=CONFIG.logging.level)


def strip_non_ascii(string):
    ''' Returns the string without non ASCII characters'''
    stripped = (c for c in string.strip() if 0 < ord(c) < 127)
    return ''.join(stripped)


def post_to_slack(message):
    slack_webhook_url = CONFIG.slack.webhook_url
    payload = {
        'text': message,
        'username': 'crawler',
        'icon_emoji': ':shirt:',
    }
    if CRAWLER in CONFIG:
        payload.update(CONFIG[CRAWLER])
    if CONFIG.slack.enabled:
        return requests.post(url=slack_webhook_url, json=payload)
    else:
        logging.info('[DRYRUN] Slack post: {}'.format(json.dumps(payload)))


def find_new_additions(curr_results, prev_results):
    prev_titles = map(lambda r: r["title"], prev_results)
    additions = []
    for curr_row in curr_results:
        curr_title = curr_row["title"]
        if curr_title not in prev_titles:
            additions.append(curr_row)
    return additions


def read_cache_file(cache_filename):
    try:
        return json.loads(open(cache_filename).read())
    except ValueError as e:
        # json parsing error
        logging.error(e)
    except IOError as e:
        # file IO error
        logging.error(e)
    return {}


def overwrite_to_cache_file(cache_filename, results):
    with(open(cache_filename, 'w')) as f:
        f.write(json.dumps(results))


def run(crawler_name, scraper_func):
    crawler_config = CONFIG.crawler[crawler_name]
    cache_filename = '.{}.json'.format(crawler_name)

    prev_results = read_cache_file(cache_filename)
    curr_results = scraper_func()
    additions = find_new_additions(curr_results, prev_results)
    overwrite_to_cache_file(cache_filename, curr_results)
    if additions:
        logging.info("additions compared to last run:")
        for row in additions:
            message = "{} - {} - {}".format(row["title"], row["price"], row["link"])
            post_to_slack(message)
    else:
        logging.info("no new additions")
